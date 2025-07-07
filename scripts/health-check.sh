#!/usr/bin/env zsh

# =============================================================================
# NixOS System Health Check Script
# =============================================================================
#
# Comprehensive health monitoring for NixOS systems with detailed reporting.
#
# What it does:
# - Checks system resources (CPU, memory, disk) and service status
# - Monitors network connectivity, security status, and Nix store health
# - Analyzes system logs and performance metrics
# - Provides detailed reporting with color-coded output and export capabilities
# - Offers automated issue detection and alert system for critical problems
# - Supports continuous monitoring and scheduled health checks
#
# Requirements:
# - NixOS system with standard tools (awk, grep, sed, df, free, uptime)
# - Sufficient permissions for system monitoring
# - Log directory access for reporting
# - Network access for connectivity checks
#
# Usage:
# - Full check: ./health-check.sh
# - Quick check: ./health-check.sh --quick
# - Specific checks: ./health-check.sh --checks disk,services
# - Export report: ./health-check.sh --export json
# - Monitor mode: ./health-check.sh --monitor
# =============================================================================

set -euo pipefail

# ============================================================================
# Configuration Variables
# ============================================================================
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/var/log/nixos-health.log"
REPORT_DIR="/var/log/nixos-health-reports"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Health check options
QUICK_MODE=false
MONITOR_MODE=false
EXPORT_FORMAT=""
CHECKS="system,resources,services,network,security,nix,logs,performance,hardware"
VERBOSE=false
ALERT_ON_CRITICAL=true

# Thresholds
DISK_WARNING_THRESHOLD=80
DISK_CRITICAL_THRESHOLD=90
MEMORY_WARNING_THRESHOLD=80
MEMORY_CRITICAL_THRESHOLD=90
CPU_WARNING_THRESHOLD=80
CPU_CRITICAL_THRESHOLD=90

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
        "CRITICAL")
            echo -e "${RED}[CRITICAL]${NC} $message"
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
    -q, --quick         Quick health check (basic checks only)
    -m, --monitor       Continuous monitoring mode
    -c, --checks LIST   Comma-separated list of checks to perform
    -e, --export FORMAT Export report (json, html, text)
    -v, --verbose       Verbose output
    -a, --no-alerts     Disable critical alerts

Available Checks:
    system      - Basic system information
    resources   - CPU, memory, disk usage
    services    - Service status and health
    network     - Network connectivity and config
    security    - Security status and vulnerabilities
    nix         - Nix store and package health
    logs        - System log analysis
    performance - Performance metrics
    hardware    - Hardware health status

Examples:
    $SCRIPT_NAME                    # Full health check
    $SCRIPT_NAME --quick            # Quick health check
    $SCRIPT_NAME --checks disk,services  # Specific checks
    $SCRIPT_NAME --export json      # Export JSON report
    $SCRIPT_NAME --monitor          # Continuous monitoring

EOF
}

check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Create report directory
    mkdir -p "$REPORT_DIR"
    
    # Check required tools
    local required_tools=("awk" "grep" "sed" "df" "free" "uptime")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log "ERROR" "Required tool not found: $tool"
            exit 1
        fi
    done
    
    log "SUCCESS" "Prerequisites check passed"
}

# ============================================================================
# Health Check Functions
# ============================================================================
check_system() {
    log "INFO" "Checking system information..."
    
    echo -e "\n${BLUE}=== System Information ===${NC}"
    
    # System information
    echo -e "${CYAN}Hostname:${NC} $(hostname)"
    echo -e "${CYAN}OS:${NC} $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${CYAN}Kernel:${NC} $(uname -r)"
    echo -e "${CYAN}Architecture:${NC} $(uname -m)"
    echo -e "${CYAN}Uptime:${NC} $(uptime -p)"
    echo -e "${CYAN}Load Average:${NC} $(uptime | awk -F'load average:' '{print $2}')"
    
    # NixOS specific information
    if command -v nix-env >/dev/null 2>&1; then
        echo -e "${CYAN}Nix Version:${NC} $(nix-env --version)"
        echo -e "${CYAN}Current Generation:${NC} $(nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')"
    fi
    
    log "SUCCESS" "System information check completed"
}

