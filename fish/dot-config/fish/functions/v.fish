function v
    if test (count $argv) -eq 0
        neovide .
    else
        neovide $argv
    end
end
