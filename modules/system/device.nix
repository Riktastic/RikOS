# =============================================================================
# Device Configuration Module
# =============================================================================
#
# This module defines device-specific configuration options that can be used
# throughout the system to conditionally enable/disable features based on
# the device's intended use (server vs desktop).
#
# What it does:
# - Defines device mode (server/desktop) configuration option
# - Provides helper functions for conditional module inclusion
# - Sets up device-specific settings and preferences
# - Controls user configuration based on device mode
#
# Requirements:
# - Device configurations should set the mode option
# - Other modules can reference this configuration
#
# Usage:
# - Set mode = "server" or mode = "desktop" in device configs
# - Use config.device.mode in other modules for conditional logic
# =============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.device;
in
{
  # ============================================================================
  # Device Configuration Options
  # ============================================================================
  options.device = {
    # ========================================================================
    # Device Mode
    # ========================================================================
    # Determines whether this device is configured as a server or desktop
    # This affects which packages and services are installed
    mode = lib.mkOption {
      type = lib.types.enum [ "server" "desktop" ];
      default = "desktop";
      description = ''
        Device mode determines the type of packages and services installed.
        
        - server: CLI-based tools only, no desktop environment, server services
        - desktop: Both CLI and GUI tools, full desktop environment
      '';
    };

    # ========================================================================
    # Device Name
    # ========================================================================
    # Human-readable name for the device
    name = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName or "unknown";
      description = "Human-readable name for this device";
    };

    # ========================================================================
    # Device Description
    # ========================================================================
    # Optional description of the device's purpose
    description = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional description of this device's purpose";
    };

    # ========================================================================
    # Server User Configuration
    # ========================================================================
    # Configuration for users on server devices
    serverUsers = lib.mkOption {
      type = lib.types.submodule {
        options = {
          # Enable minimal user configuration for server mode
          enableMinimalConfig = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Enable minimal user configuration for server devices.
              
              When enabled, users on server devices will only get:
              - Basic shell configuration
              - SSH key authentication
              - Essential CLI tools
              - No desktop environment or GUI applications
            '';
          };

          # Additional packages for server users
          extraPackages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Additional packages to install for server users";
          };

          # Enable development tools for server users
          enableDevelopmentTools = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable development tools for server users";
          };
        };
      };
      default = {};
      description = "Configuration for users on server devices";
    };
  };

  # ============================================================================
  # Device Configuration
  # ============================================================================
  config = {
    # ========================================================================
    # System Information
    # ========================================================================
    # Add device information to system information
    environment.variables = {
      NIXOS_DEVICE_MODE = cfg.mode;
      NIXOS_DEVICE_NAME = cfg.name;
    } // lib.optionalAttrs (cfg.description != null) {
      NIXOS_DEVICE_DESCRIPTION = cfg.description;
    };

    # ========================================================================
    # Colmena CLI tool (for multi-host deployment)
    # ========================================================================
  };
} 