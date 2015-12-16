{
  acelpb =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 2048;
      deployment.virtualbox.headless = true;

      # services.httpd.documentRoot = "${pkgs.valgrind}/share/doc/valgrind/html";
      networking.firewall.allowedTCPPorts = [ 80 ];

      deployment.targetHost = "192.168.56.10";
      networking.interfaces.eth1.ip4 = [ { address = "192.168.56.10"; prefixLength = 24; } ];

      # networking.firewall.allowPing = true;
      # networking.firewall.allowedTCPPorts = [ 22 80 443 ];

      # Select internationalisation properties.
      i18n.defaultLocale = "fr_BE.UTF-8";
      time.timeZone = "Europe/Berlin";

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        bashCompletion
        curl
        git
        vim
        wget
      ];

      # # List services that you want to enable:

      services = {

        postgresql = {
          enable = true;
          package = pkgs.postgresql94;
        };

      #   xserver.enable = false;

        httpd = {
          enable = true;
          adminAddr="a.borsu@gmail.com";
          enablePHP = true;

          virtualHosts = [
            { # Catches all connections to unspecified hosts.
              documentRoot = "/www";
            }
            # { # Forces all connections on acelpb.com to https
            #   hostName = "acelpb.local";
            #   extraConfig = ''
            #     RewriteEngine On
            #     RewriteCond %{HTTPS} off
            #     RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
            #   '';
            # }
            { # hostname acelpb.com with document root and owncloud
              hostName = "acelpb.local";
              documentRoot = "/www";

              extraSubservices = [
                {
                  urlPrefix = "/owncloud";
                  trustedDomain = "acelpb.local";
                  serviceType = "owncloud";
                  dbUser = builtins.readFile ./private/owncloud.dbUser;
                  dbPassword = builtins.readFile ./private/owncloud.dbPassword;
                  adminUser = builtins.readFile ./private/owncloud.adminUser;
                  adminPassword = builtins.readFile ./private/owncloud.adminPassword;
                }
              ];
              # sslServerCert = "/home/aborsu/.ssl/ssl.cert";
              # sslServerKey = "/home/aborsu/.ssl/ssl.key";
              # enableSSL = true;
            }
          ];
        };
      };


      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.extraUsers.aborsu = {
        description = "Augustin Borsu";
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "wheel" ];
      };
    };
}
