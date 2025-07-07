#!/usr/bin/env zsh

set -e  # Exit on error

# Simple status logger with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting Proton-GE auto-installer..."

# ----------------------------------------
# Detect Steam install type and set compatibilitytools.d path
# ----------------------------------------

if [ -d "$HOME/.var/app/com.valvesoftware.Steam/data/Steam" ]; then
    # Flatpak Steam installation detected
    STEAM_COMPAT_DIR="$HOME/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d"
    log "Detected Flatpak Steam installation."
elif [ -d "$HOME/.steam/steam" ]; then
    # Native Steam (older location) detected
    STEAM_COMPAT_DIR="$HOME/.steam/root/compatibilitytools.d"
    log "Detected native Steam installation (old path)."
elif [ -d "$HOME/.local/share/Steam" ]; then
    # Native Steam (newer location) detected
    STEAM_COMPAT_DIR="$HOME/.local/share/Steam/compatibilitytools.d"
    log "Detected native Steam installation (new path)."
else
    log "ERROR: Steam installation not found. Please run Steam at least once before using this script."
    exit 1
fi

# Create the compatibilitytools.d directory if it doesn't exist
mkdir -p "$STEAM_COMPAT_DIR"
log "Ensured compatibilitytools.d directory exists at: $STEAM_COMPAT_DIR"

# ----------------------------------------
# Get latest Proton-GE release tag from GitHub
# ----------------------------------------

GE_RELEASE_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

log "Fetching latest Proton-GE release info from GitHub..."
GE_TAG=$(curl -s "$GE_RELEASE_URL" | grep -Po '"tag_name": "\K.*?(?=")')
if [ -z "$GE_TAG" ]; then
    log "ERROR: Could not retrieve latest Proton-GE release tag."
    exit 1
fi
log "Latest Proton-GE release: $GE_TAG"

GE_TAR="GE-Proton${GE_TAG#GE-Proton}.tar.gz"
GE_DOWNLOAD_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$GE_TAG/$GE_TAR"

# ----------------------------------------
# Check if Proton-GE is already installed
# ----------------------------------------

if [ -d "$STEAM_COMPAT_DIR/$GE_TAG" ]; then
    log "Proton-GE $GE_TAG is already installed. Exiting."
    exit 0
fi

# ----------------------------------------
# Download and extract Proton-GE
# ----------------------------------------

TMPDIR=$(mktemp -d)
cd "$TMPDIR"
log "Created temporary directory: $TMPDIR"

log "Downloading $GE_TAR ..."
curl -LO "$GE_DOWNLOAD_URL"
log "Download complete."

log "Extracting $GE_TAR to $STEAM_COMPAT_DIR ..."
tar -xf "$GE_TAR" -C "$STEAM_COMPAT_DIR"
log "Extraction complete."

# Clean up temporary files
cd
rm -rf "$TMPDIR"
log "Cleaned up temporary files."

# ----------------------------------------
# Done!
# ----------------------------------------

log "Proton-GE $GE_TAG installed successfully!"
log "Restart Steam and select GE-Proton in Steam Play compatibility tools."
