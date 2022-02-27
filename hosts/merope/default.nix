# System configuration for my Raspberry Pi 4
{ config, pkgs, system, inputs, ... }:

let nur = import inputs.nur { nurpkgs = import inputs.nixpkgs { inherit system; }; };
in
{
  imports = [
    nur.repos.misterio.modules.argonone
    inputs.hardware.nixosModules.raspberry-pi-4

    ./hardware-configuration.nix
    ../common
    ../common/postgres.nix

    ./deluge.nix
    # ./ddclient.nix
    ./files-server.nix
    ./jitsi.nix
    ./minecraft.nix
    ./navidrome.nix
    ./nginx.nix
    ./wireguard.nix

    ./disconic.nix
    ./paste-misterio-me.nix
    ./pokedex-pfpa.nix
    ./sistemer-bot.nix
  ];

  # Static IP address
  networking = {
    useDHCP = false;
    interfaces.eth0 = {
      useDHCP = true;
      wakeOnLan.enable = true;

      ipv4.addresses = [{
        address = "192.168.77.10";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2804:14d:8084:a484:ffff:ffff:ffff:ffff";
        prefixLength = 64;
      }];
    };
    # Open ports for nginx
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  # Passwordless sudo (for remote build)
  security.sudo.extraConfig = "%wheel ALL = (ALL) NOPASSWD: ALL";

  # Enable argonone fan daemon
  hardware.argonone.enable = true;
}
