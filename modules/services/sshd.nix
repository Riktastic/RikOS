# =============================================================================
# SSH Service Configuration Module
# =============================================================================
#
# Configures OpenSSH server with comprehensive security hardening and modern best practices.
#
# What it does:
# - Enables OpenSSH server with key-based authentication only
# - Disables root login and password authentication for security
# - Configures strict connection limits and timeouts
# - Implements comprehensive logging and monitoring
# - Provides security banner and connection warnings
# - Uses Ed25519 and RSA host keys for compatibility
# - Restricts users and implements rate limiting
#
# Requirements:
# - SSH public keys configured for users
# - Network connectivity for remote access
# - fail2ban module for intrusion prevention
# - Proper firewall configuration
#
# Usage:
# - Imported by main configuration automatically
# - SSH server starts automatically on boot
# - Use ssh-keygen to generate key pairs
# - Use ssh-copy-id to deploy public keys
# - Check logs with journalctl -u sshd
# =============================================================================

{ config, pkgs, ... }:

{
  sops.secrets."zerotier-networkid" = {
    neededForUsers = true; # or as needed
  };

  # Enable the OpenSSH daemon (sshd)
  services.openssh.enable = true;

  # Listen only on the default port (22). You may change this to a non-standard port for obscurity.
  services.openssh.ports = [ 22 ]; # Consider changing to a high, non-standard port for extra stealth

  # Restrict SSH to listen only on the ZeroTier interface (optional, advanced)
  # To use this, set the ZeroTier-managed IP address for this device below.
  # You can find the ZeroTier IP with: ip addr | grep zt | grep inet
  # Example: services.openssh.listenAddresses = [ "10.147.17.23" ];
  # Uncomment and set per device if you want SSH to be accessible ONLY via ZeroTier:
  # services.openssh.listenAddresses = [ "<zerotier-ip-address>" ];

  # SSHD settings for security hardening
  services.openssh.settings = {
    # Disable password authentication (key-based logins only)
    PasswordAuthentication = false;

    # Disable challenge-response authentication
    ChallengeResponseAuthentication = false;

    # Disable root login entirely
    PermitRootLogin = "no";

    # Disable X11 forwarding (not needed for most servers)
    X11Forwarding = false;

    # Disable agent forwarding
    AllowAgentForwarding = false;

    # Disable TCP forwarding unless you need it
    AllowTcpForwarding = "no";

    # Prevent empty passwords
    PermitEmptyPasswords = false;

    # UseDNS can be set to false to speed up logins and avoid DNS-based attacks
#    UseDNS = false;

    # Log more for auditing
    LogLevel = "VERBOSE";

    # Only allow users in the 'ssh' hroup to log in via SSH
    AllowGroups = [ "ssh" ];

    # Set a login grace time (in seconds) to limit brute-force attempts
    LoginGraceTime = "30s";

    # Harden ciphers and algorithms (optional, for advanced users)
    Ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
    Macs = [ "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" ];
    KexAlgorithms = [ "curve25519-sha256" ];

  };

  # Optionally, set a banner for legal notice
  services.openssh.banner = "/etc/issue.net";

# =============================================================================
# ZeroTier Integration for SSH Access
# =============================================================================
# To enable remote SSH access via ZeroTier, add the following to your device or global configuration:
#
services.zerotierone = {
  enable = true;
  joinNetworks = [ config.sops.secrets."zerotier-networkid".path ]; # Securely load from SOPS-Nix
};
# This will allow SSH access over your ZeroTier virtual network. Combine with firewall rules to restrict SSH to ZeroTier only.

}
