# ============================================================================
# MONOLITH-SPECIFIC SWAY CONFIGURATION OVERRIDES
# ============================================================================

{
  config,
  pkgs,
  ...
}:
let
  statusBarScript = pkgs.writeShellScript "sway-monolith-status.sh" ''
    while true;
    do
      # Volume status
      volume=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
      muted=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED" || echo "")
      if [ "$muted" = "MUTED" ]; then
        volume_icon="🔇"
      elif [ "$volume" -gt 66 ]; then
        volume_icon="🔊"
      elif [ "$volume" -gt 33 ]; then
        volume_icon="🔉"
      else
        volume_icon="🔈"
      fi

      # Display all status information
      echo "$volume_icon $volume%  🕐 $(date +'%H:%M')  📅 $(date +'%Y-%m-%d')"
      sleep 5
    done
  '';
in
{
  # ========================================================================
  # IMPORT BASE SWAY CONFIGURATION
  # ========================================================================

  imports = [
    ./default.nix
  ];

  # ========================================================================
  # MONOLITH-SPECIFIC OVERRIDES
  # ========================================================================

  wayland.windowManager.sway.config = {
    # ======================================================================
    # OUTPUT CONFIGURATION - WALLPAPER
    # ======================================================================

    output = {
      "*" = {
        bg = "${../../../hosts/monolith/wallpaper.png} fill";
      };
    };

    # ======================================================================
    # STATUS BAR CONFIGURATION - DESKTOP
    # ======================================================================

    bars = [
      {
        position = "top";
        fonts = {
          names = [ "Fira Code Nerd Font" ];
          size = 11.0;
        };
        statusCommand = "${statusBarScript}";
        colors = {
          background = "#${config.colorScheme.palette.base00}";
          statusline = "#${config.colorScheme.palette.base05}";
          separator = "#${config.colorScheme.palette.base03}";
          focusedWorkspace = {
            background = "#${config.colorScheme.palette.base02}";
            border = "#${config.colorScheme.palette.base02}";
            text = "#${config.colorScheme.palette.base05}";
          };
          activeWorkspace = {
            background = "#${config.colorScheme.palette.base01}";
            border = "#${config.colorScheme.palette.base01}";
            text = "#${config.colorScheme.palette.base04}";
          };
          inactiveWorkspace = {
            background = "#${config.colorScheme.palette.base00}";
            border = "#${config.colorScheme.palette.base00}";
            text = "#${config.colorScheme.palette.base03}";
          };
          urgentWorkspace = {
            background = "#${config.colorScheme.palette.base08}";
            border = "#${config.colorScheme.palette.base08}";
            text = "#${config.colorScheme.palette.base07}";
          };
        };
      }
    ];
  };
}
