# =============================================================================
# User Template Configuration
# =============================================================================
#
# Home-manager configuration template for a user.
#
# Usage:
# - Copy this file to homes/yourusername.nix and customize
# - Imported by users.nix for the user
# - Automatically adapts to device mode
# =============================================================================

{ config, pkgs, lib, deviceMode ? "desktop", serverUsers ? { enableMinimalConfig = true; }, ... }:

{
  imports =
    if deviceMode == "desktop" then [
      ../modules/home/programs.nix
      ../modules/home/settings.nix
      ../modules/home/services.nix
    ] else if deviceMode == "server" && serverUsers.enableMinimalConfig then [
      ../modules/home/programs-server.nix
    ] else [];

  # ============================================================================
  # User Identity
  # ============================================================================
  # Override default settings with user-specific values
  # These settings identify the user and their home directory
  home = {
    username = "your-username";            # CHANGE: Set your system username
    homeDirectory = "/home/your-username"; # CHANGE: Set your home directory
    stateVersion = "25.05";                # Home-manager state version
  };

  # ============================================================================
  # Software (Desktop Mode Only)
  # ============================================================================
  # Additional packages for desktop mode
  #home.packages = lib.mkIf (cfg.mode == "desktop") (with pkgs; [
  #  # ... other packages ...
  #  hugo  # Static site generator
  #]);

  # ============================================================================
  # Git Configuration
  # ============================================================================
  # Override default git configuration with user-specific values
  # This sets up the user's identity for version control
  # Comment out if not using git
  programs.git = {
    userName = "your-git-username";        # CHANGE: Set your git username
    userEmail = "your-email@example.com";  # CHANGE: Set your git email
  };

  # ============================================================================
  # Environment Variables
  # ============================================================================
  # Add user-specific environment variables
  # These are available to all applications run by this user
  home.sessionVariables = {
    # ADD: Your environment variables here
    # Examples:
    # EDITOR = "vim";
    # BROWSER = "firefox";
    # TERMINAL = "konsole";
    # PROTON_EMAIL = "your-proton-email@protonmail.com";
    # PATH = "$HOME/.local/bin:$PATH";
  };

  # ============================================================================
  # User-Specific Overrides (Desktop Mode Only)
  # ============================================================================
  # Add any user-specific configurations that override defaults
  # This section can include customizations for programs, services, and settings
  # Only applies to desktop mode - server mode uses minimal configuration

  # ========================================================================
  # Terminal Configuration (Desktop Mode Only)
  # ========================================================================
  # Configure your preferred terminal emulator
  # Uncomment and customize based on your preference

  # programs.kitty = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   settings = {
  #     font_size = 12;
  #     background_opacity = 0.9;
  #     window_padding_width = 10;
  #   };
  # };

  # programs.alacritty = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   settings = {
  #     window.opacity = 0.9;
  #     font.size = 12;
  #   };
  # };

  # ========================================================================
  # Shell Configuration (Desktop Mode Only)
  # ========================================================================
  # Configure your preferred shell
  # Uncomment and customize based on your preference

  # programs.bash = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   initExtra = ''
  #     # Custom bash initialization
  #     export PATH="$HOME/.local/bin:$PATH"
  #     alias ll='ls -la'
  #     alias la='ls -A'
  #   '';
  # };

  # programs.zsh = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   initExtra = ''
  #     # Custom zsh initialization
  #     export PATH="$HOME/.local/bin:$PATH"
  #   '';
  # };

  # ========================================================================
  # Editor Configuration (Desktop Mode Only)
  # ========================================================================
  # Configure your preferred text editor
  # Uncomment and customize based on your preference

  # programs.vim = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   settings = {
  #     number = true;
  #     expandtab = true;
  #     tabstop = 2;
  #     shiftwidth = 2;
  #   };
  # };

  # programs.neovim = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   viAlias = true;
  #   vimAlias = true;
  # };

  # ========================================================================
  # Development Tools (Desktop Mode Only)
  # ========================================================================
  # Configure development tools and environments
  # Uncomment and customize based on your needs

  # programs.tmux = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   shortcut = "Space";
  #   baseIndex = 1;
  #   escapeTime = 0;
  # };

  # programs.gh = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   settings = {
  #     git_protocol = "ssh";
  #     editor = "vim";
  #   };
  # };

  # ========================================================================
  # Desktop Applications (Desktop Mode Only)
  # ========================================================================
  # Configure desktop applications and utilities
  # Uncomment and customize based on your preferences

  # programs.firefox = lib.mkIf (cfg.mode == "desktop") {
  #   enable = true;
  #   profiles.default = {
  #     settings = {
  #       "browser.startup.homepage" = "https://startpage.com";
  #     };
  #   };
  # };
}
