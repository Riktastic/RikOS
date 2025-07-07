# =============================================================================
# RTL-SDR Software Defined Radio Configuration Module
# =============================================================================
#
# Comprehensive support for RTL-SDR devices enabling low-cost software defined radio.
#
# What it does:
# - Enables RTL-SDR hardware support with drivers and firmware
# - Installs SDR software packages (rtl-sdr, gqrx, gnuradio)
# - Configures udev rules for non-root device access
# - Provides frequency range coverage (24 MHz to 1.7 GHz)
# - Supports 3.2 MHz bandwidth for signal reception
# - Enables receive-only operation for various signals
# - Installs specialized decoders (rtl_433, dump1090, wxtoimg)
#
# Requirements:
# - RTL-SDR hardware device (RTL2832U + R820T/R820T2)
# - USB 2.0 connectivity
# - Compatible antenna (SMA connector, 75 ohm)
# - Sufficient system resources for SDR processing
#
# Usage:
# - Imported by device configurations with RTL-SDR
# - Connect device via USB and launch SDR applications
# - Use gqrx for SDR receiver functionality
# - Use rtl_433 for IoT device decoding
# - Use dump1090 for ADS-B aircraft tracking
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # Hardware Enablement
  # ============================================================================
  # Enable RTL-SDR support in NixOS
  # This provides the necessary drivers and firmware
  hardware.rtl-sdr.enable = true;
  
  # ============================================================================
  # Software Package Installation
  # ============================================================================
  # Install essential SDR software packages
  environment.systemPackages = with pkgs; [
    rtl-sdr     # RTL-SDR command line tools and utilities
    gqrx        # SDR receiver application with GUI
    sdrangel    # Software radio toolkit and development framework
    # Optional packages - uncomment as needed:
    rtl_433    # Decode various IoT and sensor protocols
    # dump1090   # ADS-B aircraft tracking decoder
    # wxtoimg    # Weather satellite image decoder
    # cubicSDR   # Cross-platform SDR application
    # inspectrum # Signal analysis tool
    # multimon-ng # Decode various digital modes
    # gnuradio-with-packages # GNU Radio with additional packages
  ];

  # ============================================================================
  # User Permissions and udev Rules
  # ============================================================================
  # Add udev rules for RTL-SDR devices
  # This allows non-root users to access the devices
  services.udev.packages = with pkgs; [
    rtl-sdr     # Provides udev rules for RTL-SDR devices
  ];
  
  # ============================================================================
  # Optional: User Group Configuration
  # ============================================================================
  # Uncomment to add users to plugdev group for device access
  # users.users.rik.extraGroups = [ "plugdev" ];
  
  # ============================================================================
  # Optional: Custom udev Rules
  # ============================================================================
  # Uncomment to add custom udev rules for specific RTL-SDR models
  # services.udev.extraRules = ''
  #   # RTL-SDR specific rules
  #   SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE="0666"
  #   SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", TAG+="uaccess"
  #   # RTL-SDR Blog V3
  #   SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", ATTRS{serial}=="00000001", MODE="0666"
  # '';
  
  # ============================================================================
  # Optional: Frequency Range Restrictions
  # ============================================================================
  # Uncomment to restrict frequency ranges for compliance
  # environment.variables = {
  #   RTL_SDR_FREQ_MIN = "24000000";   # 24 MHz minimum
  #   RTL_SDR_FREQ_MAX = "1700000000"; # 1.7 GHz maximum
  # };
  
  # ============================================================================
  # Optional: Performance Tuning
  # ============================================================================
  # Uncomment to optimize RTL-SDR performance
  # boot.kernelParams = [
  #   "usbcore.usbfs_memory_mb=1024"  # Increase USB buffer size
  # ];
} 
