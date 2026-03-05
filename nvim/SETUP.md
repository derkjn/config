# Neovim & Tmux Setup for PHP & Go Development

This document outlines the complete setup for a professional PHP and Go development environment using Neovim and Tmux.

## ✅ What's Installed

### Neovim Plugins
- **everforest** - Beautiful theme with excellent contrast
- **telescope.nvim** - Fuzzy finder for files, text, and symbols
- **nvim-treesitter** - Syntax highlighting and code structure
- **flash.nvim** - Lightning-fast cursor movements (`s`, `S`, `r`, `R`)
- **nvim-surround** - Change/delete/add surroundings (quotes, brackets, etc.)
- **nvim-dap** - Debugging support for Go and PHP (Xdebug)
- **nvim-lspconfig** - Language server configuration for Go, PHP, Lua, JSON, YAML
- **nvim-cmp** - Smart autocompletion
- **Comment.nvim** - Toggle comments easily
- **nvim-autopairs** - Auto-complete brackets/quotes
- **gitsigns.nvim** - Git integration with line signs
- **nvim-tree.lua** - File explorer
- **lualine.nvim** - Beautiful statusline
- **bufferline.nvim** - Buffer tabs
- **conform.nvim** - Code formatting
- **nvim-lint** - Linting
- **trouble.nvim** - Diagnostics list
- **which-key.nvim** - Command palette helper

### Tmux Plugins
- **tpm** - Plugin manager
- **tmux-sensible** - Reasonable defaults
- **tmux-resurrect** - Save and restore sessions
- **tmux-continuum** - Auto-save sessions
- **vim-tmux-navigator** - Seamless Vim/Tmux navigation
- **tmux-open** - Open URLs, files from tmux
- **tmux-copycat** - Enhanced search in copy-mode

## 🚀 Quick Start

### 1. Install Required Tools

```bash
# Go language server and tools
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# PHP language server and tools
# Install via Mason in Neovim: :MasonInstall intelephense php-cs-fixer phpstan

# Neovim tools (via Mason)
# :MasonInstall delve (Go debugger)
# :MasonInstall php-debug-adapter (PHP debugger)
```

### 2. Start Tmux Session

```bash
tmux new-session -s work -c ~/projects
# Then in tmux:
# C-a c     - Create new window
# C-a n/p   - Next/previous window
# C-a h/j/k/l - Navigate panes (vim-style)
# C-a |     - Split horizontally
# C-a -     - Split vertically
```

### 3. Open Neovim

```bash
nvim .
```

## 📋 Keybindings

### Navigation
| Key | Action |
|-----|--------|
| `s` | Flash jump (any char) |
| `S` | Flash jump (treesitter nodes) |
| `r` | Remote flash (operations) |
| `R` | Treesitter search |
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Hover documentation |

### Editing
| Key | Action |
|-----|--------|
| `cs"'` | Change quotes from " to ' |
| `ds"` | Delete quotes |
| `ys$"` | Add quotes to end of line |
| `gcc` | Toggle line comment |
| `gc` | Toggle block comment (visual) |

### Searching
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>fs` | LSP symbols in document |
| `<leader>fw` | LSP symbols in workspace |

### Debugging (Go & PHP)
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue execution |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>du` | Toggle DAP UI |
| `<leader>dt` | Terminate |

### Formatting & Linting
| Key | Action |
|-----|--------|
| `<leader>cf` | Format current buffer |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |

### Tmux Shortcuts (prefix = C-a)
| Key | Action |
|-----|--------|
| `C-a \|` | Split pane horizontally |
| `C-a -` | Split pane vertically |
| `C-a h/j/k/l` | Navigate panes |
| `C-a H/J/K/L` | Resize pane |
| `C-a c` | Create window |
| `C-a n/p` | Next/Previous window |
| `C-a s` | Select session |
| `C-a r` | Reload config |

## 🐛 Debugging Setup

### Go Debugging
1. Install Delve (auto with `:MasonInstall delve`)
2. Set breakpoints with `<leader>db`
3. Run with `<leader>dc`
4. Step with `<leader>di/do/dO`

### PHP Debugging (Xdebug)
1. Configure Xdebug in php.ini:
   ```ini
   xdebug.mode=debug
   xdebug.start_with_request=trigger
   xdebug.client_port=9003
   ```
2. Install PHP Debug Adapter: `:MasonInstall php-debug-adapter`
3. Set breakpoints and trigger requests with `XDEBUG_SESSION=1`

## 🔧 File Organization in Tmux

Create a development layout:
```bash
tmux new-session -s work
# C-a c          - Create editor window  
# C-a |          - Split for terminal
# C-a c          - Create test runner window
# C-a |          - Split for test output
# C-a c          - Create build/debug window
```

## 📝 Configuration Files

- **Neovim**: `~/.config/nvim/`
  - `init.lua` - Main entry point
  - `lua/config/` - Core settings
  - `lua/plugins/` - Plugin configurations
  
- **Tmux**: `~/.config/tmux/tmux.conf`
  - Main configuration with keybindings and theme

## ✨ Tips & Tricks

1. **Fast file navigation**: `<leader>ff` then type partial filename
2. **Live code search**: `<leader>fg` searches all files in workspace
3. **Smart movement**: Flash (`s`) finds any character instantly
4. **Surround operations**: Works with all bracket types: `( [ { < "`
5. **Git integration**: `:Gitsigns` shows git changes in signs
6. **Terminal**: `:terminal` opens terminal in split (use `C-\` to toggle)
7. **Multi-cursor**: Doesn't need alt-click, use flash + visual operations

## 🚨 Troubleshooting

### LSP not working
```vim
:Mason           " Install missing servers
:LspInfo        " Check which servers are running
:Mason gopls intelephense lua_ls
```

### Theme not loading
```vim
:colorscheme everforest
```

### Lazy.nvim not syncing plugins
```vim
:Lazy sync
```

### Tmux not starting
```bash
tmux kill-server
tmux new-session -s work
```

## 🎓 Next Steps

1. **Learn Flash**: Use `s` in normal mode to jump anywhere
2. **Explore code**: Use `gd` to jump to definitions, `gr` for references
3. **Debug code**: Set breakpoints with `<leader>db` and step through
4. **Format on save**: Configure formatters through `:Mason`
5. **LSP hover**: Press `K` to see type info and docs

---

Enjoy your professional development environment! 🚀
