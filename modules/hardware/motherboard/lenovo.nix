# =============================================================================
# Lenovo Motherboard Hardware Configuration Module
# =============================================================================
#
# Lenovo motherboard-specific hardware monitoring and configuration for optimal performance.
#
# What it does:
# - Loads kernel modules for Lenovo motherboard hardware monitoring
# - Configures temperature and voltage monitoring (coretemp, nct6775)
# - Enables Lenovo WMI support for hardware management
# - Sets up audio subsystem with Intel HD Audio
# - Installs hardware monitoring tools (lm_sensors, ethtool, pavucontrol)
# - Configures ACPI resource enforcement for better hardware access
# - Provides sensor configuration for lm_sensors compatibility
#
# Requirements:
# - Compatible Lenovo motherboard (ThinkPad, ThinkCentre, IdeaCentre, Legion and similar)
# - Intel/AMD chipset with Nuvoton sensor support
# - Lenovo WMI interface support
# - Compatible audio subsystem
#
# Usage:
# - Imported by device configurations with Lenovo motherboards
# - Kernel modules loaded automatically on boot
# - Use lm_sensors for hardware monitoring
# - Use pavucontrol for audio management
# =============================================================================

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # Kernel Modules
  # ============================================================================
  # Load necessary kernel modules for Lenovo motherboard hardware monitoring
  # These modules provide access to temperature sensors, fan controls, and
  # other hardware monitoring features specific to Lenovo motherboards
  boot.kernelModules = [
    # ========================================================================
    # Temperature Monitoring
    # ========================================================================
    "coretemp"      # Intel CPU temperature monitoring driver
    
    # ========================================================================
    # Motherboard Sensors
    # ========================================================================
    "nct6775"       # Nuvoton hardware monitoring chip driver
    "nct6779"       # Nuvoton hardware monitoring chip driver (newer models)
    
    # ========================================================================
    # Lenovo-Specific Hardware
    # ========================================================================
    "lenovo_wmi"    # Lenovo Windows Management Instrumentation driver
    
    # ========================================================================
    # Audio Subsystem
    # ========================================================================
    "snd_hda_intel" # Intel High Definition Audio driver
  ];

  # ============================================================================
  # Kernel Parameters
  # ============================================================================
  # For Lenovo motherboards, these kernel parameters are often needed for full
  # sensor access and hardware monitoring functionality
  boot.kernelParams = [
    # ========================================================================
    # ACPI Resource Enforcement
    # ========================================================================
    # Relax ACPI resource enforcement for better hardware access
    # This allows access to hardware monitoring features that might be
    # restricted by strict ACPI resource enforcement
    "acpi_enforce_resources=lax"
  ];

  # ============================================================================
  # Sensor Configuration
  # ============================================================================
  # Create lm_sensors configuration for Lenovo motherboard compatibility
  # This provides compatibility with lm_sensors and other monitoring tools
  environment.etc."sysconfig/lm_sensors".text = ''
    # ========================================================================
    # Lenovo Motherboard Hardware Monitoring Configuration
    # ========================================================================
    # Generated by NixOS module for Lenovo ThinkPad, ThinkCentre, IdeaCentre, Legion and similar motherboards
    # This configuration enables hardware monitoring modules for temperature,
    # voltage, and fan speed monitoring on Lenovo motherboards
    HWMON_MODULES="coretemp nct6775 nct6779"
  '';

  # ============================================================================
  # Hardware Monitoring Tools
  # ============================================================================
  # Install comprehensive hardware monitoring and diagnostic tools
  # These tools provide system health monitoring, network diagnostics,
  # and audio control capabilities
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # Hardware Monitoring
    # ========================================================================
    lm_sensors    # Hardware monitoring and sensor utilities
    
    # ========================================================================
    # Network Monitoring
    # ========================================================================
    ethtool       # Network interface monitoring and configuration
    
    # ========================================================================
    # Audio Control
    # ========================================================================
    pavucontrol   # PulseAudio volume control and monitoring
  ];
} 