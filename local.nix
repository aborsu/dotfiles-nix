{
  acelpb =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 2048;
      deployment.virtualbox.headless = true;

      deployment.targetHost = "192.168.56.10";
      networking.interfaces.eth1.ip4 = [ { address = "192.168.56.10"; prefixLength = 24; } ];

      imports = [ ./acelpb.nix ];
    };

  nixops =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 2048;
      deployment.virtualbox.headless = true;

      deployment.targetHost = "192.168.56.11";
      networking.interfaces.eth1.ip4 = [ { address = "192.168.56.11"; prefixLength = 24; } ];

      # Select internationalisation properties.
      i18n.defaultLocale = "fr_BE.UTF-8";
      time.timeZone = "Europe/Brussels";

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        bashCompletion
        nixops
        git
        vim
      ];
    };
}
