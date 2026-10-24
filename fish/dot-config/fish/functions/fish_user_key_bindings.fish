function fish_user_key_bindings
    # right option = alt (ghostty macos-option-as-alt=right); left option
    # is reserved for macOS text input (umlauts, ß)
    bind alt-D kill-bigword
    bind \e\[127\;4u backward-kill-bigword
    bind \e\[107\;9u zmx_select
    # ctrl+shift+l (kitty CSI-u: 'l'=108, mods 1+shift+ctrl=6) clears the screen.
    # Used in plain-Ghostty tabs; inside Herdr a Herdr-side binding consumes it.
    bind \e\[108\;6u clear-screen
    # home-row-mods: option+u (dead key ¨) then s emits "¨s" → ß.
    # macOS can't compose ¨+s; native option+s → ß still works on the laptop.
    bind '¨s' 'commandline -i ß'
end
