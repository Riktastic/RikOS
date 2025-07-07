# =============================================================================
# Fail2ban Intrusion Prevention Module
# =============================================================================
#
# Configures Fail2ban for intrusion prevention and SSH security with automatic IP blocking.
#
# What it does:
# - Monitors system logs for failed login attempts and suspicious activity
# - Automatically blocks IP addresses that exhibit malicious behavior
# - Integrates with nftables firewall for network-level protection
# - Configures SSH jail with aggressive mode and permanent bans
# - Uses systemd journal backend for real-time log monitoring
# - Prevents brute force attacks and SSH-based intrusions
#
# Requirements:
# - nftables firewall module enabled
# - SSH service configured
# - systemd journal for log monitoring
# - Network connectivity for IP blocking
#
# Usage:
# - Imported by main configuration automatically
# - Fail2ban starts automatically on boot
# - Use fail2ban-client status to check status
# - Use fail2ban-client unban <ip> to unban IPs
# =============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # Module Options
  # ============================================================================
  # Define module-specific options (currently empty)
  options = {};

  # ============================================================================
  # Module Configuration
  # ============================================================================
  # Configure Fail2ban and SSH security settings
  config = {
    # ========================================================================
    # Fail2ban Service Configuration
    # ========================================================================
    # Enable and configure Fail2ban intrusion prevention
    services.fail2ban = {
      enable = true;        # Enable Fail2ban service
      maxretry = 3;         # Maximum failed attempts before ban
      bantime = "0";        # Permanent ban (0 = permanent)

      # ================================================================
      # SSH Jail Configuration
      # ================================================================
      # Configure SSH-specific intrusion prevention
      jails.sshd.settings = {
        enabled = true;                    # Enable SSH jail
        backend = "systemd";               # Use systemd journal for logs
        mode = "aggressive";               # Aggressive response mode
        banaction = "nftables-multiport";  # Use nftables for blocking
        bantime = "0";                     # Permanent ban for SSH violations
      };
    };

    # ========================================================================
    # OpenSSH Security Configuration
    # ========================================================================
    # Configure SSH server with security best practices
    services.openssh = {
      enable = true;  # Enable SSH server
      
      # ================================================================
      # SSH Security Settings
      # ================================================================
      settings = {
        PasswordAuthentication = false;  # Disable password authentication
        PermitRootLogin = "no";         # Prohibit root login
      };
    };

    # ========================================================================
    # Firewall Integration
    # ========================================================================
    # Ensure nftables is enabled for Fail2ban integration
    # This allows Fail2ban to dynamically add blocking rules
    networking.nftables.enable = true;
    
    # ================================================================
    # Additional nftables Rules
    # ================================================================
    # You can add your own nftables rules here if needed
    # This provides flexibility for custom firewall configurations
  };
}
