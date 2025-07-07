# Rust Development Suite
#
# This suite provides tools for Rust development, code quality, and database integration.
#
# Packages are grouped and ordered as follows:
#   1. Rust Toolchain (compiler, package manager, language server)
#   2. Code Quality & Utilities (linter, formatter, cargo tools)
#   3. Database & Migration (SQLx CLI)
#
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  # --- Rust Toolchain ---
  rustc              # Rust compiler
  cargo              # Rust package manager
  rust-analyzer      # Language server for Rust

  # --- Code Quality & Utilities ---
  clippy             # Rust linter
  rustfmt            # Rust code formatter
  cargo-edit         # Manage cargo dependencies

  # --- Database & Migration ---
  sqlx-cli           # SQLx migration tool
]; 
}
