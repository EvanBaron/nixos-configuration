# ============================================================================
# MONOLITH-SPECIFIC SWAY CONFIGURATION OVERRIDES
# ============================================================================

{
  pkgs,
  ...
}:
let
  theme = import ../../../themes/monolith.nix;

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
    (import ./default.nix { inherit theme; })
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
          names = [ theme.fonts.ui ];
          size = theme.fonts.size * 1.0;
        };
        statusCommand = "${statusBarScript}";
        colors = {
          background = theme.colors.background;
          statusline = theme.colors.text.primary;
          separator = theme.colors.secondary;
          focusedWorkspace = {
            background = theme.colors.workspace.focused.background;
            border = theme.colors.workspace.focused.background;
            text = theme.colors.workspace.focused.foreground;
          };
          activeWorkspace = {
            background = theme.colors.workspace.active.background;
            border = theme.colors.workspace.active.background;
            text = theme.colors.workspace.active.foreground;
          };
          inactiveWorkspace = {
            background = theme.colors.workspace.inactive.background;
            border = theme.colors.workspace.inactive.background;
            text = theme.colors.workspace.inactive.foreground;
          };
          urgentWorkspace = {
            background = theme.colors.workspace.urgent.background;
            border = theme.colors.workspace.urgent.background;
            text = theme.colors.workspace.urgent.foreground;
          };
        };
      }
    ];
  };
}
