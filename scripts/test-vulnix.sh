#!/usr/bin/env zsh

# =============================================================================
# Vulnix Vulnerability Scanner Test Script
# =============================================================================
#
# Provides comprehensive testing and validation of vulnix vulnerability scanner.
#
# What it does:
# - Verifies vulnix installation and availability
# - Tests vulnix command-line tools and scripts
# - Validates systemd timer configuration
# - Performs manual vulnerability scan
# - Provides status reporting for troubleshooting
#
# Requirements:
# - vulnix package installed via NixOS
# - systemd timers enabled for automated scanning
# - Appropriate permissions to run vulnerability scans
#
# Usage:
# - Run script to test vulnix installation
# - Review output for errors or warnings
# - Check systemd timer status for automated scans
# - Verify scan results in vulnix logs
# =============================================================================

# ============================================================================
# Script Header and Initialization
# ============================================================================
echo "=== Vulnix Vulnerability Scanner Test ==="
echo

# ============================================================================
# Test 1: Verify Vulnix Installation
# ============================================================================
# Check if vulnix is installed and available in PATH
if command -v vulnix >/dev/null 2>&1; then
    echo "✓ Vulnix is installed"
    vulnix --version
else
    echo "✗ Vulnix is not installed"
    echo "  Install with: nix-env -iA nixpkgs.vulnix"
    exit 1
fi

echo

# ============================================================================
# Test 2: Verify Vulnix Scan Script
# ============================================================================
# Check if vulnix-scan script is available
if command -v vulnix-scan >/dev/null 2>&1; then
    echo "✓ Vulnix scan script is available"
else
    echo "✗ Vulnix scan script is not available"
    echo "  This may indicate incomplete installation"
fi

echo

# ============================================================================
# Test 3: Verify Vulnix Status Script
# ============================================================================
# Check if vulnix-status script is available
if command -v vulnix-status >/dev/null 2>&1; then
    echo "✓ Vulnix status script is available"
else
    echo "✗ Vulnix status script is not available"
    echo "  This may indicate incomplete installation"
fi

echo

# ============================================================================
# Test 4: Test Vulnix Status
# ============================================================================
# Run vulnix-status to check current scanner status
echo "=== Testing vulnix-status ==="
vulnix-status

echo

# ============================================================================
# Test 5: Check Systemd Timers
# ============================================================================
# Verify that vulnix systemd timers are configured and active
echo "=== Checking vulnix systemd timers ==="
systemctl list-timers | grep vulnix

echo

# ============================================================================
# Test 6: Manual Scan Test
# ============================================================================
# Perform a manual vulnerability scan (may take several minutes)
echo "=== Testing manual vulnix scan ==="
echo "Running vulnix scan (this may take several minutes)..."
echo "Note: This is a full system scan and may generate significant output"
echo

# Execute manual scan with error handling
if vulnix-scan; then
    echo "✓ Manual scan completed successfully"
else
    echo "✗ Manual scan failed or encountered errors"
    echo "  Check vulnix logs for details: journalctl -u vulnix"
fi

echo
echo "=== Test completed ==="
echo
echo "Next steps:"
echo "1. Review scan results in /var/log/vulnix/"
echo "2. Check for any reported vulnerabilities"
echo "3. Verify automated scans are scheduled via systemd timers"
echo "4. Monitor vulnix logs: journalctl -f -u vulnix" 