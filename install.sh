#!/bin/bash

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Sync Brewfile
echo "📦 Installing packages..."
brew bundle --file=./brew/Brewfile

# Create Symlinks
echo "🔗 Linking configurations..."
ln -sf "$HOME/.dotfiles/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/.dotfiles/git/.gitconfig" "$HOME/.gitconfig"
ln -sf "$HOME/.dotfiles/git/.gitignore_global" "$HOME/.gitignore_global"

# Setup Neovim config path
mkdir -p "$HOME/.config/nvim"
ln -sf "$HOME/.dotfiles/nvim/init.lua" "$HOME/.config/nvim/init.lua"

echo "✅ System Ready. Please restart your terminal."
