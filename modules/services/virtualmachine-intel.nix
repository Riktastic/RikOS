# Virtual Machine Management Suite
#
# This suite provides tools for managing virtual machines on NixOS, with a focus on KVM/QEMU integration.
#
# Packages are grouped and ordered as follows:
#   1. Virtual Machine Managers (GUI and CLI)
#   2. Virtualization Backends (QEMU, libvirt)
#   3. Remote Display & Integration (SPICE, etc.)
#
# --- NixOS Configuration for KVM/QEMU/Libvirt ---
# Add the following to your configuration.nix:
#
#   virtualisation.libvirtd.enable = true;
#   users.groups.libvirtd.members = [ "yourusername" ];
#   virtualisation.spiceUSBRedirection.enable = true; # Optional, for USB redirection
#   boot.kernelModules = [ "kvm-intel" "kvm-amd" ]; # Use the one matching your CPU
#   environment.systemPackages = with pkgs; [ virt-manager ]; # Or import this suite
#
# After rebuilding, add your user to the 'libvirtd' group and reboot or re-login.
#
{ config, pkgs, lib, ... }:

{
  # Enable libvirt daemon for VM management
  virtualisation.libvirtd.enable = true;

  # (Optional) Enable USB redirection via SPICE
  virtualisation.spiceUSBRedirection.enable = true;

  # Load the appropriate KVM kernel module(s) for your CPU
  # Use "kvm-intel" for Intel CPUs, "kvm-amd" for AMD CPUs
  boot.kernelModules = [ "kvm-intel" ];

  # Install VM management and virtualization tools system-wide
  environment.systemPackages = with pkgs; [
    # --- Virtual Machine Managers ---
    virt-manager
    virt-viewer

    # --- Virtualization Backends ---
    qemu_full
    libvirt

    # --- Remote Display & Integration ---
    spice-gtk
    spice
    spice-protocol
  ];
}
