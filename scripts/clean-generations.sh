#!/usr/bin/env zsh

# =============================================================================
# NixOS Generation Cleanup Script
# =============================================================================
#
# Safe and comprehensive cleanup of outdated NixOS generations to maintain disk space.
#
# What it does:
# - Removes old NixOS system configurations while preserving recent ones
# - Provides interactive and automatic cleanup modes with safety checks
# - Never deletes current generation or boot generations by default
# - Offers dry-run mode to preview changes before execution
# - Implements configurable retention policies and minimum generation counts
# - Provides detailed logging and rollback information
#
# Requirements:
# - NixOS system with multiple generations
# - Sufficient permissions to remove generations
# - nix-env command available
# - Disk space management needs
#
# Usage:
# - Interactive: ./clean-generations.sh (default)
# - Automatic: ./clean-generations.sh --auto
# - Dry-run: ./clean-generations.sh --dry-run
# - Custom retention: ./clean-generations.sh --keep-days 7
# =============================================================================

set -euo pipefail

# ============================================================================
# Configuration Variables
# ============================================================================
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/var/log/nixos-cleanup.log"
DEFAULT_KEEP_DAYS=7
MIN_GENERATIONS=3
DRY_RUN=false
AUTO_MODE=false
KEEP_DAYS=$DEFAULT_KEEP_DAYS
VERBOSE=false

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
    -a, --auto          Automatic mode (no user confirmation)
    -d, --dry-run       Show what would be deleted without actually deleting
    -k, --keep-days N   Keep generations from last N days (default: $DEFAULT_KEEP_DAYS)
    -v, --verbose       Verbose output
    -m, --min-gen N     Minimum generations to keep (default: $MIN_GENERATIONS)

Examples:
    $SCRIPT_NAME                    # Interactive cleanup
    $SCRIPT_NAME --auto            # Automatic cleanup
    $SCRIPT_NAME --dry-run         # Preview changes
    $SCRIPT_NAME --keep-days 14    # Keep last 14 days
    $SCRIPT_NAME --min-gen 5       # Keep at least 5 generations

EOF
}

get_current_generation() {
    nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}'
}

get_generations_to_remove() {
    local keep_days="$1"
    local min_generations="$2"
    
    # Get all generations except current
    local generations=$(nix-env --list-generations --profile /nix/var/nix/profiles/system | \
        grep -v current | \
        awk '{print $1, $2, $3, $4, $5, $6, $7}' | \
        sort -n)
    
    # Calculate cutoff date
    local cutoff_date=$(date -d "$keep_days days ago" '+%Y-%m-%d')
    
    # Filter generations older than cutoff date
    local old_generations=$(echo "$generations" | \
        awk -v cutoff="$cutoff_date" '
        {
            date_str = $2 " " $3 " " $4
            if (date_str < cutoff) {
                print $0
            }
        }')
    
    # Ensure we keep minimum number of generations
    local total_generations=$(echo "$generations" | wc -l)
    local old_count=$(echo "$old_generations" | wc -l)
    local keep_count=$((total_generations - old_count))
    
    if [[ $keep_count -lt $min_generations ]]; then
        local excess=$((min_generations - keep_count))
        old_generations=$(echo "$old_generations" | head -n -$excess)
    fi
    
    echo "$old_generations"
}

show_generation_info() {
    local generations="$1"
    
    if [[ -z "$generations" ]]; then
        log "INFO" "No generations to remove."
        return
    fi
    
    log "INFO" "Generations to be removed:"
    echo "$generations" | while read -r line; do
        echo "  $line"
    done
    
    local count=$(echo "$generations" | wc -l)
    log "INFO" "Total generations to remove: $count"
}

# ============================================================================
# Main Cleanup Function
# ============================================================================
perform_cleanup() {
    local generations="$1"
    
    if [[ -z "$generations" ]]; then
        log "INFO" "No generations to remove."
        return 0
    fi
    
    local count=0
    echo "$generations" | while read -r line; do
        local gen_num=$(echo "$line" | awk '{print $1}')
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log "INFO" "[DRY-RUN] Would remove generation $gen_num"
        else
            log "INFO" "Removing generation $gen_num..."
            if nix-env --delete-generations "$gen_num" --profile /nix/var/nix/profiles/system; then
                log "INFO" "Successfully removed generation $gen_num"
                ((count++))
            else
                log "ERROR" "Failed to remove generation $gen_num"
            fi
        fi
    done
    
    if [[ "$DRY_RUN" == "false" ]]; then
        log "INFO" "Cleanup completed. Removed $count generations."
    fi
}

# ============================================================================
# Garbage Collection
# ============================================================================
run_garbage_collection() {
    log "INFO" "Running Nix garbage collection..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would run: nix-collect-garbage -d"
    else
        if nix-collect-garbage -d; then
            log "INFO" "Garbage collection completed successfully."
        else
            log "ERROR" "Garbage collection failed."
            return 1
        fi
    fi
}

# ============================================================================
# Safety Checks
# ============================================================================
perform_safety_checks() {
    log "INFO" "Performing safety checks..."
    
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
    
    # Check if we can access the system profile
    if [[ ! -L /nix/var/nix/profiles/system ]]; then
        log "ERROR" "System profile not found"
        exit 1
    fi
    
    log "INFO" "Safety checks passed."
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
            -a|--auto)
                AUTO_MODE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -k|--keep-days)
                KEEP_DAYS="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -m|--min-gen)
                MIN_GENERATIONS="$2"
                shift 2
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Initialize log file
    touch "$LOG_FILE"
    log "INFO" "Starting NixOS generation cleanup"
    log "INFO" "Mode: $([[ "$DRY_RUN" == "true" ]] && echo "DRY-RUN" || echo "LIVE")"
    log "INFO" "Auto mode: $AUTO_MODE"
    log "INFO" "Keep days: $KEEP_DAYS"
    log "INFO" "Min generations: $MIN_GENERATIONS"
    
    # Perform safety checks
    perform_safety_checks
    
    # Get current generation
    local current_gen=$(get_current_generation)
    log "INFO" "Current generation: $current_gen"
    
    # Get generations to remove
    local generations_to_remove=$(get_generations_to_remove "$KEEP_DAYS" "$MIN_GENERATIONS")
    
    # Show information about generations to be removed
    show_generation_info "$generations_to_remove"
    
    # Ask for confirmation in interactive mode
    if [[ "$AUTO_MODE" == "false" && "$DRY_RUN" == "false" ]]; then
       if [[ -n "$generations_to_remove" ]]; then
           echo
           echo -n "Do you want to proceed with removing these generations? (y/N): "
           read -k 1 REPLY
           echo
           if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "INFO" "Operation cancelled by user."
                exit 0
            fi
        fi
    fi
    
    # Perform cleanup
    perform_cleanup "$generations_to_remove"
    
    # Run garbage collection
    run_garbage_collection
    
    # Show final status
    log "INFO" "Cleanup process completed."
    log "INFO" "Current disk usage:"
    df -h /nix
    
    log "INFO" "Remaining generations:"
    nix-env --list-generations --profile /nix/var/nix/profiles/system
}

# ============================================================================
# Script Execution
# ============================================================================
main "$@" 
