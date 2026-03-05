#!/usr/bin/env bash
#
# Tmux + Neovim Developer Setup
# Quick session templates for different workflows
#

# Usage: source this file or use individual functions
# Example: create_go_dev_session "myproject"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create a Go development session
create_go_dev_session() {
    local project_name=${1:-go-project}
    local project_dir=${2:-.}
    
    echo -e "${BLUE}Creating Go development session: $project_name${NC}"
    
    tmux new-session -d -s "$project_name" -c "$project_dir" -x 200 -y 50
    tmux send-keys -t "$project_name" "nvim ." Enter
    tmux split-window -t "$project_name" -h -p 40 -c "$project_dir"
    
    tmux new-window -t "$project_name" -n "build" -c "$project_dir"
    tmux send-keys -t "$project_name:build" "# Build window - type 'go build ./...' to compile" Enter
    
    tmux new-window -t "$project_name" -n "test" -c "$project_dir"
    tmux send-keys -t "$project_name:test" "# Test window - type 'go test ./...' to run tests" Enter
    tmux split-window -t "$project_name:test" -v -p 50 -c "$project_dir"
    
    tmux select-window -t "$project_name:0"
    echo -e "${GREEN}✓ Session created: $project_name${NC}"
    echo -e "${YELLOW}Attach with: tmux attach -t $project_name${NC}"
}

# Create a PHP development session
create_php_dev_session() {
    local project_name=${1:-php-project}
    local project_dir=${2:-.}
    
    echo -e "${BLUE}Creating PHP development session: $project_name${NC}"
    
    tmux new-session -d -s "$project_name" -c "$project_dir" -x 200 -y 50
    tmux send-keys -t "$project_name" "nvim ." Enter
    tmux split-window -t "$project_name" -h -p 40 -c "$project_dir"
    tmux send-keys -t "$project_name" "# Terminal pane - run php artisan, docker-compose, etc." Enter
    
    tmux new-window -t "$project_name" -n "server" -c "$project_dir"
    tmux send-keys -t "$project_name:server" "# Development server - php -S localhost:8000" Enter
    
    tmux new-window -t "$project_name" -n "logs" -c "$project_dir"
    tmux send-keys -t "$project_name:logs" "# Logs window - tail -f storage/logs/*.log" Enter
    
    tmux select-window -t "$project_name:0"
    echo -e "${GREEN}✓ Session created: $project_name${NC}"
    echo -e "${YELLOW}Attach with: tmux attach -t $project_name${NC}"
}

# Create a full-stack session (API + Frontend)
create_fullstack_session() {
    local project_name=${1:-fullstack-project}
    local backend_dir=${2:-.}
    local frontend_dir=${3:-.}
    
    echo -e "${BLUE}Creating full-stack development session: $project_name${NC}"
    
    # Backend window
    tmux new-session -d -s "$project_name" -c "$backend_dir" -x 200 -y 50 -n "backend"
    tmux send-keys -t "$project_name:backend" "nvim ." Enter
    tmux split-window -t "$project_name:backend" -h -p 40 -c "$backend_dir"
    
    # API server window
    tmux new-window -t "$project_name" -n "api" -c "$backend_dir"
    tmux send-keys -t "$project_name:api" "# Start your backend server here (go run, php -S, etc.)" Enter
    
    # Frontend window
    tmux new-window -t "$project_name" -n "frontend" -c "$frontend_dir"
    tmux send-keys -t "$project_name:frontend" "nvim ." Enter
    tmux split-window -t "$project_name:frontend" -h -p 40 -c "$frontend_dir"
    tmux send-keys -t "$project_name:frontend" "# Frontend server (npm run dev, etc.)" Enter
    
    # Debugging window
    tmux new-window -t "$project_name" -n "debug" -c "$backend_dir"
    tmux send-keys -t "$project_name:debug" "# Debugging/REPL window" Enter
    
    tmux select-window -t "$project_name:backend"
    echo -e "${GREEN}✓ Session created: $project_name${NC}"
    echo -e "${YELLOW}Attach with: tmux attach -t $project_name${NC}"
}

# Quick session switcher
list_sessions() {
    echo -e "${BLUE}Active Tmux Sessions:${NC}"
    if tmux list-sessions 2>/dev/null; then
        echo ""
        echo -e "${YELLOW}Attach with: tmux attach -t <session-name>${NC}"
    else
        echo -e "${RED}No active sessions${NC}"
    fi
}

# Kill a session
kill_session() {
    local session=$1
    if [ -z "$session" ]; then
        echo -e "${RED}Usage: kill_session <session-name>${NC}"
        return 1
    fi
    tmux kill-session -t "$session"
    echo -e "${GREEN}✓ Session killed: $session${NC}"
}

# Use-specific templates
usage() {
    cat << 'EOF'
Tmux + Neovim Session Templates

USAGE:
  source ~/.config/tmux/sessions.sh
  create_go_dev_session "myproject" "/path/to/project"
  create_php_dev_session "laravel-app" "/path/to/laravel"
  create_fullstack_session "api" "/path/to/backend" "/path/to/frontend"

FUNCTIONS:
  create_go_dev_session NAME [DIR]        - Create Go development session
  create_php_dev_session NAME [DIR]       - Create PHP development session
  create_fullstack_session NAME BACK FRONT - Create full-stack session
  list_sessions                           - List active sessions
  kill_session NAME                       - Kill a session

EXAMPLES:
  # Go project
  create_go_dev_session "redis-client" "/home/user/projects/redis-client"

  # PHP project
  create_php_dev_session "laravel-api" "/home/user/projects/laravel"

  # Full stack
  create_fullstack_session "myapp" "/path/to/api" "/path/to/web"

TMUX KEY BINDINGS (in session):
  C-a c       - Create new window
  C-a |       - Split pane horizontally
  C-a -       - Split pane vertically
  C-a hjkl    - Navigate panes (vim-style)
  C-a HJKL    - Resize pane
  C-a :       - Run tmux command
  C-a s       - Select session
  C-a r       - Reload config

For more info:
  cat ~/.config/tmux/SETUP.md
  cat ~/.config/nvim/SETUP.md
EOF
}

# If script is called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        help|--help|-h)
            usage
            ;;
        go)
            create_go_dev_session "$2" "$3"
            ;;
        php)
            create_php_dev_session "$2" "$3"
            ;;
        fullstack)
            create_fullstack_session "$2" "$3" "$4"
            ;;
        list)
            list_sessions
            ;;
        kill)
            kill_session "$2"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
fi
