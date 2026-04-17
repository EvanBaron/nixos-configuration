{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/shared.nix
    ../../modules/nixos/nvidia/laptop.nix
  ];

  activeTheme = lib.mkDefault "nomad";

  device.type = "laptop";

  networking.hostName = "laptop";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  powerManagement.powertop.enable = true;

  home-manager.users = {
    "${config.user.username}" = import ./home.nix;
  };
  home-manager.backupFileExtension = "backup";
}
