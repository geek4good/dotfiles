function zmx_select --description "project-aware zmx session picker"
    # ── project slug ──────────────────────────────────────────────────────────

    set -l root (git rev-parse --show-toplevel 2>/dev/null; or true)
    set -l name
    if test -n "$root"
        set name (basename "$root")
    else
        set name (basename "$PWD")
    end
    set -l project (string lower "$name" | string replace -ra '[^a-z0-9]' '-' | string replace -ra '\-+' '-' | string trim -c '-')

    # ── sessions ──────────────────────────────────────────────────────────────

    set -l sessions (zmx list --short 2>/dev/null; or true)
    set -l default "$project-term"

    # ── args ──────────────────────────────────────────────────────────────────

    if contains -- --name $argv
        echo "$default"
        return
    end

    # ── build fzf input (current project first) ──────────────────────────────

    set -l list
    for s in $sessions
        if string match -q "$project-*" $s
            set -a list $s
        end
    end
    for s in $sessions
        if not string match -q "$project-*" $s
            set -a list $s
        end
    end
    if not contains "$default" $list
        set -l tmp "$default"
        set list $tmp $list
    end
    if test (count $list) -eq 0
        set list "$default"
    end

    # ── fzf picker ────────────────────────────────────────────────────────────

    set -l tmp (mktemp)
    printf '%s\n' $list | fzf \
        --print-query \
        --height=80% \
        --reverse \
        --prompt="zmx> " \
        --header="Enter: attach or create · <project>-<program> · term=shell · Esc: cancel" \
        --preview='zmx history {} | tail -50' \
        --preview-window=right:60%:follow \
    > $tmp
    set -l rc $status

    set -l query    (sed -n '1p' $tmp)
    set -l selected (sed -n '2p' $tmp)
    rm -f $tmp

    set -l session
    if test $rc -eq 0; and test -n "$selected"
        set session $selected
    else if test -n "$query"; and test $rc -ne 130
        set session $query
    else
        return 130
    end

    # ── remote session (server.session) ───────────────────────────────────────

    if string match -qr '^[a-zA-Z0-9][a-zA-Z0-9-]*\.[a-zA-Z0-9]' "$session"
        set -l server (string split -m1 '.' $session)[1]
        set -l ssh_hosts (grep "^Host " ~/.ssh/config | string replace -r '^Host ' '' | string trim | grep -v '\*')
        if contains "$server" $ssh_hosts
            printf '\033[2J\033[H'
            exec autossh -M 0 -q $session
        end
    end

    # ── existing session → attach directly ────────────────────────────────────

    if contains "$session" $sessions
        printf '\033[2J\033[H'
        exec zmx attach $session
    end

    # ── new session: resolve project directory and program ────────────────────

    set -l program "term"
    set -l project_dir ""
    set -l found false

    # Handle explicit path input (e.g. ~/Projects/www)
    if string match -qr '^[~/\.]' "$session"
        set -l explicit_path (eval echo "$session")
        set -l slug (basename "$explicit_path" | string lower | string replace -ra '[^a-z0-9]' '-' | string replace -ra '\-+' '-' | string trim -c '-')
        set session "$slug-term"
        set project_dir "$explicit_path"
        set found true
    end

    # ── 1. Match current project prefix (most common case) ───────────────────
    # We know $project from git root / PWD, so use it to extract the program.

    if not $found; and string match -q "$project-*" "$session"
        set program (string replace -- "$project-" "" "$session")
        if test -n "$root"
            set project_dir "$root"
        else
            set project_dir "$PWD"
        end
        set found true
    end

    # ── 2. Longest-prefix matching in ~/Projects (cross-project) ─────────────

    if not $found
        set -l dash_parts (string split '-' $session)
        set -l num_parts (count $dash_parts)

        # Try full name as project directory
        set -l dir (find ~/Projects -maxdepth 2 -name "$session" -type d 2>/dev/null | head -1; or true)
        if test -n "$dir"
            set project_dir "$dir"
            set found true
        end

        # Try progressively shorter prefixes
        if not $found; and test $num_parts -ge 2
            for i in (seq $num_parts -1 2)
                set -l proj_parts
                set -l prog_parts
                for j in (seq 1 (math $i - 1))
                    set -a proj_parts $dash_parts[$j]
                end
                for j in (seq $i $num_parts)
                    set -a prog_parts $dash_parts[$j]
                end
                set -l proj_candidate (string join '-' $proj_parts)
                set -l prog_candidate (string join '-' $prog_parts)

                set dir (find ~/Projects -maxdepth 2 -name "$proj_candidate" -type d 2>/dev/null | head -1; or true)
                if test -n "$dir"
                    set project_dir "$dir"
                    set program "$prog_candidate"
                    set found true
                    break
                end
            end
        end
    end

    # ── fallback directory picker ─────────────────────────────────────────────

    if test -z "$project_dir"
        set -l dir_tmp (mktemp)
        find ~/Projects -maxdepth 2 -type d -name '.git' -exec dirname {} \; 2>/dev/null | sort | fzf \
            --print-query \
            --height=80% \
            --reverse \
            --prompt="dir> " \
            --header="Pick or type path for '$session' · e.g. myapp or org/repo · Esc: use \$PWD" \
        > $dir_tmp
        set -l dir_rc $status
        set -l dir_query (sed -n '1p' $dir_tmp)
        set -l dir_selected (sed -n '2p' $dir_tmp)
        rm -f $dir_tmp

        if test $dir_rc -ne 130; and test -n "$dir_query"
            if string match -qr '^[~/\.]' "$dir_query"
                set project_dir (eval echo "$dir_query")
            else if test -n "$dir_selected"
                set project_dir $dir_selected
            else
                set project_dir "$HOME/Projects/$dir_query"
            end
            mkdir -p "$project_dir"
        end
    end

    if test -n "$project_dir"
        cd "$project_dir"
    end

    # ── create and attach ─────────────────────────────────────────────────────

    printf '\033[2J\033[H'
    if test "$program" != "term"
        exec zmx attach $session $program
    else
        exec zmx attach $session
    end
end
