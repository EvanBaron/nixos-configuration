# ============================================================================
# MONOLITH CONFIGURATION - Desktop Host
# ============================================================================

{
  ...
}:
let
  theme = import ../../themes/monolith.nix;
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

  networking.hostName = "monolith";

  # ========================================================================
  # HOME MANAGER INTEGRATION
  # ========================================================================

  home-manager = {
    users = {
      "ebaron" = import ./home.nix;
    };
  };
}
