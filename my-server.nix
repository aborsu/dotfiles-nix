let
  acelpbIp = "91.121.89.48";
in
{
  acelpb =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "none";
      deployment.targetHost = acelpbIp;

      boot.initrd.availableKernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" =
        { device = "/dev/disk/by-uuid/ffc9ae5b-fbeb-417c-8d5c-e8264cf67cfd";
          fsType = "ext4";
        };

      fileSystems."/home" =
        { device = "/dev/disk/by-uuid/1d341331-f650-47ed-b887-c3746c82e9e7";
          fsType = "ext4";
        };

      fileSystems."/var" =
        { device = "/dev/disk/by-uuid/c794f800-0f22-482f-b905-6b4cafdeff91";
          fsType = "ext4";
        };

      swapDevices =
        [ { device = "/dev/disk/by-uuid/1a28f73a-6957-4a3b-9d2f-03106b83bbd6"; }
          { device = "/dev/disk/by-uuid/b8e18aad-15bc-47b0-b51e-5853bfc46a42"; }
        ];

      # Define your hostname.
      networking.hostName = "ns358417";
      networking.hostId = "385cabe4";

      # IPv4 settings
      networking.interfaces.eth0.ip4 = [
        { address = acelpbIp;
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

      # Use the GRUB 2 boot loader.
      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;

      # Define on which hard drive you want to install Grub.
      boot.loader.grub.device = "/dev/sda";

      imports = [ ./acelpb1.nix ];
    };
}
