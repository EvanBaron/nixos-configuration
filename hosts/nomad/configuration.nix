# ============================================================================
# NOMAD CONFIGURATION - Laptop Host
# ============================================================================

{
  ...
}:
let
  theme = import ../../themes/nomad.nix;
in
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

  # ========================================================================
  # HOME MANAGER INTEGRATION
  # ========================================================================

  home-manager = {
    users = {
      "ebaron" = import ./home.nix;
    };
  };
}
