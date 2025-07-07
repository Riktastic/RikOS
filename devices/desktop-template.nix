# =============================================================================
# Desktop Device Configuration Template
# =============================================================================
#
# Template for creating new desktop device configurations.
#
# What it does:
# - Provides structure for new desktop device configurations
# - Imports hardware modules for CPU, GPU, motherboard, peripherals
# - Configures boot settings and filesystem mounts
# - Sets up network configuration and desktop-specific services
# - Includes desktop environment and GUI applications
#
# Requirements:
# - Hardware module imports for your desktop device
# - Device-specific boot and filesystem configuration
# - Network settings for your environment
# - Desktop environment preferences
#
# Usage:
# - Copy to devices/your-desktop-name.nix
# - Update hostname and device-specific settings
# - Import appropriate hardware modules
# - Configure network and filesystem settings
# - Customize desktop environment and applications
# =============================================================================

{ config, pkgs, lib, modulesPath, ... }:

{
  # ============================================================================
  # Desktop Device Configuration
  # ============================================================================
  # Set the device mode and identification
  device = {
    mode = "desktop";  # Desktop mode - includes GUI applications and desktop environment
    name = "your-desktop-name";  # CHANGE: Set your desktop device name
    description = "Your desktop device description";  # CHANGE: Optional description
  };

  # ============================================================================
  # Desktop Device Identification
  # ============================================================================
  # Update this section with your desktop device's information
  networking = {
    hostName = "your-desktop-name";  # CHANGE: Set your desktop device hostname
    # Network configuration is defined below in the networking section
  };

  # ============================================================================
  # Desktop-Specific Packages
  # ============================================================================
  # Add packages that are specific to this desktop device
  # These are in addition to the global system packages
  environment.systemPackages = with pkgs; [
    # ADD: Desktop-specific packages here
    # Examples:
    # - GUI development tools
    # - Desktop applications
    # - Gaming software
    # - Multimedia applications
    # - Hardware-specific utilities
  ];

  # ============================================================================
  # Desktop-Specific Services
  # ============================================================================
  # Add services that are specific to this desktop device
  services = {
    # ADD: Desktop-specific services here
    # Examples:
    # - Display managers
    # - Desktop environment services
    # - GUI applications
    # - Gaming services
  };

  # ============================================================================
  # Desktop Hardware Module Imports
  # ============================================================================
  # Import hardware-specific modules based on your desktop device's actual hardware
  # Remove or comment out modules that don't apply to your desktop device
  imports = [
    # ========================================================================
    # Core Hardware Components
    # ========================================================================
    # CPU Configuration - Choose one based on your processor
    # ../modules/hardware/cpu/intel.nix      # Intel CPU configuration
    # ../modules/hardware/cpu/amd.nix        # AMD CPU configuration (if available)
    
    # GPU Configuration - Choose one based on your graphics card
    # ../modules/hardware/gpu/nvidia.nix     # NVIDIA GPU configuration
    # ../modules/hardware/gpu/amd.nix        # AMD GPU configuration (if available)
    # ../modules/hardware/gpu/intel.nix      # Intel integrated graphics
    
    # Motherboard Configuration - Choose based on your motherboard
    # ../modules/hardware/motherboard/asus.nix     # ASUS motherboard
    # ../modules/hardware/motherboard/gigabyte.nix # Gigabyte motherboard (if available)
    # ../modules/hardware/motherboard/msi.nix      # MSI motherboard (if available)

    # ========================================================================
    # Radio Hardware (Optional)
    # ========================================================================
    # Uncomment if you have Software Defined Radio equipment
    # ../modules/hardware/radio/hackrf/hackrf-one.nix  # HackRF One SDR transceiver
    # ../modules/hardware/radio/rtlsdr/rtlsdr.nix      # RTL-SDR USB dongle

    # ========================================================================
    # Peripheral Devices
    # ========================================================================
    # Input/output devices and accessories
    # Update these based on your actual peripherals
    # ../modules/hardware/peripherals/webcam/logitech.nix   # Logitech webcam
    # ../modules/hardware/peripherals/headset/logitech.nix  # Logitech headset
    # ../modules/hardware/peripherals/keyboard/generic.nix  # Generic keyboard
    # ../modules/hardware/peripherals/mouse/logitech.nix    # Logitech mouse

    # ========================================================================
    # Desktop Environment (Required for Desktop Mode)
    # ========================================================================
    # Desktop environment configuration
    ../modules/desktop/kde.nix   # KDE Plasma desktop environment

    # ========================================================================
    # Database Services (Optional)
    # ========================================================================
    # Uncomment if you need database servers for development
    # ../modules/services/postgresql.nix  # PostgreSQL database server
    # ../modules/services/redis.nix       # Redis in-memory database
    # ../modules/services/minio.nix       # MinIO object storage
    # ../modules/services/mariadb.nix     # MariaDB database server

    # ========================================================================
    # Network Services
    # ========================================================================
    # Network configuration and DNS settings
    ../modules/network/dns.nix  # DNS-over-TLS configuration
  ];

  # ============================================================================
  # Desktop Boot Configuration
  # ============================================================================
  # Desktop device-specific boot settings and kernel modules
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
  # Desktop Filesystem Configuration
  # ============================================================================
  # Mount points and filesystem settings for desktop device
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
        "discard"     # Enable TRIM for SSD optimization
      ];
    };

    # ========================================================================
    # Boot Partition
    # ========================================================================
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";  # CHANGE: Set your boot partition
      fsType = "vfat";                        # FAT32 for UEFI compatibility
      options = [
        "fmask=0077"  # File permission mask
        "dmask=0077"  # Directory permission mask
      ];
    };

    # ========================================================================
    # Temporary Filesystem
    # ========================================================================
    "/tmp" = {
      device = "tmpfs";  # In-memory filesystem
      fsType = "tmpfs";
      options = [
        "size=4G"   # CHANGE: Adjust size based on your RAM
        "mode=1777" # Standard tmpfs permissions
      ];
    };

    # ADD: Additional mount points as needed
    # Examples:
    # "/home" = { ... };
    # "/var" = { ... };
    # "/opt" = { ... };
  };

  # ============================================================================
  # Swap Configuration
  # ============================================================================
  # Virtual memory configuration
  swapDevices = [
    {
      device = "/dev/disk/by-label/NIXSWAP";  # CHANGE: Set your swap partition
    }
    # ADD: Additional swap devices if needed
  ];

  # ============================================================================
  # Desktop Network Configuration
  # ============================================================================
  # Network configuration for your desktop device
  # Choose between DHCP (automatic) or static IP configuration
  networking = {
    # Option 1: DHCP (automatic IP assignment) - DEFAULT FOR DESKTOPS
    useDHCP = true;
    
    # Option 2: Static IP configuration (uncomment and configure if needed)
    # useDHCP = false;
    # interfaces.enp6s0 = {  # CHANGE: Set your network interface name
    #   # Static IP address configuration
    #   ipv4.addresses = [
    #     {
    #       address = "192.168.1.100";  # CHANGE: Set your device IP address
    #       prefixLength = 24;          # CHANGE: Set your subnet mask
    #     }
    #   ];
    #   
    #   # Default gateway configuration
    #   ipv4.routes = [
    #     {
    #       address = "0.0.0.0";        # Default route (all traffic)
    #       prefixLength = 0;           # Match all addresses
    #       via = "192.168.1.1";        # CHANGE: Set your gateway address
    #     }
    #   ];
    #   
    #   mtu = 1500;  # CHANGE: Set appropriate MTU for your network
    # };
  };

  # ============================================================================
  # Desktop Platform Configuration
  # ============================================================================
  # Target platform for package compilation
  # CHANGE: Set to your architecture
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # Other options: "aarch64-linux", "i686-linux", etc.

  # ============================================================================
  # Desktop CPU Configuration
  # ============================================================================
  # CPU microcode updates
  # Uncomment and configure based on your CPU
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # ============================================================================
  # Desktop Hardware Services
  # ============================================================================
  # Hardware monitoring and management services for desktop
  services = {
    hardware = {
      # bolt.enable = true;  # Thunderbolt device management (if applicable)
      # ADD: Other desktop hardware services as needed
    };
  };
} 