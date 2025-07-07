# =============================================================================
# Linux Auditing System (auditd) Configuration Module
# =============================================================================
#
# Enables Linux Auditing System for comprehensive system monitoring and security logging.
#
# What it does:
# - Provides detailed tracking of system events and file access
# - Monitors user activity and authentication events
# - Tracks privileged operations and system changes
# - Supports compliance and forensic analysis
# - Generates audit trails for security investigations
#
# Requirements:
# - Linux kernel with audit support
# - Sufficient disk space for audit logs
# - Proper permissions for audit directory
#
# Usage:
# - Import in main configuration
# - auditd service starts automatically on boot
# - Logs written to /var/log/audit/
# - Use ausearch and aureport for log analysis
# =============================================================================

# Auditd (Linux Auditing System) module
{ config, pkgs, ... }:

{
  # ============================================================================
  # Linux Auditing System
  # ============================================================================
  # Enable the Linux Auditing System (auditd)
  # This provides comprehensive system monitoring and security event logging
  security.audit.enable = true;

  # Increase the audit backlog limit to avoid kauditd hold queue overflow during boot
  boot.kernelParams = [ "audit=1" "audit_backlog_limit=8192" ]; # Audit=1, is usually already enabled by security.audit.enable.
}
