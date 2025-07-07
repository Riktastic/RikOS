# =============================================================================
# Default Home Manager Programs Module
# =============================================================================
#
# Installs common development tools and applications for all users.
#
# What it does:
# - Installs development tools (git, vim, etc.)
# - Provides terminal and shell utilities
# - Includes productivity applications
# - Sets up development environment basics
#
# Requirements:
# - home-manager enabled
# - Sufficient disk space for applications
#
# Usage:
# - Import in user home-manager configurations
# - Programs available in user environment
# =============================================================================

{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Development Tools
  # ============================================================================
  # Install essential development and programming tools
  # These provide the foundation for software development
  home.packages = with pkgs; [
    # ========================================================================
    # Version Control
    # ========================================================================
    git                     # Distributed version control system
    gh                      # GitHub CLI for repository management

    # ========================================================================
    # Text Editors and IDEs
    # ========================================================================
    neovim                  # Modern Vim implementation
    vscodium                # IDE

    # ========================================================================
    # Terminal and Shell
    # ========================================================================
    tmux                    # Terminal multiplexer
    htop                    # Interactive process viewer
    tree                    # Directory tree display

    # ========================================================================
    # System Utilities
    # ========================================================================
    wget                    # Web download utility
    curl                    # Command line HTTP client
    jq                      # JSON processor
    ripgrep                 # Fast text search tool
    p7zip                   # 7z archive tool
    unzip                   # Zip archive tool
    bleachbit
  ];

  # ============================================================================
  # Git Configuration
  # ============================================================================
  # Configure Git with modern defaults
  programs.git = {
    enable = true;                     # Enable Git configuration

    # ========================================================================
    # Git Global Settings
    # ========================================================================
    # Configure Git behavior and defaults
    extraConfig = {
      init.defaultBranch = "main";     # Use 'main' as default branch
      pull.rebase = true;              # Use rebase for pulls
      push.autoSetupRemote = true;     # Auto-setup remote on push
    };
  };

  # ============================================================================
  # Shell Configuration
  # ============================================================================
  # Configure default shell (zsh) with useful features
  programs.zsh = {
    enable = true;                     # Enable zsh configuration

    # ========================================================================
    # Zsh Settings
    # ========================================================================
    # Configure zsh behavior and appearance
    autosuggestion.enable = true;      # Command autosuggestions
    enableCompletion = true;           # Tab completion
    syntaxHighlighting.enable = true;  # Syntax highlighting

    # ========================================================================
    # Shell Aliases
    # ========================================================================
    # Useful command aliases for productivity
    shellAliases = {
      ll = "ls -la";                   # List all files with details
      la = "ls -A";                    # List all files except . and ..
      l = "ls -CF";                    # List files in column format
      ".." = "cd ..";                    # Go up one directory
      "..." = "cd ../..";                # Go up two directories
      grep = "grep --color=auto";      # Colorized grep
      df = "df -h";                    # Human-readable disk usage
      du = "du -h";                    # Human-readable directory sizes
    };
  };
}
