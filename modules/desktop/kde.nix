# =============================================================================
# KDE Plasma 6 Desktop Environment Configuration Module
# =============================================================================
#
# This module configures KDE Plasma 6, the latest Qt6-based desktop
# environment with comprehensive customization options and productivity tools.
# Only enabled in desktop mode.
#
# What it does:
# - Enables KDE Plasma 6 desktop environment with Wayland/X11 support
# - Installs comprehensive KDE application suite (Dolphin, Konsole, etc.)
# - Configures SDDM display manager with Wayland support
# - Sets up KDE Connect for mobile device integration
# - Configures Qt6 environment variables for optimal performance
#
# Requirements:
# - X server enabled
# - Graphics drivers configured
# - Sufficient system resources for desktop environment
# - Device mode must be "desktop"
#
# Usage:
# - Import this module in device configurations
# - KDE Plasma 6 starts automatically on boot (desktop mode only)
# - Applications available in the application menu
# - Configure via System Settings (kde-systemsettings)
# =============================================================================

{ config, pkgs, lib, ... }:

let
  cfg = config.device;
in

lib.mkIf (cfg.mode == "desktop") {

  # ============================================================================
  # X Server Configuration
  # ============================================================================
  # Enable X server for desktop environment support
  # This provides the foundation for graphical applications
  services.xserver = {
    enable = true;  # Enable X server
  };

  # ============================================================================
  # KDE Plasma 6 Desktop Manager
  # ============================================================================
  # Enable KDE Plasma 6 as the desktop environment
  # This provides the complete desktop experience
  services.desktopManager.plasma6.enable = true;

  # ============================================================================
  # Display Manager Configuration
  # ============================================================================
  # Configure SDDM (Simple Desktop Display Manager) for login interface
  services.displayManager.sddm = {
    enable = true;        # Enable SDDM display manager
    
    # ========================================================================
    # Wayland Support
    # ========================================================================
    # Enable Wayland support in SDDM
    # This allows login to Wayland sessions
    wayland.enable = true;
  };

  # ============================================================================
  # Power management services
  # ============================================================================
  # Ensures power management is working.
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = true;
     
  # ============================================================================
  # D-Bus Configuration
  # ============================================================================
  # Enable dconf for GNOME-style configuration storage
  # This provides additional configuration capabilities
  programs.dconf.enable = true;

  # ============================================================================
  # KDE Plasma Applications
  # ============================================================================
  # Install comprehensive KDE Plasma application suite
  # These applications provide the complete desktop experience
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # Core KDE Applications (Qt6-based)
    # ========================================================================
    kdePackages.konsole                    # Advanced terminal emulator
    kdePackages.dolphin                    # File manager
    kdePackages.gwenview                   # Image viewer
    kdePackages.ark                        # Archive manager
    kdePackages.kcalc                      # Calculator
    kdePackages.kdeconnect-kde             # Mobile device integration
    kdePackages.kde-gtk-config             # GTK theme configuration
    kdePackages.kmenuedit                  # Menu editor
    kdePackages.kscreen                    # Display configuration
    kdePackages.ksystemstats               # System monitoring
    kdePackages.kwalletmanager             # Password and key management
    kdePackages.kwrited                    # KDE Write Daemon
    kdePackages.plasma-browser-integration # Browser integration
    kdePackages.plasma-systemmonitor       # System resource monitor
    kdePackages.plasma-workspace           # Core workspace components
    kdePackages.filelight 
    kdePackages.sddm-kcm

    # ========================================================================
    # Additional Useful Applications
    # ========================================================================
    pkgs.qt6Packages.qt6ct                 # Qt6 configuration tool
    pkgs.qt6Packages.qtstyleplugin-kvantum # Advanced theme engine for Qt6

    # ========================================================================
    # Custom windows theming
    # ========================================================================
    nur.repos.shadowrz.klassy-qt6
  ];

  # ============================================================================
  # KDE Connect Configuration
  # ============================================================================
  # Enable KDE Connect for mobile device integration
  # This provides seamless connection between desktop and mobile devices
  programs.kdeconnect.enable = true;

  # ============================================================================
  # Environment Variables
  # ============================================================================
  # Configure Qt6 and display server environment variables
  # These ensure optimal compatibility and performance
  environment.variables = {
    # ========================================================================
    # Qt6 Display Platform Configuration
    # ========================================================================
    # Prefer Wayland, fallback to X11 for compatibility
    # This provides the best of both display protocols
    QT_QPA_PLATFORM = "wayland;xcb";
    
    # ========================================================================
    # Display Scaling Configuration
    # ========================================================================
    # Configure display scaling for high DPI displays
    # These settings ensure proper scaling across different displays
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";     # Auto-detect screen scaling
    QT_SCALE_FACTOR = "1";                 # Global scale factor
    QT_SCREEN_SCALE_FACTORS = "1";         # Per-screen scale factors

    NIXOS_OZONE_WL = "1"; # Improves Wayland support for many apps
    MOZ_ENABLE_WAYLAND = "1";
  };
}
 
