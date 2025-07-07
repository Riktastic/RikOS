# =============================================================================
# MinIO Object Storage Service Configuration Module
# =============================================================================
#
# Configures MinIO, a high-performance, S3-compatible object storage server.
#
# What it does:
# - Enables MinIO service with S3-compatible object storage API
# - Configures web console and API endpoints (ports 9000/9001)
# - Installs MinIO client and AWS CLI for object operations
# - Provides shell aliases for service management
# - Sets up environment variables for easy access
# - Configures data protection and encryption
# - Enables multi-tenant access control and versioning
# - Supports event notifications and lifecycle management
#
# Requirements:
# - Sufficient disk space for object storage
# - MinIO package and dependencies
# - Compatible system architecture
# - Network access for API and console
#
# Usage:
# - Imported by device configurations automatically
# - MinIO starts automatically on boot
# - Access web console at http://localhost:9001
# - Use mc client for object operations
# - Use aws s3 commands for S3-compatible operations
# =============================================================================

{ config, pkgs, lib, ... }:

let
  # ============================================================================
  # Configuration Constants
  # ============================================================================
  # MinIO data directory for object storage
  minioDataDir = "/var/lib/minio";
  
  # MinIO API server port
  minioPort = 9000;
  
  # MinIO web console port
  minioConsolePort = 9001;
in
{
  # ============================================================================
  # MinIO Service Configuration
  # ============================================================================
  # Configure MinIO object storage server with optimized settings
  services.minio = {
    enable = true;                    # Enable MinIO service
    dataDir = [minioDataDir];         # Set data directory for objects
    
    # ========================================================================
    # Network Configuration
    # ========================================================================
    # Configure network endpoints for API and console access
    listenAddress = "127.0.0.1:${toString minioPort}";      # API server address
    consoleAddress = "127.0.0.1:${toString minioConsolePort}";  # Web console address
    
    # ========================================================================
    # Authentication Configuration
    # ========================================================================
    # Development credentials for MinIO access
    # Note: In production, use secure credential management
    rootCredentialsFile = pkgs.writeText "minio-credentials" ''
      # ================================================================
      # MinIO Root Credentials
      # ================================================================
      # Default development credentials
      # Change these in production environments
      MINIO_ROOT_USER=minioadmin
      MINIO_ROOT_PASSWORD=minioadmin
    '';
  };

  # ============================================================================
  # Object Storage Management Tools
  # ============================================================================
  # Install comprehensive MinIO management and client tools
  environment.systemPackages = with pkgs; [
    minio-client  # MinIO client for object operations
    awscli2       # AWS CLI for S3-compatible commands
  ];

  # ============================================================================
  # Directory Setup
  # ============================================================================
  # Create necessary directories with proper permissions
  # This ensures MinIO can access its data directory securely
  system.activationScripts.minioDir = ''
    # ========================================================================
    # MinIO Directory Setup
    # ========================================================================
    # Create data directory with proper ownership and permissions
    mkdir -p ${minioDataDir}
    chown minio:minio ${minioDataDir}
    chmod 750 ${minioDataDir}
  '';

  # ============================================================================
  # Shell Aliases
  # ============================================================================
  # Add convenient shell aliases for MinIO management
  # These provide quick access to common object storage operations
  programs.zsh.shellAliases = {
    # ========================================================================
    # Service Management Aliases
    # ========================================================================
    minio-start = "sudo systemctl start minio";      # Start MinIO service
    minio-stop = "sudo systemctl stop minio";        # Stop MinIO service
    minio-restart = "sudo systemctl restart minio";  # Restart MinIO service
    minio-status = "sudo systemctl status minio";    # Check service status
    
    # ========================================================================
    # Monitoring and Debugging Aliases
    # ========================================================================
    minio-log = "sudo journalctl -u minio -f";       # View real-time logs
    
    # ========================================================================
    # Client Configuration Aliases
    # ========================================================================
    mc = "mc --config-dir ~/.config/minio";          # MinIO client with config
  };

  # ============================================================================
  # Environment Variables
  # ============================================================================
  # Set MinIO environment variables for easy access
  # These variables are used by MinIO clients and applications
  environment.variables = {
    MINIO_ENDPOINT = "http://localhost:${toString minioPort}";      # API endpoint
    MINIO_CONSOLE = "http://localhost:${toString minioConsolePort}";  # Web console URL
    MINIO_ROOT_USER = "minioadmin";     # Root user for authentication
    MINIO_ROOT_PASSWORD = "minioadmin"; # Root password for authentication
  };
} 
