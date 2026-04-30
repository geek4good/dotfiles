function zmx_select --description "zmx session picker with fzf"
    set -l tmp (mktemp)

    begin
        zmx list 2>/dev/null | while read -l line
            set -l f (string split \t $line)
            set -l name    (string replace 'session_name=' '' $f[1])
            set -l pid     (string replace 'pid=' ''         $f[2])
            set -l clients (string replace 'clients=' ''     $f[3])
            set -l dir     (string replace 'started_in=' ''  $f[5])
            printf "%-20s  pid:%-8s  clients:%-2s  %s\n" $name $pid $clients $dir
        end
    end | fzf \
        --print-query \
        --expect=ctrl-n \
        --height=80% \
        --reverse \
        --prompt="zmx> " \
        --header="Enter: select | Ctrl-N: create new" \
        --preview='zmx history {1}' \
        --preview-window=right:60%:follow \
    > $tmp
    set -l rc $status

    set -l query    (sed -n '1p' $tmp)
    set -l key      (sed -n '2p' $tmp)
    set -l selected (sed -n '3p' $tmp)
    rm -f $tmp

    set -l session_name
    if test "$key" = ctrl-n -a -n "$query"
        set session_name $query
    else if test $rc -eq 0 -a -n "$selected"
        set session_name (string match -r '^\S+' $selected)
    else if test -n "$query"
        set session_name $query
    else
        return 130
    end

    zmx attach $session_name
end
