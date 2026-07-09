# Color-theme switcher CLI — recolors starship + tmux status bar + pane sidebar
# + pane menu together. Deployed to ~/.oh-my-zsh/custom/ (auto-sourced by
# oh-my-zsh) by bin/sync-tmux-from-work.sh, so it needs no edit to zshrc.
#
#   theme            print the active theme
#   theme gruvbox    switch to gruvbox
#   theme badwolf    switch to the original "Bad Wolf" colors
#   theme toggle     flip to the other theme
#   theme list       list available themes
#
# On the fly inside tmux you can also press prefix+T for a picker.
theme() { "$HOME/.config/tmux/theme-switch.sh" "${@:-current}"; }

# Tab-completion for the subcommands (themes + verbs).
_theme() { compadd $("$HOME/.config/tmux/theme-switch.sh" list 2>/dev/null) toggle current list menu; }
compdef _theme theme 2>/dev/null || true
