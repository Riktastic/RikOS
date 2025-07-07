# Not tested!

# =============================================================================
# AMD GPU Configuration Module
# =============================================================================
#
# Configures AMD GPU drivers and optimizations for performance and stability.
#
# What it does:
# - Installs open source AMDGPU drivers with performance optimizations
# - Enables DRM modesetting for Wayland/X11 support
# - Configures kernel parameters for maximum performance
# - Provides hardware acceleration and OpenGL/Vulkan support
# - Supports gaming and multimedia optimization
# - Installs monitoring tools (radeontop, glxinfo)
#
# Requirements:
# - Compatible AMD GPU (GCN, RDNA, Vega, Navi, etc.)
# - Sufficient system resources for GPU operations
# - X server enabled for display support
# - Compatible kernel modules
#
# Usage:
# - Imported by device configurations with AMD GPUs
# - Drivers automatically installed and configured
# - Use radeontop for GPU monitoring
# =============================================================================

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # AMD Driver Configuration
  # ============================================================================
  # Configure AMDGPU open source drivers with performance optimizations
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For Steam and legacy 32-bit apps
  };

  hardware.graphics.extraPackages = with pkgs; [ mesa.drivers vaapiVdpau libvdpau-va-gl ];
  hardware.graphics.extraPackages32 = with pkgs; [ mesa.drivers vaapiVdpau libvdpau-va-gl ];

  # ============================================================================
  # Boot Optimizations
  # ============================================================================
  # Enable early KMS for faster boot and better graphics performance
  boot.initrd.kernelModules = [
    "amdgpu"  # AMD graphics driver
  ];

  # ============================================================================
  # Kernel Parameters
  # ============================================================================
  # Configure kernel parameters for AMD GPU optimization
  # These parameters enhance performance and stability
  boot.kernelParams = [
    # Enable DC (Display Core) for modern display protocols (default on recent kernels)
    "amdgpu.dc=1"

    # Enable performance tuning (overclocking, fan control, etc.) if supported
    # Uncomment the next line to allow overclocking via sysfs (use with caution)
    # "amdgpu.ppfeaturemask=0xffffffff"
  ];

  # ============================================================================
  # Monitoring Tools
  # ============================================================================
  # Install AMD GPU monitoring and diagnostic tools
  environment.systemPackages = with pkgs; [
    radeontop   # AMD GPU utilization monitoring
    glxinfo     # OpenGL information and diagnostic tool
    vulkan-tools # Vulkan info and diagnostics (vulkaninfo)
  ];

  # ============================================================================
  # Optional: Enable firmware for newer AMD GPUs
  # ============================================================================
  hardware.amdgpu = {
    # Most users should leave this as default (auto-detects needed firmware)
    # Uncomment for troubleshooting or to force firmware loading
    # firmware = "all";
  };
}
