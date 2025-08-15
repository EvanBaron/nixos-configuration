# ============================================================================
# NOMAD-SPECIFIC SWAY CONFIGURATION OVERRIDES
# ============================================================================

{
  config,
  pkgs,
  lib,
  ...
}:
let
  theme = import ../../../themes/nomad.nix;

  statusBarScript = pkgs.writeShellScript "sway-nomad-status.sh" ''
    #!${pkgs.stdenv.shell}
    while true;
    do
      # Battery status
      battery_level=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 || echo "?")
      battery_status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1 || echo "Unknown")
      if [ "$battery_status" = "Charging" ];
      then
        battery_icon="🔌"
      elif [ "$battery_level" -gt 80 ];
      then
        battery_icon="🔋"
      elif [ "$battery_level" -gt 40 ];
      then
        battery_icon="🪫"
      else
        battery_icon="🪫"
      fi

      # WiFi status
      wifi_name=$(${pkgs.coreutils}/bin/timeout 2 ${pkgs.networkmanager}/bin/nmcli -t -f NAME c show --active | head -1)
      if [ -n "$wifi_name" ]; then
          wifi_icon="📶"
      else
          wifi_icon="📵"
          wifi_name="Disconnected"
      fi

      # Bluetooth status
      bluetooth_powered=$(${pkgs.coreutils}/bin/timeout 2 ${pkgs.bluez}/bin/bluetoothctl show | grep "Powered" | awk '{print $2}')
      if [ "$bluetooth_powered" = "yes" ];
      then
        bluetooth_icon="🔵"
      else
        bluetooth_icon="⚫"
      fi

      # Volume status
      volume_line=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)
      volume=$(echo "$volume_line" | awk '{print int($2*100)}')
      muted=$(echo "$volume_line" | grep -o "MUTED" || echo "")
      if [ "$muted" = "MUTED" ];
      then
        volume_icon="🔇"
      elif [ "$volume" -gt 66 ];
      then
        volume_icon="🔊"
      elif [ "$volume" -gt 33 ];
      then
        volume_icon="🔉"
      else
        volume_icon="🔈"
      fi

      # Display all status information
      echo "$battery_icon $battery_level%  $wifi_icon $wifi_name  $bluetooth_icon  $volume_icon $volume%  🕐 $(date +'%H:%M')  📅 $(date +'%Y-%m-%d')"
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
  # NOMAD-SPECIFIC OVERRIDES
  # ========================================================================

  wayland.windowManager.sway.config = {
    # ======================================================================
    # OUTPUT CONFIGURATION - WALLPAPER
    # ======================================================================

    output = {
      "*" = {
        bg = "${../../../hosts/nomad/wallpaper.png} fill";
      };
    };

    # ======================================================================
    # LAPTOP-SPECIFIC KEYBINDINGS
    # ======================================================================

    keybindings =
      let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in
      lib.mkOptionDefault {
        # Brightness controls
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";

        # Power management
        "${modifier}+F4" = "exec systemctl suspend";
        "${modifier}+Shift+F4" = "exec systemctl hibernate";

        # WiFi toggles
        "${modifier}+F2" =
          "exec ${pkgs.networkmanager}/bin/nmcli radio wifi off && ${pkgs.libnotify}/bin/notify-send 'WiFi' 'Disabled'";
        "${modifier}+Shift+F2" =
          "exec ${pkgs.networkmanager}/bin/nmcli radio wifi on && ${pkgs.libnotify}/bin/notify-send 'WiFi' 'Enabled'";
        "${modifier}+n" = "exec ${pkgs.networkmanagerapplet}/bin/nm-connection-editor";

        # Bluetooth toggles
        "${modifier}+F3" =
          "exec ${pkgs.bluez}/bin/bluetoothctl power off && ${pkgs.libnotify}/bin/notify-send 'Bluetooth' 'Disabled'";
        "${modifier}+Shift+F3" =
          "exec ${pkgs.bluez}/bin/bluetoothctl power on && ${pkgs.libnotify}/bin/notify-send 'Bluetooth' 'Enabled'";
        "${modifier}+Shift+b" = "exec ${pkgs.blueman}/bin/blueman-manager";
      };

    # ======================================================================
    # STATUS BAR CONFIGURATION - LAPTOP
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

    # ======================================================================
    # LAPTOP-SPECIFIC INPUT CONFIGURATION
    # ======================================================================

    input = {
      # Touchpad configuration for laptop
      "type:touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
        dwt = "enabled"; # Disable while typing
        accel_profile = "adaptive";
        pointer_accel = "0.3";
        scroll_factor = "0.5";
        middle_emulation = "enabled";
        tap_button_map = "lrm"; # Left, right, middle for 1, 2, 3 finger tap
      };
    };

    # ======================================================================
    # LAPTOP-SPECIFIC WINDOW RULES
    # ======================================================================

    window.commands = [
      # Network manager as floating window
      {
        command = "floating enable, resize set 800 600";
        criteria = {
          app_id = "nm-connection-editor";
        };
      }

      # Bluetooth manager as floating window
      {
        command = "floating enable, resize set 600 400";
        criteria = {
          app_id = "blueman-manager";
        };
      }

      # Power management GUI
      {
        command = "floating enable";
        criteria = {
          app_id = "org.gnome.PowerStats";
        };
      }
    ];
  };

  # ========================================================================
  # LAPTOP-SPECIFIC ADDITIONAL CONFIGURATION
  # ========================================================================

  wayland.windowManager.sway.extraConfig = ''
    # Auto-lock on lid close (requires systemd-logind)
    bindswitch --reload --locked lid:on exec ${pkgs.swaylock}/bin/swaylock -fF

    # Idle configuration for laptop - more aggressive power saving
    exec ${pkgs.swayidle}/bin/swayidle -w \
        timeout 300 '${pkgs.swaylock}/bin/swaylock -fF' \
        timeout 600 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        timeout 900 'systemctl suspend' \
        before-sleep '${pkgs.swaylock}/bin/swaylock -fF'

    # Start network manager applet
    exec ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator

    # Start bluetooth manager
    exec ${pkgs.blueman}/bin/blueman-applet

    # Start notification daemon with laptop-appropriate settings
    exec ${pkgs.mako}/bin/mako --font='${theme.fonts.ui} ${toString theme.fonts.size}' --background-color='${theme.colors.background}' --text-color='${theme.colors.text.primary}' --border-color='${theme.colors.primary}' --border-radius=8 --border-size=2 --default-timeout=5000
  '';

  # ========================================================================
  # LAPTOP-SPECIFIC HOME MANAGER PACKAGES
  # ========================================================================

  home.packages = with pkgs; [
    # Power management
    brightnessctl
    powertop

    # Network management
    networkmanagerapplet
    iwgtk # Lightweight WiFi GUI

    # Bluetooth management
    blueman
  ];

  # ========================================================================
  # LAPTOP-SPECIFIC SERVICES
  # ========================================================================

  services = {
    mako = {
      enable = false;
    };

    kanshi = {
      enable = true;
      profiles = {
        "laptop-only" = {
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
            }
          ];
        };
        "external-display" = {
          outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              # You may need to change this to match your external display's name
              # (e.g., "DP-1" or "HDMI-A-1")
              criteria = "DP-1";
              status = "enable";
            }
          ];
        };
      };
    };
  };
}
