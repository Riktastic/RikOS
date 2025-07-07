# NOT Tested!

# =============================================================================
# AMD CPU Hardware Configuration Module
# =============================================================================
#
# AMD CPU-specific optimizations and configurations for performance and stability.
#
# What it does:
# - Configures AMD CPU frequency scaling driver for power management
# - Enables CPU microcode updates for security and stability
# - Sets performance governor for maximum CPU speed
# - Implements thermal management with k10temp and thermald
# - Configures kernel parameters for optimal performance
# - Installs AMD monitoring tools for hardware monitoring
# - Provides thermal protection and monitoring
#
# Requirements:
# - Compatible AMD CPU
# - AMD CPUFreq driver support
# - Thermal management capabilities (k10temp, thermald)
# - Sufficient cooling for performance mode
#
# Usage:
# - Imported by device configurations with AMD CPUs
# - CPU optimizations applied automatically on boot
# - Thermal management starts automatically
# - Use lm_sensors and monitoring tools for hardware monitoring
# =============================================================================

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # Kernel Parameters
  # ============================================================================
  # AMD CPU specific kernel parameters for optimal performance
  boot.kernelParams = [
    # ========================================================================
    # AMD CPUFreq Driver Configuration
    # ========================================================================
    # Use amd_pstate driver if supported (Zen 2/3/4, Linux 6.1+)
    "amd_pstate=active"

    # ========================================================================
    # CPU State Management
    # ========================================================================
    # Limit maximum C-state for performance (optional, may reduce idle power savings)
    "processor.max_cstate=1"
    "idle=nomwait" # Optional: disables mwait-based C-states for some AMD CPUs

    # ========================================================================
    # Security and Performance Trade-offs
    # ========================================================================
    # Enable AMD CPU mitigations (more secure but slightly slower)
    # Uncomment the following line if you want maximum performance over security
    "mitigations=on"

    # ========================================================================
    # CPU Performance Optimizations
    # ========================================================================
    "amd_idle.max_cstate=1"     # Limit AMD CPU C-states
  ];

  # ============================================================================
  # CPU Microcode Updates
  # ============================================================================
  # Enable AMD CPU microcode updates for security and stability
  hardware.cpu.amd.updateMicrocode = true;

  # ============================================================================
  # Power Management Configuration
  # ============================================================================
  # Configure AMD CPU power management for optimal performance
  powerManagement = {
    # ========================================================================
    # CPU Frequency Governor
    # ========================================================================
    # Use performance governor for maximum CPU speed
    cpuFreqGovernor = "performance";

    # ========================================================================
    # SCSI Link Power Management
    # ========================================================================
    # Use maximum performance setting for SCSI links
    scsiLinkPolicy = "max_performance";
  };

  # ============================================================================
  # Hardware Monitoring Tools
  # ============================================================================
  # Install AMD CPU monitoring and diagnostic tools
  environment.systemPackages = with pkgs; [
    lm_sensors        # Hardware monitoring (includes k10temp for AMD)
    cpupower          # CPU frequency and power tuning
    stress-ng         # CPU stress testing and diagnostics
  ];

  # ============================================================================
  # Thermal Management Service
  # ============================================================================
  # Enable thermal management with thermald (works with k10temp on AMD)
  services.thermald = {
    enable = true;    # Enable thermal daemon for AMD CPUs

    # ========================================================================
    # Thermal Configuration
    # ========================================================================
    # Use a custom configuration file if needed (optional)
    configFile = pkgs.writeText "thermal-conf.xml" ''
      <?xml version="1.0"?>
      <!-- ================================================================ -->
      <!-- AMD CPU Thermal Management Configuration -->
      <!-- ================================================================ -->
      <ThermalConfiguration>
        <Platform>
          <Name>AMD CPU Thermal Management</Name>
          <ProductName>AMD CPU</ProductName>
          <Preference>PERFORMANCE</Preference>
          <ThermalZones>
            <ThermalZone>
              <Type>CPU</Type>
              <TripPoints>
                <TripPoint>
                  <Temperature>85</Temperature>
                  <Type>passive</Type>
                </TripPoint>
                <TripPoint>
                  <Temperature>95</Temperature>
                  <Type>critical</Type>
                </TripPoint>
              </TripPoints>
            </ThermalZone>
          </ThermalZones>
        </Platform>
      </ThermalConfiguration>
    '';
  };
}
