# =============================================================================
# NixOS System Configuration
# =============================================================================
#
# Main NixOS configuration file that defines base system settings and imports
# all necessary modules. Serves as the foundation for all devices.
#
# What it does:
# - Configures hardware, system, security, and software modules
# - Sets up user management and desktop environment
# - Imports device-specific configurations
# - Defines global system settings and packages
#
# Requirements:
# - NixOS 25.05 or later
# - Device-specific hardware configuration
# - Proper module organization
#
# Usage:
# - Imported by flake.nix for each device
# - Device configurations can override these settings
# - All modules organized by category for maintenance
# =============================================================================

{ config, lib, pkgs, hostname, nur, ... }:

{
  # ============================================================================
  # SOPS, for storing secrets 
  # ============================================================================
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt"; # path to your age keys or other key files
    defaultSopsFile = ./secrets.yaml;                # path to your encrypted secrets file
    defaultSopsFormat = "yaml";
  };

  # ============================================================================
  # NixOS User Repository import
  # ============================================================================
  # Allows modules to install packages from the NixOS User Repository
  nixpkgs.overlays = [ nur.overlays.default ];

  # ============================================================================
  # Module Imports
  # ============================================================================
  # Import all necessary modules organized by category
  imports = [
    # ========================================================================
    # Device Configuration
    # ========================================================================
    # Device-specific configuration options (mode, name, etc.)
    ./modules/system/device.nix

    # ========================================================================
    # Hardware Configuration
    # ========================================================================
    # Global hardware settings that apply to all devices
    ./modules/hardware/global.nix

    # ========================================================================
    # System Modules
    # ========================================================================
    # Core system configuration modules
    ./modules/system/kernel.nix        # Kernel selection and configuration
    ./modules/system/boot.nix          # Bootloader and boot process
    ./modules/system/fonts.nix         # System fonts and typography
    ./modules/system/networking.nix    # Network configuration
    ./modules/system/printing.nix      # Print service configuration
    ./modules/system/sound.nix         # Audio system configuration
    ./modules/system/motd.nix          # Message of the day
    ./modules/system/performance.nix   # Performance tuning and optimization



    # ========================================================================
    # User Management
    # ========================================================================
    # User account definitions and home-manager integration
    ./users.nix

    # ========================================================================
    # Desktop Environment
    # ========================================================================
    # Desktop environment configuration (set globally for all devices)
    ./modules/desktop/kde.nix  # KDE Plasma desktop environment, uses NUR

    # ========================================================================
    # Security Modules
    # ========================================================================
    # Comprehensive security configuration for hardened system
    ./modules/security/antivirus.nix    # ClamAV antivirus protection
    ./modules/security/antirootkit.nix  # Rootkit detection (chkrootkit)
    ./modules/security/intrusionprevention.nix     # Intrusion prevention system
    ./modules/security/firewall.nix     # Network firewall configuration
    ./modules/security/auditing.nix       # System audit daemon
    ./modules/security/mandatoryaccesscontrol.nix     # Mandatory access control
    ./modules/security/secureboot.nix   # Secure boot configuration
    ./modules/security/vulnerabilitymanagement.nix       # Vulnerability scanning

    # ========================================================================
    # Common Services
    # ========================================================================
    # Essential system services
    ./modules/services/sshd.nix  # SSH daemon for remote access
  ];

  # ============================================================================
  # Nix Package Manager Configuration
  # ============================================================================
  # Configure the Nix package manager and garbage collection
  nix = {
    # Enable experimental features for modern Nix functionality
    settings.experimental-features = ["nix-command" "flakes"];
    
    # Automatic garbage collection to manage disk space
    gc = {
      automatic = true;           # Enable automatic garbage collection
      dates = "weekly";           # Run weekly (every Sunday at 03:15)
      options = "--delete-older-than 30d";  # Remove packages older than 30 days
    };
  };

  # ============================================================================
  # Package Management
  # ============================================================================
  # Allow installation of proprietary/unfree software
  # This is necessary for drivers, firmware, and some applications
  nixpkgs.config.allowUnfree = true;

  system.autoUpgrade = {
    enable = true;           # Enable automatic upgrades
    allowReboot = false;     # Set to true if you want auto-reboots when needed
  };

  # ============================================================================
  # System Version
  # ============================================================================
  # NixOS version for state management
  # Increment this when making incompatible changes
  system.stateVersion = "25.05";

  # ============================================================================
  # System Packages
  # ============================================================================
  # Essential packages installed system-wide
  environment.systemPackages = with pkgs; [
    # ========================================================================
    # System Administration Tools
    # ========================================================================
    vim        # Advanced text editor
    wget       # Web download utility
    git        # Version control system
    htop       # Interactive process viewer
    tmux       # Terminal multiplexer
    sops       # Encrypt and decrypt NixOS secrets
    age        # Encryption modules of SOPS
    colmena    # Colmena multi-host deployment tool
    
    # ========================================================================
    # Development Tools
    # ========================================================================
    gcc        # GNU Compiler Collection
    gnumake    # Build automation tool
    python3    # Python programming language

    # ========================================================================
    # Shell and Theme
    # ========================================================================
    zsh                    # Advanced shell with features
    zsh-syntax-highlighting  # Syntax highlighting for zsh
    zsh-autosuggestions    # Command suggestions based on history
    zsh-powerlevel10k      # Advanced prompt theme
    
    # ========================================================================
    # Modern Command-Line Tools
    # ========================================================================
    eza                    # Modern replacement for ls with icons
    bat                    # Modern replacement for cat with syntax highlighting
    fd                     # Modern replacement for find
    ripgrep                # Modern replacement for grep
    fzf                    # Fuzzy finder for interactive selection
    pfetch-rs              # System information display

    imapsync
  ];

  programs.zsh.enable = true;
  
  # ============================================================================
  # Security Settings
  # ============================================================================
  # System-wide security configuration
  security = {
    # Require password for sudo access (wheel group)
    sudo.wheelNeedsPassword = true;    
  };
}

