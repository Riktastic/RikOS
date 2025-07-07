# =============================================================================
# NVIDIA GPU Configuration Module
# =============================================================================
#
# Configures NVIDIA GPU drivers and optimizations for performance and stability.
#
# What it does:
# - Installs proprietary NVIDIA drivers with performance optimizations
# - Enables DRM modesetting for Wayland/X11 support
# - Configures kernel parameters for maximum performance
# - Provides hardware acceleration and OpenGL support
# - Supports CUDA, gaming, and multimedia optimization
# - Installs monitoring tools (nvidia-smi, glxinfo)
#
# Requirements:
# - Compatible NVIDIA GPU (GeForce, Quadro, Tesla, RTX, GTX)
# - Sufficient system resources for GPU operations
# - X server enabled for display support
# - Compatible kernel modules
#
# Usage:
# - Imported by device configurations with NVIDIA GPUs
# - Drivers automatically installed and configured
# - Use nvidia-smi for GPU monitoring
# - Use nvidia-settings for configuration
# =============================================================================

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # NVIDIA Driver Configuration
  # ============================================================================
  # Configure NVIDIA proprietary drivers with performance optimizations
  hardware.nvidia = {
    # ========================================================================
    # Driver Package Selection
    # ========================================================================
    # Use the stable NVIDIA driver package
    # This provides the latest stable driver with security updates
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # ========================================================================
    # Power Management
    # ========================================================================
    # Configure NVIDIA power management features
    # Disabled by default for maximum performance
    powerManagement = {
      enable = false;  # Disable power management for performance
    };

    # ========================================================================
    # Display Configuration
    # ========================================================================
    # Enable DRM modesetting for modern display protocols
    # This provides better compatibility with Wayland and modern X11
    modesetting.enable = true;

    # ========================================================================
    # Open Source Alternative
    # ========================================================================
    # Use proprietary driver (not open source Nouveau)
    # Proprietary driver provides better performance and features
    open = false;

    # ========================================================================
    # NVIDIA Settings
    # ========================================================================
    # Enable NVIDIA settings application
    # Provides GUI for configuring NVIDIA-specific options
    nvidiaSettings = true;
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # ============================================================================
  # Boot Optimizations
  # ============================================================================
  # Enable early KMS for faster boot and better graphics performance
  boot.initrd.kernelModules = [
    "nvidia"  # NVIDIA graphics driver
  ];

  # ============================================================================
  # Kernel Parameters
  # ============================================================================
  # Configure kernel parameters for NVIDIA optimization
  # These parameters enhance performance and stability
  boot.kernelParams = [
    # ========================================================================
    # DRM Modesetting
    # ========================================================================
    # Enable NVIDIA DRM modesetting for modern display protocols
    # This provides better compatibility with Wayland and modern X11
    "nvidia-drm.modeset=1"

    # ========================================================================
    # Performance Optimization
    # ========================================================================
    # Override maximum performance settings
    # This ensures the GPU runs at maximum performance
    "nvidia.NVreg_RegistryDwords=OverrideMaxPerf=0x1"

    # ========================================================================
    # Power Management
    # ========================================================================
    # Enable page attribute table for power management
    # This optimizes memory access patterns
    "nvidia.NVreg_UsePageAttributeTable=1"

    # ========================================================================
    # Memory Management
    # ========================================================================
    # Optimize system memory allocations
    # This improves memory management and reduces latency
    "nvidia.NVreg_InitializeSystemMemoryAllocations=1"
  ];

  # ============================================================================
  # Monitoring Tools
  # ============================================================================
  # Install NVIDIA monitoring and diagnostic tools
  # These tools provide insights into GPU performance and status
  environment.systemPackages = with pkgs; [
    glxinfo  # OpenGL information and diagnostic tool
  ];

  # ============================================================================
  # X Server Configuration
  # ============================================================================
  # Configure X server to use NVIDIA driver
  # This ensures proper driver loading and initialization
  services.xserver.videoDrivers = [ "nvidia" ];
}
