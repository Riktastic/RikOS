# =============================================================================
# System Fonts Configuration Module
# =============================================================================
#
# Configures system fonts, font rendering, and typography for optimal display quality.
#
# What it does:
# - Installs comprehensive font packages (Noto, Nerd Fonts, CJK, emoji)
# - Configures fontconfig for optimal rendering and anti-aliasing
# - Provides international character support and Unicode coverage
# - Enables subpixel rendering and font hinting optimization
# - Supports programming fonts with ligatures and icons
# - Ensures consistent typography across all applications
# - Disabled in server mode to reduce resource usage
#
# Requirements:
# - Fontconfig package and dependencies
# - Sufficient disk space for font packages
# - Compatible display hardware for rendering
# - Desktop mode (disabled in server mode)
#
# Usage:
# - Import in device configurations
# - Font packages installed system-wide (desktop mode only)
# - Fontconfig optimizes rendering automatically (desktop mode only)
# - Applications use configured fonts immediately (desktop mode only)
# =============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.device;
in
{
  # ============================================================================
  # Font Configuration
  # ============================================================================
  # Configure system fonts, rendering, and typography
  # Only enabled in desktop mode - servers typically don't need extensive fonts
  fonts = lib.mkIf (cfg.mode == "desktop") {
    # ========================================================================
    # Fontconfig Configuration
    # ========================================================================
    # Enable fontconfig for optimal font rendering and management
    # Fontconfig provides font discovery, rendering optimization, and
    # font substitution for consistent typography across applications
    fontconfig = {
      enable = true;                   # Enable fontconfig for font management
    };
    
    # ========================================================================
    # Font Package Selection
    # ========================================================================
    # Install comprehensive font packages for various use cases
    # These packages provide high-quality typography for different
    # languages, scripts, and applications
    packages = with pkgs; [
      # ================================================================
      # Noto Font Family
      # ================================================================
      # Google's comprehensive font family with excellent Unicode coverage
      noto-fonts                       # Complete Noto font family
      
      # ================================================================
      # Emoji and Symbol Fonts
      # ================================================================
      # High-quality emoji font for modern communication
      noto-fonts-emoji-blob-bin        # Noto emoji with blob style
      
      # ================================================================
      # International Fonts
      # ================================================================
      # Chinese, Japanese, Korean font support
      noto-fonts-cjk-sans              # CJK sans-serif fonts
      
      # ================================================================
      # Developer Fonts
      # ================================================================
      # Nerd Fonts for terminal and development use
      nerd-fonts._0xproto              # 0xProto Nerd Font variant
      nerd-fonts.symbols-only          # Nerd Font symbols only
    ];
  };
}
