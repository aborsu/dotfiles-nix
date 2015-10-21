# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "fr_BE.UTF-8";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    screen
    byobu
    irssi
    bashCompletion
    vim
    iptables
    git
  ];

  # List services that you want to enable:


  services = {

    postgresql = {
      enable = true;
      package = pkgs.postgresql94;
    };

    mysql = {
      enable = true;
      package = pkgs.mysql;
    };

    xserver.enable = false;

    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };

    httpd = {
      enable = true;
      adminAddr="a.borsu@gmail.com";
      enablePHP = true;

      virtualHosts = [
        { # Catches all connections to unspecified hosts.
          documentRoot = "/www";
        }
        { # Forces all connections on acelpb.com to https
          hostName = "acelpb.com";
          extraConfig = ''
            RewriteEngine On
            RewriteCond %{HTTPS} off
            RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
          '';
        }
        { # hostname acelpb.com with document root and owncloud
          hostName = "acelpb.com";
          documentRoot = "/wwwacelpb";
      
          extraSubservices = [
            {
              trustedDomain = "acelpb.com";
              serviceType = "owncloud";
              dbUser = "owncloud";
              dbPassword = "SECRET";
              adminUser = "aborsu";
              adminPassword = "SECRET";
            }
          ];
          sslServerCert = "/home/aborsu/.ssl/ssl.cert";
          sslServerKey = "/home/aborsu/.ssl/ssl.key";
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
    password = "test";
  };

}

