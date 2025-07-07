# Node.js Development Suite
#
# This suite provides tools for Node.js and JavaScript/TypeScript development.
# Supports both desktop (GUI + CLI) and server (CLI only) modes.
#
# Packages are grouped and ordered as follows:
#   1. Node.js Toolchain (runtime, npm, yarn)
#   2. Code Quality & Utilities (TypeScript, linter, formatter, nodemon)
#
{ config, pkgs, lib, ... }:

let
  cfg = config.device;
in
{
  environment.systemPackages = with pkgs; [
    # --- Core Node.js Tools (Both modes) ---
    nodejs                 # JavaScript runtime
    nodePackages.npm       # Node package manager
    yarn                   # Alternative package manager
    nodePackages.typescript # TypeScript language
    nodePackages.eslint    # JavaScript linter
    nodePackages.prettier  # Code formatter
    nodePackages.nodemon   # Auto-restart for Node.js
    nodePackages.pm2       # Process manager for Node.js
  ] ++ lib.optionals (cfg.mode == "desktop") [
    # --- Desktop-specific tools ---
    # (No additional GUI tools needed for Node.js development)
  ];
}
