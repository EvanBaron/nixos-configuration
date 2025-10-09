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
    ../../modules/nixos/nvidia/nomad.nix
    ../../modules/nixos/steam.nix
  ];

  networking.hostName = "nomad";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ========================================================================
  # POWER MANAGEMENT
  # ========================================================================
  services.tlp.enable = true;
  powerManagement.powertop.enable = true;

  powerManagement.cpuFreqGovernor = "powersave";

  # ========================================================================
  # BRIGHTNESS CONTROL
  # ========================================================================
  programs.light.enable = true;
  users.groups.video.members = [ config.user.username ];

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
