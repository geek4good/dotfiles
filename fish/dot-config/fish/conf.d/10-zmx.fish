# Start zmx if not already inside a session (skip inside Herdr)
# zmx is still available for nvim/editor sessions via `za` or cmd+k.
if status is-interactive; and test -z "$ZMX_SESSION"; and test -z "$HERDR_ENV"
    function __zmx_autostart --on-event fish_prompt
        functions --erase __zmx_autostart
        zmx_select
    end
end
