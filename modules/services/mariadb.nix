# =============================================================================
# MariaDB Database Service Configuration Module
# =============================================================================
#
# Configures MariaDB, a community-developed fork of MySQL for robust database services.
#
# What it does:
# - Enables MariaDB service with optimized performance settings
# - Configures InnoDB buffer pool and query cache for optimal performance
# - Sets up comprehensive logging (slow queries, errors, general)
# - Installs management tools (mysql-workbench)
# - Provides shell aliases for service management
# - Configures UTF8MB4 character set and collation
# - Enables multiple storage engines (InnoDB, MyISAM, Aria)
# - Sets up proper directory permissions and ownership
#
# Requirements:
# - Sufficient disk space for database files
# - Memory for buffer pools and caches
# - MariaDB package
# - Compatible system architecture
#
# Usage:
# - Imported by device configurations automatically
# - MariaDB starts automatically on boot
# - Use mysql-workbench for GUI administration
# - Use mysql-start/mysql-stop aliases for service management
# =============================================================================

{ config, pkgs, lib, ... }:

let
  # ============================================================================
  # Configuration Constants
  # ============================================================================
  # MariaDB data directory for database files
  mysqlDataDir = "/var/lib/mysql";
  
  # MariaDB server port
  mysqlPort = 3306;
in
{
  # ============================================================================
  # MariaDB Service Configuration
  # ============================================================================
  # Configure MariaDB database server with optimized settings
  services.mysql = {
    enable = true;                    # Enable MariaDB service
    package = pkgs.mariadb;           # Use MariaDB package
    dataDir = mysqlDataDir;           # Set data directory
    
    # ========================================================================
    # Database Settings
    # ========================================================================
    # Configure MariaDB server parameters for optimal performance
    settings = {
      # ================================================================
      # Server Configuration
      # ================================================================
      mysqld = {
        port = mysqlPort;             # Database server port
        
        # ============================================================
        # Connection Settings
        # ============================================================
        max_connections = 100;        # Maximum concurrent connections
        max_allowed_packet = "64M";   # Maximum packet size for queries
        
        # ============================================================
        # InnoDB Storage Engine Settings
        # ============================================================
        # Optimized for development environment
        innodb_buffer_pool_size = "256M";        # InnoDB buffer pool size
        innodb_log_file_size = "64M";            # InnoDB log file size
        innodb_flush_log_at_trx_commit = 2;      # Faster, less safe flushing
        innodb_flush_method = "O_DIRECT";        # Direct I/O for better performance
        
        # ============================================================
        # MyISAM Storage Engine Settings
        # ============================================================
        key_buffer_size = "32M";      # Key buffer for MyISAM tables
        
        # ============================================================
        # Query Cache Configuration
        # ============================================================
        # Query cache (deprecated in MySQL 8, but still useful in MariaDB)
        query_cache_size = "32M";     # Query cache size
        query_cache_limit = "2M";     # Maximum query result size for cache
        
        # ============================================================
        # Logging Configuration
        # ============================================================
        # Comprehensive logging for development and debugging
        slow_query_log = 1;           # Enable slow query logging
        slow_query_log_file = "/var/log/mysql/mariadb-slow.log";  # Slow query log file
        long_query_time = 2;          # Query time threshold for slow log
        log_error = "/var/log/mysql/mariadb.err";  # Error log file
        general_log = 1;              # Enable general query logging
        general_log_file = "/var/log/mysql/mariadb.log";  # General log file
        
        # ============================================================
        # Character Set Configuration
        # ============================================================
        character-set-server = "utf8mb4";        # Default character set
        collation-server = "utf8mb4_unicode_ci"; # Default collation
        
        # ============================================================
        # Memory and Performance Settings
        # ============================================================
        tmp_table_size = "32M";       # Maximum size for temporary tables
        max_heap_table_size = "32M";  # Maximum size for memory tables
        table_open_cache = 2000;      # Number of open tables to cache
        thread_cache_size = 128;      # Number of threads to cache
      };
    };
  };

  # ============================================================================
  # Database Management Tools
  # ============================================================================
  # Install comprehensive MariaDB management and administration tools
  environment.systemPackages = with pkgs; [
    mariadb         # Core MariaDB package with utilities
    mysql-workbench # GUI administration tool
  ];

  # ============================================================================
  # Directory Setup
  # ============================================================================
  # Create necessary directories with proper permissions
  # This ensures MariaDB can access its data and log directories securely
  system.activationScripts.mysqlDir = ''
    # ========================================================================
    # MariaDB Directory Setup
    # ========================================================================
    # Create data directory with proper ownership and permissions
    mkdir -p ${mysqlDataDir}
    chown mysql:mysql ${mysqlDataDir}
    chmod 750 ${mysqlDataDir}
    
    # Create log directory with proper ownership and permissions
    mkdir -p /var/log/mysql
    chown mysql:mysql /var/log/mysql
    chmod 750 /var/log/mysql
  '';

  # ============================================================================
  # Shell Aliases
  # ============================================================================
  # Add convenient shell aliases for MariaDB management
  # These provide quick access to common database operations
  programs.zsh.shellAliases = {
    # ========================================================================
    # Service Management Aliases
    # ========================================================================
    mysql-start = "sudo systemctl start mysql";      # Start MariaDB service
    mysql-stop = "sudo systemctl stop mysql";        # Stop MariaDB service
    mysql-restart = "sudo systemctl restart mysql";  # Restart MariaDB service
    mysql-status = "sudo systemctl status mysql";    # Check service status
    
    # ========================================================================
    # Monitoring and Debugging Aliases
    # ========================================================================
    mysql-log = "sudo journalctl -u mysql -f";       # View real-time logs
    mysql-slow-log = "sudo tail -f /var/log/mysql/mariadb-slow.log";  # Monitor slow queries
    mysql-error-log = "sudo tail -f /var/log/mysql/mariadb.err";      # View error logs
    mysql-general-log = "sudo tail -f /var/log/mysql/mariadb.log";    # View general logs
    
    # ========================================================================
    # Database Connection Aliases
    # ========================================================================
    mysql = "mycli -h localhost -P ${toString mysqlPort}";           # Connect as default user
    mysql-root = "sudo mycli -h localhost -P ${toString mysqlPort} -u root";  # Connect as root
  };

  # ============================================================================
  # Environment Variables
  # ============================================================================
  # Set MariaDB environment variables for easy access
  # These variables are used by MariaDB clients and applications
  environment.variables = {
    MYSQL_HOST = "localhost";         # Database host
    MYSQL_PORT = toString mysqlPort;  # Database port
    MYSQL_USER = "root";              # Default database user
    MYSQL_DATABASE = "mysql";         # Default database name
    MYSQL_UNIX_PORT = "/run/mysqld/mysqld.sock";  # Unix socket path
  };

  # ============================================================================
  # Systemd Service Configuration
  # ============================================================================
  # Add useful systemd service overrides for enhanced MariaDB operation
  systemd.services.mysql = {
    # ========================================================================
    # Service Dependencies
    # ========================================================================
    # Ensure the service starts after network is available
    after = [ "network.target" ];
    
    # ========================================================================
    # Environment Configuration
    # ========================================================================
    # Add custom environment variables
    environment = {
      MYSQL_TCP_PORT = toString mysqlPort;  # TCP port for MariaDB
    };
    
    # ========================================================================
    # Service Configuration
    # ========================================================================
    # Add custom service settings for optimal performance
    serviceConfig = {
      # Increase open file limit for better performance
      LimitNOFILE = "65535";
      
      # ================================================================
      # Pre-start Scripts
      # ================================================================
      # Add custom options and pre-start checks
      ExecStartPre = [
        "+${pkgs.writeScript "mysql-check" ''
          #!${pkgs.bash}/bin/bash
          # ============================================================
          # MariaDB Pre-start Check Script
          # ============================================================
          # Ensure data directory exists with proper permissions
          if [ ! -d "${mysqlDataDir}" ]; then
            mkdir -p "${mysqlDataDir}"
            chown mysql:mysql "${mysqlDataDir}"
            chmod 750 "${mysqlDataDir}"
          fi
        ''}"
      ];
    };
  };
} 
