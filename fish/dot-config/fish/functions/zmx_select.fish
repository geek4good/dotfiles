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

    # ── next session number ───────────────────────────────────────────────────

    set -l sessions (zmx list --short 2>/dev/null; or true)
    set -l n 1
    while contains "$project-$n" $sessions
        set n (math $n + 1)
    end
    set -l default "$project-$n"

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
        --header="Enter: attach or create · type a path to set dir · Esc: cancel" \
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

    # ── resolve project directory ─────────────────────────────────────────────

    set -l explicit_path

    # Check if the session name itself is a path (typed in the picker)
    if string match -qr '^[~/\.]' "$session"
        set explicit_path (eval echo "$session")
        # Derive session name from the last path component
        set -l slug (basename "$explicit_path" | string lower | string replace -ra '[^a-z0-9]' '-' | string replace -ra '\-+' '-' | string trim -c '-')
        set -l sn 1
        while contains "$slug-$sn" $sessions
            set sn (math $sn + 1)
        end
        set session "$slug-$sn"
    end

    # Try to match slug against ~/Projects
    set -l project_slug (string replace -r '\-\d+$' '' $session)
    set -l project_dir

    if test -n "$explicit_path"
        set project_dir "$explicit_path"
    else
        set project_dir (find ~/Projects -maxdepth 2 -name "$project_slug" -type d 2>/dev/null | head -1; or true)
    end

    if test -z "$project_dir"
        # No match — pick or type a path
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

    printf '\033[2J\033[H'
    exec zmx attach $session
end
