#!/usr/bin/env zsh

# =============================================================================
# NixOS System Maintenance Script
# =============================================================================
#
# Provides comprehensive system maintenance for NixOS installations.
#
# What it does:
# - Performs system updates and package cache cleanup
# - Conducts system health checks and performance optimization
# - Applies security updates and log rotation
# - Manages disk space and service health monitoring
# - Provides modular task execution with comprehensive logging
#
# Requirements:
# - Root privileges
# - Nix and systemd available
# - Sufficient disk space for maintenance operations
#
# Usage:
# - ./system-maintenance.sh: Full maintenance
# - ./system-maintenance.sh --tasks update,cleanup: Specific tasks
# - ./system-maintenance.sh --dry-run: Preview changes
# - ./system-maintenance.sh --scheduled: Non-interactive mode
# =============================================================================

set -euo pipefail

# ============================================================================
# Configuration Variables
# ============================================================================
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/var/log/nixos-maintenance.log"
LOCK_FILE="/var/run/nixos-maintenance.lock"
DRY_RUN=false
SCHEDULED_MODE=false
VERBOSE=false
TASKS="update,cleanup,health,optimize,security,logs,disk,services"

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
    -d, --dry-run       Show what would be done without actually doing it
    -s, --scheduled     Run in scheduled mode (non-interactive)
    -v, --verbose       Verbose output
    -t, --tasks TASKS   Comma-separated list of tasks to run
    -l, --log-file FILE Custom log file path

Available Tasks:
    update    - System and package updates
    cleanup   - Cache and generation cleanup
    health    - System health checks
    optimize  - Performance optimization
    security  - Security updates and checks
    logs      - Log rotation and cleanup
    disk      - Disk space analysis and cleanup
    services  - Service health monitoring

Examples:
    $SCRIPT_NAME                    # Full maintenance
    $SCRIPT_NAME --tasks update,cleanup  # Specific tasks only
    $SCRIPT_NAME --dry-run          # Preview changes
    $SCRIPT_NAME --scheduled        # Non-interactive mode

EOF
}

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log "ERROR" "Maintenance already running (PID: $pid)"
            exit 1
        else
            log "WARN" "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT
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
    
    # Check if systemd is available
    if ! command -v systemctl >/dev/null 2>&1; then
        log "ERROR" "systemctl is not available"
        exit 1
    fi
    
    log "SUCCESS" "Prerequisites check passed"
}

# ============================================================================
# Maintenance Tasks
# ============================================================================
task_update() {
    log "INFO" "Starting system update task..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would run system updates"
        return 0
    fi
    
    # Update Nix channels
    log "INFO" "Updating Nix channels..."
    nix-channel --update
    
    # Update system
    log "INFO" "Updating system..."
    nixos-rebuild build
    
    # Check for available updates
    local available_updates=$(nixos-rebuild dry-activate 2>&1 | grep -c "would be activated" || echo "0")
    if [[ $available_updates -gt 0 ]]; then
        log "WARN" "System updates are available. Run 'nixos-rebuild switch' to apply them."
    else
        log "SUCCESS" "System is up to date"
    fi
}

task_cleanup() {
    log "INFO" "Starting cleanup task..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would perform cleanup operations"
        return 0
    fi
    
    # Clean Nix store
    log "INFO" "Cleaning Nix store..."
    nix-collect-garbage -d
    
    # Clean old generations
    log "INFO" "Cleaning old generations..."
    nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system
    
    # Clean temporary files
    log "INFO" "Cleaning temporary files..."
    find /tmp -type f -atime +7 -delete 2>/dev/null || true
    find /var/tmp -type f -atime +7 -delete 2>/dev/null || true
    
    log "SUCCESS" "Cleanup completed"
}

task_health() {
    log "INFO" "Starting system health check..."
    
    # Check disk space
    log "INFO" "Checking disk space..."
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 90 ]]; then
        log "WARN" "Disk usage is high: ${disk_usage}%"
    else
        log "SUCCESS" "Disk usage is acceptable: ${disk_usage}%"
    fi
    
    # Check memory usage
    log "INFO" "Checking memory usage..."
    local mem_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    log "INFO" "Memory usage: ${mem_usage}%"
    
    # Check system load
    log "INFO" "Checking system load..."
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    log "INFO" "System load average: $load_avg"
    
    # Check failed services
    log "INFO" "Checking for failed services..."
    local failed_services=$(systemctl --failed --no-legend | wc -l)
    if [[ $failed_services -gt 0 ]]; then
        log "WARN" "Found $failed_services failed services"
        systemctl --failed
    else
        log "SUCCESS" "No failed services found"
    fi
}

task_optimize() {
    log "INFO" "Starting performance optimization..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would perform optimization tasks"
        return 0
    fi
    
    # Optimize Nix store
    log "INFO" "Optimizing Nix store..."
    nix-store --optimise
    
    # Clear systemd journal if it's too large
    log "INFO" "Checking systemd journal size..."
    local journal_size=$(journalctl --disk-usage | awk '{print $1}' | sed 's/M//')
    if [[ $journal_size -gt 1000 ]]; then
        log "INFO" "Journal size is large (${journal_size}M), rotating..."
        journalctl --rotate
        journalctl --vacuum-time=30d
    fi
    
    log "SUCCESS" "Optimization completed"
}

