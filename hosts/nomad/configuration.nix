{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/shared.nix
    ../../modules/nixos/tuigreet.nix
    ../../modules/nixos/nvidia/nomad.nix
  ];

  networking.hostName = "nomad";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.tlp.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  programs.light.enable = true;

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
