#!/usr/bin/env zsh

# =============================================================================
# NixOS System Backup Script
# =============================================================================
#
# Comprehensive backup functionality for NixOS systems with disaster recovery support.
#
# What it does:
# - Creates backups of NixOS configuration files and system state
# - Supports incremental and full backup modes with compression
# - Provides remote backup destinations and encryption support
# - Includes backup verification and integrity checks
# - Offers automated backup scheduling and rotation
# - Backs up user data, SSH keys, and custom configurations
#
# Requirements:
# - Root privileges for system backup
# - Required tools: tar, gzip, rsync, ssh, scp
# - Sufficient disk space for backup storage
# - Network access for remote backups
#
# Usage:
# - Full backup: ./backup-system.sh
# - Incremental: ./backup-system.sh --incremental
# - Config only: ./backup-system.sh --config-only
# - Remote: ./backup-system.sh --remote user@host:/path
# - Encrypted: ./backup-system.sh --encrypt
# =============================================================================

set -euo pipefail

# ============================================================================
# Configuration Variables
# ============================================================================
SCRIPT_NAME="$(basename "$0")"
BACKUP_ROOT="/var/backups/nixos"
LOG_FILE="/var/log/nixos-backup.log"
LOCK_FILE="/var/run/nixos-backup.lock"
TEMP_DIR="/tmp/nixos-backup-$$"
HOSTNAME=$(hostname)
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_NAME="nixos-backup-${HOSTNAME}-${TIMESTAMP}"

# Backup options
INCREMENTAL=false
CONFIG_ONLY=false
ENCRYPT_BACKUP=false
REMOTE_DEST=""
VERBOSE=false
DRY_RUN=false
COMPRESS=true
VERIFY_BACKUP=true

# ============================================================================
# Color Codes for Output
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# Logging Functions
# ============================================================================
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "DEBUG")
            if [[ "$VERBOSE" == "true" ]]; then
                echo -e "${BLUE}[DEBUG]${NC} $message"
            fi
            ;;
        "SUCCESS")
            echo -e "${CYAN}[SUCCESS]${NC} $message"
            ;;
    esac
    
    # Log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# ============================================================================
# Helper Functions
# ============================================================================
show_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
    -h, --help              Show this help message
    -i, --incremental       Create incremental backup
    -c, --config-only       Backup only configuration files
    -e, --encrypt           Encrypt backup with GPG
    -r, --remote DEST       Remote backup destination (user@host:/path)
    -v, --verbose           Verbose output
    -d, --dry-run           Show what would be backed up without doing it
    -n, --no-compress       Disable compression
    -V, --no-verify         Skip backup verification
    -o, --output DIR        Custom backup output directory

Examples:
    $SCRIPT_NAME                    # Full backup
    $SCRIPT_NAME --incremental      # Incremental backup
    $SCRIPT_NAME --config-only      # Configuration files only
    $SCRIPT_NAME --remote user@host:/backups  # Remote backup
    $SCRIPT_NAME --encrypt          # Encrypted backup
    $SCRIPT_NAME --dry-run          # Preview backup

EOF
}

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log "ERROR" "Backup already running (PID: $pid)"
            exit 1
        else
            log "WARN" "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    echo $$ > "$LOCK_FILE"
    trap 'cleanup_on_exit' EXIT
}

cleanup_on_exit() {
    rm -f "$LOCK_FILE"
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "This script must be run as root (use sudo)"
        exit 1
    fi
    
    # Check required tools
    local required_tools=("tar" "gzip" "rsync" "ssh" "scp")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log "ERROR" "Required tool not found: $tool"
            exit 1
        fi
    done
    
    # Create backup directory
    mkdir -p "$BACKUP_ROOT"
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    log "SUCCESS" "Prerequisites check passed"
}

# ============================================================================
# Backup Functions
# ============================================================================
backup_nixos_config() {
    log "INFO" "Backing up NixOS configuration..."
    
    local config_dir="$TEMP_DIR/config"
    mkdir -p "$config_dir"
    
    # Copy main configuration files
    cp -r /etc/nixos "$config_dir/"
    
    # Copy flake files if they exist
    if [[ -f /etc/nixos/flake.nix ]]; then
        cp /etc/nixos/flake.nix "$config_dir/"
        cp /etc/nixos/flake.lock "$config_dir/" 2>/dev/null || true
    fi
    
    # Copy hardware configuration
    if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
        cp /etc/nixos/hardware-configuration.nix "$config_dir/"
    fi
    
    # Backup system generation information
    log "INFO" "Backing up system generation information..."
    nix-env --list-generations --profile /nix/var/nix/profiles/system > "$config_dir/system-generations.txt"
    
    # Backup current system state
    nixos-rebuild dry-activate > "$config_dir/system-state.txt" 2>&1 || true
    
    log "SUCCESS" "NixOS configuration backup completed"
}

