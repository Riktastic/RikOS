# =============================================================================
# Server Home Manager Programs Module
# =============================================================================
#
# Installs CLI-only development tools and applications for server users.
#
# What it does:
# - Installs development tools (git, vim, etc.) - CLI only
# - Provides terminal and shell utilities
# - Includes server management and monitoring tools
# - Sets up development environment basics without GUI
# - Excludes all desktop applications and GUI tools
#
# Requirements:
# - home-manager enabled
# - Sufficient disk space for applications
# - Server environment (no desktop)
#
# Usage:
# - Import in server user home-manager configurations
# - Programs available in user environment
# - No GUI applications or desktop dependencies
# =============================================================================

{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Development Tools (CLI Only)
  # ============================================================================
  # Install essential development and programming tools
  # These provide the foundation for software development without GUI
  home.packages = with pkgs; [
    # ========================================================================
    # Version Control
    # ========================================================================
    git                     # Distributed version control system
    gh                      # GitHub CLI for repository management

    # ========================================================================
    # Text Editors (CLI Only)
    # ========================================================================
    vim                     # Classic text editor
    neovim                  # Modern Vim implementation
    nano                    # Simple text editor for beginners
    micro                   # Modern and intuitive terminal-based text editor

    # ========================================================================
    # Terminal and Shell
    # ========================================================================
    tmux                    # Terminal multiplexer
    screen                  # Terminal multiplexer (alternative)
    htop                    # Interactive process viewer
    tree                    # Directory tree display
    exa                     # Modern ls replacement
    bat                     # Better cat with syntax highlighting
    fd                      # Fast find alternative
    ripgrep                 # Fast text search tool
    fzf                     # Fuzzy finder

    # ========================================================================
    # System Utilities
    # ========================================================================
    wget                    # Web download utility
    curl                    # Command line HTTP client
    jq                      # JSON processor
    yq                      # YAML processor
    p7zip                   # 7z archive tool
    unzip                   # Zip archive tool
    tar                     # Archive utility
    gzip                    # Compression utility
    rsync                   # File synchronization utility
    rclone                  # Cloud storage sync tool

    # ========================================================================
    # Network Tools
    # ========================================================================
    nmap                    # Network scanner
    mtr                     # Network diagnostic tool
    iftop                   # Network bandwidth monitor
    iotop                   # I/O monitoring
    ncdu                    # Disk usage analyzer

    # ========================================================================
    # Monitoring and Debugging
    # ========================================================================
    lsof                    # List open files
    strace                  # System call tracer
    ltrace                  # Library call tracer
    tcpdump                 # Network packet analyzer
    wireshark-cli           # Network protocol analyzer (CLI)

    # ========================================================================
    # Development Languages (CLI Only)
    # ========================================================================
    python3                 # Python interpreter
    nodejs                  # Node.js runtime
    rustc                   # Rust compiler
    cargo                   # Rust package manager
    go                      # Go programming language
    gcc                     # GNU C compiler
    gdb                     # GNU debugger
    valgrind                # Memory error detector

    # ========================================================================
    # Database Tools
    # ========================================================================
    sqlite                  # SQLite database
    postgresql              # PostgreSQL client
    mysql                   # MySQL client
    redis-cli               # Redis command line interface

    # ========================================================================
    # Container and Virtualization
    # ========================================================================
    docker                  # Container platform
    docker-compose          # Multi-container Docker applications
    podman                  # Container engine
    kubectl                 # Kubernetes command line tool
    helm                    # Kubernetes package manager

    # ========================================================================
    # Security Tools
    # ========================================================================
    openssl                 # SSL/TLS toolkit
    gpg                     # GNU Privacy Guard
    sshfs                   # SSH filesystem
    sshuttle                # Transparent proxy over SSH

    # ========================================================================
    # Backup and Sync
    # ========================================================================
    restic                  # Fast, secure, efficient backup program
    borgbackup              # Deduplicating archiver
    duplicity              # Encrypted bandwidth-efficient backup
  ];

  # ============================================================================
  # Git Configuration
  # ============================================================================
  # Configure Git with modern defaults for server use
  programs.git = {
    enable = true;                     # Enable Git configuration

    # ========================================================================
    # Git Global Settings
    # ========================================================================
    # Configure Git behavior and defaults for server environment
    extraConfig = {
      init.defaultBranch = "main";     # Use 'main' as default branch
      pull.rebase = true;              # Use rebase for pulls
      push.autoSetupRemote = true;     # Auto-setup remote on push
      core.editor = "vim";             # Use vim as default editor
      core.autocrlf = "input";         # Handle line endings
      
      # Server-specific git aliases
      alias.st = "status";
      alias.co = "checkout";
      alias.br = "branch";
      alias.ci = "commit";
      alias.unstage = "reset HEAD --";
      alias.last = "log -1 HEAD";
      alias.lg = "log --oneline --graph --decorate";
    };
  };

  # ============================================================================
  # Shell Configuration
  # ============================================================================
  # Configure default shell (bash) with useful features for server use
  programs.bash = {
    enable = true;                     # Enable bash configuration

    # ========================================================================
    # Bash Settings
    # ========================================================================
    # Configure bash behavior and appearance for server environment
    initExtra = ''
      # Server environment setup
      export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.npm-global/bin:$PATH"
      
      # Development environment setup
      if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
      fi
      
      # Python virtual environment prompt
      export VIRTUAL_ENV_DISABLE_PROMPT=1
      
      # Server-specific aliases
      alias ll='ls -la'
      alias la='ls -A'
      alias l='ls -CF'
      alias ..='cd ..'
      alias ...='cd ../..'
      
      # System information aliases
      alias df='df -h'
      alias du='du -h'
      alias free='free -h'
      
      # Process management
      alias ps='ps aux'
      alias top='htop'
      
      # Network tools
      alias myip='curl -s ifconfig.me'
      alias ports='netstat -tulanp'
      
      # Git shortcuts
      alias gs='git status'
      alias ga='git add'
      alias gc='git commit'
      alias gp='git push'
      alias gl='git log --oneline'
      
      # Development aliases
      alias py='python3'
      alias pip='pip3'
      alias node='nodejs'
      alias rustc='rustc --color=always'
      alias cargo='cargo --color=always'
    '';

    # ========================================================================
    # Shell Aliases
    # ========================================================================
    # Useful command aliases for server productivity
    shellAliases = {
      ll = "ls -la";                   # List all files with details
      la = "ls -A";                    # List all files except . and ..
      l = "ls -CF";                    # List files in column format
      ".." = "cd ..";                  # Go up one directory
      "..." = "cd ../..";              # Go up two directories
      grep = "grep --color=auto";      # Colorized grep
      df = "df -h";                    # Human-readable disk usage
      du = "du -h";                    # Human-readable directory sizes
      
      # Server management aliases
      update = "sudo nixos-rebuild switch";
      upgrade = "sudo nixos-rebuild switch --upgrade";
      clean = "sudo nix-collect-garbage -d";
      
      # Network aliases
      myip = "curl -s ifconfig.me";
      ports = "netstat -tulanp";
      
      # Development aliases
      gst = "git status";
      gco = "git checkout";
      gcm = "git commit -m";
      gpl = "git pull";
      gps = "git push";
    };
  };

  # ============================================================================
  # SSH Configuration
  # ============================================================================
  # Configure SSH for server users
  programs.ssh = {
    enable = true;
    extraConfig = ''
      # Server-specific SSH settings
      ServerAliveInterval = 60
      ServerAliveCountMax = 3
      
      # Use SSH agent for key management
      AddKeysToAgent = yes
      UseKeychain = yes
      
      # Compression for slow connections
      Compression = yes
      
      # Keep connections alive
      TCPKeepAlive = yes
    '';
  };

  # ============================================================================
  # Tmux Configuration
  # ============================================================================
  # Configure tmux for server use
  programs.tmux = {
    enable = true;
    shortcut = "Space";
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = ''
      # Server-specific tmux settings
      set -g default-terminal "screen-256color"
      set -g status-bg black
      set -g status-fg white
      
      # Enable mouse support
      set -g mouse on
      
      # Increase scrollback buffer
      set -g history-limit 10000
      
      # Start window numbering at 1
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Automatically renumber windows
      set -g renumber-windows on
      
      # Set window and pane titles
      set -g set-titles on
      set -g set-titles-string "#T"
    '';
  };

  # ============================================================================
  # Vim Configuration
  # ============================================================================
  # Configure vim for server use
  programs.vim = {
    enable = true;
    settings = {
      number = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      autoindent = true;
      smartindent = true;
      showmatch = true;
      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = true;
      ruler = true;
      backspace = "indent,eol,start";
    };
    extraConfig = ''
      " Server-specific vim settings
      syntax on
      filetype plugin indent on
      
      " Set colorscheme for terminal
      set background=dark
      
      " Enable line wrapping
      set wrap
      set linebreak
      
      " Show whitespace characters
      set list
      set listchars=tab:>·,trail:·,extends:>,precedes:<
      
      " Enable persistent undo
      set undofile
      set undodir=~/.vim/undodir
      
      " Search settings
      set incsearch
      set hlsearch
      set ignorecase
      set smartcase
    '';
  };
} 