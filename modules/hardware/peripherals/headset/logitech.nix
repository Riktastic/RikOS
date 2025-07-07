# =============================================================================
# Logitech Headset Configuration Module
# =============================================================================
#
# Comprehensive configuration for Logitech headsets and audio peripherals with PipeWire.
#
# What it does:
# - Configures PipeWire for modern audio processing with ALSA compatibility
# - Enables Bluetooth connectivity for wireless headsets
# - Installs audio management tools (pavucontrol, pamixer, blueman)
# - Provides 32-bit audio application support
# - Sets up PulseAudio compatibility server
# - Configures low-latency audio processing
# - Enables battery monitoring for wireless devices
# - Supports gaming audio optimization and noise cancellation
#
# Requirements:
# - Compatible Logitech headset hardware
# - Bluetooth adapter for wireless headsets
# - PipeWire audio system support
# - Sufficient system resources for audio processing
#
# Usage:
# - Imported by device configurations with Logitech headsets
# - PipeWire configured automatically on boot
# - Use pavucontrol for audio device management
# - Use blueman for Bluetooth device management
# =============================================================================

# hardware/peripherals/headset/logitech.nix
# Configuration for Logitech headset
#
# This configuration enables:
# - Full PipeWire support
# - Bluetooth connectivity
# - Audio control utilities
#
# Common Logitech headset features:
# - High-quality audio
# - Noise-cancelling microphone
# - Volume controls
# - Mute button
# - Bluetooth connectivity (on wireless models)
#
# Supported features:
# - Audio playback
# - Microphone input
# - Volume control
# - Bluetooth audio
# - Audio device switching

{ config, pkgs, ... }:

{
  # ============================================================================
  # PipeWire Audio System
  # ============================================================================
  # Configure PipeWire for comprehensive audio support
  services.pipewire = {
    enable = true;                      # Enable PipeWire audio system
    
    # ========================================================================
    # Audio Support
    # ========================================================================
    # Enable audio processing and routing
    # Provides high-quality, low-latency audio processing
    audio.enable = true;
    
    # ========================================================================
    # ALSA Compatibility
    # ========================================================================
    # Enable ALSA compatibility layer
    # Ensures compatibility with ALSA-based applications
    alsa.enable = true;
    
    # ========================================================================
    # 32-bit Audio Support
    # ========================================================================
    # Enable 32-bit audio application support
    # Required for some legacy audio applications and games
    alsa.support32Bit = true;
    
    # ========================================================================
    # PulseAudio Compatibility
    # ========================================================================
    # Enable PulseAudio compatibility server
    # Provides compatibility for PulseAudio-based applications
    pulse.enable = true;
    
    # ========================================================================
    # JACK Support
    # ========================================================================
    # Disable JACK by default (enable if using JACK applications)
    # JACK provides professional audio routing capabilities
    jack.enable = false;
  };

  # ============================================================================
  # Bluetooth Configuration
  # ============================================================================
  # Configure Bluetooth for wireless headset connectivity
  hardware.bluetooth = {
    enable = true;                      # Enable Bluetooth support
    
    # ========================================================================
    # Power Management
    # ========================================================================
    # Enable Bluetooth on boot for automatic device connectivity
    powerOnBoot = true;
    
    # ========================================================================
    # Bluetooth Settings
    # ========================================================================
    # Configure Bluetooth for optimal headset performance
    settings = {
      General = {
        # ================================================================
        # Fast Connection
        # ================================================================
        # Enable fast connection and reconnection
        # Improves user experience with wireless headsets
        FastConnectable = true;
        
        # ================================================================
        # Experimental Features
        # ================================================================
        # Enable experimental features for battery reporting
        # Allows monitoring of headset battery levels
        Experimental = true;
      };
    };
  };

  # ============================================================================
  # Bluetooth Management
  # ============================================================================
  # Enable Blueman for Bluetooth device management
  # Provides GUI for Bluetooth device pairing and management
  services.blueman.enable = true;

  # ============================================================================
  # Audio and Headset Utilities
  # ============================================================================
  # Install comprehensive audio and headset management tools
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # Audio Control
    # ========================================================================
    # PulseAudio Volume Control for audio device management
    # Provides GUI for volume control and device switching
    pavucontrol
    
    # ========================================================================
    # Command-line Audio Control
    # ========================================================================
    # Command-line volume control utility
    # Allows script-based audio control and automation
    pamixer
    
    # ========================================================================
    # Bluetooth Management
    # ========================================================================
    # Bluetooth management GUI
    # Provides interface for Bluetooth device pairing and management
    blueman
    
    # ========================================================================
    # Battery Monitoring
    # ========================================================================
    # Power management and battery monitoring
    # Provides battery status information for wireless devices
    upower
    
    # ========================================================================
    # Headset Control
    # ========================================================================
    # Headset control utilities for Logitech gaming headsets
    # Provides control over mute LED, battery status, and sidetone
    headsetcontrol
  ];

  # ============================================================================
  # Device Detection
  # ============================================================================
  # Enable udev rules for headset control utilities
  # Allows automatic detection and control of supported Logitech headsets
  services.udev.packages = with pkgs; [
    headsetcontrol  # Provides udev rules for Logitech headset detection
  ];
}
