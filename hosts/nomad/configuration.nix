{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/shared.nix
    ../../modules/nixos/nvidia/nomad.nix
  ];

  networking.hostName = "nomad";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.power-profiles-daemon.enable = true;
  powerManagement.powertop.enable = true;

  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
      user = config.user;
    };

    users = {
      "${config.user.username}" = import ./home.nix;
    };
  };
}
