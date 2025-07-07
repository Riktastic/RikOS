#!/usr/bin/env zsh

# =============================================================================
# NixOS System Update Script
# =============================================================================
#
# Provides safe and comprehensive system updates for NixOS installations.
#
# What it does:
# - Updates Nix channels and builds new system configuration
# - Performs safety checks and health verification
# - Activates new configuration with rollback capabilities
# - Provides multiple update modes (full, channels-only, build-only)
#
# Requirements:
# - Root privileges
# - Nix and nixos-rebuild available
# - Sufficient disk space for updates
#
# Usage:
# - ./update-system.sh: Full system update
# - ./update-system.sh --channels-only: Update channels only
# - ./update-system.sh --build-only: Build configuration only
# - ./update-system.sh --dry-run: Preview update
# =============================================================================

set -euo pipefail

# ============================================================================
# Configuration Variables
# ============================================================================
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/var/log/nixos-update.log"
LOCK_FILE="/var/run/nixos-update.lock"
BACKUP_DIR="/var/backups/nixos-updates"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Update options
CHANNELS_ONLY=false
BUILD_ONLY=false
DRY_RUN=false
AUTO_MODE=false
VERBOSE=false
SKIP_CHECKS=false
FORCE_UPDATE=false

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
    -h, --help          Show this help message
    -c, --channels-only Update Nix channels only
    -b, --build-only    Build system configuration only
    -d, --dry-run       Show what would be updated without doing it
    -a, --auto          Automatic mode (non-interactive)
    -v, --verbose       Verbose output
    -s, --skip-checks   Skip pre-update health checks
    -f, --force         Force update even if checks fail
    -r, --rollback      Rollback to previous generation

Examples:
    $SCRIPT_NAME                    # Full system update
    $SCRIPT_NAME --channels-only    # Update channels only
    $SCRIPT_NAME --build-only       # Build configuration only
    $SCRIPT_NAME --dry-run          # Preview update
    $SCRIPT_NAME --auto             # Automatic update
    $SCRIPT_NAME --rollback         # Rollback to previous generation

EOF
}

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log "ERROR" "Update already running (PID: $pid)"
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
}

check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "This script must be run as root (use sudo)"
        exit 1
    fi
    
    # Check if Nix is available
    if ! command -v nix-env >/dev/null 2>&1; then
        log "ERROR" "Nix is not available or not in PATH"
        exit 1
    fi
    
    # Check if nixos-rebuild is available
    if ! command -v nixos-rebuild >/dev/null 2>&1; then
        log "ERROR" "nixos-rebuild is not available"
        exit 1
    fi
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    log "SUCCESS" "Prerequisites check passed"
}

# ============================================================================
# System Health Checks
# ============================================================================
check_system_health() {
    if [[ "$SKIP_CHECKS" == "true" ]]; then
        log "INFO" "Skipping system health checks"
        return 0
    fi
    
    log "INFO" "Performing system health checks..."
    
    local health_ok=true
    
    # Check disk space
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 90 ]]; then
        log "WARN" "Disk usage is high: ${disk_usage}%"
        if [[ "$FORCE_UPDATE" == "false" ]]; then
            health_ok=false
        fi
    else
        log "SUCCESS" "Disk usage is acceptable: ${disk_usage}%"
    fi
    
    # Check for failed services
    local failed_services=$(systemctl --failed --no-legend | wc -l)
    if [[ $failed_services -gt 0 ]]; then
        log "WARN" "Found $failed_services failed services"
        systemctl --failed
        if [[ "$FORCE_UPDATE" == "false" ]]; then
            health_ok=false
        fi
    else
        log "SUCCESS" "No failed services found"
    fi
    
    # Check system load
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local load_threshold=5.0
    if (( $(echo "$load_avg > $load_threshold" | bc -l) )); then
        log "WARN" "System load is high: $load_avg"
        if [[ "$FORCE_UPDATE" == "false" ]]; then
            health_ok=false
        fi
    else
        log "SUCCESS" "System load is acceptable: $load_avg"
    fi
    
    # Check memory usage
    local mem_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    if (( $(echo "$mem_usage > 90" | bc -l) )); then
        log "WARN" "Memory usage is high: ${mem_usage}%"
        if [[ "$FORCE_UPDATE" == "false" ]]; then
            health_ok=false
        fi
    else
        log "SUCCESS" "Memory usage is acceptable: ${mem_usage}%"
    fi
    
    if [[ "$health_ok" == "false" ]]; then
        log "ERROR" "System health checks failed"
        if [[ "$AUTO_MODE" == "false" ]]; then
            read -p "Continue with update anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            exit 1
        fi
    fi
    
    log "SUCCESS" "System health checks passed"
}

# ============================================================================
# Backup Functions
# ============================================================================
create_system_snapshot() {
    log "INFO" "Creating system snapshot..."
    
    local snapshot_dir="$BACKUP_DIR/snapshot-$TIMESTAMP"
    mkdir -p "$snapshot_dir"
    
    # Backup current system state
    nix-env --list-generations --profile /nix/var/nix/profiles/system > "$snapshot_dir/generations.txt"
    
    # Backup current configuration
    if [[ -d /etc/nixos ]]; then
        cp -r /etc/nixos "$snapshot_dir/"
    fi
    
    # Backup service status
    systemctl list-units --type=service > "$snapshot_dir/services.txt"
    
    # Backup system information
    uname -a > "$snapshot_dir/system-info.txt"
    cat /etc/os-release > "$snapshot_dir/os-release.txt" 2>/dev/null || true
    
    log "SUCCESS" "System snapshot created: $snapshot_dir"
    echo "$snapshot_dir"
}

