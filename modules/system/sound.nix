# =============================================================================
# System Sound Configuration Module
# =============================================================================
#
# This module configures the audio system using PipeWire, a modern
# audio and video processing framework for low-latency, high-quality audio.
#
# What it does:
# - Enables PipeWire for modern audio processing with low latency
# - Provides PulseAudio compatibility layer for application support
# - Configures ALSA compatibility with 32-bit application support
# - Enables real-time scheduling priority via rtkit
# - Supports dynamic audio device management and hot-plugging
# - Provides optional JACK compatibility for professional audio
# - Enables Bluetooth audio and HDMI audio passthrough
# - Supports multi-device audio routing and device switching
# - Disabled in server mode to reduce resource usage
#
# Requirements:
# - Compatible audio hardware
# - PipeWire package and dependencies
# - rtkit for real-time scheduling
# - Sufficient system resources for audio processing
# - Desktop mode (disabled in server mode)
#
# Usage:
# - Imported by device configurations automatically
# - PipeWire starts automatically on boot (desktop mode only)
# - Audio applications work without additional configuration (desktop mode only)
# - Enable JACK support for professional audio applications (desktop mode only)
# =============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.device;
in
{
  # ============================================================================
  # Real-time Scheduling
  # ============================================================================
  # Enable rtkit for real-time scheduling priority
  # Only enabled in desktop mode - servers typically don't need audio processing
  security.rtkit.enable = lib.mkIf (cfg.mode == "desktop") true;

  # ============================================================================
  # Audio System Configuration
  # ============================================================================
  # Configure PipeWire for modern, low-latency audio processing
  # Only enabled in desktop mode - servers typically don't need audio
  services.pipewire = lib.mkIf (cfg.mode == "desktop") {
    enable = true;                     # Enable PipeWire audio system
    
    # ========================================================================
    # PulseAudio Compatibility
    # ========================================================================
    # Enable PulseAudio compatibility layer
    # This ensures all PulseAudio applications work seamlessly
    pulse.enable = true;
    
    # ========================================================================
    # ALSA Compatibility
    # ========================================================================
    # Enable ALSA compatibility for legacy applications
    alsa.enable = true;                # Enable ALSA compatibility layer
    
    # ========================================================================
    # 32-bit ALSA Support
    # ========================================================================
    # Enable 32-bit ALSA support for legacy applications
    # This is important for some games and older software
    alsa.support32Bit = true;
    
    # ========================================================================
    # JACK Compatibility (Optional)
    # ========================================================================
    # Enable JACK compatibility for professional audio applications
    # Uncomment this line if you need JACK support for DAWs or
    # professional audio software
    #jack.enable = true;
  };
} 
