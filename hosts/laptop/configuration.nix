{
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/shared.nix
    ../../modules/nixos/nvidia/laptop.nix
    ../../modules/nixos/sunshine.nix
  ];

  activeTheme = lib.mkDefault "nomad";

  device.type = "laptop";

  networking.hostName = "laptop";

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  # powerManagement.powertop.enable = true;

  home-manager.users = {
    "${config.user.username}" = import ./home.nix;
  };
  home-manager.backupFileExtension = "backup";
}
