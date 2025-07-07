# =============================================================================
# Redis In-Memory Database Service Configuration Module
# =============================================================================
#
# Configures Redis, a high-performance in-memory data structure store.
#
# What it does:
# - Enables Redis service with optimized memory management
# - Configures LRU eviction policy and persistence strategies
# - Installs Redis CLI tools for database management
# - Provides shell aliases for service management
# - Sets up environment variables for easy access
# - Configures automatic data persistence with save intervals
# - Supports various data structures and pub/sub messaging
# - Enables Lua scripting and atomic operations
#
# Requirements:
# - Sufficient RAM for in-memory storage
# - Redis package
# - Compatible system architecture
# - Disk space for persistence files
#
# Usage:
# - Imported by device configurations automatically
# - Redis starts automatically on boot
# - Use redis-cli for database access
# - Use redis-start/redis-stop aliases for service management
# =============================================================================

{ config, pkgs, lib, ... }:

let
  # ============================================================================
  # Configuration Constants
  # ============================================================================
  # Redis server port for client connections
  redisPort = 6379;
in
{
  # ============================================================================
  # Redis Service Configuration
  # ============================================================================
  # Configure Redis in-memory database server with optimized settings
  services.redis.servers."" = {
    enable = true;                    # Enable Redis service
    port = redisPort;                 # Set Redis server port
    
    # ========================================================================
    # Redis Settings
    # ========================================================================
    # Configure Redis server parameters for optimal performance
    settings = {
      # ================================================================
      # Memory Management
      # ================================================================
      # Performance tuning for development environment
      maxmemory = "512mb";            # Maximum memory usage limit
      maxmemory-policy = "allkeys-lru";  # LRU eviction policy for all keys
      
      # ================================================================
      # Persistence Configuration
      # ================================================================
      # Enable data persistence with configurable save intervals
      # This ensures data survives server restarts
      save = [
        "900 1"    # Save after 15 minutes if at least 1 key changed
        "300 10"   # Save after 5 minutes if at least 10 keys changed
        "60 10000" # Save after 1 minute if at least 10000 keys changed
      ];
    };
  };

  # ============================================================================
  # Redis Management Tools
  # ============================================================================
  # Install Redis command-line tools and utilities
  environment.systemPackages = with pkgs; [
    redis    # Core Redis package with CLI and utilities
  ];

  # ============================================================================
  # Shell Aliases
  # ============================================================================
  # Add convenient shell aliases for Redis management
  # These provide quick access to common Redis operations
  programs.zsh.shellAliases = {
    # ========================================================================
    # Service Management Aliases
    # ========================================================================
    redis-start = "sudo systemctl start redis";      # Start Redis service
    redis-stop = "sudo systemctl stop redis";        # Stop Redis service
    redis-restart = "sudo systemctl restart redis";  # Restart Redis service
    redis-status = "sudo systemctl status redis";    # Check service status
    
    # ========================================================================
    # Monitoring and Debugging Aliases
    # ========================================================================
    redis-log = "sudo journalctl -u redis -f";       # View real-time logs
    redis-cli = "redis-cli -p ${toString redisPort}";  # Connect to Redis server
  };

  # ============================================================================
  # Environment Variables
  # ============================================================================
  # Set Redis environment variables for easy access
  # These variables are used by Redis clients and applications
  environment.variables = {
    REDIS_HOST = "localhost";         # Redis server host
    REDIS_PORT = toString redisPort;  # Redis server port
  };
} 
