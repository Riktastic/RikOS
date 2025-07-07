# =============================================================================
# Gaming Software Module
# =============================================================================
#
# Provides gaming software and tools for NixOS 25.05 LTS.
#
# What it does:
# - Installs Steam, Lutris, and Proton-GE for gaming
# - Configures Wine and graphics translation layers (DXVK, VKD3D)
# - Sets up GameMode for performance optimization
# - Installs gaming fonts and utilities
#
# Requirements:
# - Hardware support (GPU drivers, OpenGL, audio) in hardware modules
# - Sufficient disk space for games and compatibility tools
#
# Usage:
# - Import in device configurations
# - Gaming software available in applications menu
# - Proton-GE available for Steam compatibility
# - GameMode optimizes performance during gaming
# =============================================================================

{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Package Installation
  # ============================================================================
  # Install gaming software and dependencies
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # Gaming Platforms
    # ========================================================================
    steam                    # Valve's gaming platform
    lutris                   # Game manager for multiple platforms

    # ========================================================================
    # Wine and Compatibility
    # ========================================================================
    wine                    # Windows compatibility layer
    winetricks             # Wine utilities and package manager

    # ========================================================================
    # Graphics Translation Layers
    # ========================================================================
    dxvk                    # DirectX to Vulkan translation
    vkd3d                   # DirectX 12 to Vulkan translation

    # ========================================================================
    # Gaming Utilities
    # ========================================================================
    gamemode                # Game optimization daemon
    mangohud                # FPS and system monitoring overlay
    goverlay                # MangoHud configuration GUI
  ];

  # ============================================================================
  # Steam Configuration
  # ============================================================================
  # Enable Steam with proper hardware support
  programs.steam = {
    enable = true;                    # Enable Steam
    remotePlay.openFirewall = true;   # Allow remote play connections
    dedicatedServer.openFirewall = true;  # Allow dedicated server connections
  };

  # ============================================================================
  # Font Configuration
  # ============================================================================
  # Install fonts commonly used in games
  fonts.packages = with pkgs; [
    # ========================================================================
    # Gaming Fonts
    # ========================================================================
    liberation_ttf          # Liberation fonts (Arial, Times, Courier equivalents)
    noto-fonts              # Google Noto fonts for international support
    noto-fonts-cjk-sans          # Chinese, Japanese, Korean fonts
    noto-fonts-emoji        # Emoji fonts
  ];

  # ============================================================================
  # Environment Variables
  # ============================================================================
  # Set environment variables for gaming applications
  environment.variables = {
    # ========================================================================
    # Wine Environment
    # ========================================================================
    WINEDLLOVERRIDES = "dxgi=n";  # Use native dxgi for better compatibility
  };

   # ========================================================================
   # GameMode Service
   # ========================================================================
   # GameMode optimizes system performance during gaming
   programs.gamemode = {
      enable = true;              # Enable GameMode service
      settings = {
        general = {
          # Performance settings for gaming
          renice = 10;            # Process priority adjustment
          ioprio = 0;             # I/O priority
        };
        cpu = {
          # CPU governor settings
          governor = "performance";  # Use performance governor
          energy_perf_preference = "performance";  # Energy performance preference
        };
        gpu = {
          # GPU performance settings
          apply_gpu_optimisations = "accept-responsibility";  # GPU optimizations
          gpu_device = 0;         # Primary GPU device
        };
     };
   };
}
