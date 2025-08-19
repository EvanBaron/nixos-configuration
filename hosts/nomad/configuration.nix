# ============================================================================
# NOMAD CONFIGURATION - Laptop Host
# ============================================================================

{
  config,
  inputs,
  ...
}:
{
  # ========================================================================
  # SYSTEM IMPORTS AND HOST IDENTIFICATION
  # ========================================================================

  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/shared.nix
    ../../modules/nixos/tuigreet.nix
  ];

  networking.hostName = "nomad";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ========================================================================
  # HOME MANAGER INTEGRATION
  # ========================================================================

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      user = config.user;
    };

    users = {
      "${config.user.username}" = import ./home.nix;
    };
  };
}
