# Not tested!

# =============================================================================
# Intel GPU Offload Configuration Module (Secondary GPU)
# =============================================================================
#
# Configures Intel integrated graphics for offloading (PRIME) with a discrete GPU.
#
# What it does:
# - Installs Intel Mesa drivers and Vulkan support
# - Sets up X server for offloading (PRIME Render Offload)
# - Installs monitoring tools
# - Provides example of running apps on the Intel GPU
#
# Requirements:
# - Intel iGPU present (HD Graphics, Iris, Xe, Arc, etc.)
# - Discrete GPU (AMD or NVIDIA) as main display
#
# Usage:
# - Import in systems with both discrete and Intel GPUs
# - Use DRI_PRIME=1 to run apps on Intel GPU
# =============================================================================

{ config, pkgs, ... }:

{
  # Use main GPU driver first, then "modesetting" for Intel offload
  # Example: [ "nvidia" "modesetting" ] or [ "amdgpu" "modesetting" ]
  services.xserver.videoDrivers = [ "amdgpu" "modesetting" ];

  hardware.graphics.extraPackages = with pkgs; [ mesa.drivers vaapiVdpau libvdpau-va-gl ];
  hardware.graphics.extraPackages32 = with pkgs; [ mesa.drivers vaapiVdpau libvdpau-va-gl ];


  environment.systemPackages = with pkgs; [
    intel-gpu-tools
    glxinfo
    vulkan-tools
  ];

  # Example usage for offloading:
  # Run an application on the Intel GPU:
  # $ DRI_PRIME=1 glxinfo | grep "OpenGL renderer"
  # $ DRI_PRIME=1 firefox

  # Optionally, you can add a script or alias for convenience:
  environment.shellAliases = {
    intel-run = "DRI_PRIME=1";
  };
}
