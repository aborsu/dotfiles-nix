# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_BE.UTF-8";
  time.timeZone = "Europe/Brussels";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bashCompletion
    git
    vim
    wget
  ];

  systemd.services.httpd.environment.SSL_CERT_FILE = "/home/aborsu/.ssl/ssl.crt";

  services = {

    openssh.enable = true;

    postgresql = {
      enable = true;
      package = pkgs.postgresql94;
    };

    xserver.enable = false;

    jenkins = {
      enable = true;
      extraOptions = [ "--prefix=/jenkins" "--httpListenAddress=localhost" ];
      port = 2711;
    };

    httpd = let domain1 = "acelpb.com"; in {
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


              ProxyPass         /jenkins  http://localhost:2711/jenkins nocanon
              ProxyPassReverse  /jenkins  http://localhost:2711/jenkins
              ProxyRequests     Off
              AllowEncodedSlashes NoDecode

              # Local reverse proxy authorization override
              # Most unix distribution deny proxy by default (ie /etc/apache2/mods-enabled/proxy.conf in Ubuntu)
              <Proxy http://localhost:2711/jenkins*>
                Order deny,allow
                Allow from all
              </Proxy>
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
          sslServerCert = "/home/aborsu/.ssl/ssl.cert";
          sslServerKey = "/home/aborsu/.ssl/ssl.key";
          enableSSL = true;
        }
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.aborsu = {
    description = "Augustin Borsu";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDT6nGess3TiV7KCZqCzv7wqny1GYsH9bkiT6Vae2Xo8I0YgvkqD6C/QszEk28lu7CMsm2bb8bDkYKm6Ce8jTin+hyobVvlxC5fAYZK8oE4AKn1rHkDqq1wnJwTRIrB97Nc2077BHAv2OLh5G2A/uazkIWxcoIBJNne9fFXY8B98DoB4WsDtBxj7OFnDIm27qX2VtScrr7U95SGjKN6F6MUyFEcFu9GhkXLs8BS/G8oVfSSmHFTBpIeNQ69BX7NXb+mWP98ouD4yGsRSiKZHdSwjVWI1JU4MO0tGkRAZXY2p0vacp+ePh6r0ESHbVUazX4Vof7p1i35VlIg850C9iAq6xhx3b59lYVk6AyAhfj0lujz10+00EkHy6l9BmtzBV1mFmTJpMPFQQ00Hup92ihMyGNglgPs23s3lR8iLjQ7gDpNohHmFKBFSG2Jp2tEhnfuH3tz3NWn4pXPyIUWs5znRb9Sup7/XoRtelZrSEai/EUPeP5RysYMsxiRoms47rD8FWTE0hQFUrHjQzk+RGUd/OCBv3LPR6wiwfRmdIJnNg6yDahNsRiJ3bCqtwjRkdpZ1ezLAzgwNVaNRWq4EEHMfeQ7Oud7yjgdqhb0vvAy5J4ZSHM05+77sNQoAPVEYlEhYJwyfukDMprkImypVhdOplkGaqTxMDvPY46ipGjK5Q== aborsu@mbpro-gus-Ven 16 oct 2015 10:13:03 CEST" ];
  };

  users.extraUsers.jcm = {
    isNormalUser = true;
    description = "Jean-Christophe Maigrot";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKjZS/Z37B0kZ1jfWXNQGEsNU9LM2Y2YcghHqFiO5IuWSu+XzFoRdeeFfcsfF/j5uQbWy+23z2CvuivsdNAdqS4Gl7X+wAg9pG9A+h9BRWEjGN/Llpq0NOPeiFSgLOxFuu4VOU6QzVPpgSLLWqM+av3Ib8q5UHCE49CPIcptwnOFmSQtvk6nDtbZpb9WA+MnL+xOp1P1nXu9JbpUUvCcZuqYWSrg+OMEkFv9ujTzK9uEnUMgQq4N7o4swUpXcs1dKt9Ev96Pr+GlSmcr567l+Ach2nX6+4l01ygzCCzEEzyodFT8qf8xGw3Aak+38Bu/qcqtHXNxPQ4IQgFyhyiyFl jcm@acelpb-" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Define your hostname.
  networking.hostName = "ns358417";
  networking.hostId = "385cabe4";

  # IPv4 settings
  networking.interfaces.eth0.ip4 = [
    { address = "91.121.89.48";
      prefixLength = 24; } ];
  networking.defaultGateway = "91.121.89.254";
  networking.nameservers = [ "213.186.33.99" ];

  # IPv6 settings
  networking.localCommands =
    ''
      ip -6 addr add 2001:41D0:1:8E30::/64 dev eth0
      ip -6 route add 2001:41D0:1:8Eff:ff:ff:ff:ff dev eth0
      ip -6 route add default via 2001:41D0:1:8Eff:ff:ff:ff:ff
    '';
}


