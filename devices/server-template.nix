# =============================================================================
# Server Device Configuration Template
# =============================================================================
#
# Template for creating new server device configurations.
#
# What it does:
# - Provides structure for server device configurations
# - Imports hardware modules for CPU, GPU, motherboard
# - Configures boot settings and filesystem mounts
# - Sets up network configuration and server-specific services
# - Uses hardened kernel for security
# - CLI-only environment (no desktop)
#
# Requirements:
# - Hardware module imports for your server
# - Device-specific boot and filesystem configuration
# - Network settings for your server environment
#
# Usage:
# - Copy to devices/your-server-name.nix
# - Update hostname and device-specific settings
# - Import appropriate hardware modules
# - Configure network and filesystem settings
# =============================================================================

{ config, pkgs, lib, modulesPath, ... }:

{
  # ============================================================================
  # Device Configuration
  # ============================================================================
  # Set the device mode and identification
  device = {
    mode = "server";  # Server mode - CLI only, no desktop environment
    name = "your-server-name";  # CHANGE: Set your server name
    description = "Your server description";  # CHANGE: Optional description
    
    # ========================================================================
    # Server User Configuration
    # ========================================================================
    # Configure how users are set up on this server device
    serverUsers = {
      # Enable minimal user configuration (recommended for servers)
      enableMinimalConfig = true;
      
      # Additional packages for server users
      extraPackages = with pkgs; [
        # ADD: Additional packages for server users
        # Examples:
        # - Monitoring tools (htop, iotop, iftop)
        # - Backup software (rsync, rclone)
        # - Server management tools (tmux, screen)
        # - Development tools (git, vim, nano)
      ];
      
      # Enable development tools for server users
      # Set to true if users need development capabilities
      enableDevelopmentTools = false;
    };
  };

  # ============================================================================
  # Device Identification
  # ============================================================================
  # Update this section with your device's information
  networking = {
    hostName = "your-server-name";  # CHANGE: Set your device hostname
    # Network configuration is defined below in the networking section
  };

  # ============================================================================
  # Localization
  # ============================================================================
  time.timeZone = "Europe/Amsterdam";  # System timezone
  i18n = {
    defaultLocale = "en_US.UTF-8";  # English language for messages
    extraLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  # ============================================================================
  # Device-Specific Packages
  # ============================================================================
  # Add packages that are specific to this server
  # These are in addition to the global system packages
  environment.systemPackages = with pkgs; [
    # ADD: Server-specific packages here
    # Examples:
    # - Monitoring tools (htop, iotop, iftop)
    # - Backup software
    # - Server management tools
    # - Hardware-specific utilities
  ];

  # ============================================================================
  # Device-Specific Services
  # ============================================================================
  # Add services that are specific to this server
  services = {
    # ADD: Server-specific services here
    # Examples:
    # - Web servers (nginx, apache)
    # - Database servers (postgresql, redis, mariadb)
    # - Monitoring agents
    # - Custom applications
  };

  # ============================================================================
  # Hardware Module Imports
  # ============================================================================
  # Import hardware-specific modules based on your server's actual hardware
  # Remove or comment out modules that don't apply to your server
  imports = [
    # ========================================================================
    # Core Hardware Components
    # ========================================================================
    # CPU Configuration - Choose one based on your processor
    # ../modules/hardware/cpu/intel.nix      # Intel CPU configuration
    # ../modules/hardware/cpu/amd.nix        # AMD CPU configuration (if available)
    
    # GPU Configuration - Choose one based on your graphics card
    # ../modules/hardware/gpu/nvidia.nix     # NVIDIA GPU configuration (if needed)
    # ../modules/hardware/gpu/amd.nix        # AMD GPU configuration (if needed)
    # ../modules/hardware/gpu/intel.nix      # Intel integrated graphics
    
    # Motherboard Configuration - Choose based on your motherboard
    # ../modules/hardware/motherboard/asus.nix     # ASUS motherboard
    # ../modules/hardware/motherboard/gigabyte.nix # Gigabyte motherboard (if available)
    # ../modules/hardware/motherboard/msi.nix      # MSI motherboard (if available)

    # ========================================================================
    # Server Services
    # ========================================================================
    # Database servers for applications and development
    # ../modules/services/postgresql.nix  # PostgreSQL database server
    # ../modules/services/redis.nix       # Redis in-memory database
    # ../modules/services/minio.nix       # MinIO object storage
    # ../modules/services/mariadb.nix     # MariaDB database server
    # ../modules/services/docker.nix      # Docker containerization
    # ../modules/services/virtualmachine-intel.nix  # Virtualization support

    # ========================================================================
    # Network Services
    # ========================================================================
    # Network configuration and DNS settings
    ../modules/network/dns.nix  # DNS-over-TLS configuration

    # ========================================================================
    # Software Suites (Server Mode)
    # ========================================================================
    # These modules will automatically install CLI versions in server mode
    # Desktop-specific modules (proton, office, gaming, internet, media) don't need changes
    #../modules/software/data.nix         # Data Science suite (CLI tools)
    #../modules/software/development.nix  # Development suite (CLI tools)
    #../modules/software/development/go.nix      # Go Language suite
    #../modules/software/development/nodejs.nix  # Node.js/JavaScript suite
    #../modules/software/development/python.nix  # Python suite
    #../modules/software/development/php.nix     # PHP suite
    #../modules/software/development/rust.nix    # Rust suite
  ];

  # ============================================================================
  # Boot Configuration
  # ============================================================================
  # Device-specific boot settings and kernel modules
  boot = {
    # ========================================================================
    # Initial RAM Disk (initrd) Configuration
    # ========================================================================
    # Kernel modules needed for boot process
    # Update these based on your hardware
    initrd = {
      # Available kernel modules for hardware detection during boot
      availableKernelModules = [
        # Storage controllers
        "xhci_pci"    # USB 3.0 controller
        "ahci"        # SATA controller
        "nvme"        # NVMe storage
        "usbhid"      # USB HID devices
        "usb_storage" # USB storage devices
        "sd_mod"      # SCSI disk support
        "sr_mod"      # SCSI CD-ROM support
      ];
      
      # Kernel modules to load during boot
      kernelModules = [
        "dm-snapshot"  # Device mapper snapshot support
        "cryptd"       # Crypto device support
        
        # ADD: Additional modules for your hardware
      ];
      
      # LUKS encryption configuration for root partition
      # Update device path to match your setup
      luks.devices."cryptroot" = {
        device = "/dev/disk/by-label/NIXLUKS";  # CHANGE: Set your encrypted device
      };
    };

    # ========================================================================
    # Kernel Modules
    # ========================================================================
    # Additional kernel modules for this device
    # Note: Some modules are set in imported hardware modules
    kernelModules = [
      # ADD: Device-specific kernel modules
      # Examples:
      # "kvm-intel"    # Intel KVM virtualization support
      # "kvm-amd"      # AMD KVM virtualization support
    ];

    # ========================================================================
    # Bootloader Configuration
    # ========================================================================
    # UEFI bootloader settings
    loader = {
      systemd-boot.enable = true;  # Use systemd-boot as bootloader
      efi.canTouchEfiVariables = true;  # Allow modification of EFI variables
    };
  };

  # ============================================================================
  # Filesystem Configuration
  # ============================================================================
  # Mount points and filesystem settings
  # Update device paths to match your partition layout
  fileSystems = {
    # ========================================================================
    # Root Filesystem
    # ========================================================================
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";  # CHANGE: Set your root partition
      fsType = "ext4";                        # CHANGE: Set your filesystem type
      options = [
        "noatime"     # Don't update access times (performance)
        "nodiratime"  # Don't update directory access times
      ];
    };

    # ========================================================================
    # Boot Filesystem
    # ========================================================================
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";  # CHANGE: Set your boot partition
      fsType = "vfat";                        # FAT32 for UEFI boot
    };

    # ========================================================================
    # Additional Filesystems
    # ========================================================================
    # Add additional mount points as needed
    # Examples:
    # "/data" = {
    #   device = "/dev/disk/by-label/DATA";
    #   fsType = "ext4";
    #   options = [ "noatime" "nodiratime" ];
    # };
  };

  # ============================================================================
  # Network Configuration
  # ============================================================================
  # Network settings for server environment
  networking = {
    # ========================================================================
    # Network Interfaces
    # ========================================================================
    # Configure network interfaces
    # Update interface names and IP addresses for your network
    interfaces = {
      # Example: Static IP configuration
      # "eth0" = {
      #   useDHCP = false;
      #   ipv4.addresses = [{
      #     address = "192.168.1.100";
      #     prefixLength = 24;
      #   }];
      # };
    };

    # ========================================================================
    # Default Gateway
    # ========================================================================
    # Set default gateway for internet access
    # defaultGateway = "192.168.1.1";

    # ========================================================================
    # DNS Configuration
    # ========================================================================
    # DNS servers for name resolution
    # nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };

  # ============================================================================
  # System State Version
  # ============================================================================
  # NixOS version for state management
  # Increment this when making incompatible changes
  system.stateVersion = "25.05";
} 