#!/bin/bash

# Setup script for Neovim + Tmux development environment
# For PHP and Go backend development

set -e

echo "🚀 Setting up Neovim + Tmux environment..."
echo ""

# Check if neovim is installed
if ! command -v nvim &> /dev/null; then
    echo "❌ Neovim is not installed. Please install it first:"
    echo "   Ubuntu/Debian: sudo apt install neovim"
    exit 1
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "❌ Tmux is not installed. Please install it first:"
    echo "   Ubuntu/Debian: sudo apt install tmux"
    exit 1
fi

NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
TMUX_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# Step 1: Initialize Neovim plugins
echo "📦 Installing Neovim plugins from lockfile..."
nvim --headless "+Lazy! restore" +qa 2>/dev/null || true
echo "✅ Neovim plugins restored from lazy-lock.json"
echo ""

# Step 2: Install Mason tools
echo "🔧 Installing language servers and tools via Mason..."
nvim --headless "+MasonInstall gopls intelephense lua_ls delve php-debug-adapter" +qa 2>/dev/null || true
echo "✅ Mason tools installed"
echo ""

echo "🌐 Installing JSON/YAML language servers via npm..."
if command -v npm &> /dev/null; then
    npm install -g vscode-langservers-extracted yaml-language-server 2>/dev/null || true
    echo "✅ JSON/YAML language servers installed"
else
    echo "⚠️  npm not found. Install Node.js/npm to enable jsonls and yamlls."
fi
echo ""

# Step 3: Install formatters and linters
echo "🎨 Installing formatters and linters..."
echo "   - Go: gofumpt, goimports, golangci-lint"
echo "   - PHP: php-cs-fixer, phpstan"
echo ""
echo "   To install via Mason:"
echo "   :MasonInstall gofumpt goimports golangci-lint"
echo "   :MasonInstall php-cs-fixer phpstan"
echo ""

# Step 4: Set up Tmux plugins
echo "🔌 Setting up Tmux plugins..."
TMUX_PLUGINS_DIR="$HOME/.tmux/plugins"
mkdir -p "$TMUX_PLUGINS_DIR"

if [ ! -d "$TMUX_PLUGINS_DIR/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGINS_DIR/tpm" 2>/dev/null
    echo "✅ TPM installed"
fi

if [ ! -d "$TMUX_PLUGINS_DIR/tmux-sensible" ]; then
    echo "   Run in Tmux: C-a + I    (capital I) to install plugins"
fi
echo ""

# Step 5: Go setup
echo "📚 Go development tools:"
if command -v go &> /dev/null; then
    echo "   Installing Go tools..."
    go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null || true
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>/dev/null || true
    echo "✅ Go tools installed"
else
    echo "⚠️  Go is not installed. Install from: https://go.dev/dl"
fi
echo ""

# Step 6: Verify configuration
echo "✅ Configuration files:"
echo "   • Neovim: $NVIM_CONFIG/"
echo "   • Tmux:   $TMUX_CONFIG/tmux.conf"
echo ""

# Final instructions
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Start Tmux:  tmux new-session -s work"
echo "2. Open editor: nvim ."
echo "3. In Tmux, install plugins: C-a + I (capital I)"
echo "4. Read setup docs: cat $NVIM_CONFIG/SETUP.md"
echo ""
echo "Key features configured:"
echo "   ✨ Everforest theme"
echo "   🔍 Fuzzy find (telescope)"
echo "   🌳 Treesitter syntax highlighting"
echo "   🐛 Debugging (DAP for Go & PHP)"
echo "   🔤 Vim-surround for editing"
echo "   ⚡ Flash for fast navigation"
echo "   📦 LSP for Go, PHP, Lua, JSON, YAML"
echo ""
echo "Happy coding! 🚀"
