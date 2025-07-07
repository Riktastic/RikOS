#!/usr/bin/env zsh

set -euo pipefail

LOGFILE="/var/log/setup-encrypted-disk.log"

# Logging function
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  echo "$msg"
  echo "$msg" >> "$LOGFILE"
}

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  log "ERROR: This script must be run as root!"
  exit 1
fi

log "=== Script started ==="

# Ask for device name
read "DEV?Enter the device name to format (e.g., sda or sdb): "
DEVICE="/dev/${DEV}"

# Confirm device exists
if [[ ! -b $DEVICE ]]; then
  log "ERROR: Device $DEVICE does not exist!"
  exit 1
fi

log "User selected device: $DEVICE"
echo "WARNING: This will DELETE ALL DATA and partition table on $DEVICE!"
read "CONFIRM?Type YES to continue: "
if [[ "$CONFIRM" != "YES" ]]; then
  log "User aborted at confirmation prompt."
  echo "Aborted."
  exit 1
fi

# Zap partition table and create a new GPT partition
log "Wiping partition table and creating new partition on $DEVICE..."
sgdisk --zap-all "$DEVICE"
sgdisk -o "$DEVICE"
sgdisk -n 1:0:0 -t 1:8300 "$DEVICE"
partprobe "$DEVICE"

PART="${DEVICE}1"
sleep 2

# Confirm partition exists
if [[ ! -b $PART ]]; then
  log "ERROR: Partition $PART does not exist!"
  exit 1
fi

log "Partition created: $PART"

# Ask for LUKS label
read "LABEL?Enter a label for the LUKS mapping (e.g., mydata): "
log "Using LUKS label: $LABEL"

# LUKS format and open
log "Encrypting $PART with LUKS..."
cryptsetup luksFormat "$PART"
cryptsetup open "$PART" "$LABEL"
log "LUKS device opened as /dev/mapper/$LABEL"

# Create keyfile directory if needed
mkdir -p /etc/secrets/initrd/

# Keyfile is named after the label
KEYFILE="/etc/secrets/initrd/${LABEL}-keyfile"
log "Generating keyfile at $KEYFILE"
dd if=/dev/urandom of="$KEYFILE" bs=1024 count=4
chmod 0400 "$KEYFILE"
log "Keyfile created and permissions set."

# Add keyfile to LUKS
cryptsetup luksAddKey "$PART" "$KEYFILE"
log "Keyfile added to LUKS slot."

# Format the mapped device
log "Formatting /dev/mapper/$LABEL as ext4..."
mkfs.ext4 "/dev/mapper/$LABEL"
log "Filesystem created."

# Get UUID
UUID=$(blkid -s UUID -o value "$PART")
HOSTNAME=$(hostname)
NIXCFG="/etc/nixos/devices/${HOSTNAME}.nix"

# Add NixOS config
log "Adding NixOS configuration to $NIXCFG..."

cat <<EOF >> "$NIXCFG"

# $LABEL on $DEVICE
boot.initrd.luks.devices."$LABEL" = {
  device = "/dev/disk/by-uuid/$UUID";
  keyFile = "/${LABEL}-keyfile";
};

fileSystems."/mnt/$LABEL" = {
  device = "/dev/mapper/$LABEL";
  fsType = "ext4";
};
EOF

log "NixOS configuration updated: $NIXCFG"

echo "Done!"
echo "Add this to your /etc/nixos/configuration.nix if not already included:"
echo "  imports = [ ./devices/${HOSTNAME}.nix ];"
echo "Remember to run 'nixos-rebuild switch' and reboot to use the new disk."

log "=== Script finished successfully ==="
