function fish_user_key_bindings
    bind alt-D kill-bigword
    bind \e\[127\;4u backward-kill-bigword
    bind \e\[107\;9u zmx_select
    # ctrl+shift+l (kitty CSI-u: 'l'=108, mods 1+shift+ctrl=6) clears the screen.
    # Used in plain-Ghostty tabs; inside Herdr a Herdr-side binding consumes it.
    bind \e\[108\;6u clear-screen
end