# ============================================================================
# Update Functions
# ============================================================================
update_channels() {
    log "INFO" "Updating Nix channels..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would update Nix channels"
        return 0
    fi
    
    # Update all channels
    nix-channel --update
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Nix channels updated successfully"
    else
        log "ERROR" "Failed to update Nix channels"
        return 1
    fi
}

build_system() {
    log "INFO" "Building system configuration..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would build system configuration"
        return 0
    fi
    
    # Build the system configuration
    nixos-rebuild build
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "System configuration built successfully"
    else
        log "ERROR" "Failed to build system configuration"
        return 1
    fi
}

activate_system() {
    log "INFO" "Activating new system configuration..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would activate system configuration"
        return 0
    fi
    
    # Activate the new configuration
    nixos-rebuild switch
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "System configuration activated successfully"
    else
        log "ERROR" "Failed to activate system configuration"
        return 1
    fi
}

# ============================================================================
# Verification Functions
# ============================================================================
verify_update() {
    log "INFO" "Verifying system update..."
    
    # Check if system is bootable
    log "INFO" "Checking system bootability..."
    nixos-rebuild dry-activate > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "System is bootable"
    else
        log "ERROR" "System is not bootable"
        return 1
    fi
    
    # Check critical services
    log "INFO" "Checking critical services..."
    local critical_services=("sshd" "systemd-logind" "NetworkManager")
    local service_ok=true
    
    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log "SUCCESS" "Service $service is running"
        else
            log "ERROR" "Service $service is not running"
            service_ok=false
        fi
    done
    
    if [[ "$service_ok" == "false" ]]; then
        log "ERROR" "Critical service verification failed"
        return 1
    fi
    
    # Check for failed services
    local failed_services=$(systemctl --failed --no-legend | wc -l)
    if [[ $failed_services -gt 0 ]]; then
        log "WARN" "Found $failed_services failed services after update"
        systemctl --failed
    else
        log "SUCCESS" "No failed services after update"
    fi
    
    log "SUCCESS" "System update verification completed"
}

# ============================================================================
# Rollback Functions
# ============================================================================
rollback_system() {
    log "INFO" "Rolling back system..."
    
    # Get current and previous generations
    local current_gen=$(nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
    local previous_gen=$(nix-env --list-generations --profile /nix/var/nix/profiles/system | grep -v current | tail -1 | awk '{print $1}')
    
    if [[ -z "$previous_gen" ]]; then
        log "ERROR" "No previous generation found for rollback"
        return 1
    fi
    
    log "INFO" "Rolling back from generation $current_gen to $previous_gen"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would rollback to generation $previous_gen"
        return 0
    fi
    
    # Switch to previous generation
    nix-env --switch-generation "$previous_gen" --profile /nix/var/nix/profiles/system
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "System rolled back to generation $previous_gen"
        log "INFO" "Reboot required to complete rollback"
    else
        log "ERROR" "Failed to rollback system"
        return 1
    fi
}

show_generations() {
    log "INFO" "Available system generations:"
    nix-env --list-generations --profile /nix/var/nix/profiles/system
}

# ============================================================================
# Main Update Process
# ============================================================================
perform_update() {
    local snapshot_dir=""
    
    # Create system snapshot
    snapshot_dir=$(create_system_snapshot)
    
    # Update channels
    if [[ "$CHANNELS_ONLY" == "false" ]]; then
        update_channels
    fi
    
    # Build system
    if [[ "$BUILD_ONLY" == "false" ]]; then
        build_system
    fi
    
    # Activate system
    if [[ "$CHANNELS_ONLY" == "false" && "$BUILD_ONLY" == "false" ]]; then
        activate_system
        
        # Verify update
        verify_update
    fi
    
    # Show generation information
    show_generations
    
    log "SUCCESS" "System update completed successfully"
    log "INFO" "Snapshot saved to: $snapshot_dir"
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
            -c|--channels-only)
                CHANNELS_ONLY=true
                shift
                ;;
            -b|--build-only)
                BUILD_ONLY=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -a|--auto)
                AUTO_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -s|--skip-checks)
                SKIP_CHECKS=true
                shift
                ;;
            -f|--force)
                FORCE_UPDATE=true
                shift
                ;;
            -r|--rollback)
                rollback_system
                exit 0
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
    log "INFO" "Starting NixOS system update"
    log "INFO" "Mode: $([[ "$DRY_RUN" == "true" ]] && echo "DRY-RUN" || echo "LIVE")"
    log "INFO" "Channels only: $CHANNELS_ONLY"
    log "INFO" "Build only: $BUILD_ONLY"
    log "INFO" "Auto mode: $AUTO_MODE"
    
    # Acquire lock
    acquire_lock
    
    # Check prerequisites
    check_prerequisites
    
    # Perform health checks
    check_system_health
    
    # Perform update
    perform_update
    
    # Final summary
    log "SUCCESS" "System update process completed"
    log "INFO" "Log file: $LOG_FILE"
}

# ============================================================================
# Script Execution
# ============================================================================
main "$@" 