# ============================================================================
# MONOLITH CONFIGURATION - Desktop Host
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
    ../../modules/nixos/nvidia/monolith.nix
    ../../modules/nixos/steam.nix
  ];

  networking.hostName = "monolith";

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
