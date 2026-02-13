# -- Environment --
export DOTFILES="$HOME/.dotfiles"
export EDITOR="nvim"

# -- Toolchain Lazy-Loading --
# OCaml
[[ ! -r $HOME/.opam/opam-init/init.zsh ]] || source $HOME/.opam/opam-init/init.zsh > /dev/null 2>&1

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# -- Aliases --
alias ls="eza --icons --group-directories-first"
alias cat="bat"
alias grep="rg"
alias v="nvim"
alias g="git"

# -- FZF (Fuzzy Finder) Integration --
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
