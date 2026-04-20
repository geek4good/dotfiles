function fish_prompt
    set -l color (test $status -eq 0; and echo brcyan; or echo brmagenta)
    set_color $color
    echo -n '❯ '
    set_color normal
end
