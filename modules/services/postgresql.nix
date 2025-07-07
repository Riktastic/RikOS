# =============================================================================
# PostgreSQL Database Service Configuration Module
# =============================================================================
#
# Configures PostgreSQL 16 database server with optimized settings for development and production.
#
# What it does:
# - Enables PostgreSQL 16 service with optimized performance settings
# - Configures memory allocation and connection pooling
# - Sets up comprehensive logging for development and debugging
# - Installs management tools (pgcli, pgAdmin4, pg_top)
# - Provides shell aliases for service management
# - Configures environment variables for easy database access
# - Enables JIT compilation and advanced features
#
# Requirements:
# - Sufficient disk space for database files
# - Memory for shared buffers and cache
# - PostgreSQL 16 package
# - Compatible system architecture
#
# Usage:
# - Imported by device configurations automatically
# - PostgreSQL starts automatically on boot
# - Use pgcli for enhanced database access
# - Use pgstart/pgstop aliases for service management
# =============================================================================

{ config, pkgs, lib, ... }:

let
  # ============================================================================
  # Configuration Constants
  # ============================================================================
  # PostgreSQL data directory for database files
  pgDataDir = "/var/lib/postgresql/16";
  
  # PostgreSQL server port
  pgPort = 5432;
in
{
  # ============================================================================
  # PostgreSQL Service Configuration
  # ============================================================================
  # Configure PostgreSQL database server with optimized settings
  services.postgresql = {
    enable = true;                    # Enable PostgreSQL service
    package = pkgs.postgresql_16;     # Use PostgreSQL 16
    dataDir = pgDataDir;              # Set data directory
    
    # ========================================================================
    # Database Settings
    # ========================================================================
    # Configure PostgreSQL server parameters for optimal performance
    settings = {
      # ================================================================
      # Connection Configuration
      # ================================================================
      port = pgPort;                  # Database server port
      
      # ================================================================
      # Performance Tuning
      # ================================================================
      # Optimized for development environment
      max_connections = 100;          # Maximum concurrent connections
      shared_buffers = "256MB";       # Shared memory for caching
      effective_cache_size = "768MB"; # Estimated available memory
      maintenance_work_mem = "64MB";  # Memory for maintenance operations
      work_mem = "4MB";               # Memory per query operation
      
      # ================================================================
      # Logging Configuration
      # ================================================================
      # Comprehensive logging for development and debugging
      log_min_duration_statement = 0;     # Log all statements
      log_checkpoints = true;             # Log checkpoint activity
      log_connections = true;             # Log client connections
      log_disconnections = true;          # Log client disconnections
      log_lock_waits = true;              # Log lock wait events
      log_temp_files = 0;                 # Log all temporary files
      log_autovacuum_min_duration = 0;    # Log all autovacuum activity
      
      # ================================================================
      # Advanced Features
      # ================================================================
      jit = true;                     # Enable Just-In-Time compilation
    };
  };

  # ============================================================================
  # Database Management Tools
  # ============================================================================
  # Install comprehensive PostgreSQL management and administration tools
  environment.systemPackages = with pkgs; [
    postgresql_16    # Core PostgreSQL package with utilities
    pgcli            # Advanced command-line interface with syntax highlighting
    pgadmin4-desktopmode         # Web-based database administration tool
    pg_top           # Real-time PostgreSQL monitoring tool
  ];

  # ============================================================================
  # Directory Setup
  # ============================================================================
  # Create necessary directories with proper permissions
  # This ensures PostgreSQL can access its data directory securely
  system.activationScripts.postgresqlDir = ''
    # ========================================================================
    # PostgreSQL Directory Setup
    # ========================================================================
    # Create data directory with proper ownership and permissions
    mkdir -p ${pgDataDir}
    chown postgres:postgres ${pgDataDir}
    chmod 700 ${pgDataDir}
  '';

  # ============================================================================
  # Shell Aliases
  # ============================================================================
  # Add convenient shell aliases for PostgreSQL management
  # These provide quick access to common database operations
  programs.zsh.shellAliases = {
    # ========================================================================
    # Service Management Aliases
    # ========================================================================
    pgstart = "sudo systemctl start postgresql";      # Start PostgreSQL service
    pgstop = "sudo systemctl stop postgresql";        # Stop PostgreSQL service
    pgrestart = "sudo systemctl restart postgresql";  # Restart PostgreSQL service
    pgstatus = "sudo systemctl status postgresql";    # Check service status
    
    # ========================================================================
    # Monitoring and Debugging Aliases
    # ========================================================================
    pglog = "sudo journalctl -u postgresql -f";       # View real-time logs
    pgcli = "pgcli -h localhost -p ${toString pgPort}";  # Connect with pgcli
  };

  # ============================================================================
  # Environment Variables
  # ============================================================================
  # Set PostgreSQL environment variables for easy access
  # These variables are used by PostgreSQL clients and tools
  environment.variables = {
    PGHOST = "localhost";             # Database host
    PGPORT = toString pgPort;         # Database port
    PGUSER = "postgres";              # Default database user
    PGDATABASE = "postgres";          # Default database name
  };
} 
