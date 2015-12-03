{
  owncloud =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 1024;
      deployment.virtualbox.headless = true;
      deployment.targetHost = "192.168.56.50";

      networking.firewall.enable = false;
      networking.firewall.allowedTCPPorts = [ 80 ];
      networking.firewall.allowPing = true;
      networking.interfaces.eth1.ip4 = [ { address = "192.168.56.50"; prefixLength = 24; } ];


      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        wget
        vim
        git
        curl
      ];

      services = {

        mysql = {
          enable = true;
          package = pkgs.mariadb;
        };

        postgresql = {
          enable = true;
          package = pkgs.postgresql94;
          # authentication = pkgs.lib.mkOverride 10 ''
          #   local mediawiki all ident map=mwusers
          #   local all all ident
          # '';
          # identMap = ''
          #   mwusers root mediawiki
          #   mwusers wwwrun mediawiki
          # '';
        };

        xserver.enable = false;

        openssh = {
          enable = true;
          allowSFTP = false;
          forwardX11 = false;
          permitRootLogin = "yes";
          passwordAuthentication = true;
          challengeResponseAuthentication = false;
        };


        httpd = {
          enable = true;
          adminAddr="a.borsu@gmail.com";
          enablePHP = true;
          documentRoot = "/www";

          virtualHosts = [
            {

              hostName = "owncloud.local";
              extraSubservices = [
                {
                  urlPrefix = "/owncloud705";
                  trustedDomain = "owncloud.local";
                  package = pkgs.owncloud705;
                  serviceType = "owncloud";
                  dbUser = "owncloud705";
                  dbPassword = "owncloud705";
                  dbName = "owncloud705";
                  adminUser = "aborsu";
                  adminPassword = "owncloud705";
                  dataDir = "/var/lib/owncloud705";
                }
                {
                  urlPrefix = "/owncloud70";
                  trustedDomain = "owncloud.local";
                  package = pkgs.owncloud70;
                  serviceType = "owncloud";
                  dbUser = "owncloud70";
                  dbPassword = "owncloud70";
                  dbName = "owncloud70";
                  adminUser = "aborsu";
                  adminPassword = "owncloud70";
                  dataDir = "/var/lib/owncloud70";
                }
                {
                  urlPrefix = "/owncloud80";
                  trustedDomain = "owncloud.local";
                  package = pkgs.owncloud80;
                  serviceType = "owncloud";
                  dbUser = "owncloud80";
                  dbPassword = "owncloud80";
                  dbName = "owncloud80";
                  adminUser = "aborsu";
                  adminPassword = "owncloud80";
                  dataDir = "/var/lib/owncloud80";
                }
                {
                  urlPrefix = "/owncloud81";
                  trustedDomain = "owncloud.local";
                  package = pkgs.owncloud81;
                  serviceType = "owncloud";
                  dbUser = "owncloud81";
                  dbPassword = "owncloud81";
                  dbName = "owncloud81";
                  adminUser = "aborsu";
                  adminPassword = "owncloud81";
                  dataDir = "/var/lib/owncloud81";
                }
                {
                  urlPrefix = "/owncloud82";
                  trustedDomain = "owncloud.local";
                  package = pkgs.owncloud82;
                  serviceType = "owncloud";
                  dbUser = "owncloud82";
                  dbPassword = "owncloud82";
                  dbName = "owncloud82";
                  adminUser = "aborsu";
                  adminPassword = "owncloud82";
                  dataDir = "/var/lib/owncloud82";
                }
              ];
            }
          ];
        };
      };

    };
}
