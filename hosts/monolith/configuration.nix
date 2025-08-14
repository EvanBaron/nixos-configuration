# ============================================================================
# MONOLITH CONFIGURATION - Desktop Host
# ============================================================================
#
# Host Details:
# - Type: Desktop computer
# - Theme: Olive/Yellow-green color scheme matching wallpaper
#
{
  pkgs,
  inputs,
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
    (import ../../modules/nixos/gtkgreet.nix { inherit theme; })
  ];

  networking.hostName = "monolith";

  # ========================================================================
  # VISUAL THEMING CONFIGURATION
  # ========================================================================

  # ------------------------------------------------------------------------
  # Wallpaper Configuration
  # Sets the desktop background image for all outputs
  # ------------------------------------------------------------------------
  environment.etc."sway/config.d/wallpaper".text = ''
    # Apply monolith wallpaper to all connected displays
    # Uses 'fill' mode to scale appropriately while maintaining aspect ratio
    output * bg ${./wallpaper.png} fill
  '';

  # ------------------------------------------------------------------------
  # Status Bar Configuration
  # Desktop-specific status bar (no battery info needed)
  # ------------------------------------------------------------------------
  environment.etc."sway/config.d/statusbar".text = ''
    # Status bar for desktop - shows time and date with olive theme
    bar {
        position top                    # Place at top of screen
        height 32                       # Comfortable height for readability

        # Display current time and date with icons
        status_command while date +'🕐 %H:%M  📅 %Y-%m-%d'; do sleep 1; done

        # Use our themed font
        font pango:${theme.fonts.ui} ${toString theme.fonts.size}

        # Color scheme matching our olive theme
        colors {
            background ${theme.colors.background}    # Dark background
            statusline ${theme.colors.text.primary}  # Olive text
            separator ${theme.colors.secondary}      # Darker olive separator

            # Workspace indicator colors
            focused_workspace   ${theme.colors.workspace.focused.background} ${theme.colors.workspace.focused.background} ${theme.colors.workspace.focused.foreground}
            active_workspace    ${theme.colors.workspace.active.background} ${theme.colors.workspace.active.background} ${theme.colors.workspace.active.foreground}
            inactive_workspace  ${theme.colors.workspace.inactive.background} ${theme.colors.workspace.inactive.background} ${theme.colors.workspace.inactive.foreground}
            urgent_workspace    ${theme.colors.workspace.urgent.background} ${theme.colors.workspace.urgent.background} ${theme.colors.workspace.urgent.foreground}
        }
    }
  '';

  # ------------------------------------------------------------------------
  # Window Border and Decoration Colors
  # Sway window styling based on focus state
  # ------------------------------------------------------------------------
  environment.etc."sway/config.d/colors".text = ''
    # Window color configuration for monolith olive theme
    # Format: client.<state> <border> <background> <text> <indicator> <child_border>

    client.focused           ${theme.colors.border.focused}   ${theme.colors.border.focused}    ${theme.colors.text.onPrimary}   ${theme.colors.secondary}   ${theme.colors.border.focused}
    client.focused_inactive  ${theme.colors.border.inactive}   ${theme.colors.border.inactive}    ${theme.colors.text.primary}   ${theme.colors.border.inactive}   ${theme.colors.border.inactive}
    client.unfocused         ${theme.colors.border.unfocused}   ${theme.colors.border.unfocused}    ${theme.colors.text.secondary}   ${theme.colors.border.unfocused}   ${theme.colors.border.unfocused}
    client.urgent            ${theme.colors.border.urgent}   ${theme.colors.border.urgent}    ${theme.colors.text.onPrimary}   ${theme.colors.border.urgent}   ${theme.colors.border.urgent}
    client.placeholder       ${theme.colors.background}   ${theme.colors.background}    ${theme.colors.text.primary}   ${theme.colors.background}   ${theme.colors.background}
  '';

  # ------------------------------------------------------------------------
  # Application Launcher Configuration
  # Themed wmenu for application launching
  # ------------------------------------------------------------------------
  environment.etc."sway/config.d/wmenu".text = ''
    # Custom wmenu styling matching monolith olive theme
    set $menu wmenu-run -f "${theme.fonts.ui} ${toString theme.fonts.size}" -N "${theme.colors.menu.background}" -n "${theme.colors.menu.foreground}" -M "${theme.colors.menu.selected.background}" -m "${theme.colors.menu.selected.foreground}" -S "${theme.colors.menu.highlight.background}" -s "${theme.colors.menu.highlight.foreground}"

    # Bind Super+D to launch the themed application menu
    bindsym $mod+d exec $menu
  '';

  # ========================================================================
  # HOME MANAGER INTEGRATION
  # ========================================================================

  home-manager = {
    users = {
      "ebaron" = import ./home.nix;
    };
  };
}