task_security() {
    log "INFO" "Starting security checks..."
    
    # Check for security updates
    log "INFO" "Checking for security updates..."
    nix-channel --update
    
    # Check for failed login attempts
    log "INFO" "Checking for failed login attempts..."
    local failed_logins=$(journalctl -u sshd --since "1 hour ago" | grep "Failed password" | wc -l)
    if [[ $failed_logins -gt 10 ]]; then
        log "WARN" "High number of failed login attempts: $failed_logins"
    fi
    
    # Check for suspicious processes
    log "INFO" "Checking for suspicious processes..."
    local suspicious_procs=$(ps aux | grep -E "(cryptominer|miner|coin)" | grep -v grep | wc -l)
    if [[ $suspicious_procs -gt 0 ]]; then
        log "WARN" "Found $suspicious_procs potentially suspicious processes"
    fi
    
    # Check firewall status
    log "INFO" "Checking firewall status..."
    if systemctl is-active --quiet nftables; then
        log "SUCCESS" "Firewall is active"
    else
        log "WARN" "Firewall is not active"
    fi
    
    log "SUCCESS" "Security checks completed"
}

task_logs() {
    log "INFO" "Starting log maintenance..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY-RUN] Would perform log maintenance"
        return 0
    fi
    
    # Rotate systemd journal
    log "INFO" "Rotating systemd journal..."
    journalctl --rotate
    journalctl --vacuum-time=30d
    
    # Clean old log files
    log "INFO" "Cleaning old log files..."
    find /var/log -name "*.log.*" -mtime +30 -delete 2>/dev/null || true
    find /var/log -name "*.gz" -mtime +30 -delete 2>/dev/null || true
    
    # Clean maintenance log if it's too large
    if [[ -f "$LOG_FILE" ]]; then
        local log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo "0")
        if [[ $log_size -gt 10485760 ]]; then  # 10MB
            log "INFO" "Rotating maintenance log..."
            mv "$LOG_FILE" "${LOG_FILE}.old"
            gzip "${LOG_FILE}.old" 2>/dev/null || true
        fi
    fi
    
    log "SUCCESS" "Log maintenance completed"
}

task_disk() {
    log "INFO" "Starting disk space analysis..."
    
    # Show disk usage by directory
    log "INFO" "Disk usage by directory:"
    du -h --max-depth=1 / 2>/dev/null | sort -hr | head -10
    
    # Show Nix store usage
    log "INFO" "Nix store usage:"
    du -sh /nix/store 2>/dev/null || log "WARN" "Could not check Nix store usage"
    
    # Show largest files
    log "INFO" "Largest files in /nix/store:"
    find /nix/store -type f -size +100M 2>/dev/null | head -5 | while read -r file; do
        echo "  $(du -h "$file" | cut -f1) - $file"
    done
    
    if [[ "$DRY_RUN" == "false" ]]; then
        # Clean old kernels if disk usage is high
        local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
        if [[ $disk_usage -gt 85 ]]; then
            log "WARN" "Disk usage is high, cleaning old kernels..."
            nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system
        fi
    fi
    
    log "SUCCESS" "Disk analysis completed"
}

task_services() {
    log "INFO" "Starting service health monitoring..."
    
    # Check critical services
    local critical_services=("sshd" "systemd-logind" "NetworkManager")
    
    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log "SUCCESS" "Service $service is running"
        else
            log "ERROR" "Service $service is not running"
        fi
    done
    
    # Check for failed services
    local failed_services=$(systemctl --failed --no-legend | wc -l)
    if [[ $failed_services -gt 0 ]]; then
        log "WARN" "Failed services found:"
        systemctl --failed --no-legend | while read -r line; do
            log "WARN" "  $line"
        done
    fi
    
    # Check service startup times
    log "INFO" "Slowest starting services:"
    systemd-analyze blame | head -5
    
    log "SUCCESS" "Service monitoring completed"
}

# ============================================================================
# Task Execution
# ============================================================================
run_task() {
    local task="$1"
    
    case "$task" in
        "update")
            task_update
            ;;
        "cleanup")
            task_cleanup
            ;;
        "health")
            task_health
            ;;
        "optimize")
            task_optimize
            ;;
        "security")
            task_security
            ;;
        "logs")
            task_logs
            ;;
        "disk")
            task_disk
            ;;
        "services")
            task_services
            ;;
        *)
            log "ERROR" "Unknown task: $task"
            return 1
            ;;
    esac
}

run_tasks() {
    local task_list="$1"
    local IFS=','
    
    for task in $task_list; do
        task=$(echo "$task" | xargs)  # Trim whitespace
        if [[ -n "$task" ]]; then
            log "INFO" "Running task: $task"
            if run_task "$task"; then
                log "SUCCESS" "Task '$task' completed successfully"
            else
                log "ERROR" "Task '$task' failed"
                if [[ "$SCHEDULED_MODE" == "false" ]]; then
                    read -p "Continue with remaining tasks? (y/N): " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        exit 1
                    fi
                fi
            fi
        fi
    done
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
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -s|--scheduled)
                SCHEDULED_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -t|--tasks)
                TASKS="$2"
                shift 2
                ;;
            -l|--log-file)
                LOG_FILE="$2"
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
    log "INFO" "Starting NixOS system maintenance"
    log "INFO" "Mode: $([[ "$DRY_RUN" == "true" ]] && echo "DRY-RUN" || echo "LIVE")"
    log "INFO" "Tasks: $TASKS"
    
    # Acquire lock
    acquire_lock
    
    # Check prerequisites
    check_prerequisites
    
    # Run tasks
    run_tasks "$TASKS"
    
    # Final summary
    log "SUCCESS" "System maintenance completed successfully"
    log "INFO" "Log file: $LOG_FILE"
}

# ============================================================================
# Script Execution
# ============================================================================
main "$@" 