# PHP Development Suite
#
# This suite provides tools for PHP development, code quality, and a preconfigured Nginx web server with PHP-FPM.
#
# Packages are grouped and ordered as follows:
#   1. PHP Toolchain (PHP, extensions, composer)
#   2. Code Quality & Utilities (linters, formatters)
#   3. Web Server (Nginx with PHP-FPM)
#
{ config, pkgs, ... }:

let
  customPhp = pkgs.php.withExtensions ({ enabled, all }: enabled ++ [
    all.imagick
    all.redis
    all.sodium
    all.intl
    all.mbstring
    all.gd
    all.pdo
    all.pdo_mysql
    all.pdo_pgsql
    all.zip
    all.xml
    all.curl
    all.bcmath
    all.soap
    all.apcu
    all.xdebug
    all.yaml
  ]);
in
{
  environment.systemPackages = with pkgs; [
    # --- PHP Toolchain ---
    customPhp
    phpPackages.composer        # PHP dependency manager

    # --- Code Quality & Utilities ---
    phpPackages.phpstan         # Static analysis tool
    phpPackages.psysh           # Interactive shell

    # --- Web Utilities ---
    curl
    jq
    dart-sass 
  ];

  # --- Nginx Web Server with PHP-FPM ---
  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      root = "/var/www";
      locations."/" = {
        index = "index.php";
        extraConfig = ''
          try_files $uri $uri/ =404;
        '';
      };
      locations."~ \.php$" = {
        extraConfig = ''
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_pass unix:${config.services.phpfpm.pools.php.socket};
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        '';
      };
    };
  };

  services.phpfpm.pools.php = {
    user = "nginx";
    group = "nginx";
    phpPackage = pkgs.php;
    phpOptions = ''
      upload_max_filesize = 512M
      post_max_size = 512M
      memory_limit = 512M
    '';
    settings = {
      "listen.owner" = "nginx";
      "listen.group" = "nginx";
      "pm" = "dynamic";
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
    };
  };

  # Ensure /var/www exists and is writable
  systemd.tmpfiles.rules = [
    "d /var/www 0755 nginx nginx - -"
  ];
}
