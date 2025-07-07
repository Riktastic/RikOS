# =============================================================================
# Default Home Manager Configuration Module
# =============================================================================
#
# Template and integration point for all default home-manager configurations.
#
# What it does:
# - Imports all default home-manager modules (programs, settings, services)
# - Provides complete default user environment configuration
# - Serves as template for new user configurations
# - Ensures consistent setup across different user accounts
#
# Requirements:
# - home-manager flake input
# - Individual default modules (programs, settings, services)
# - User-specific home configuration files
#
# Usage:
# - Import in user-specific home-manager configurations
# - Override username and home directory for actual users
# - Extend with user-specific programs or services
# - User configurations handle device-specific imports
# =============================================================================

{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Module Imports
  # ============================================================================
  # Import all default home-manager modules
  # These provide comprehensive user environment configuration
  imports = [
    ./programs.nix    # Development tools and applications
    ./settings.nix    # Environment and XDG configuration
    ./services.nix    # Background services
  ];

  # ============================================================================
  # Basic Home Manager Configuration
  # ============================================================================
  # Set the home-manager state version
  # This should match your NixOS version for compatibility
  home.stateVersion = "25.05";
  
  # Enable home-manager for this user
  # This provides the home-manager command and functionality
  programs.home-manager.enable = true;

  # ============================================================================
  # User Configuration (Template Values)
  # ============================================================================
  # These values should be overridden by the actual user configuration
  # They serve as placeholders and examples
  home.username = "default-user";        # Should be overridden
  home.homeDirectory = "/home/default-user";  # Should be overridden
} 