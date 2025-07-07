# =============================================================================
# Generic Keyboard Configuration Module
# =============================================================================
#
# General keyboard configuration and layout settings for standard keyboards.
#
# What it does:
# - Configures system-wide US keyboard layout for X11 and console
# - Applies ergonomic remapping (Caps Lock → Control)
# - Installs keyboard diagnostic tools (xev, xmodmap)
# - Ensures consistent keyboard behavior across X11 and TTY
# - Provides XKB layout system integration
# - Supports layout switching and customization
# - Enables keyboard event monitoring and troubleshooting
#
# Requirements:
# - X server enabled for X11 keyboard features
# - Standard keyboard hardware
# - Compatible XKB layout support
# - Console keymap support
#
# Usage:
# - Imported by device configurations automatically
# - Keyboard layout applied system-wide on boot
# - Use xev for keyboard event diagnostics
# - Use xmodmap for custom key remapping
# =============================================================================

# hardware/peripherals/keyboard/generic.nix
# General keyboard configuration for NixOS
#
# Features:
# - Sets system-wide keyboard layout (default: US)
# - Applies ergonomic remapping (default: Caps Lock → Control)
# - Installs diagnostic and configuration tools
#
# Suitable for most standard keyboards. Advanced features
# (macros, backlighting, polling rate) are typically set on
# the keyboard itself if supported.

{ config, pkgs, ... }:

{
  # ============================================================================
  # X11 Keyboard Configuration
  # ============================================================================
  # Configure X server keyboard settings for system-wide keyboard layout
  services.xserver.xkb = {
    # ========================================================================
    # Keyboard Layout
    # ========================================================================
    # Set US keyboard layout as default
    # This provides standard QWERTY layout for most users
    layout = "us";
    
    # ========================================================================
    # Layout Variant
    # ========================================================================
    # No special variant - use standard US layout
    # Variants can include Dvorak, Colemak, or other specialized layouts
    variant = "";
    
    # ========================================================================
    # Ergonomic Options
    # ========================================================================
    # Map Caps Lock key to Control for better ergonomics
    # This reduces finger strain and improves typing efficiency
    options = "ctrl:nocaps";
  };

  # ============================================================================
  # Console Keyboard Configuration
  # ============================================================================
  # Configure console keymap for TTY terminals to match X11 layout
  # This ensures consistent keyboard behavior across X11 and console
  console.keyMap = "us";

  # ============================================================================
  # Keyboard Diagnostic Tools
  # ============================================================================
  # Install useful keyboard tools for diagnostics and configuration
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # X Event Viewer
    # ========================================================================
    # X event viewer for keyboard diagnostics and troubleshooting
    # Shows real-time X events including key presses and releases
    xorg.xev
    
    # ========================================================================
    # X Key Remapping Tool
    # ========================================================================
    # X key remapping tool for custom keyboard configurations
    # Allows advanced key remapping and customization
    xorg.xmodmap
  ];
}
