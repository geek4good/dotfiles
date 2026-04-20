# Environment
set -gx LC_ALL "en_GB.UTF-8"
set -gx EDITOR nvim
set -gx LESS -R
set -gx HOMEBREW_NO_ENV_HINTS 1
umask 022

# PATH
fish_add_path $HOME/.local/share/mise/shims
fish_add_path $HOME/Applications
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/.local/bin
fish_add_path /Users/geek4good/Library/pnpm

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# fnox
if command -q fnox
    fnox activate fish | source
end

# mise
mise activate fish | source

# fzf
fzf --fish | source

# Worktrunk
if command -q wt
    wt config shell init fish | source
end

# starship
if command -q starship
    starship init fish | source
end

# Abbreviations — editor
abbr -a vi nvim
abbr -a vim nvim
abbr -a view 'nvim -R'
abbr -a vimdiff 'nvim -d'

# Abbreviations — listing
abbr -a ll 'ls -lh'
abbr -a la 'ls -lhA'

# Abbreviations — brew
abbr -a bubo 'brew update && brew outdated'
abbr -a bubc 'brew upgrade && brew cleanup'
abbr -a bcubo 'brew update && brew outdated --cask'
abbr -a bcubc 'brew upgrade --cask && brew cleanup'
abbr -a bubu 'brew update && brew outdated && brew update && brew outdated --cask && brew upgrade && brew cleanup && brew upgrade --cask && brew cleanup'

# Abbreviations — mise
abbr -a ml 'mise latest'

# Abbreviations — docker (via Lima)
abbr -a d docker.lima
abbr -a dc 'docker.lima compose'
abbr -a dps 'docker.lima ps'
abbr -a dpsa 'docker.lima ps -a'
abbr -a di 'docker.lima images'
abbr -a drm 'docker.lima rm'
abbr -a drmi 'docker.lima rmi'
abbr -a dl 'docker.lima logs'
abbr -a dsh 'docker.lima exec -it'

# Abbreviations — git
abbr -a g git
abbr -a gs 'git status'
abbr -a gl 'git log --oneline -20'
abbr -a gla 'git log --oneline --all -20'
abbr -a gd 'git diff'
abbr -a gds 'git diff --staged'
abbr -a ga 'git add'
abbr -a gap 'git add -p'
abbr -a gc 'git commit'
abbr -a gca 'git commit -a'
abbr -a gcam 'git commit -am'
abbr -a gp 'git push'
abbr -a gpf 'git push --force-with-lease'
abbr -a gu 'git pull'
abbr -a gr 'git rebase'
abbr -a gri 'git rebase -i'
abbr -a gb 'git branch'
abbr -a gco 'git checkout'
abbr -a gsw 'git switch'
abbr -a gt 'git tag'
abbr -a gf 'git fetch'
abbr -a gclean 'git clean -fd'

# Abbreviations — work
abbr -a oc 'ocx oc -p ws'
