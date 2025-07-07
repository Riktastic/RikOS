# Internet Suite
#
# This suite provides essential tools for internet access, communication, and remote connectivity.
#
# Packages are grouped and ordered as follows:
#   1. Web Browsers (main and privacy-focused browsers)
#   2. Email (email clients)
#   3. Messaging (chat and messaging clients)
#   4. File Transfer (BitTorrent, FTP, etc.)
#   5. Remote Access (remote desktop, VNC)
#   6. Proton Services (Proton Pass, ProtonMail Bridge, ProtonMail Desktop)
#   7. VPN Clients (Proton VPN, WireGuard, etc.)
#
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  # --- Web Browsers ---
  vivaldi              # Chromium-based browser
  vivaldi-ffmpeg-codecs
  firefox              # Web browser
  tor-browser          # Privacy-focused browser

  # --- Email ---
  thunderbird          # Email client

  # --- Messaging ---
  signal-desktop       # Signal messaging client
  discord              # Discord messaging client
 
  # --- Remote Access ---
  remmina              # Remote desktop and VNC client

  # --- Proton Services ---
  protonmail-bridge    # ProtonMail Bridge (IMAP/SMTP integration)
  protonmail-bridge-gui
  protonmail-desktop   # ProtonMail Desktop Client
  proton-pass          # Proton Pass (password manager)
  protonvpn-gui        # Proton VPN (GUI client)

  # --- VPN Clients ---
  wireguard-tools      # WireGuard VPN (CLI tools)
  wg-netmanager        # WireGuard NetworkManager integration
  openvpn
  networkmanager-openvpn # OpenVPN support for NetworkManager
];
}
