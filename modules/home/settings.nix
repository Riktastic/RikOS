# =============================================================================
# Default Home Manager Settings Module
# =============================================================================
#
# Essential environment configuration, XDG directory setup, and application defaults.
#
# What it does:
# - Sets environment variables for locale, editor, and application defaults
# - Configures XDG base directories for proper file organization
# - Establishes MIME type associations for file handling
# - Provides Git configuration with modern defaults
# - Ensures consistent user environment across applications
#
# Requirements:
# - XDG-compliant applications
# - KDE Plasma desktop for MIME associations
# - Git for version control configuration
#
# Usage:
# - Import in user home-manager configurations
# - Settings apply automatically on login
# - XDG directories created if they don't exist
# - Applications use configured defaults
# =============================================================================

{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Environment Variables Configuration
  # ============================================================================
  # Set essential environment variables for consistent behavior
  # These ensure proper locale, editor, and application defaults
  home.sessionVariables = {
    # ========================================================================
    # Default Applications
    # ========================================================================
    EDITOR = "codium";                 # Default text editor (VS Code)
    VISUAL = "nvim";                   # Visual editor (Neovim)
    BROWSER = "vivaldi";               # Default web browser
    TERMINAL = "konsole";              # Default terminal emulator
    
    # ========================================================================
    # Qt Application Settings
    # ========================================================================
    QT_QPA_PLATFORM = "wayland;xcb";   # Prefer Wayland, fallback to X11
    QT_AUTO_SCREEN_SCALE_FACTOR = "1"; # Disable automatic scaling
    QT_SCALE_FACTOR = "1";             # Set scale factor to 1
    QT_SCREEN_SCALE_FACTORS = "1";     # Set screen scale factors to 1
  };

  # ============================================================================
  # XDG Base Directory Configuration
  # ============================================================================
  # Configure XDG base directories for proper file organization
  # This follows the XDG Base Directory Specification
  xdg = {
    enable = true;                     # Enable XDG base directory support
    
    # ========================================================================
    # User Directory Configuration
    # ========================================================================
    # Configure standard user directories
    userDirs = {
      enable = true;                   # Enable user directory configuration
      createDirectories = true;        # Create directories if they don't exist
      
      # Standard XDG directory paths
      documents = "$HOME/Documents";   # Document storage
      download = "$HOME/Downloads";    # Download directory
      videos = "$HOME/Videos";         # Video files
      pictures = "$HOME/Pictures";     # Image files
      music = "$HOME/Music";           # Audio files
      desktop = "$HOME/Desktop";       # Desktop files
      templates = "$HOME/Templates";   # Template files
      publicShare = "$HOME/Public";    # Public sharing directory
    };
    
    # ========================================================================
    # MIME Type Association Configuration
    # ========================================================================
    # Configure default applications for different file types
    mimeApps = {
      enable = true;                   # Enable MIME type associations
      
      # Default applications for common file types
      defaultApplications = {
        "text/plain" = [ "org.kde.kate.desktop" ];           # Text files
        "text/html" = [ "vivaldi.desktop" ];                 # HTML files
        "x-scheme-handler/http" = [ "vivaldi.desktop" ];     # HTTP links
        "x-scheme-handler/https" = [ "vivaldi.desktop" ];    # HTTPS links
        "application/pdf" = [ "org.kde.okular.desktop" ];    # PDF files
        "image/jpeg" = [ "org.kde.gwenview.desktop" ];       # JPEG images
        "image/png" = [ "org.kde.gwenview.desktop" ];        # PNG images
      };
    };
  };

  # ============================================================================
  # Git Configuration
  # ============================================================================
  # Configure Git with modern defaults and best practices
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
} 
