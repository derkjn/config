# Neovim & Tmux Setup - Quick Reference

## ⚡ Quick Start

```bash
# 1. Run the setup script
~/.config/nvim/setup.sh

# 2. Start tmux
tmux new-session -s work -c ~/projects

# 3. Open neovim
nvim .

# 4. In tmux, install plugins: C-a I (capital I)
```

## 🔧 Installation Checklist

- [x] Neovim v0.12+ installed
- [x] Tmux 3.4+ installed
- [x] TPM (Tmux Plugin Manager) installed at `~/.tmux/plugins/tpm`
- [x] All core plugins configured
- [ ] Language servers installed (via `:Mason` in nvim)
- [ ] Formatters installed (via `:Mason` in nvim)
- [ ] Go tools installed (optional but recommended)

## 📦 Required Language Servers

Install in Neovim with: `:MasonInstall <name>`

### For PHP Development
```
intelephense          # LSP server
php-cs-fixer         # Formatter
phpstan              # Linter
php-debug-adapter    # Debugger (Xdebug)
```

### For Go Development
```
gopls                # LSP server
delve                # Debugger
```

### Core Tools
```
lua_ls               # Lua (for nvim config)
jsonls               # JSON
yamlls               # YAML
```

## 🚀 Key Bindings by Category

### Navigation & Search
```
s              Flash jump
S              Flash treesitter
gd             Go to definition
gr             Find references
<leader>ff     Find files
<leader>fg     Live grep
<leader>fb     Find buffers
```

### Code Editing
```
cs"'           Change quotes
ds"            Delete surrounding
ys              Add surrounding
gcc            Toggle comment
<leader>cf     Format buffer
<leader>ca     Code actions
```

### Debugging
```
<leader>db     Toggle breakpoint
<leader>dc     Continue
<leader>di     Step into
<leader>do     Step over
<leader>du     Toggle DAP UI
```

### Tmux (prefix: C-a)
```
|              Split horizontally
-              Split vertically
hjkl           Navigate panes
HJKL           Resize panes
c              New window
n/p            Next/Previous window
s              Select session
r              Reload config
```

## 🐛 Troubleshooting

### Neovim won't start / slow startup
```vim
:Lazy sync            " Ensure all plugins are synced
:Lazy stats           " Check plugin load times
:Lazy profile         " Profile startup times
```

### LSP not working
```vim
:Mason                " View installed servers
:MasonInstall gopls   " Install a specific server
:LspInfo              " Check which servers are running
```

### Theme not loaded
```vim
:colorscheme everforest
:set background=dark
```

### Tmux plugins not working
1. Run: `tmux kill-server`
2. Create new session: `tmux new-session`
3. Install plugins: `C-a I`

### Formatters not working
Ensure they're installed and configured:
```vim
:Mason
" Install: gofumpt, php-cs-fixer, stylua, etc.
:ConformInfo  " Check conform status
```

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lazy-lock.json          # Plugin lock file
├── SETUP.md                # Full documentation
├── setup.sh                # Setup script
└── lua/
    ├── config/
    │   ├── options.lua     # Editor settings
    │   ├── keymaps.lua     # Global keybindings
    │   ├── autocmds.lua    # Auto commands
    │   └── lazy.lua        # Plugin manager setup
    └── plugins/
        ├── colorscheme.lua # Everforest theme
        ├── lsp.lua         # Language servers
        ├── completion.lua  # Autocompletion
        ├── dap.lua         # Debugging
        ├── telescope.lua   # Fuzzy finder
        ├── treesitter.lua  # Syntax highlighting
        ├── flash.lua       # Fast navigation
        ├── surround.lua    # Text objects
        ├── editor.lua      # Editing utilities
        ├── ui.lua          # UI enhancements
        ├── nvim-tree.lua   # File explorer
        └── git.lua         # Git integration

~/.config/tmux/
└── tmux.conf                # Main configuration
```

## 🎓 Tips & Tricks

### Working with Windows in Tmux
```bash
# Layout for coding + terminal
tmux new-session -s work
tmux split-window -h          # Split editor/terminal
tmux new-window               # New project window
tmux split-window             # Split for tests

# Layout for debugging
tmux new-window
tmux split-window -v          # Editor top, debug bottom
```

### Vim-Tmux Integration
- Navigate between tmux panes and vim splits seamlessly
- Works with vim-tmux-navigator plugin
- C-hjkl works in both vim windows and tmux panes

### Efficient Go Development
```
<leader>db              Set breakpoint
:DapContinue            Run to breakpoint
<leader>di/do/dO        Step through code
<leader>dr              Open REPL
```

### Efficient PHP Development
1. Configure Xdebug in php.ini:
   ```ini
   xdebug.mode=debug
   xdebug.client_port=9003
   xdebug.start_with_request=trigger
   ```

2. Set breakpoint with `<leader>db`
3. Trigger request with `XDEBUG_SESSION=1` cookie
4. Use `<leader>dc` to continue

## 📞 Support & Resources

### Neovim
- `:help nvim`
- `:help lspconfig`
- https://neovim.io/

### Tmux
- `tmux list-commands`
- `man tmux`
- https://github.com/tmux/tmux

### Plugins
- Lazy.nvim: https://github.com/folke/lazy.nvim
- LSPconfig: https://github.com/neovim/nvim-lspconfig
- Telescope: https://github.com/nvim-telescope/telescope.nvim
- Flash: https://github.com/folke/flash.nvim
- TPM: https://github.com/tmux-plugins/tpm

## ✅ Verification Checklist

After setup, verify everything works:

```vim
" Check plugins loaded
:Lazy status

" Check language servers
:MasonLog
:LspInfo

" Check treesitter
:TSStatus

" Check colorscheme
:colorscheme everforest

" Test flash
s " then type a character

" Test telescope
<leader>ff " then start typing a filename
```

---

**Last updated**: March 5, 2024
**Neovim version**: v0.12.0+
**Tmux version**: 3.4+
