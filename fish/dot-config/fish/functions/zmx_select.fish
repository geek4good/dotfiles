function zmx_select --description "zmx session picker with fzf"
    set -l tmp (mktemp)

    zmx list --short 2>/dev/null | fzf \
        --print-query \
        --height=80% \
        --reverse \
        --prompt="zmx> " \
        --header="Enter: attach or create" \
        --preview='zmx history {} | tail -50' \
        --preview-window=right:60%:follow \
    > $tmp
    set -l rc $status

    set -l query    (sed -n '1p' $tmp)
    set -l selected (sed -n '2p' $tmp)
    rm -f $tmp

    set -l session_name
    if test $rc -eq 0; and test -n "$selected"
        set session_name $selected
    else if test -n "$query"; and test $rc -ne 130
        set session_name $query
    else
        return 130
    end

    zmx attach $session_name
end
