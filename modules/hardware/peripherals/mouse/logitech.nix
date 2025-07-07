# =============================================================================
# Logitech Mouse Configuration Module
# =============================================================================
#
# Comprehensive configuration for Logitech mice and input devices with libinput support.
#
# What it does:
# - Enables libinput for modern input device handling
# - Configures adaptive acceleration profile for optimal mouse performance
# - Enables natural scrolling for touchpads
# - Installs Solaar for wireless Logitech device management
# - Provides Piper for gaming mouse configuration
# - Supports high DPI tracking and programmable buttons
# - Enables battery monitoring for wireless devices
# - Configures udev rules for device detection
#
# Requirements:
# - Compatible Logitech mouse hardware
# - libinput driver support
# - USB or wireless connectivity
# - Compatible kernel modules
#
# Usage:
# - Imported by device configurations with Logitech mice
# - libinput configured automatically on boot
# - Use solaar for wireless device management
# - Use piper for gaming mouse configuration
# =============================================================================

# hardware/peripherals/mouse/logitech.nix
# Configuration for Logitech mice
#
# This configuration enables:
# - Modern mouse input handling (libinput)
# - Logitech device management
# - Mouse configuration tools
#
# Supported Logitech mouse features:
# - High DPI tracking
# - Programmable buttons
# - On-board memory
# - Wireless connectivity (on wireless models)
# - Battery monitoring (on wireless models)
#
# Common applications:
# - Solaar: Wireless device management
# - Piper: Gaming mouse configuration
# - Logitech G Hub (via Wine, if needed)

{ config, pkgs, ... }:

{
  # ============================================================================
  # Libinput Configuration
  # ============================================================================
  # Enable libinput for modern input device handling
  # libinput provides unified input device support for mice, touchpads, and other input devices
  services.libinput.enable = true;

  # ============================================================================
  # Mouse Configuration
  # ============================================================================
  # Configure mouse-specific settings for optimal performance
  services.libinput.mouse = {
    # ========================================================================
    # Acceleration Profile
    # ========================================================================
    # Use adaptive acceleration profile for general use
    # Change to "flat" for gaming mice that prefer linear acceleration
    # Adaptive profile provides natural mouse movement with acceleration
    accelProfile = "adaptive";  # Options: "adaptive", "flat"
    
    # ========================================================================
    # Additional Mouse Options
    # ========================================================================
    # Add more mouse-specific options as needed
    # Examples: sensitivity, button mapping, scroll speed
  };

  # ============================================================================
  # Touchpad Configuration
  # ============================================================================
  # Configure touchpad settings for laptops and touchpad-equipped devices
  services.libinput.touchpad = {
    # ========================================================================
    # Natural Scrolling
    # ========================================================================
    # Enable natural scrolling for touchpads
    # This provides intuitive scrolling direction similar to mobile devices
    naturalScrolling = true;
    
    # ========================================================================
    # Additional Touchpad Options
    # ========================================================================
    # Add more touchpad-specific options as needed
    # Examples: tap-to-click, palm detection, gesture support
  };

  # ============================================================================
  # Logitech Device Management Tools
  # ============================================================================
  # Install Logitech device management and configuration tools
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # Wireless Device Management
    # ========================================================================
    # Solaar for wireless Logitech device management
    # Provides battery monitoring, device pairing, and wireless receiver management
    solaar
    
    # ========================================================================
    # Gaming Mouse Configuration
    # ========================================================================
    # Piper for gaming mouse configuration GUI
    # Allows configuration of DPI, buttons, RGB lighting, and macros
    piper
  ];

  # ============================================================================
  # Udev Rules for Device Detection
  # ============================================================================
  # Enable udev rules for Solaar to support wireless Logitech devices
  # This allows automatic detection and management of wireless Logitech peripherals
  services.udev.packages = with pkgs; [
    solaar  # Provides udev rules for Logitech wireless device detection
  ];
}
