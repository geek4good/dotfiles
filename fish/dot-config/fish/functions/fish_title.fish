function fish_title
    if set -q ZMX_SESSION
        echo $ZMX_SESSION
    else
        # Default: show command if running, otherwise pwd
        echo (prompt_pwd)
    end
end
