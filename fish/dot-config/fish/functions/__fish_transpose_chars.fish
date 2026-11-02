function __fish_transpose_chars --description "Swap the characters around the cursor (zsh parity)"
    set -l buf (commandline -b)
    set -l C (commandline -C)
    set -l len (string length -- $buf)
    test $len -ge 2; or return
    # At end of line: swap the last two characters
    if test $C -eq $len
        set C (math $len - 1)
    end
    test $C -ge 1; or return
    set -l before (string sub --length (math $C - 1) -- $buf)
    set -l c1 (string sub --start $C --length 1 -- $buf)
    set -l c2 (string sub --start (math $C + 1) --length 1 -- $buf)
    set -l after (string sub --start (math $C + 2) -- $buf)
    commandline --replace (string join '' -- $before $c2 $c1 $after)
    commandline --cursor (math $C + 1)
end
