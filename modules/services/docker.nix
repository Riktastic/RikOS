  # Docker Suite
#
# This suite provides tools for containerization and container orchestration using Docker and Docker Compose.
#
# Packages are grouped and ordered as follows:
#   1. Docker Engine (core Docker tools)
#   2. Docker Compose (compose and orchestration)
#   3. Utilities (completion, CLI tools)
#
# --- NixOS Configuration for Docker ---
# Add the following to your configuration.nix:
#
#   virtualisation.docker.enable = true;
#   users.groups.docker.members = [ "yourusername" ];
#   environment.systemPackages = with pkgs; [ docker-compose ]; # Or import this suite
#
# After rebuilding, add your user to the 'docker' group and reboot or re-login.
#

{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = true;

  # Add Docker-related tools to the system packages
  environment.systemPackages = with pkgs; [
    # --- Docker Engine ---
    docker

    # --- Docker Compose ---
    docker-compose
  ];
}
