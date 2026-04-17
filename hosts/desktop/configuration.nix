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
    ../../modules/nixos/nvidia/desktop.nix
  ];

  activeTheme = lib.mkDefault "monolith";

  networking.hostName = "desktop";

  home-manager.users = {
    "${config.user.username}" = import ./home.nix;
  };
}
