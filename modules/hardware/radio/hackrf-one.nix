# =============================================================================
# HackRF One Software Defined Radio Configuration Module
# =============================================================================
#
# Comprehensive support for the HackRF One Software Defined Radio (SDR) device.
#
# What it does:
# - Enables HackRF One hardware support with drivers and firmware
# - Installs SDR software packages (hackrf, gqrx, gnuradio)
# - Configures udev rules for non-root device access
# - Provides frequency range coverage (1 MHz to 6 GHz)
# - Supports 20 MHz bandwidth for signal analysis
# - Enables transmit and receive capabilities
# - Installs command-line tools and GUI applications
#
# Requirements:
# - HackRF One hardware device
# - USB 2.0 connectivity
# - Compatible antenna (SMA connector, 50 ohm)
# - Sufficient system resources for SDR processing
#
# Usage:
# - Imported by device configurations with HackRF One
# - Connect device via USB and launch SDR applications
# - Use gqrx for SDR receiver functionality
# - Use gnuradio for custom signal processing
# - Check local regulations before transmitting
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # Hardware Enablement
  # ============================================================================
  # Enable HackRF One support in NixOS
  # This provides the necessary drivers and firmware
  hardware.hackrf.enable = true;
  
  # ============================================================================
  # Software Package Installation
  # ============================================================================
  # Install essential SDR software packages
  environment.systemPackages = with pkgs; [
    hackrf      # HackRF command line tools and utilities
    sdrangel        # SDR receiver application with GUI
    gnuradio    # Software radio toolkit and development framework
    # Optional packages - uncomment as needed:
    # cubicSDR   # Cross-platform SDR application
    # inspectrum # Signal analysis tool
    # rtl_433    # Decode various RF protocols
    # multimon-ng # Decode various digital modes
  ];

  # ============================================================================
  # User Permissions and udev Rules
  # ============================================================================
  # Add udev rules for HackRF One
  # This allows non-root users to access the device
  services.udev.packages = with pkgs; [
    hackrf      # Provides udev rules for HackRF devices
  ];
  
  # ============================================================================
  # Optional: User Group Configuration
  # ============================================================================
  # Uncomment to add users to plugdev group for device access
  # users.users.rik.extraGroups = [ "plugdev" ];
  
  # ============================================================================
  # Optional: Custom udev Rules
  # ============================================================================
  # Uncomment to add custom udev rules for specific configurations
  # services.udev.extraRules = ''
  #   # HackRF One specific rules
  #   SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6089", MODE="0666"
  #   SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6089", TAG+="uaccess"
  # '';
  
  # ============================================================================
  # Optional: Frequency Range Restrictions
  # ============================================================================
  # Uncomment to restrict frequency ranges for compliance
  # environment.variables = {
  #   HACKRF_FREQ_MIN = "2400000000";  # 2.4 GHz minimum
  #   HACKRF_FREQ_MAX = "2483500000";  # 2.4 GHz maximum
  # };
} 