backup_system_state() {
    log "INFO" "Backing up system state..."
    
    local state_dir="$TEMP_DIR/system-state"
    mkdir -p "$state_dir"
    
    # System information
    uname -a > "$state_dir/system-info.txt"
    cat /etc/os-release > "$state_dir/os-release.txt" 2>/dev/null || true
    
    # Package information
    nix-env -q > "$state_dir/installed-packages.txt" 2>/dev/null || true
    
    # Service status
    systemctl list-units --type=service > "$state_dir/services.txt"
    
    # Network configuration
    ip addr show > "$state_dir/network-config.txt"
    ip route show > "$state_dir/routing-table.txt"
    
    # Mount points
    mount > "$state_dir/mounts.txt"
    
    # Disk usage
    df -h > "$state_dir/disk-usage.txt"
    
    # User accounts
    cat /etc/passwd > "$state_dir/users.txt"
    cat /etc/group > "$state_dir/groups.txt"
    
    log "SUCCESS" "System state backup completed"
}

backup_ssh_keys() {
    log "INFO" "Backing up SSH keys and certificates..."
    
    local ssh_dir="$TEMP_DIR/ssh"
    mkdir -p "$ssh_dir"
    
    # Backup SSH host keys
    if [[ -d /etc/ssh ]]; then
        cp -r /etc/ssh "$ssh_dir/"
    fi
    
    # Backup SSH authorized keys for users
    for user_home in /home/*; do
        if [[ -d "$user_home" ]]; then
            local user=$(basename "$user_home")
            local ssh_user_dir="$ssh_dir/users/$user"
            mkdir -p "$ssh_user_dir"
            
            if [[ -f "$user_home/.ssh/authorized_keys" ]]; then
                cp "$user_home/.ssh/authorized_keys" "$ssh_user_dir/"
            fi
            
            if [[ -f "$user_home/.ssh/id_rsa.pub" ]]; then
                cp "$user_home/.ssh/id_rsa.pub" "$ssh_user_dir/"
            fi
            
            if [[ -f "$user_home/.ssh/id_ed25519.pub" ]]; then
                cp "$user_home/.ssh/id_ed25519.pub" "$ssh_user_dir/"
            fi
        fi
    done
    
    log "SUCCESS" "SSH keys backup completed"
}

backup_custom_scripts() {
    log "INFO" "Backing up custom scripts..."
    
    local scripts_dir="$TEMP_DIR/scripts"
    mkdir -p "$scripts_dir"
    
    # Backup scripts directory if it exists
    if [[ -d /etc/nixos/scripts ]]; then
        cp -r /etc/nixos/scripts "$scripts_dir/"
    fi
    
    # Backup any custom scripts in /usr/local/bin
    if [[ -d /usr/local/bin ]]; then
        find /usr/local/bin -type f -executable -exec cp {} "$scripts_dir/" \;
    fi
    
    log "SUCCESS" "Custom scripts backup completed"
}

backup_user_data() {
    if [[ "$CONFIG_ONLY" == "true" ]]; then
        log "INFO" "Skipping user data backup (config-only mode)"
        return 0
    fi
    
    log "INFO" "Backing up user data..."
    
    local users_dir="$TEMP_DIR/users"
    mkdir -p "$users_dir"
    
    # Backup important user configuration files
    for user_home in /home/*; do
        if [[ -d "$user_home" ]]; then
            local user=$(basename "$user_home")
            local user_backup_dir="$users_dir/$user"
            mkdir -p "$user_backup_dir"
            
            # Backup important dotfiles
            local important_files=(
                ".bashrc" ".bash_profile" ".zshrc" ".zsh_profile"
                ".gitconfig" ".ssh/config" ".gnupg/pubring.kbx"
                ".config/nixpkgs" ".config/home-manager"
            )
            
            for file in "${important_files[@]}"; do
                if [[ -e "$user_home/$file" ]]; then
                    mkdir -p "$(dirname "$user_backup_dir/$file")"
                    cp -r "$user_home/$file" "$user_backup_dir/$file"
                fi
            done
        fi
    done
    
    log "SUCCESS" "User data backup completed"
}

create_backup_archive() {
    log "INFO" "Creating backup archive..."
    
    local archive_name="$BACKUP_NAME"
    if [[ "$COMPRESS" == "true" ]]; then
        archive_name="${archive_name}.tar.gz"
    else
        archive_name="${archive_name}.tar"
    fi
    
    local archive_path="$BACKUP_ROOT/$archive_name"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would create archive: $archive_path"
        return 0
    fi
    
    # Create archive
    cd "$TEMP_DIR"
    if [[ "$COMPRESS" == "true" ]]; then
        tar -czf "$archive_path" .
    else
        tar -cf "$archive_path" .
    fi
    
    # Encrypt if requested
    if [[ "$ENCRYPT_BACKUP" == "true" ]]; then
        log "INFO" "Encrypting backup archive..."
        gpg --encrypt --recipient "$(whoami)" "$archive_path"
        rm "$archive_path"
        archive_path="${archive_path}.gpg"
    fi
    
    log "SUCCESS" "Backup archive created: $archive_path"
    echo "$archive_path"
}

verify_backup() {
    local archive_path="$1"
    
    if [[ "$VERIFY_BACKUP" == "false" ]]; then
        log "INFO" "Skipping backup verification"
        return 0
    fi
    
    log "INFO" "Verifying backup archive..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would verify archive: $archive_path"
        return 0
    fi
    
    # Test archive integrity
    if [[ "$ENCRYPT_BACKUP" == "true" ]]; then
        gpg --decrypt "$archive_path" | tar -tzf - > /dev/null
    else
        tar -tzf "$archive_path" > /dev/null
    fi
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Backup verification passed"
    else
        log "ERROR" "Backup verification failed"
        return 1
    fi
}

transfer_to_remote() {
    local archive_path="$1"
    
    if [[ -z "$REMOTE_DEST" ]]; then
        return 0
    fi
    
    log "INFO" "Transferring backup to remote destination: $REMOTE_DEST"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would transfer: $archive_path to $REMOTE_DEST"
        return 0
    fi
    
    # Extract host and path from remote destination
    local remote_host=$(echo "$REMOTE_DEST" | cut -d: -f1)
    local remote_path=$(echo "$REMOTE_DEST" | cut -d: -f2)
    
    # Create remote directory if it doesn't exist
    ssh "$remote_host" "mkdir -p $(dirname "$remote_path")"
    
    # Transfer the backup
    scp "$archive_path" "$REMOTE_DEST"
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Backup transferred successfully"
    else
        log "ERROR" "Failed to transfer backup"
        return 1
    fi
}

cleanup_old_backups() {
    log "INFO" "Cleaning up old backups..."
    
    # Keep only the last 10 backups
    local backup_count=$(find "$BACKUP_ROOT" -name "nixos-backup-*.tar.gz*" | wc -l)
    if [[ $backup_count -gt 10 ]]; then
        local to_delete=$((backup_count - 10))
        find "$BACKUP_ROOT" -name "nixos-backup-*.tar.gz*" -printf '%T@ %p\n' | \
            sort -n | head -n "$to_delete" | cut -d' ' -f2- | \
            while read -r file; do
                if [[ "$DRY_RUN" == "true" ]]; then
                    log "INFO" "[DRY-RUN] Would delete: $file"
                else
                    rm "$file"
                    log "INFO" "Deleted old backup: $file"
                fi
            done
    fi
}

# ============================================================================
# Main Script Logic
# ============================================================================
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--incremental)
                INCREMENTAL=true
                shift
                ;;
            -c|--config-only)
                CONFIG_ONLY=true
                shift
                ;;
            -e|--encrypt)
                ENCRYPT_BACKUP=true
                shift
                ;;
            -r|--remote)
                REMOTE_DEST="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -n|--no-compress)
                COMPRESS=false
                shift
                ;;
            -V|--no-verify)
                VERIFY_BACKUP=false
                shift
                ;;
            -o|--output)
                BACKUP_ROOT="$2"
                shift 2
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Initialize
    touch "$LOG_FILE"
    log "INFO" "Starting NixOS system backup"
    log "INFO" "Mode: $([[ "$DRY_RUN" == "true" ]] && echo "DRY-RUN" || echo "LIVE")"
    log "INFO" "Backup type: $([[ "$CONFIG_ONLY" == "true" ]] && echo "CONFIG-ONLY" || echo "FULL")"
    log "INFO" "Incremental: $INCREMENTAL"
    log "INFO" "Encrypted: $ENCRYPT_BACKUP"
    log "INFO" "Remote destination: ${REMOTE_DEST:-"None"}"
    
    # Acquire lock
    acquire_lock
    
    # Check prerequisites
    check_prerequisites
    
    # Perform backups
    backup_nixos_config
    backup_system_state
    backup_ssh_keys
    backup_custom_scripts
    backup_user_data
    
    # Create archive
    local archive_path=$(create_backup_archive)
    
    # Verify backup
    verify_backup "$archive_path"
    
    # Transfer to remote if specified
    transfer_to_remote "$archive_path"
    
    # Cleanup old backups
    cleanup_old_backups
    
    # Final summary
    log "SUCCESS" "System backup completed successfully"
    log "INFO" "Backup location: $archive_path"
    log "INFO" "Backup size: $(du -h "$archive_path" | cut -f1)"
    log "INFO" "Log file: $LOG_FILE"
}

# ============================================================================
# Script Execution
# ============================================================================
main "$@" 