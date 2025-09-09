# ============================================================================
# NOMAD-SPECIFIC SWAY CONFIGURATION OVERRIDES
# ============================================================================

{
  config,
  pkgs,
  lib,
  ...
}:
{
  # ========================================================================
  # IMPORT BASE SWAY CONFIGURATION
  # ========================================================================

  imports = [
    ./default.nix
    ./waybar.nix
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
        "XF86MonBrightnessDown" = "exec light -U 5";
        "XF86MonBrightnessUp" = "exec light -A 5";

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

    bars = [ ];

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
    exec ${pkgs.mako}/bin/mako --font='Fira Code Nerd Font 11' --background-color='#${config.colorScheme.palette.base00}' --text-color='#${config.colorScheme.palette.base05}' --border-color='#${config.colorScheme.palette.base0D}' --border-radius=8 --border-size=2 --default-timeout=5000
  '';

  # ========================================================================
  # LAPTOP-SPECIFIC HOME MANAGER PACKAGES
  # ========================================================================

  home.packages = with pkgs; [
    # Power management
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
