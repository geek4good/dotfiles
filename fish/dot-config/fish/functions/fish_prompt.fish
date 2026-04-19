function fish_prompt
    set -l color (test $status -eq 0; and echo 14; or echo 13)
    set_color $color
    echo -n '❯ '
    set_color normal
end
