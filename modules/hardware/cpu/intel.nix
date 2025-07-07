# =============================================================================
# Intel CPU Hardware Configuration Module
# =============================================================================
#
# Intel CPU-specific optimizations and configurations for performance and stability.
#
# What it does:
# - Configures Intel P-state driver for power management
# - Enables CPU microcode updates for security and stability
# - Sets performance governor for maximum CPU speed
# - Implements thermal management with DPTF framework
# - Configures kernel parameters for optimal performance
# - Installs Intel GPU tools for hardware monitoring
# - Provides thermal protection and monitoring
#
# Requirements:
# - Compatible Intel CPU
# - Intel P-state driver support
# - Thermal management capabilities
# - Sufficient cooling for performance mode
#
# Usage:
# - Imported by device configurations with Intel CPUs
# - CPU optimizations applied automatically on boot
# - Thermal management starts automatically
# - Use intel-gpu-tools for hardware monitoring
# =============================================================================

# Intel CPU
#
# This module contains Intel CPU specific optimizations for better performance
# while maintaining stability on NixOS 25.05 LTS.

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # Kernel Parameters
  # ============================================================================
  # Intel CPU specific kernel parameters for optimal performance
  boot.kernelParams = [
    # ========================================================================
    # Intel P-state Driver Configuration
    # ========================================================================
    # Enable Intel P-state driver for advanced power management
    "intel_pstate=active"
    
    # ========================================================================
    # CPU State Management
    # ========================================================================
    # Enable Intel CPU performance features and state control
    "intel_idle.max_cstate=1"     # Limit maximum C-state for performance
    "processor.max_cstate=1"      # Limit processor C-state for stability
    
    # ========================================================================
    # Security and Performance Trade-offs
    # ========================================================================
    # Enable Intel CPU mitigations (more secure but slightly slower)
    # Uncomment the following line if you want maximum performance over security
    "mitigations=on"  # Disables security mitigations for maximum performance

    # ========================================================================
    # CPU Performance Optimizations
    # ========================================================================
    "intel_idle.max_cstate=1"     # Limit Intel CPU C-states
  ];

  # ============================================================================
  # CPU Microcode Updates
  # ============================================================================
  # Enable Intel CPU microcode updates for security and stability
  # These updates fix hardware bugs and security vulnerabilities
  hardware.cpu.intel.updateMicrocode = true;

  # ============================================================================
  # Power Management Configuration
  # ============================================================================
  # Configure Intel CPU power management for optimal performance
  powerManagement = {
    # ========================================================================
    # CPU Frequency Governor
    # ========================================================================
    # Use performance governor for maximum CPU speed
    # Alternative options: "powersave", "ondemand", "conservative"
    cpuFreqGovernor = "performance";
    
    # ========================================================================
    # SCSI Link Power Management
    # ========================================================================
    # Use maximum performance setting for SCSI links
    # This disables SCSI link power saving for best speed
    scsiLinkPolicy = "max_performance";
  };

  # ============================================================================
  # Hardware Monitoring Tools
  # ============================================================================
  # Install Intel CPU monitoring and diagnostic tools
  environment.systemPackages = with pkgs; [
    intel-gpu-tools  # Intel GPU and CPU monitoring utilities
  ];

  # ============================================================================
  # Thermal Management Service
  # ============================================================================
  # Enable Intel CPU thermal management with DPTF
  services.thermald = {
    enable = true;    # Enable thermal daemon for Intel CPUs
    
    # ========================================================================
    # Thermal Configuration
    # ========================================================================
    # Configure Dynamic Platform and Thermal Framework (DPTF)
    # This provides advanced thermal management for Intel processors
    configFile = pkgs.writeText "thermal-conf.xml" ''
      <?xml version="1.0"?>
      <!-- ================================================================ -->
      <!-- Intel CPU Thermal Management Configuration -->
      <!-- ================================================================ -->
      <!-- This configuration defines thermal zones and trip points for -->
      <!-- optimal CPU thermal management and protection -->
      <ThermalConfiguration>
        <Platform>
          <!-- ============================================================ -->
          <!-- Platform Information -->
          <!-- ============================================================ -->
          <Name>Intel CPU Thermal Management</Name>
          <ProductName>Intel CPU</ProductName>
          <Preference>PERFORMANCE</Preference>
          
          <!-- ============================================================ -->
          <!-- Thermal Zones Configuration -->
          <!-- ============================================================ -->
          <ThermalZones>
            <ThermalZone>
              <!-- ======================================================== -->
              <!-- CPU Thermal Zone -->
              <!-- ======================================================== -->
              <Type>CPU</Type>
              <TripPoints>
                <!-- ==================================================== -->
                <!-- Passive Cooling Trip Point -->
                <!-- ==================================================== -->
                <!-- Triggers passive cooling at 85°C -->
                <TripPoint>
                  <Temperature>85</Temperature>
                  <Type>passive</Type>
                </TripPoint>
                
                <!-- ==================================================== -->
                <!-- Critical Temperature Trip Point -->
                <!-- ==================================================== -->
                <!-- Triggers critical action at 95°C -->
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
