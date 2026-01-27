{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  # Laptop check using system hostname
  isLaptop = osConfig.networking.hostName == "nomad";
  modifier = config.wayland.windowManager.sway.config.modifier;
in
{
  # Import Waybar for both hosts
  imports = [ ./waybar.nix ];

  options.theme.wallpaper = lib.mkOption {
    type = lib.types.path;
    description = "Path to the wallpaper image";
  };

  config = {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      SDL_VIDEODRIVER = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    wayland.windowManager.sway = {
      enable = true;
      package = null;

      config = {
        modifier = "Mod4";

        fonts = {
          names = [ "Fira Code Nerd Font" ];
          size = 11.0;
        };

        window = {
          border = 2;
          titlebar = false;
        };

        floating = {
          border = 2;
          titlebar = false;
        };

        focus.followMouse = true;

        gaps = {
          inner = 8;
          outer = 4;
          smartGaps = true;
          smartBorders = "on";
        };

        # Dynamic Wallpaper based on hostname
        output = {
          "*" = {
            bg = "${config.theme.wallpaper} fill";
          };
        };

        # Disable default bars
        bars = [ ];

        input = lib.mkIf isLaptop {
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
            dwt = "enabled";
            accel_profile = "adaptive";
            pointer_accel = "0.3";
            scroll_factor = "0.5";
            middle_emulation = "enabled";
            tap_button_map = "lrm";
          };
        };

        colors = {
          focused = {
            background = "#${config.colorScheme.palette.base02}";
            border = "#${config.colorScheme.palette.base0D}";
            childBorder = "#${config.colorScheme.palette.base0D}";
            indicator = "#${config.colorScheme.palette.base0D}";
            text = "#${config.colorScheme.palette.base07}";
          };
          focusedInactive = {
            background = "#${config.colorScheme.palette.base01}";
            border = "#${config.colorScheme.palette.base01}";
            childBorder = "#${config.colorScheme.palette.base01}";
            indicator = "#${config.colorScheme.palette.base03}";
            text = "#${config.colorScheme.palette.base05}";
          };
          unfocused = {
            background = "#${config.colorScheme.palette.base00}";
            border = "#${config.colorScheme.palette.base00}";
            childBorder = "#${config.colorScheme.palette.base00}";
            indicator = "#${config.colorScheme.palette.base00}";
            text = "#${config.colorScheme.palette.base04}";
          };
          urgent = {
            background = "#${config.colorScheme.palette.base08}";
            border = "#${config.colorScheme.palette.base08}";
            childBorder = "#${config.colorScheme.palette.base08}";
            indicator = "#${config.colorScheme.palette.base08}";
            text = "#${config.colorScheme.palette.base07}";
          };
          placeholder = {
            background = "#${config.colorScheme.palette.base00}";
            border = "#${config.colorScheme.palette.base00}";
            childBorder = "#${config.colorScheme.palette.base00}";
            indicator = "#${config.colorScheme.palette.base00}";
            text = "#${config.colorScheme.palette.base05}";
          };
        };

        keybindings = lib.mkOptionDefault (
          {
            # Common Keybindings
            "${modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
            "${modifier}+d" =
              "exec ${pkgs.wmenu}/bin/wmenu-run -f 'Fira Code Nerd Font 11' -N '#${config.colorScheme.palette.base00}' -n '#${config.colorScheme.palette.base05}' -M '#${config.colorScheme.palette.base02}' -m '#${config.colorScheme.palette.base07}' -S '#${config.colorScheme.palette.base0D}' -s '#${config.colorScheme.palette.base07}'";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+f" = "fullscreen";
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+e" =
              "exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";

            # Focus & Movement
            "${modifier}+Left" = "focus left";
            "${modifier}+Down" = "focus down";
            "${modifier}+Up" = "focus up";
            "${modifier}+Right" = "focus right";
            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Down" = "move down";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+Right" = "move right";

            # Layout
            "${modifier}+b" = "splith";
            "${modifier}+v" = "splitv";
            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";
            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+space" = "focus mode_toggle";
            "${modifier}+Shift+minus" = "move scratchpad";
            "${modifier}+minus" = "scratchpad show";

            # Media & Screenshots
            "Print" =
              "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
            "${modifier}+Print" = "exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy";

            # Audio
            "XF86AudioRaiseVolume" =
              "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ${pkgs.libnotify}/bin/notify-send 'Volume' \"$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%\"";
            "XF86AudioLowerVolume" =
              "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ${pkgs.libnotify}/bin/notify-send 'Volume' \"$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%\"";
            "XF86AudioMute" =
              "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ${pkgs.libnotify}/bin/notify-send 'Audio' 'Output $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo Muted || echo Unmuted)'";
            "XF86AudioMicMute" =
              "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && ${pkgs.libnotify}/bin/notify-send 'Audio' 'Microphone $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo Muted || echo Unmuted)'";
            "${modifier}+a" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";

            # Media Keys
            "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          }
          // lib.optionalAttrs isLaptop {
            # Laptop Specific Keybindings

            # Brightness
            "XF86MonBrightnessDown" = "exec light -U 5";
            "XF86MonBrightnessUp" = "exec light -A 5";

            # Power
            "${modifier}+F4" = "exec systemctl suspend";
            "${modifier}+Shift+F4" = "exec systemctl hibernate";

            # WiFi & Bluetooth
            "${modifier}+F2" =
              "exec ${pkgs.networkmanager}/bin/nmcli radio wifi off && ${pkgs.libnotify}/bin/notify-send 'WiFi' 'Disabled'";
            "${modifier}+Shift+F2" =
              "exec ${pkgs.networkmanager}/bin/nmcli radio wifi on && ${pkgs.libnotify}/bin/notify-send 'WiFi' 'Enabled'";
            "${modifier}+n" = "exec ${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
            "${modifier}+F3" =
              "exec ${pkgs.bluez}/bin/bluetoothctl power off && ${pkgs.libnotify}/bin/notify-send 'Bluetooth' 'Disabled'";
            "${modifier}+Shift+F3" =
              "exec ${pkgs.bluez}/bin/bluetoothctl power on && ${pkgs.libnotify}/bin/notify-send 'Bluetooth' 'Enabled'";
            "${modifier}+Shift+b" = "exec ${pkgs.blueman}/bin/blueman-manager";
          }
        );

        window.commands = [
          # Common Rules
          {
            command = "floating enable, resize set 800 600";
            criteria = {
              app_id = "pavucontrol";
            };
          }
          {
            command = "border pixel 2";
            criteria = {
              class = ".*";
            };
          }
        ]
        ++ lib.optionals isLaptop [
          # Laptop Specific Rules
          {
            command = "floating enable, resize set 800 600";
            criteria = {
              app_id = "nm-connection-editor";
            };
          }
          {
            command = "floating enable, resize set 600 400";
            criteria = {
              app_id = "blueman-manager";
            };
          }
          {
            command = "floating enable";
            criteria = {
              app_id = "org.gnome.PowerStats";
            };
          }
        ];
      };

      extraConfig = ''
        exec waybar
      ''
      + lib.optionalString isLaptop ''
        # Auto-lock on lid close
        bindswitch --reload --locked lid:on exec ${pkgs.swaylock}/bin/swaylock -fF

        # Idle configuration for laptop
        exec ${pkgs.swayidle}/bin/swayidle -w \
            timeout 300 '${pkgs.swaylock}/bin/swaylock -fF' \
            timeout 600 'swaymsg "output * dpms off"' \
            resume 'swaymsg "output * dpms on"' \
            timeout 900 'systemctl suspend' \
            before-sleep '${pkgs.swaylock}/bin/swaylock -fF'

        # Laptop tray apps
        exec ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
        exec ${pkgs.blueman}/bin/blueman-applet
      '';
    };

    home.packages =
      with pkgs;
      [
        # Common
        pavucontrol
        pulseaudio
        alsa-utils
        libnotify
        playerctl
        waybar
      ]
      ++ lib.optionals isLaptop [
        # Laptop specific
        powertop
        networkmanagerapplet
        iwgtk
        blueman
      ];

    # Kanshi for laptop only
    services.kanshi = lib.mkIf isLaptop {
      enable = true;
      settings = [
        {
          profile.name = "laptop-only";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
            }
          ];
        }
        {
          profile.name = "external-display";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "DP-1";
              status = "enable";
            }
          ];
        }
      ];
    };
  };
}
