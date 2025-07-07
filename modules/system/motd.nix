# =============================================================================
# Message of the Day (MOTD) Configuration Module
# =============================================================================
#
# This module configures the Message of the Day (MOTD) system and SSH
# connection information display using fastfetch for system information.
#
# What it does:
# - Displays system information on SSH login using fastfetch
# - Shows NixOS ASCII art and hardware details
# - Configures custom MOTD and SSH banner
# - Provides system status overview for remote connections
#
# Requirements:
# - fastfetch package (installed automatically)
# - SSH service enabled
# - Interactive shells (bash/zsh)
#
# Usage:
# - Import this module in device configurations
# - SSH connections will show system information automatically
# - Run 'fastfetch' manually for system details
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # System Information Tools
  # ============================================================================
  # Install fastfetch for system information display
  environment.systemPackages = with pkgs; [
    fastfetch  # Modern system information display tool with ASCII art
  ];

  # ============================================================================
  # Interactive Shell Configuration
  # ============================================================================
  # Configure shells to show system information on SSH connections and new shells
  programs.bash.interactiveShellInit = ''
    # ========================================================================
    # SSH Connection Information Display
    # ========================================================================
    # Show device mode and system information when connecting via SSH
    if [ -n "$SSH_CONNECTION" ]; then
      echo ""
      echo "    ██████╗ ██╗██╗  ██╗ ██████╗ ███████╗"
      echo "    ██╔══██╗██║██║ ██╔╝██╔═══██╗██╔════╝"
      echo "    ██████╔╝██║█████╔╝ ██║   ██║███████╗"
      echo "    ██╔══██╗██║██╔═██╗ ██║   ██║╚════██║"
      echo "    ██║  ██║██║██║  ██╗╚██████╔╝███████║"
      echo "    ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
      echo ""
      echo "Connected to: $NIXOS_DEVICE_NAME ($NIXOS_DEVICE_MODE mode)"
      echo "Description: $NIXOS_DEVICE_DESCRIPTION"
      echo "RikOS: $(nixos-version 2>/dev/null | head -n1 | sed 's/(.*)//' | xargs) (Rev: $(nixos-version --revision 2>/dev/null || echo 'unknown'))"
      echo "========================================================================"
      fastfetch
    fi
  '';

  # ============================================================================
  # Zsh Configuration for MOTD
  # ============================================================================
  # Configure zsh to show system information on SSH connections
  programs.zsh.interactiveShellInit = ''
    # ========================================================================
    # SSH Connection Information Display
    # ========================================================================
    # Show device mode and system information when connecting via SSH
    if [ -n "$SSH_CONNECTION" ]; then
      echo ""
      echo "    ██████╗ ██╗██╗  ██╗ ██████╗ ███████╗"
      echo "    ██╔══██╗██║██║ ██╔╝██╔═══██╗██╔════╝"
      echo "    ██████╔╝██║█████╔╝ ██║   ██║███████╗"
      echo "    ██╔══██╗██║██╔═██╗ ██║   ██║╚════██║"
      echo "    ██║  ██║██║██║  ██╗╚██████╔╝███████║"
      echo "    ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
      echo ""
      echo "Connected to: $NIXOS_DEVICE_NAME ($NIXOS_DEVICE_MODE mode)"
      echo "Description: $NIXOS_DEVICE_DESCRIPTION"
      echo "RikOS: $(nixos-version 2>/dev/null | head -n1 | sed 's/(.*)//' | xargs) (Rev: $(nixos-version --revision 2>/dev/null || echo 'unknown'))"
      echo "========================================================================"
      fastfetch
    fi
  '';

  # ============================================================================
  # Global Shell Configuration
  # ============================================================================
  # Configure global shell behavior for all users
  environment.interactiveShellInit = ''
    # ========================================================================
    # System Information Display
    # ========================================================================
    # Show fastfetch on new shell sessions (optional, uncomment to enable)
    # fastfetch --logo nixos
    
    # ========================================================================
    # SSH Connection Information Display
    # ========================================================================
    # Show device mode and system information when connecting via SSH
    if [ -n "$SSH_CONNECTION" ]; then
      echo ""
      echo "    ██████╗ ██╗██╗  ██╗ ██████╗ ███████╗"
      echo "    ██╔══██╗██║██║ ██╔╝██╔═══██╗██╔════╝"
      echo "    ██████╔╝██║█████╔╝ ██║   ██║███████╗"
      echo "    ██╔══██╗██║██╔═██╗ ██║   ██║╚════██║"
      echo "    ██║  ██║██║██║  ██╗╚██████╔╝███████║"
      echo "    ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
      echo ""
      echo "Connected to: $NIXOS_DEVICE_NAME ($NIXOS_DEVICE_MODE mode)"
      echo "Description: $NIXOS_DEVICE_DESCRIPTION"
      echo "RikOS: $(nixos-version 2>/dev/null | head -n1 | sed 's/(.*)//' | xargs) (Rev: $(nixos-version --revision 2>/dev/null || echo 'unknown'))"
      echo "========================================================================"
      fastfetch
    fi
  '';

  # ============================================================================
  # Fastfetch Configuration
  # ============================================================================
  # Create custom fastfetch configuration for RikOS branding
  environment.etc."fastfetch/config.jsonc".text = ''
    // ========================================================================
    // Fastfetch Configuration for RikOS
    // ========================================================================
    // Custom configuration for RikOS system information display
    {
      "logo": {
        "type": "nixos",
        "padding": {
          "left": 2,
          "right": 1
        }
      },
      "display": {
        "separator": " ",
        "keyWidth": 10,
        "title": {
          "text": "RikOS System Information"
        }
      },
      "modules": [
        "title",
        "os",
        "kernel",
        "packages",
        "shell",
        "terminal",
        "cpu",
        "gpu",
        "memory",
        "disk",
        "uptime"
      ]
    }
  '';

  # ============================================================================
  # MOTD Configuration
  # ============================================================================
  # Create dynamic MOTD script that generates content with ASCII art
  environment.etc."motd".source = pkgs.writeScript "motd" ''
    #!${pkgs.bash}/bin/bash
    
    # ========================================================================
    # RikOS Dynamic MOTD Generator
    # ========================================================================
    
    echo ""
    echo "    ██████╗ ██╗██╗  ██╗ ██████╗ ███████╗"
    echo "    ██╔══██╗██║██║ ██╔╝██╔═══██╗██╔════╝"
    echo "    ██████╔╝██║█████╔╝ ██║   ██║███████╗"
    echo "    ██╔══██╗██║██╔═██╗ ██║   ██║╚════██║"
    echo "    ██║  ██║██║██║  ██╗╚██████╔╝███████║"
    echo "    ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
    echo ""
    echo "Welcome to RikOS $(nixos-version 2>/dev/null | head -n1 | sed 's/(.*)//' | xargs)"
    echo "System: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Revision: $(nixos-version --revision 2>/dev/null || echo 'unknown')"
    echo ""
    echo "For system information, run: fastfetch"
    echo "For device information, run: device-info"
    echo "For system status, run: systemctl status"
    echo "For package updates, run: sudo nixos-rebuild switch --upgrade"
    echo ""
    echo "========================================================================"
  '';

  # ============================================================================
  # SSH Banner Configuration
  # ============================================================================
  # Create dynamic SSH banner with ASCII art
  environment.etc."ssh/banner".source = pkgs.writeScript "ssh-banner" ''
    #!${pkgs.bash}/bin/bash
    
    # ========================================================================
    # RikOS Dynamic SSH Banner Generator
    # ========================================================================
    
    echo ""
    echo "    ██████╗ ██╗██╗  ██╗ ██████╗ ███████╗"
    echo "    ██╔══██╗██║██║ ██╔╝██╔═══██╗██╔════╝"
    echo "    ██████╔╝██║█████╔╝ ██║   ██║███████╗"
    echo "    ██╔══██╗██║██╔═██╗ ██║   ██║╚════██║"
    echo "    ██║  ██║██║██║  ██╗╚██████╔╝███████║"
    echo "    ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
    echo ""
    echo "Welcome to RikOS $(nixos-version 2>/dev/null | head -n1 | sed 's/(.*)//' | xargs)"
    echo "System: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Revision: $(nixos-version --revision 2>/dev/null || echo 'unknown')"
    echo ""
    echo "For system information, run: fastfetch"
    echo "For device information, run: device-info"
    echo ""
    echo "========================================================================"
  '';
}
