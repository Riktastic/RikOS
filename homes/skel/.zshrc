# ========================================================================
# Powerlevel10k Instant Prompt
# ========================================================================
# Powerlevel10k Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========================================================================
# History Configuration
# ========================================================================
# Configure command history for better productivity
HISTSIZE=10000           # Number of commands in memory
SAVEHIST=10000           # Number of commands to save
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"  # History file location
setopt HIST_IGNORE_DUPS  # Ignore duplicate commands
setopt HIST_IGNORE_SPACE # Ignore commands starting with space
setopt HIST_VERIFY       # Verify history expansion
setopt SHARE_HISTORY     # Share history between sessions
setopt EXTENDED_HISTORY  # Include timestamps in history

# ========================================================================
# System Information Display
# ========================================================================
# Show pfetch on non-TTY terminals for system information
case $(tty) in
  (/dev/tty[1-9]) ;;      # Skip on TTY terminals
  (*) eval pfetch ;;      # Show system info on other terminals
esac

# ========================================================================
# Directory Navigation
# ========================================================================
# Enhanced directory navigation features
setopt AUTO_CD           # Change directory without cd
setopt AUTO_PUSHD        # Push directories onto stack
setopt PUSHD_IGNORE_DUPS # Ignore duplicates in directory stack
setopt PUSHD_SILENT      # Suppress directory stack output

# ========================================================================
# Completion System
# ========================================================================
# Advanced completion system with menu selection
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select              # Menu selection
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Color-coded completion
zstyle ':completion:*' rehash true               # Rehash completion cache

# ========================================================================
# Key Bindings
# ========================================================================
# Enhanced key bindings for better navigation
bindkey '^[[A' up-line-or-search           # Up arrow: history search
bindkey '^[[B' down-line-or-search         # Down arrow: history search
bindkey '^[[H' beginning-of-line            # Home: beginning of line
bindkey '^[[F' end-of-line                  # End: end of line
bindkey '^[[3~' delete-char                 # Delete: delete character
bindkey '^[[1;5C' forward-word              # Ctrl+Right: forward word
bindkey '^[[1;5D' backward-word             # Ctrl+Left: backward word

# ========================================================================
# Command Aliases
# ========================================================================
# Color-coded command aliases for better visibility
alias ls='ls --color=auto'                   # Colored ls output
alias ll='ls -lah'                           # Long listing with hidden files
alias la='ls -A'                             # List all files
alias l='ls -CF'                             # Column format listing
alias grep='grep --color=auto'               # Colored grep output
alias fgrep='fgrep --color=auto'             # Colored fgrep output
alias egrep='egrep --color=auto'             # Colored egrep output
alias diff='diff --color=auto'               # Colored diff output
alias ip='ip --color=auto'                   # Colored ip output
alias sudo='sudo '                           # Allow aliases to work with sudo

# ========================================================================
# NixOS Management Aliases
# ========================================================================
# Convenient aliases for NixOS system management
alias nix-update='sudo nixos-rebuild switch --upgrade'  # Update system
alias nix-clean='sudo nix-collect-garbage -d'          # Clean old generations
alias nix-search='nix search nixpkgs#'                  # Search packages

# ========================================================================
# Git Workflow Aliases
# ========================================================================
# Short aliases for common git operations
alias gs='git status'           # Git status
alias ga='git add'              # Git add
alias gc='git commit'           # Git commit
alias gp='git push'             # Git push
alias gl='git pull'             # Git pull
alias gd='git diff'             # Git diff
alias gco='git checkout'        # Git checkout
alias gb='git branch'           # Git branch

# ========================================================================
# Directory Shortcuts
# ========================================================================
# Hash directories for quick navigation
hash -d nixos=/etc/nixos        # NixOS configuration
hash -d docs=~/Documents        # Documents directory
hash -d dl=~/Downloads          # Downloads directory
hash -d pics=~/Pictures         # Pictures directory

# ========================================================================
# Plugin Loading
# ========================================================================
# Load zsh plugins for enhanced functionality
source /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ========================================================================
# Theme Loading
# ========================================================================
# Load Powerlevel10k theme for advanced prompt
source /run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

# Load custom p10k configuration if available
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
