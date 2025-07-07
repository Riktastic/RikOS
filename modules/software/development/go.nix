# Go Development Suite
#
# This suite provides tools for Go development, code quality, and debugging.
# Supports both desktop (GUI + CLI) and server (CLI only) modes.
#
# Packages are grouped and ordered as follows:
#   1. Go Toolchain (compiler, language server)
#   2. Code Quality & Utilities (debugger, linter, tools)
#
{ config, pkgs, lib, ... }:

let
  cfg = config.device;
in
{
  environment.systemPackages = with pkgs; [
    # --- Core Go Tools (Both modes) ---
    go                   # Go compiler
    gopls                # Go language server
    delve                # Go debugger
    golangci-lint        # Go linter
    gotools              # Go tools
    go-tools             # Additional Go tools
    goreleaser           # Go release automation
    air                  # Live reload for Go apps
    gofumpt              # Go formatter
    gosec                # Go security linter
  ] ++ lib.optionals (cfg.mode == "desktop") [
    # --- Desktop-specific tools ---
    # (No additional GUI tools needed for Go development)
  ];
}
