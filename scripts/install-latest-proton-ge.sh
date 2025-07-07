#!/usr/bin/env bash

# =============================================================================
# Install Latest Proton-GE Script
# =============================================================================
#
# Downloads and installs the latest Proton-GE release into the Steam compatibility tools directory.
#
# What it does:
# - Fetches the latest Proton-GE release from GitHub
# - Downloads and extracts it to ~/.steam/root/compatibilitytools.d
# - Optionally cleans up old Proton-GE versions
#
# Requirements:
# - curl, jq, tar, unzip
# - Sufficient disk space in home directory
# - Steam installed and run at least once
#
# Usage:
#   ./install-latest-proton-ge.sh
# =============================================================================

set -euo pipefail

GITHUB_API="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"
STEAM_COMPAT_DIR="$HOME/.steam/root/compatibilitytools.d"

# Ensure required tools are installed
for tool in curl jq tar unzip; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Error: $tool is required but not installed." >&2
    exit 1
  fi
done

# Create compatibility tools directory if it doesn't exist
mkdir -p "$STEAM_COMPAT_DIR"

# Fetch latest release info
echo "Fetching latest Proton-GE release info..."
RELEASE_JSON=$(curl -sSL "$GITHUB_API")
LATEST_TAG=$(echo "$RELEASE_JSON" | jq -r .tag_name)
ASSET_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | endswith(".tar.gz")) | .browser_download_url')
ASSET_NAME=$(basename "$ASSET_URL")

if [[ -z "$ASSET_URL" ]]; then
  echo "Error: Could not find Proton-GE tar.gz asset in the latest release." >&2
  exit 1
fi

# Download the latest Proton-GE release
echo "Downloading $ASSET_NAME..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -L -o "$ASSET_NAME" "$ASSET_URL"

# Extract to compatibility tools directory
echo "Extracting $ASSET_NAME to $STEAM_COMPAT_DIR..."
tar -xzf "$ASSET_NAME" -C "$STEAM_COMPAT_DIR"

# Clean up temporary files
cd ~
rm -rf "$TMP_DIR"

echo "Proton-GE $LATEST_TAG installed to $STEAM_COMPAT_DIR."

# Optional: Clean up old Proton-GE versions (keep the latest)
cd "$STEAM_COMPAT_DIR"
GE_DIRS=(GE-Proton*)
if [[ ${#GE_DIRS[@]} -gt 1 ]]; then
  echo "Cleaning up old Proton-GE versions..."
  # Sort and keep the latest, remove the rest
  LATEST_DIR=$(ls -d GE-Proton* | sort -V | tail -n 1)
  for dir in GE-Proton*; do
    if [[ "$dir" != "$LATEST_DIR" ]]; then
      echo "Removing old version: $dir"
      rm -rf "$dir"
    fi
  done
fi

echo "Done. Restart Steam to use the new Proton-GE." 