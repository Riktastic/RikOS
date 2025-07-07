# Not tested!

# =============================================================================
# Intel GPU Configuration Module (Main GPU)
# =============================================================================
#
# Configures Intel integrated graphics as the primary GPU for NixOS 25.05+.
#
# Features:
# - Installs Intel Mesa drivers and Vulkan support
# - Enables hardware acceleration (OpenGL, VA-API, Vulkan, QuickSync)
# - Installs monitoring tools (intel-gpu-tools, glxinfo, vulkan-tools)
# - Optimizes kernel parameters for stability and performance
#
# Requirements:
# - Intel iGPU (HD Graphics, Iris, Xe, Arc, etc.)
# - No discrete GPU, or you want to use Intel as main display
#
# Usage:
# - Import in systems where Intel is the primary GPU
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # X Server Video Drivers
  # ============================================================================
  # Use "modesetting" for modern Intel GPUs (recommended), "intel" for legacy.
  # Including both is safe for compatibility.
  services.xserver.videoDrivers = [ "intel" "modesetting" ];

  # ============================================================================
  # OpenGL, VA-API, and Vulkan Support
  # ============================================================================
  # NOTE: hardware.opengl is deprecated in NixOS 25.05+; use hardware.graphics instead.
  hardware.graphics = {
    enable = true;

    # Extra packages for hardware acceleration and video decoding
    extraPackages = with pkgs; [
      intel-media-driver   # VA-API driver for Broadwell (Gen8) and newer, including Arc GPUs[1][4][6]
      vaapiIntel           # VA-API driver for pre-Broadwell (legacy)
      vaapiVdpau           # VA-API to VDPAU bridge
      libvdpau-va-gl       # VDPAU to OpenGL bridge
      vulkan-loader        # Vulkan loader and utilities
      mesa.drivers         # Mesa OpenGL/Vulkan drivers (safe for all vendors)
    ];

    # 32-bit support for Steam, Wine, etc.
    extraPackages32 = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      vulkan-loader
      mesa.drivers
    ];
  };

  # ============================================================================
  # Boot Optimizations
  # ============================================================================
  # Load Intel graphics driver early for faster boot and better graphics performance
  boot.initrd.kernelModules = [
    "i915"    # Intel graphics kernel module
  ];

  # Kernel parameters for improved display initialization and optional firmware
  boot.kernelParams = [
    "i915.fastboot=1"     # Faster display initialization
    # "i915.enable_guc=2" # Enable GuC/HuC firmware for newer chips (uncomment if supported)
  ];

  # ============================================================================
  # Monitoring and Diagnostic Tools
  # ============================================================================
  environment.systemPackages = with pkgs; [
    intel-gpu-tools   # Intel GPU monitoring and diagnostics
    glxinfo           # OpenGL information tool
    vulkan-tools      # Vulkan info and diagnostics (vulkaninfo)
  ];

  # ============================================================================
  # Environment Variables for VA-API/QuickSync (Recommended)
  # ============================================================================
  # Set the correct VA-API driver for modern Intel GPUs (iHD = intel-media-driver)
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    # Optionally, set LIBVA_DRIVERS_PATH if you use custom driver locations
    # LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
  };

  # ============================================================================
  # User Group for GPU Access (Recommended)
  # ============================================================================
  # Ensure users needing hardware acceleration are in "video" and "render" groups
  # users.users.<yourusername>.extraGroups = [ "video" "render" ];
}
