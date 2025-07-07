#!/usr/bin/env zsh

# =============================================================================
# Security Notification Script
# =============================================================================
#
# Monitors security logs and sends internal email notifications for security issues.
#
# What it does:
# - Monitors antivirus (ClamAV) detections and antirootkit findings
# - Checks vulnerability scanner (vulnix) results and failed login attempts
# - Monitors firewall blocks and security events
# - Sends email notifications to system administrator
# - Provides daily summary reports and immediate alerts
#
# Requirements:
# - Mail command available in system
# - Security services (ClamAV, chkrootkit, vulnix) configured
# - Proper log file permissions and access
#
# Usage:
# - Run manually: ./security-notify.sh
# - Daily summary: ./security-notify.sh --daily
# - Configure ADMIN_EMAIL variable for notifications
# =============================================================================

# Configuration
ADMIN_EMAIL="rik@localhost"
LOG_FILE="/var/log/security-notifications.log"
LAST_CHECK_FILE="/var/run/security-notify.last"
MAIL_CMD="/run/current-system/sw/bin/mail"

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Function to send email notification
send_notification() {
    local subject="$1"
    local message="$2"
    local priority="$3"
    
    # Add timestamp
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local full_message="Security Alert - $timestamp

$message

This is an automated notification from your NixOS security monitoring system."

    # Send email
    echo "$full_message" | $MAIL_CMD -s "[$priority] $subject" "$ADMIN_EMAIL"
    
    # Log the notification
    echo "[$timestamp] [$priority] $subject" >> "$LOG_FILE"
}

# Check antivirus logs
check_antivirus() {
    local clamav_log="/var/log/clamav/scan.log"
    if [[ -f "$clamav_log" ]]; then
        local detections=$(grep -c "FOUND" "$clamav_log" 2>/dev/null || echo "0")
        if [[ $detections -gt 0 ]]; then
            local recent_detections=$(grep "FOUND" "$clamav_log" | tail -5)
            send_notification "Antivirus Detection" "Found $detections malware detection(s):

$recent_detections" "HIGH"
        fi
    fi
}

# Check antirootkit logs
check_antirootkit() {
    local chkrootkit_log="/var/log/chkrootkit.log"
    if [[ -f "$chkrootkit_log" ]]; then
        local suspicious=$(grep -c "suspicious" "$chkrootkit_log" 2>/dev/null || echo "0")
        local infected=$(grep -c "INFECTED" "$chkrootkit_log" 2>/dev/null || echo "0")
        
        if [[ $suspicious -gt 0 || $infected -gt 0 ]]; then
            local findings=$(grep -E "(suspicious|INFECTED)" "$chkrootkit_log" | tail -5)
            send_notification "Antirootkit Alert" "Found $suspicious suspicious and $infected infected items:

$findings" "CRITICAL"
        fi
    fi
}

# Check vulnerability scanner
check_vulnerabilities() {
    local vulnix_log="/var/log/vulnix.log"
    if [[ -f "$vulnix_log" ]]; then
        local vulnerabilities=$(grep -c "VULNERABILITY" "$vulnix_log" 2>/dev/null || echo "0")
        if [[ $vulnerabilities -gt 0 ]]; then
            local recent_vulns=$(grep "VULNERABILITY" "$vulnix_log" | tail -5)
            send_notification "Vulnerability Detected" "Found $vulnerabilities vulnerability(ies):

$recent_vulns" "HIGH"
        fi
    fi
}

# Check failed login attempts
check_failed_logins() {
    local failed_count=$(journalctl -u sshd --since "1 hour ago" | grep "Failed password" | wc -l)
    if [[ $failed_count -gt 10 ]]; then
        send_notification "High Failed Login Attempts" "Detected $failed_count failed login attempts in the last hour. Possible brute force attack." "MEDIUM"
    fi
}

# Check firewall blocks
check_firewall() {
    local blocks=$(journalctl -u nftables --since "1 hour ago" | grep "drop" | wc -l)
    if [[ $blocks -gt 50 ]]; then
        send_notification "High Firewall Activity" "Firewall blocked $blocks connections in the last hour. Possible attack." "MEDIUM"
    fi
}

# Daily summary
send_daily_summary() {
    local yesterday=$(date -d "yesterday" '+%Y-%m-%d')
    local summary="Daily Security Summary - $yesterday

Security events from yesterday:
- Antivirus detections: $(grep -c "FOUND" /var/log/clamav/scan.log 2>/dev/null || echo "0")
- Failed logins: $(journalctl -u sshd --since "yesterday" | grep "Failed password" | wc -l)
- Firewall blocks: $(journalctl -u nftables --since "yesterday" | grep "drop" | wc -l)
- System alerts: $(grep -c "$yesterday" "$LOG_FILE" 2>/dev/null || echo "0")

Check /var/log/ for detailed information."

    send_notification "Daily Security Summary" "$summary" "INFO"
}

# Main execution
main() {
    # Check if this is a daily summary run
    if [[ "$1" == "--daily" ]]; then
        send_daily_summary
        exit 0
    fi
    
    # Run security checks
    check_antivirus
    check_antirootkit
    check_vulnerabilities
    check_failed_logins
    check_firewall
    
    # Update last check time
    date > "$LAST_CHECK_FILE"
}

# Run main function
main "$@" 