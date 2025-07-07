# =============================================================================
# Logitech Webcam Configuration Module
# =============================================================================
#
# Comprehensive support for Logitech webcams and USB video devices with UVC driver.
#
# What it does:
# - Enables UVC (USB Video Class) driver for USB webcams
# - Installs v4l2loopback for virtual video device support
# - Provides Video4Linux2 (V4L2) framework integration
# - Supports HD video capture and built-in microphones
# - Enables compatibility with webcam applications
# - Configures kernel modules for webcam functionality
# - Provides optional utilities and user permissions
#
# Requirements:
# - Compatible Logitech webcam hardware (C270, C920, C922, Brio, etc.)
# - USB connectivity for webcam
# - UVC driver support
# - Video4Linux2 framework
#
# Usage:
# - Imported by device configurations with Logitech webcams
# - Webcam automatically detected and configured
# - Access via /dev/video* devices
# - Use v4l2-ctl --list-devices to verify detection
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # Kernel Module Configuration
  # ============================================================================
  # Enable UVC (USB Video Class) driver
  # This is the standard driver for most USB webcams including Logitech
  boot.kernelModules = [ 
    "uvcvideo"      # USB Video Class driver
    "v412loopback"  # Virtual video device support
  ];
  
  # Install additional kernel modules for enhanced functionality
  boot.extraModulePackages = with config.boot.kernelPackages; [ 
    v4l2loopback    # Virtual video device kernel module
  ];
  
  # ============================================================================
  # System Packages (Optional)
  # ============================================================================
  # Uncomment to install webcam utilities system-wide
  # environment.systemPackages = with pkgs; [
  #   v4l-utils      # Video4Linux utilities (v4l2-ctl, etc.)
  #   cheese         # GNOME webcam viewer
  #   guvcview       # GTK+ webcam viewer
  # ];
  
  # ============================================================================
  # User Permissions (Optional)
  # ============================================================================
  # Uncomment to add users to video group for webcam access
  # users.users.rik.extraGroups = [ "video" ];
  
  # ============================================================================
  # udev Rules (Optional)
  # ============================================================================
  # Uncomment to add custom udev rules for specific webcam models
  # services.udev.extraRules = ''
  #   # Logitech webcam specific rules
  #   SUBSYSTEM=="video4linux", ATTRS{idVendor}=="046d", MODE="0666"
  # '';
} 