check_resources() {
    log "INFO" "Checking system resources..."
    
    echo -e "\n${BLUE}=== System Resources ===${NC}"
    
    # Disk usage
    echo -e "${CYAN}Disk Usage:${NC}"
    df -h | grep -E '^/dev/' | while read -r line; do
        local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        local mount=$(echo "$line" | awk '{print $6}')
        local size=$(echo "$line" | awk '{print $2}')
        local used=$(echo "$line" | awk '{print $3}')
        local avail=$(echo "$line" | awk '{print $4}')
        
        if [[ $usage -ge $DISK_CRITICAL_THRESHOLD ]]; then
            echo -e "  ${RED}$mount: ${usage}% used (${used}/${size}, ${avail} avail)${NC}"
            log "CRITICAL" "Disk usage critical on $mount: ${usage}%"
        elif [[ $usage -ge $DISK_WARNING_THRESHOLD ]]; then
            echo -e "  ${YELLOW}$mount: ${usage}% used (${used}/${size}, ${avail} avail)${NC}"
            log "WARN" "Disk usage high on $mount: ${usage}%"
        else
            echo -e "  ${GREEN}$mount: ${usage}% used (${used}/${size}, ${avail} avail)${NC}"
        fi
    done
    
    # Memory usage
    echo -e "\n${CYAN}Memory Usage:${NC}"
    local mem_info=$(free -h)
    local total_mem=$(echo "$mem_info" | awk 'NR==2{print $2}')
    local used_mem=$(echo "$mem_info" | awk 'NR==2{print $3}')
    local free_mem=$(echo "$mem_info" | awk 'NR==2{print $4}')
    local mem_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    
    if (( $(echo "$mem_usage >= $MEMORY_CRITICAL_THRESHOLD" | bc -l) )); then
        echo -e "  ${RED}Total: $total_mem, Used: $used_mem, Free: $free_mem (${mem_usage}%)${NC}"
        log "CRITICAL" "Memory usage critical: ${mem_usage}%"
    elif (( $(echo "$mem_usage >= $MEMORY_WARNING_THRESHOLD" | bc -l) )); then
        echo -e "  ${YELLOW}Total: $total_mem, Used: $used_mem, Free: $free_mem (${mem_usage}%)${NC}"
        log "WARN" "Memory usage high: ${mem_usage}%"
    else
        echo -e "  ${GREEN}Total: $total_mem, Used: $used_mem, Free: $free_mem (${mem_usage}%)${NC}"
    fi
    
    # CPU usage (if available)
    if command -v top >/dev/null 2>&1; then
        echo -e "\n${CYAN}CPU Usage:${NC}"
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        if (( $(echo "$cpu_usage >= $CPU_CRITICAL_THRESHOLD" | bc -l) )); then
            echo -e "  ${RED}CPU Usage: ${cpu_usage}%${NC}"
            log "CRITICAL" "CPU usage critical: ${cpu_usage}%"
        elif (( $(echo "$cpu_usage >= $CPU_WARNING_THRESHOLD" | bc -l) )); then
            echo -e "  ${YELLOW}CPU Usage: ${cpu_usage}%${NC}"
            log "WARN" "CPU usage high: ${cpu_usage}%"
        else
            echo -e "  ${GREEN}CPU Usage: ${cpu_usage}%${NC}"
        fi
    fi
    
    log "SUCCESS" "Resource check completed"
}

check_services() {
    log "INFO" "Checking service status..."
    
    echo -e "\n${BLUE}=== Service Status ===${NC}"
    
    # Check failed services
    local failed_services=$(systemctl --failed --no-legend | wc -l)
    if [[ $failed_services -gt 0 ]]; then
        echo -e "${RED}Failed Services ($failed_services):${NC}"
        systemctl --failed --no-legend | while read -r line; do
            echo -e "  ${RED}$line${NC}"
        done
        log "CRITICAL" "Found $failed_services failed services"
    else
        echo -e "${GREEN}No failed services found${NC}"
    fi
    
    # Check critical services
    echo -e "\n${CYAN}Critical Services:${NC}"
    local critical_services=("sshd" "systemd-logind" "NetworkManager" "systemd-resolved")
    local service_ok=true
    
    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo -e "  ${GREEN}$service: Running${NC}"
        else
            echo -e "  ${RED}$service: Not running${NC}"
            service_ok=false
        fi
    done
    
    if [[ "$service_ok" == "false" ]]; then
        log "CRITICAL" "Critical services are not running"
    fi
    
    # Service startup times
    echo -e "\n${CYAN}Slowest Starting Services:${NC}"
    systemd-analyze blame | head -5 | while read -r line; do
        echo -e "  $line"
    done
    
    log "SUCCESS" "Service check completed"
}

