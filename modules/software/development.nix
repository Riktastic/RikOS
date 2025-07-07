# Development Suite
#
# This suite provides general-purpose development tools and editors for multiple languages and workflows.
# Supports both desktop (GUI + CLI) and server (CLI only) modes.
#
# Packages are grouped and ordered as follows:
#   1. Editors & IDEs (code editors, IDEs)
#   2. Version Control & Diff (version control, diff/merge tools)
#   3. Compilers & Build Tools (compilers, build systems)
#   4. Containers & Virtualization (containerization, virtualization)
#   5. Utilities (formatters, linters, JSON tools, build helpers)
#
{ config, pkgs, lib, ... }:

let
  cfg = config.device;
in
{
  environment.systemPackages = with pkgs; [
    # --- Core Development Tools (Both modes) ---
    git                # Version control
    gcc                # C/C++ compiler
    gdb                # Debugger
    cmake              # Build system
    jq                 # JSON processor
    shellcheck         # Shell script linter
    nixpkgs-fmt        # Nix formatter
    pkg-config         # Build helper for native dependencies
    sshfs              # To map remote servers to local directories
    vim                # Terminal text editor
    nano                # Simple terminal editor
    micro               # Modern terminal editor
    tmux                # Terminal multiplexer
    screen              # Terminal multiplexer (alternative)

    # --- Desktop-specific tools ---
  ] ++ lib.optionals (cfg.mode == "desktop") [
    vscodium           # Code editor (open source build)
    code-cursor        # AI extended VSCode
    meld               # Diff/merge tool (GUI)
  ];
}
