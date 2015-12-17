# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_BE.UTF-8";
  time.timeZone = "Europe/Brussels";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bashCompletion
    byobu
    git
    iptables
    irssi
    screen
    vim
    wget
  ];

  systemd.services.httpd.environment.SSL_CERT_FILE = "/home/aborsu/.ssl/ssl.crt";

  services = {

    postgresql = {
      enable = true;
      package = pkgs.postgresql94;
    };

    xserver.enable = false;

    httpd = let domain1 = "acelpb.local"; in {
      enable = true;
      adminAddr="a.borsu@gmail.com";
      enablePHP = true;

      virtualHosts = [
        { # Catches all connections to unspecified hosts.
          documentRoot = "/var/www/root";
        }
        { # Forces all connections on acelpb.com to https
          hostName = domain1;
          extraConfig = ''
            RewriteEngine On
            RewriteCond %{HTTPS} off
            RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
          '';
        }
        { # hostname acelpb.com with document root and owncloud
          hostName = domain1;
          documentRoot = "/var/www/root";
          extraConfig =
            ''
              Alias /jcm /var/www/jcm

              <Directory /var/www/jcm>
                Options Indexes FollowSymLinks
                AllowOverride FileInfo
                Require all granted
              </Directory>
            '';

          extraSubservices = [
            {
              trustedDomain = domain1;
              urlPrefix = "/owncloud";
              serviceType = "owncloud";
              dbUser = builtins.readFile ./private/owncloud.dbUser;
              dbPassword = builtins.readFile ./private/owncloud.dbPassword;
              adminUser = builtins.readFile ./private/owncloud.adminUser;
              adminPassword = builtins.readFile ./private/owncloud.adminPassword;
            }
          ];
          sslServerCert = "/home/aborsu/.ssl/ssl.cert";;
          sslServerKey = "/home/aborsu/.ssl/ssl.key";;
          enableSSL = true;
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

  users.extraUsers.jcm = {
    isNormalUser = true;
    description = "Jean-Christophe Maigrot";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKjZS/Z37B0kZ1jfWXNQGEsNU9LM2Y2YcghHqFiO5IuWSu+XzFoRdeeFfcsfF/j5uQbWy+23z2CvuivsdNAdqS4Gl7X+wAg9pG9A+h9BRWEjGN/Llpq0NOPeiFSgLOxFuu4VOU6QzVPpgSLLWqM+av3Ib8q5UHCE49CPIcptwnOFmSQtvk6nDtbZpb9WA+MnL+xOp1P1nXu9JbpUUvCcZuqYWSrg+OMEkFv9ujTzK9uEnUMgQq4N7o4swUpXcs1dKt9Ev96Pr+GlSmcr567l+Ach2nX6+4l01ygzCCzEEzyodFT8qf8xGw3Aak+38Bu/qcqtHXNxPQ4IQgFyhyiyFl jcm@acelpb-" ];
  };

}