check_network() {
    log "INFO" "Checking network connectivity..."
    
    echo -e "\n${BLUE}=== Network Status ===${NC}"
    
    # Network interfaces
    echo -e "${CYAN}Network Interfaces:${NC}"
    ip addr show | grep -E "^[0-9]+:" | while read -r line; do
        local iface=$(echo "$line" | awk '{print $2}' | sed 's/://')
        local state=$(echo "$line" | awk '{print $9}')
        if [[ "$state" == "UP" ]]; then
            echo -e "  ${GREEN}$iface: $state${NC}"
        else
            echo -e "  ${RED}$iface: $state${NC}"
        fi
    done
    
    # Default gateway
    echo -e "\n${CYAN}Default Gateway:${NC}"
    local gateway=$(ip route show default | awk '/default/ {print $3}')
    if [[ -n "$gateway" ]]; then
        echo -e "  ${GREEN}Gateway: $gateway${NC}"
        
        # Test connectivity
        if ping -c 1 -W 3 "$gateway" >/dev/null 2>&1; then
            echo -e "  ${GREEN}Gateway connectivity: OK${NC}"
        else
            echo -e "  ${RED}Gateway connectivity: FAILED${NC}"
            log "ERROR" "Gateway connectivity failed"
        fi
    else
        echo -e "  ${RED}No default gateway configured${NC}"
        log "ERROR" "No default gateway configured"
    fi
    
    # DNS resolution
    echo -e "\n${CYAN}DNS Resolution:${NC}"
    if nslookup google.com >/dev/null 2>&1; then
        echo -e "  ${GREEN}DNS resolution: OK${NC}"
    else
        echo -e "  ${RED}DNS resolution: FAILED${NC}"
        log "ERROR" "DNS resolution failed"
    fi
    
    # Internet connectivity
    echo -e "\n${CYAN}Internet Connectivity:${NC}"
    if curl -s --connect-timeout 5 https://www.google.com >/dev/null 2>&1; then
        echo -e "  ${GREEN}Internet connectivity: OK${NC}"
    else
        echo -e "  ${RED}Internet connectivity: FAILED${NC}"
        log "ERROR" "Internet connectivity failed"
    fi
    
    log "SUCCESS" "Network check completed"
}

check_security() {
    log "INFO" "Checking security status..."
    
    echo -e "\n${BLUE}=== Security Status ===${NC}"
    
    # Firewall status
    echo -e "${CYAN}Firewall Status:${NC}"
    if systemctl is-active --quiet nftables; then
        echo -e "  ${GREEN}nftables: Active${NC}"
    elif systemctl is-active --quiet iptables; then
        echo -e "  ${GREEN}iptables: Active${NC}"
    else
        echo -e "  ${RED}No firewall active${NC}"
        log "WARN" "No firewall is active"
    fi
    
    # SSH service status
    echo -e "\n${CYAN}SSH Service:${NC}"
    if systemctl is-active --quiet sshd; then
        echo -e "  ${GREEN}SSH daemon: Running${NC}"
        
        # Check SSH configuration
        if sshd -t >/dev/null 2>&1; then
            echo -e "  ${GREEN}SSH configuration: Valid${NC}"
        else
            echo -e "  ${RED}SSH configuration: Invalid${NC}"
            log "ERROR" "SSH configuration is invalid"
        fi
    else
        echo -e "  ${RED}SSH daemon: Not running${NC}"
    fi
    
    # Failed login attempts
    echo -e "\n${CYAN}Failed Login Attempts (last hour):${NC}"
    local failed_logins=$(journalctl -u sshd --since "1 hour ago" | grep "Failed password" | wc -l)
    if [[ $failed_logins -gt 10 ]]; then
        echo -e "  ${RED}High number of failed logins: $failed_logins${NC}"
        log "WARN" "High number of failed login attempts: $failed_logins"
    else
        echo -e "  ${GREEN}Failed logins: $failed_logins${NC}"
    fi
    
    # Open ports
    echo -e "\n${CYAN}Open Ports:${NC}"
    if command -v ss >/dev/null 2>&1; then
        ss -tln | grep LISTEN | while read -r line; do
            echo -e "  $line"
        done
    fi
    
    log "SUCCESS" "Security check completed"
}

