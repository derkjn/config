#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log() {
  echo -e "${BLUE}[setup]${NC} $*"
}

success() {
  echo -e "${GREEN}✓${NC} $*"
}
  
  success "Ubuntu Linux detected (${VERSION_CODENAME:-unknown})"

info() {
  echo -e "${CYAN}ℹ${NC} $*"
}

section() {
  echo ""
  echo -e "${BOLD}${CYAN}▶ $*${NC}"
}

fail() {
  echo -e "${RED}✗ ERROR: $*${NC}" >&2
  exit 1
}

require_ubuntu_linux() {
  [[ "$(uname -s)" == "Linux" ]] || fail "This script only supports Linux."
  [[ -f /etc/os-release ]] || fail "Cannot detect distribution (/etc/os-release missing)."

  # shellcheck source=/dev/null
  source /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || fail "This script only supports Ubuntu. Detected: ${ID:-unknown}"
}

as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

cleanup_legacy_warp_apt_conflicts() {
  local apt_file

  info "Cleaning legacy Warp APT repo conflicts (if any)..."
  as_root rm -f /etc/apt/trusted.gpg.d/warpdotdev.gpg

  while IFS= read -r apt_file; do
    [[ -n "$apt_file" ]] || continue

    if [[ "$apt_file" == "/etc/apt/sources.list" ]]; then
      as_root sed -i '/releases\.warp\.dev\/linux\/deb/d' /etc/apt/sources.list
    else
      as_root rm -f "$apt_file"
    fi
  done < <(grep -RIl 'releases\.warp\.dev/linux/deb' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null || true)
}

install_apt_prereqs() {
  section "APT Prerequisites"
  as_root apt-get update
  as_root apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    unzip \
    wget
  success "APT prerequisites installed"
}

install_dev_system_tools() {
  section "Developer System Tools"
  as_root apt-get install -y \
    build-essential \
    make \
    pkg-config \
    fzf \
    ripgrep \
    fd-find \
    composer

  if ! dpkg -s xclip >/dev/null 2>&1 && ! dpkg -s wl-clipboard >/dev/null 2>&1; then
    as_root apt-get install -y xclip wl-clipboard \
      || as_root apt-get install -y xclip \
      || as_root apt-get install -y wl-clipboard \
      || true
  fi
  success "Developer system tools installed"
}

