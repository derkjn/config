# Ubuntu Workstation Setup

A comprehensive, production-ready provisioning script and configuration suite for setting up a complete Ubuntu development environment. **100% vibecoded** with GitHub Copilot.

## What's Included

### 🚀 Provisioning Script (`setup-workstation.sh`)

An idempotent, human-friendly bash script that automates the entire workstation setup in one command:

```bash
./setup-workstation.sh
```

**Installs:**
- **Node.js** via nvm (latest LTS)
- **Go** with golangci-lint for linting
- **PHP 8.4** with developer extensions (intl, mysql, sqlite3, xdebug)
- **Neovim** (v0.12-dev, unstable channel, version-locked)
- **tmux** terminal multiplexer
- **GitHub Copilot** npm package
- **Language Servers** (JSON, YAML, tree-sitter-cli)
- **IBM Plex Mono Nerd Font** for terminal/editor
- **Standard terminal workflow** (tmux + system terminal)
- **System tools** (ripgrep, fd-find, fzf, composer, build-essential, xclip)

**Configures:**
- Neovim with Lazy.nvim plugin manager and LSP
- tmux with sensible defaults
- Shell environment (`.bashrc`, `.aliases`, `.exports`, `.inputrc`)
- Git global defaults
- Post-install plugin initialization

### 📝 Editor Configurations

#### Neovim (`nvim/`)
- **Plugin Manager:** Lazy.nvim with locked versions (`lazy-lock.json`)
- **Theme:** Everforest with Delirium UI dark background (#282829)
- **LSP Setup:** gopls, intelephense, lua_ls, JSON/YAML servers
- **Tools:** Telescope, Flash, Trouble, Conform (formatter), nvim-lint
- **Completion:** nvim-cmp with LSP integration
- **Treesitter:** Syntax highlighting

Key features:
- Inline LSP error display with virtual text
- Code formatting on save
- Linting on buffer write
- Go-to-definition, references, implementation
- Code actions and rename

#### tmux (`tmux/`)
- Clean, minimal configuration
- Session management helpers
- Plugin support (TPM - Tmux Plugin Manager)

### 🛠️ Shell Environment
- `.aliases` — Custom aliases including `dev` (quick tmux session)
- `.exports` — Environment variables
- `.inputrc` — Readline history search (Up/Down arrows)
- `.path` — PATH customization
- `.functions` — Helper functions
- `.extra` — User-specific overrides (merged non-destructively)

## Usage

### Initial Setup

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url> ~/.config
   cd ~/.config
   ```

2. **Run the setup script:**
   ```bash
   ./setup-workstation.sh
   ```

3. **Reload your shell:**
   ```bash
   source ~/.bashrc
   # or open a new terminal
   ```

4. **Verify installations:**
   ```bash
   nvm --version && node --version && go version && golangci-lint --version && php -v && nvim --version | head -1 && tmux -V
   ```

### Environment Variables (Optional)

Set these before running the script to customize installation:

- `NEOVIM_CHANNEL` — `stable` or `unstable` (default: `unstable` for v0.12-dev)
- `NEOVIM_APT_VERSION` — Specific Neovim version (e.g., `0.12.0~unstable-1`)
- `GIT_USER_NAME` — Git global user name
- `GIT_USER_EMAIL` — Git global user email

Example:
```bash
GIT_USER_NAME="Your Name" GIT_USER_EMAIL="you@example.com" ./setup-workstation.sh
```

### Running Neovim Post-Install

After setup completes, Neovim plugins are restored from `lazy-lock.json` (deterministic, reproducible build). To sync plugins:

```bash
nvim/setup.sh
```

Or manually in Neovim:
```vim
:Lazy restore  " Restore locked versions
:MasonInstall  " Install Mason LSP servers
```

## Design Philosophy

### Idempotent & Safe
- Checks before installation; skips if already installed
- Non-destructive dotfile merging (preserves user modifications outside managed blocks)
- Version locking prevents unexpected upgrades
- `apt-mark hold` on Neovim for stability

### User-Friendly
- Clear, colorized output with progress indicators
- Section headers and success messages
- Helpful error messages with remediation hints
- No silent failures

### Reproducible
- Pinned versions (nvm, Neovim, npm packages, Lazy plugins)
- Lazy plugin lock file pinned via `lazy-lock.json`
- Deterministic installation order
- Environment-aware setup

## Folder Structure

```
.
├── README.md                    # This file
├── setup-workstation.sh         # Main provisioning script
├── .aliases                     # Shell aliases
├── .exports                     # Shell exports
├── .inputrc                     # Readline config
├── .path                        # Optional PATH additions
├── .functions                   # Optional shell helpers
├── .extra                       # Optional local overrides
├── nvim/                        # Neovim configuration
│   ├── init.lua                # Entry point
│   ├── lazy-lock.json          # Plugin lock file
│   ├── setup.sh                # Post-install initializer
│   ├── SETUP.md                # Neovim setup guide
│   ├── THEME_GUIDE.md          # Theme customization
│   └── lua/
│       ├── config/             # Core configuration
│       └── plugins/            # Plugin specs
└── tmux/                        # tmux configuration
    ├── tmux.conf              # Main config
    ├── sessions.sh            # Session helpers
    └── SETUP.md               # tmux setup guide
```

## Troubleshooting

### golangci-lint not found
After running the setup script, open a new terminal or run `source ~/.bashrc` to update PATH.

### Neovim plugins not loading
Run `nvim/setup.sh` to restore plugins from lock file, or use `:Lazy restore` in Neovim.

### LSP not working
Verify language servers are installed:
```vim
:MasonInstall gopls intelephense lua_ls
:checkhealth
```

## Requirements

- **OS:** Ubuntu 22.04 or later
- **Bash:** 4+
- **Internet:** Required for package downloads
- **Sudo:** Required for system package installation

## Vibes

This entire setup—script logic, error handling, documentation, configuration organization—was developed using GitHub Copilot with an iterative, conversational approach. Every function, test, and feature emerged from natural dialogue between human intent and AI code generation.

No copy-paste boilerplate. No tutorials followed verbatim. Just pure **vibe-coding energy** ✨

---

## License

MIT

## Author

Developed with ❤️ and 🤖 vibes