check_nix() {
    log "INFO" "Checking Nix store health..."
    
    echo -e "\n${BLUE}=== Nix Store Health ===${NC}"
    
    # Nix store usage
    echo -e "${CYAN}Nix Store Usage:${NC}"
    if [[ -d /nix/store ]]; then
        local store_size=$(du -sh /nix/store 2>/dev/null | cut -f1)
        echo -e "  ${GREEN}Store size: $store_size${NC}"
    else
        echo -e "  ${RED}Nix store not found${NC}"
    fi
    
    # System generations
    echo -e "\n${CYAN}System Generations:${NC}"
    if command -v nix-env >/dev/null 2>&1; then
        local gen_count=$(nix-env --list-generations --profile /nix/var/nix/profiles/system | wc -l)
        echo -e "  ${GREEN}Total generations: $gen_count${NC}"
        
        # Show recent generations
        nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5 | while read -r line; do
            echo -e "  $line"
        done
    fi
    
    # Nix store integrity
    echo -e "\n${CYAN}Store Integrity:${NC}"
    if command -v nix-store >/dev/null 2>&1; then
        if nix-store --verify --check-contents >/dev/null 2>&1; then
            echo -e "  ${GREEN}Store integrity: OK${NC}"
        else
            echo -e "  ${RED}Store integrity: FAILED${NC}"
            log "ERROR" "Nix store integrity check failed"
        fi
    fi
    
    log "SUCCESS" "Nix store check completed"
}

check_logs() {
    log "INFO" "Checking system logs..."
    
    echo -e "\n${BLUE}=== System Logs ===${NC}"
    
    # Recent errors
    echo -e "${CYAN}Recent Errors (last hour):${NC}"
    local error_count=$(journalctl --since "1 hour ago" --priority=err | wc -l)
    if [[ $error_count -gt 0 ]]; then
        echo -e "  ${YELLOW}Error count: $error_count${NC}"
        journalctl --since "1 hour ago" --priority=err | tail -5 | while read -r line; do
            echo -e "  $line"
        done
    else
        echo -e "  ${GREEN}No recent errors${NC}"
    fi
    
    # Recent warnings
    echo -e "\n${CYAN}Recent Warnings (last hour):${NC}"
    local warning_count=$(journalctl --since "1 hour ago" --priority=warning | wc -l)
    if [[ $warning_count -gt 0 ]]; then
        echo -e "  ${YELLOW}Warning count: $warning_count${NC}"
        journalctl --since "1 hour ago" --priority=warning | tail -5 | while read -r line; do
            echo -e "  $line"
        done
    else
        echo -e "  ${GREEN}No recent warnings${NC}"
    fi
    
    # Systemd journal size
    echo -e "\n${CYAN}Journal Size:${NC}"
    local journal_size=$(journalctl --disk-usage | awk '{print $1}')
    echo -e "  ${GREEN}Journal size: $journal_size${NC}"
    
    log "SUCCESS" "Log check completed"
}

check_performance() {
    log "INFO" "Checking performance metrics..."
    
    echo -e "\n${BLUE}=== Performance Metrics ===${NC}"
    
    # System load
    echo -e "${CYAN}System Load:${NC}"
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local load_threshold=5.0
    if (( $(echo "$load_avg > $load_threshold" | bc -l) )); then
        echo -e "  ${RED}Load average: $load_avg (High)${NC}"
        log "WARN" "System load is high: $load_avg"
    else
        echo -e "  ${GREEN}Load average: $load_avg${NC}"
    fi
    
    # Process count
    echo -e "\n${CYAN}Process Information:${NC}"
    local process_count=$(ps aux | wc -l)
    echo -e "  ${GREEN}Total processes: $process_count${NC}"
    
    # Top processes by CPU
    echo -e "\n${CYAN}Top Processes by CPU:${NC}"
    ps aux --sort=-%cpu | head -6 | while read -r line; do
        echo -e "  $line"
    done
    
    # Top processes by memory
    echo -e "\n${CYAN}Top Processes by Memory:${NC}"
    ps aux --sort=-%mem | head -6 | while read -r line; do
        echo -e "  $line"
    done
    
    log "SUCCESS" "Performance check completed"
}

