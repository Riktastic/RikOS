# =============================================================================
# System Users Configuration
# =============================================================================
#
# Manages system user accounts and their associated home-manager configurations.
#
# What it does:
# - Defines system users with proper home directories and permissions
# - Configures home-manager for user dotfiles and personal settings
# - Sets up SSH key-based authentication for secure remote access
# - Manages user groups and sudo access via wheel group
# - Provides centralized user management across all devices
#
# Requirements:
# - home-manager flake input
# - User-specific home configuration files
# - SSH public keys for remote access
# - Hashed passwords for local authentication
#
# Usage:
# - Define users in users.users attribute
# - Configure home-manager settings for each user
# - Import user-specific home configurations
# - Generate hashed passwords with mkpasswd -m sha-512
# =============================================================================

{ config, lib, pkgs, ... }:

{
#   sops.secrets."users-example" = {
#     neededForUsers = true;
#   };

  # ============================================================================
  # System User Definitions
  # ============================================================================
  # Define system user accounts that will be created in /etc/passwd
  # Each user gets a home directory and proper system integration
  users.users = {
    # ========================================================================
    # Template for adding new users:
    #
    # username = {
    #   isNormalUser = true;
    #   extraGroups = [ "wheel" "docker" "video" "audio" ];
    #   hashedPassword = "$6$...";  # Generate with mkpasswd -m sha-512
    #   openssh.authorizedKeys.keys = [
    #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... user@hostname"
    #   ];
    # };
    #
    # Steps to add a new user:
    # 1. Add user definition above
    # 2. Create home configuration: homes/username.nix
    # 3. Add home-manager configuration below
    # 4. Generate hashed password: mkpasswd -m sha-512
    # 5. Add SSH public key for remote access
  };

  # ============================================================================
  # Home Manager Configurations
  # ============================================================================
  # Configure home-manager for each user
  # This manages user dotfiles, applications, and personal settings
  home-manager.backupFileExtension = "backup";

  home-manager.users = {
    # ========================================================================
    # Template for adding new user configurations:
    #
    # username = { ... }: {
    #   imports = [
    #     (import ./homes/username.nix {
    #       inherit pkgs lib;
    #       deviceMode = config.device.mode;
    #       serverUsers = config.device.serverUsers;
    #     })
    #   ];
    # };
    #
    # Steps to add new user configuration:
    # 1. Create home configuration file: homes/username.nix
    # 2. Copy from homes/template.nix and customize
    # 3. Add configuration here
    # 4. Rebuild system to apply changes
  };

  # ============================================================================
  # User Groups
  # ============================================================================
  # Define additional user groups if needed
  # Most groups are created automatically when needed
  users.groups = {
    # ========================================================================
    # Custom Groups
    # ========================================================================
    # Add custom groups here if needed
    # Examples:
    # docker = { };
    # media = { };
    # development = { };
  };

  # ============================================================================
  # Security Settings
  # ============================================================================
  # Additional security settings for user management
  security = {
    # ========================================================================
    # Sudo Configuration
    # ========================================================================
    # Configure sudo access for wheel group
    sudo = {
      wheelNeedsPassword = true;  # Require password for sudo
      # extraRules = [  # Additional sudo rules if needed
      #   {
      #     users = [ "username" ];
      #     commands = [ "ALL" ];
      #   }
      # ];
    };
  };
}
