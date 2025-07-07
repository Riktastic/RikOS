# =============================================================================
# NixOS Flake Configuration
# =============================================================================
#
# This flake defines the NixOS system configurations for all devices
# in the network using a declarative approach.
#
# What it does:
# - Manages multiple NixOS systems from a single repository
# - Provides device-specific configurations with shared base settings
# - Integrates home-manager for user configuration management
# - Supports secure boot with lanzaboote
# - Uses NixOS 25.05 LTS for stability
#
# Requirements:
# - nixpkgs (NixOS 25.05 LTS)
# - home-manager for user configurations
# - lanzaboote for secure boot support
# - nixos-hardware for hardware-specific configs
#
# Usage:
# - Build device: nix build .#nixosConfigurations.hercules.config.system.build.toplevel
# - Deploy device: nixos-rebuild switch --flake .#hercules
# - Add new device: Copy template and update this flake
# =============================================================================

{
  # ============================================================================
  # Flake Description
  # ============================================================================
  description = "Riks NixOS flake";

  # ============================================================================
  # Input Dependencies
  # ============================================================================
  # External dependencies required by this flake
  inputs = {
    # ========================================================================
    # Core NixOS: https://search.nixos.org/packages
    # ========================================================================
    # Use NixOS 25.05 LTS (Uakari) for stability
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ========================================================================
    # SOPS, for storing secrets: https://github.com/Mic92/sops-nix
    # ========================================================================
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ========================================================================
    # Nix User Repository (NUR): https://nur.nix-community.org/
    # ========================================================================
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";  # Use same nixpkgs version
    };
    
    # ========================================================================
    # User Management
    # ========================================================================
    # Home Manager for user configuration management
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";  # Use same nixpkgs version
    };

    # ========================================================================
    # Security
    # ========================================================================
    # Secure Boot support for UEFI systems
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";  # Use same nixpkgs version
    };

    # ========================================================================
    # Hardware Support
    # ========================================================================
    # Hardware-specific configurations and drivers
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # ========================================================================
    # Colmena: NixOS multi-host deployment tool
    # ========================================================================
    # https://github.com/zhaofengli/colmena
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ============================================================================
  # Flake Outputs
  # ============================================================================
  # Define the NixOS configurations for each device
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, lanzaboote, nixos-hardware, sops-nix, nur, ... }@inputs:
    let
      # ========================================================================
      # Helper Functions
      # ========================================================================
      # Helper function to create a host configuration
      # This standardizes the configuration process for all devices
      mkHost = { system, hostname, modules, specialArgs ? {} }:
        nixpkgs.lib.nixosSystem {
          inherit system;  # Target architecture (x86_64-linux, aarch64-linux, etc.)
          
          # Special arguments passed to all modules
          specialArgs = {
            inherit inputs;      # Make all inputs available to modules
            inherit hostname;    # Make hostname available to modules
            inherit nur;
          } // specialArgs;      # Additional special arguments

          # Module list for this device
          modules = [
            # Overlay to use unstable Proton packages. In this situation it will make sure the Proton packages are always up-to-date
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [
                (final: prev: {
                  protonmail-bridge = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.protonmail-bridge;
                  protonmail-desktop = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.protonmail-desktop;
                  protonpass = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.protonpass;
                  protonvn-gui = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.protonvpn-gui;
                })
              ];
            })

            # ====================================================================
            # Common Modules (Applied to all devices)
            # ====================================================================
            lanzaboote.nixosModules.lanzaboote  # Secure boot support
            ./configuration.nix                 # Main system configuration
            ./users.nix                         # User management
            sops-nix.nixosModules.sops          # Secure secret management

            # ====================================================================
            # Device-Specific Configuration
            # ====================================================================
            # Import device-specific configuration file
            ./devices/${hostname}.nix            

            # ====================================================================
            # Home Manager Integration
            # ====================================================================
            # Home Manager for user configuration management
            home-manager.nixosModules.home-manager
            {
              # Home Manager settings
              home-manager.useGlobalPkgs = true;           # Use system packages
              home-manager.backupFileExtension = "backup"; # Backup existing configs
              home-manager.useUserPackages = true;         # Install user packages
              home-manager.extraSpecialArgs = { inherit inputs; };  # Pass inputs to home-manager
            }
          ] ++ modules;  # Additional device-specific modules
       };
    in
    {
      # ========================================================================
      # NixOS Configurations
      # ========================================================================
      # Define NixOS configurations for each device
      nixosConfigurations = {
        # ====================================================================
        # Hercules Device Configuration
        # ====================================================================
        # Main desktop/workstation configuration
        hercules = mkHost {
          system = "x86_64-linux";  # Target architecture
          hostname = "hercules";    # Device hostname
          modules = [
            # Device-specific modules can be added here
            # Examples:
            # - Hardware-specific configurations
            # - Custom services
            # - Development tools
          ];
        };

        # ====================================================================
        # Lira Server Configuration
        # ====================================================================
        # Production server configuration (CLI-only)
#        lira = mkHost {
#          system = "x86_64-linux";  # Target architecture
#          hostname = "lira";        # Device hostname
#          modules = [
            # Device-specific modules can be added here
            # Examples:
            # - Hardware-specific configurations
            # - Server services
            # - Monitoring tools
#          ];
#        };

        # ====================================================================
        # Add More Devices Here
        # ====================================================================
        # Template for adding new devices:
        # 
        # your-device-name = mkHost {
        #   system = "x86_64-linux";  # or "aarch64-linux", etc.
        #   hostname = "your-device-name";
        #   modules = [
        #     # Device-specific modules
        #   ];
        # };
        #
        # Steps to add a new device:
        # 1. Create device configuration file: devices/your-device-name.nix
        # 2. Copy from devices/template.nix (desktop) or devices/server-template.nix (server) and customize
        # 3. Add configuration to this flake
        # 4. Build and deploy: nixos-rebuild switch --flake .#your-device-name
      };
    };
}