ensure_bashrc_fzf() {
  local bashrc_file="$HOME/.bashrc"
  touch "$bashrc_file"

  if ! grep -Fq '/usr/share/doc/fzf/examples/key-bindings.bash' "$bashrc_file"; then
    info "Adding fzf bash integration to .bashrc..."
    cat >>"$bashrc_file" <<'EOF'

if command -v fzf >/dev/null 2>&1; then
  [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
  [ -f /usr/share/doc/fzf/examples/completion.bash ] && source /usr/share/doc/fzf/examples/completion.bash
fi
EOF
  else
    info "fzf bash integration already present in .bashrc."
  fi
}

install_nvm() {
  section "Node.js (via nvm)"
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"

  if [[ ! -s "$nvm_dir/nvm.sh" ]]; then
    info "Installing nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  else
    success "nvm already installed"
  fi

  set +u
  # shellcheck source=/dev/null
  source "$nvm_dir/nvm.sh"

  info "Installing latest LTS Node.js via nvm..."
  nvm install --lts
  nvm alias default 'lts/*'
  nvm use --lts
  set -u
  success "Node.js LTS installed"
}

install_go() {
  section "Go & golangci-lint"
  if command -v go >/dev/null 2>&1; then
    success "Go already installed ($(go version | cut -d' ' -f3))"
  else
    info "Installing Go..."
    as_root apt-get install -y golang-go
  fi

  # Ensure Go is in PATH for this script
  export PATH="$HOME/go/bin:$PATH:/usr/local/go/bin"

  # Check if golangci-lint is already installed
  if command -v golangci-lint >/dev/null 2>&1; then
    success "golangci-lint already installed ($(golangci-lint --version | head -1))"
    return
  fi

  info "Installing golangci-lint..."
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>&1 || fail "Failed to install golangci-lint"

  if command -v golangci-lint >/dev/null 2>&1; then
    success "Go and golangci-lint installed ($(golangci-lint --version | head -1))"
  else
    fail "golangci-lint installation verification failed"
  fi
}

install_php84() {
  section "PHP 8.4"
  if dpkg -s php8.4 >/dev/null 2>&1; then
    success "PHP 8.4 already installed"
    return
  fi

  info "Installing PHP 8.4 from ondrej/php PPA..."
  as_root add-apt-repository -y ppa:ondrej/php
  as_root apt-get update
  as_root apt-get install -y \
    php8.4 \
    php8.4-cli \
    php8.4-common \
    php8.4-curl \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-zip
  success "PHP 8.4 installed"
}

install_php84_extras() {
  info "Installing PHP 8.4 developer extensions..."
  as_root apt-get install -y \
    php8.4-intl \
    php8.4-mysql \
    php8.4-sqlite3 \
    php8.4-xdebug
  success "PHP extensions installed"
}

install_neovim_tmux() {
  section "Neovim & tmux"
  local neovim_channel
  local neovim_ppa
  local nvim_version_output

  neovim_channel="${NEOVIM_CHANNEL:-unstable}"
  if [[ "$neovim_channel" == "stable" ]]; then
    neovim_ppa="ppa:neovim-ppa/stable"
  else
    neovim_ppa="ppa:neovim-ppa/unstable"
    neovim_channel="unstable"
  fi

  info "Installing Neovim from ${neovim_ppa} (${neovim_channel} channel)..."
  as_root add-apt-repository -y "$neovim_ppa"
  as_root apt-get update

  if [[ -n "${NEOVIM_APT_VERSION:-}" ]]; then
    info "Installing Neovim version ${NEOVIM_APT_VERSION}..."
    as_root apt-get install -y "neovim=${NEOVIM_APT_VERSION}"
  else
    as_root apt-get install -y neovim
  fi

  nvim_version_output="$(nvim --version | head -1 2>/dev/null || true)"
  if [[ "$neovim_channel" == "unstable" && "$nvim_version_output" != *"v0.12"* ]]; then
    fail "Expected Neovim v0.12 on unstable channel, got: ${nvim_version_output:-unknown}"
  fi

  as_root apt-mark hold neovim || true
  success "Neovim installed and held (${nvim_version_output:-version unknown})"

  info "Installing tmux..."
  as_root apt-get install -y tmux
  success "tmux installed"
}

install_copilot_npm() {
  section "GitHub Copilot (npm)"
  info "Installing @github/copilot globally via npm..."
  npm install -g @github/copilot
  success "GitHub Copilot installed"
}

install_npm_language_servers() {
  section "Language Servers (npm)"
  info "Installing JSON/YAML language servers and tree-sitter CLI via npm..."
  npm install -g vscode-langservers-extracted yaml-language-server tree-sitter-cli
  success "Language servers and tree-sitter CLI installed"
}

install_ibm_plex_mono_nerdfont() {
  section "IBM Plex Mono Nerd Font"
  local font_dir="${HOME}/.local/share/fonts"
  local tmp_dir

  if find "$font_dir" -maxdepth 1 -type f \( -iname '*IBMPlexMono*.ttf' -o -iname '*BlexMono*Nerd*Font*.ttf' \) | grep -q . 2>/dev/null \
    || fc-list | grep -Eiq 'BlexMono Nerd Font|IBM Plex Mono Nerd Font|BlexMonoNerdFont'; then
    success "BlexMono Nerd Font already installed"
    return
  fi

  tmp_dir="$(mktemp -d)"

  info "Downloading and installing BlexMono Nerd Font..."
  mkdir -p "$font_dir"

  curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IBMPlexMono.zip" -o "$tmp_dir/IBMPlexMono.zip"
  unzip -o "$tmp_dir/IBMPlexMono.zip" -d "$tmp_dir/IBMPlexMono"
  find "$tmp_dir/IBMPlexMono" -type f -name "*.ttf" -exec cp {} "$font_dir/" \;
  fc-cache -f "$font_dir"

  rm -rf "$tmp_dir"
  success "IBM Plex Mono Nerd Font installed"
}

install_warp() {
  section "Warp Terminal"
  info "Configuring Warp terminal APT repository..."
  as_root mkdir -p /etc/apt/keyrings

  # Remove legacy/conflicting Warp repository definitions and key locations.
  for apt_list_file in /etc/apt/sources.list /etc/apt/sources.list.d/*.list; do
    [[ -f "$apt_list_file" ]] || continue
    if grep -Fq 'releases.warp.dev/linux/deb' "$apt_list_file"; then
      as_root sed -i '/releases\.warp\.dev\/linux\/deb/d' "$apt_list_file"
    fi
  done
  as_root rm -f /etc/apt/sources.list.d/warpdotdev.list
  as_root rm -f /etc/apt/trusted.gpg.d/warpdotdev.gpg

  curl -fsSL https://releases.warp.dev/linux/keys/warp.asc | as_root gpg --dearmor -o /etc/apt/keyrings/warp.gpg
  echo "deb [signed-by=/etc/apt/keyrings/warp.gpg] https://releases.warp.dev/linux/deb stable main" | as_root tee /etc/apt/sources.list.d/warp.list >/dev/null

  as_root apt-get update

  if dpkg -s warp-terminal >/dev/null 2>&1; then
    success "Warp terminal already installed"
  else
    info "Installing Warp terminal..."
    as_root apt-get install -y warp-terminal
    success "Warp terminal installed"
  fi
}

sync_editor_configs() {
  section "Editor Configurations"
  local config_home
  config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

  info "Syncing Neovim and tmux configs into ${config_home}..."
  mkdir -p "$config_home/nvim" "$config_home/tmux"

  if [[ -d "$SCRIPT_DIR/nvim" ]]; then
    cp -a "$SCRIPT_DIR/nvim/." "$config_home/nvim/"
  else
    fail "Missing nvim config directory at: $SCRIPT_DIR/nvim"
  fi

  if [[ -d "$SCRIPT_DIR/tmux" ]]; then
    cp -a "$SCRIPT_DIR/tmux/." "$config_home/tmux/"
  else
    fail "Missing tmux config directory at: $SCRIPT_DIR/tmux"
  fi
  success "Editor configs synced"
}

ensure_bashrc_defaults() {
  section "Shell Environment Setup"
  local bashrc_file="$HOME/.bashrc"
  touch "$bashrc_file"

  if ! grep -Fq 'for file in ~/.{path,exports,aliases,functions,extra}; do' "$bashrc_file"; then
    info "Adding dotfile source loop to .bashrc..."
    cat >>"$bashrc_file" <<'EOF'

for file in ~/.{path,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
EOF
  fi

  if ! grep -Fq 'export NVM_DIR="$HOME/.nvm"' "$bashrc_file"; then
    info "Adding nvm initialization to .bashrc..."
    cat >>"$bashrc_file" <<'EOF'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
  fi
  success "Shell environment configured"
}

merge_dotfile_preserve_existing() {
  local source_file="$1"
  local target_file="$2"
  local file_name
  local begin_marker
  local end_marker
  local temp_file

  file_name="$(basename "$source_file")"
  begin_marker="# >>> setup-workstation ${file_name} >>>"
  end_marker="# <<< setup-workstation ${file_name} <<<"

  if [[ ! -f "$target_file" ]]; then
    info "Creating $target_file from repo $file_name..."
    cp -a "$source_file" "$target_file"
    return
  fi

  temp_file="$(mktemp)"
  awk -v begin="$begin_marker" -v end="$end_marker" '
    BEGIN { in_block = 0 }
    $0 == begin { in_block = 1; next }
    $0 == end { in_block = 0; next }
    in_block == 0 { print }
  ' "$target_file" >"$temp_file"

  {
    cat "$temp_file"
    echo
    echo "$begin_marker"
    cat "$source_file"
    echo
    echo "$end_marker"
  } >"$target_file"

  rm -f "$temp_file"
}

sync_shell_dotfiles() {
  section "Shell Dotfiles"

  local aliases_file="$HOME/.aliases"
  local exports_file="$HOME/.exports"
  local inputrc_file="$HOME/.inputrc"
  local backup_stamp
  local backup_dir

  backup_stamp="$(date +%Y%m%d-%H%M%S)"
  backup_dir="$HOME/.setup-workstation-backups/$backup_stamp"

  for file_path in "$aliases_file" "$exports_file" "$inputrc_file"; do
    if [[ -f "$file_path" ]]; then
      if [[ ! -d "$backup_dir" ]]; then
        mkdir -p "$backup_dir"
      fi
      cp -a "$file_path" "$backup_dir/"
      info "Backed up $(basename "$file_path") to $backup_dir"
    fi
  done

  touch "$aliases_file" "$exports_file" "$inputrc_file"

  if ! grep -Fq '_dev_tmux_start() {' "$aliases_file"; then
    info "Appending dev tmux function to .aliases..."
    cat >>"$aliases_file" <<'EOF'

# Dev tmux session
_dev_tmux_start() {
  local target_dir
  if [ -d "$HOME/dab" ]; then
    target_dir="$HOME/dab"
  else
    target_dir="$PWD"
  fi
  tmux new-session -A -s dev -c "$target_dir"
}
EOF
  fi

  if ! grep -Fq "alias dev='_dev_tmux_start'" "$aliases_file"; then
    info "Appending dev alias to .aliases..."
    echo "alias dev='_dev_tmux_start'" >>"$aliases_file"
  fi

  if ! grep -Fq 'export PATH="$HOME/go/bin:$PATH"' "$exports_file"; then
    info "Appending Go PATH export to .exports..."
    cat >>"$exports_file" <<'EOF'

# Go binaries path
export PATH="$HOME/go/bin:$PATH"
EOF
  fi

  if ! grep -Fq 'npm config get prefix' "$exports_file"; then
    info "Appending npm global bin export to .exports..."
    cat >>"$exports_file" <<'EOF'

# npm global bin path (for @github/copilot and other global packages)
if command -v npm >/dev/null 2>&1; then
  export PATH="$(npm config get prefix)/bin:$PATH"
fi
EOF
  fi

  if [[ -f "$SCRIPT_DIR/.inputrc" ]] && ! cmp -s "$SCRIPT_DIR/.inputrc" "$inputrc_file"; then
    info "Updating .inputrc..."
    cp "$SCRIPT_DIR/.inputrc" "$inputrc_file"
  fi

  success "Shell dotfiles synced (append-only)"
}

run_post_install_initializers() {
  section "Post-Install Initialization"
  local bashrc_file="$HOME/.bashrc"

  if [[ -f "$SCRIPT_DIR/nvim/setup.sh" ]]; then
    info "Running Neovim post-install initializer..."
    chmod +x "$SCRIPT_DIR/nvim/setup.sh"
    "$SCRIPT_DIR/nvim/setup.sh"
    success "Neovim setup completed"
  fi

  if [[ -f "$SCRIPT_DIR/tmux/setup.sh" ]]; then
    info "Running tmux post-install initializer..."
    chmod +x "$SCRIPT_DIR/tmux/setup.sh"
    "$SCRIPT_DIR/tmux/setup.sh"
    success "tmux setup completed"
  elif [[ -f "$SCRIPT_DIR/tmux/sessions.sh" ]]; then
    info "Enabling tmux sessions helper from .bashrc..."
    chmod +x "$SCRIPT_DIR/tmux/sessions.sh"
    if ! grep -Fq 'source ~/.config/tmux/sessions.sh' "$bashrc_file"; then
      echo '' >>"$bashrc_file"
      echo '[ -f ~/.config/tmux/sessions.sh ] && source ~/.config/tmux/sessions.sh' >>"$bashrc_file"
    fi
  fi
}

configure_git_defaults() {
  section "Git Configuration"
  info "Applying default global Git configuration..."
  git config --global init.defaultBranch main
  git config --global pull.rebase false
  git config --global fetch.prune true
  git config --global core.editor nvim

  if [[ -n "${GIT_USER_NAME:-}" ]]; then
    git config --global user.name "$GIT_USER_NAME"
  fi

  if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi

  if [[ -z "$(git config --global --get user.name || true)" || -z "$(git config --global --get user.email || true)" ]]; then
    info "Git identity can be set with: GIT_USER_NAME and GIT_USER_EMAIL"
  fi
  success "Git configuration applied"
}

run_neovim_health_check() {
  section "Neovim Health Check"
  local health_log
  local errors
  local warnings

  if ! command -v nvim >/dev/null 2>&1; then
    info "Skipping health check (nvim not installed)"
    return
  fi

  health_log="${HOME}/.cache/nvim/setup-checkhealth.log"
  mkdir -p "$(dirname "$health_log")"

  info "Running Neovim health check..."
  nvim --headless "+checkhealth" +qa >"$health_log" 2>&1 || true

  errors="$(grep -Eic '\berror\b' "$health_log" || true)"
  warnings="$(grep -Eic '\bwarn(ing)?\b' "$health_log" || true)"

  if [[ "$errors" -eq 0 && "$warnings" -eq 0 ]]; then
    success "Neovim health check passed"
  else
    log "Neovim: ${errors} errors, ${warnings} warnings (see $health_log)"
  fi
}

main() {
  echo
  echo -e "${BOLD}${CYAN}╭─ Ubuntu Workstation Setup ${CYAN}─╮${NC}"
  echo -e "${CYAN}│${NC}"
  
  require_ubuntu_linux
  cleanup_legacy_warp_apt_conflicts
  install_apt_prereqs
  install_dev_system_tools
  install_nvm
  install_go
  install_php84
  install_php84_extras
  install_neovim_tmux
  install_copilot_npm
  install_npm_language_servers
  install_ibm_plex_mono_nerdfont
  install_warp
  sync_editor_configs
  sync_shell_dotfiles
  ensure_bashrc_defaults
  ensure_bashrc_fzf
  configure_git_defaults
  run_post_install_initializers
  run_neovim_health_check

  echo -e "${CYAN}│${NC}"
  echo -e "${BOLD}${GREEN}╰─ Setup Complete ${GREEN}─╯${NC}"
  echo
  log "Run in a new shell: source ~/.bashrc"
  log "Verify: nvm --version && node --version && go version && golangci-lint --version && php -v && nvim --version | head -1 && tmux -V"
  echo
}

main "$@"