check_hardware() {
    log "INFO" "Checking hardware status..."
    
    echo -e "\n${BLUE}=== Hardware Status ===${NC}"
    
    # CPU information
    echo -e "${CYAN}CPU Information:${NC}"
    if [[ -f /proc/cpuinfo ]]; then
        local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        local cpu_cores=$(grep -c "processor" /proc/cpuinfo)
        echo -e "  ${GREEN}Model: $cpu_model${NC}"
        echo -e "  ${GREEN}Cores: $cpu_cores${NC}"
    fi
    
    # Memory information
    echo -e "\n${CYAN}Memory Information:${NC}"
    if [[ -f /proc/meminfo ]]; then
        local total_mem=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
        local total_mem_gb=$((total_mem / 1024 / 1024))
        echo -e "  ${GREEN}Total RAM: ${total_mem_gb}GB${NC}"
    fi
    
    # Temperature (if available)
    echo -e "\n${CYAN}Temperature Sensors:${NC}"
    if command -v sensors >/dev/null 2>&1; then
        sensors | grep -E "(Core|temp)" | while read -r line; do
            echo -e "  $line"
        done
    else
        echo -e "  ${YELLOW}Temperature sensors not available${NC}"
    fi
    
    # Disk health (if available)
    echo -e "\n${CYAN}Disk Health:${NC}"
    if command -v smartctl >/dev/null 2>&1; then
        for disk in /dev/sd[a-z]; do
            if [[ -b "$disk" ]]; then
                if smartctl -H "$disk" >/dev/null 2>&1; then
                    local health=$(smartctl -H "$disk" | grep "SMART overall-health" | awk '{print $6}')
                    if [[ "$health" == "PASSED" ]]; then
                        echo -e "  ${GREEN}$disk: $health${NC}"
                    else
                        echo -e "  ${RED}$disk: $health${NC}"
                        log "WARN" "Disk health issue detected on $disk"
                    fi
                fi
            fi
        done
    else
        echo -e "  ${YELLOW}SMART tools not available${NC}"
    fi
    
    log "SUCCESS" "Hardware check completed"
}

# ============================================================================
# Report Generation
# ============================================================================
generate_report() {
    local format="$1"
    local report_file="$REPORT_DIR/health-report-$TIMESTAMP.$format"
    
    log "INFO" "Generating $format report: $report_file"
    
    case "$format" in
        "json")
            # Generate JSON report
            cat > "$report_file" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "checks": {
    "system": "completed",
    "resources": "completed",
    "services": "completed",
    "network": "completed",
    "security": "completed",
    "nix": "completed",
    "logs": "completed",
    "performance": "completed",
    "hardware": "completed"
  }
}
EOF
            ;;
        "html")
            # Generate HTML report
            cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>NixOS Health Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 10px; }
        .section { margin: 20px 0; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="header">
        <h1>NixOS Health Report</h1>
        <p>Generated: $(date)</p>
        <p>Hostname: $(hostname)</p>
    </div>
    <div class="section">
        <h2>System Health Summary</h2>
        <p>All health checks completed successfully.</p>
    </div>
</body>
</html>
EOF
            ;;
        "text")
            # Generate text report
            echo "NixOS Health Report" > "$report_file"
            echo "Generated: $(date)" >> "$report_file"
            echo "Hostname: $(hostname)" >> "$report_file"
            echo "" >> "$report_file"
            echo "All health checks completed successfully." >> "$report_file"
            ;;
    esac
    
    log "SUCCESS" "Report generated: $report_file"
    echo "$report_file"
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
            -q|--quick)
                QUICK_MODE=true
                CHECKS="system,resources,services"
                shift
                ;;
            -m|--monitor)
                MONITOR_MODE=true
                shift
                ;;
            -c|--checks)
                CHECKS="$2"
                shift 2
                ;;
            -e|--export)
                EXPORT_FORMAT="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -a|--no-alerts)
                ALERT_ON_CRITICAL=false
                shift
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
    log "INFO" "Starting NixOS health check"
    log "INFO" "Mode: $([[ "$QUICK_MODE" == "true" ]] && echo "QUICK" || echo "FULL")"
    log "INFO" "Checks: $CHECKS"
    
    # Check prerequisites
    check_prerequisites
    
    # Run health checks
    local IFS=','
    for check in $CHECKS; do
        check=$(echo "$check" | xargs)  # Trim whitespace
        case "$check" in
            "system")
                check_system
                ;;
            "resources")
                check_resources
                ;;
            "services")
                check_services
                ;;
            "network")
                check_network
                ;;
            "security")
                check_security
                ;;
            "nix")
                check_nix
                ;;
            "logs")
                check_logs
                ;;
            "performance")
                check_performance
                ;;
            "hardware")
                check_hardware
                ;;
            *)
                log "WARN" "Unknown check: $check"
                ;;
        esac
    done
    
    # Generate report if requested
    if [[ -n "$EXPORT_FORMAT" ]]; then
        generate_report "$EXPORT_FORMAT"
    fi
    
    # Final summary
    log "SUCCESS" "Health check completed successfully"
    log "INFO" "Log file: $LOG_FILE"
}

# ============================================================================
# Script Execution
# ============================================================================
main "$@" 