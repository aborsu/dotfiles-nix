# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.hostName = "papacube"; # Define your hostname.
  networking.hostId = "07b765cf";
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "be-latin1";
    defaultLocale = "fr_BE.UTF-8";
  };

  # Needed for steam
  hardware.opengl.driSupport32Bit = true;


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [

    # CmdLine
    sl
    nettools
    git
    scala
    sshpass
    openssl
    sshfsFuse
    pythonPackages.py3status
    python3
    python3Packages.ipython
    python3Packages.numpy
    python3Packages.scipy
    ruby
    htop
    sbt
    jdk
    unrar
    unzip
    vim
    wget
    which
    packer
    ansible

    # Desktop Specific
    vagrant

    # Games
    steam

    # Graphical environment
    dmenu
    firefoxWrapper
    i3lock
    i3status
    networkmanagerapplet

    #Non-Free
    skype
    sublime3
  ];


  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [
      pkgs.anonymousPro
      pkgs.corefonts
      pkgs.dejavu_fonts
      pkgs.font-awesome-ttf
      pkgs.freefont_ttf
      pkgs.terminus_font
      pkgs.ttf_bitstream_vera
    ];
  };

  nix = {
    extraOptions = ''
        gc-keep-outputs = true
        gc-keep-derivations = true
        auto-optimise-store = true
    '';
  };

  nixpkgs.config = {

    allowUnfree = true;

    firefox = {
      jre = false;
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };
  };

  # List services that you want to enable:

  programs = {
    bash.enableCompletion = true;
  };


  networking.firewall.enable = false;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 80 8080 9200 7630 7474 ];

  virtualisation.virtualbox.host.enable = true;

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    openssh.enable = true;
    openssh.allowSFTP = false;
    openssh.forwardX11 = false;
    openssh.permitRootLogin = "no";
    openssh.passwordAuthentication = true;
    openssh.challengeResponseAuthentication = false;

    postgresql = {
      enable = true;
    };

    httpd = {
      enable = true;
      adminAddr = "a.borsu@gmail.com";
      enablePHP = true;
      documentRoot = "/www";
      # extraSubservices = [ {
      # 	serviceType = "owncloud";
      # 	dbPassword = "test";
      # 	adminPassword = "test";
      # }];
    };

   xserver = {
      xrandrHeads = ["HDMI2" "HDMI1"];

      enable = true;
      layout = "be";

      windowManager.i3.enable = true;
      windowManager.default = "i3";
      desktopManager.xfce.enable = true;
      displayManager.lightdm.enable = true;
    };
  };

  users.extraUsers."aborsu" =
      { #createUser = true;
        extraGroups = [ "wheel" "vboxusers" "networkmanager" ] ;
        home = "/home/aborsu";
        description = "Augustin Borsu";
        uid = 1000;
      };

  time.timeZone = "Europe/Brussels";
}

