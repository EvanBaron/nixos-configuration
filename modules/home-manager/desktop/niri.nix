{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:

let
  isLaptop = osConfig.device.type == "laptop";

  waylandEnv = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
    GDK_BACKEND = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  envToKdl =
    attrs: lib.concatStringsSep "\n        " (lib.mapAttrsToList (k: v: ''${k} "${v}"'') attrs);
in
{
  imports = [
    ./swaylock.nix
  ];

  services.swayidle = lib.mkIf isLaptop {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
      }
      {
        timeout = 600;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];
  };

  home.sessionVariables = (lib.mapAttrs (_: lib.mkDefault) waylandEnv) // {
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  xdg.configFile."niri/config.kdl".text = ''
    hotkey-overlay {
        skip-at-startup
    }

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            ${
              if isLaptop then
                ''
                  tap
                  dwt
                  accel-speed 0.3
                  accel-profile "adaptive"
                ''
              else
                ""
            }
        }

        mouse {
            accel-speed 0.2
            accel-profile "adaptive"
        }
    }

    output "DP-1" {
        mode "2560x1440@144.000"
        scale 1.0
    }

    layout {
        gaps 6
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 1
            active-color "#${config.colorScheme.palette.base02}"
            inactive-color "#${config.colorScheme.palette.base01}"
        }

        border {
            off
        }
    }

    prefer-no-csd

    window-rule {
        geometry-corner-radius 6
        clip-to-geometry true
    }

    spawn-at-startup "sh" "-c" "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP NIRI_SOCKET && hash dbus-update-activation-environment 2>/dev/null && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP NIRI_SOCKET"
    spawn-at-startup "${pkgs.quickshell}/bin/quickshell"
    spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${config.theme.wallpaper}" "-m" "fill"
    ${
      if isLaptop then
        ''
          spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet" "--indicator"
          spawn-at-startup "${pkgs.blueman}/bin/blueman-applet"
        ''
      else
        ""
    }

    binds {
        // Essential
        Mod+Return { spawn "${pkgs.kitty}/bin/kitty"; }
        Mod+D { spawn "${pkgs.quickshell}/bin/quickshell" "ipc" "call" "launcher" "toggle"; }
        Mod+Shift+D { spawn "${pkgs.wofi}/bin/wofi" "--show" "drun"; }
        Mod+S { spawn "${pkgs.quickshell}/bin/quickshell" "ipc" "call" "controlcenter" "toggle"; }
        Mod+Shift+Q { close-window; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+L { spawn "${pkgs.swaylock-effects}/bin/swaylock" "-fF"; }
        Mod+Shift+E { quit; }
        Mod+V { toggle-window-floating; }

        // Navigation — Left/Right also center the focused column via IPC
        Mod+Left  { spawn "sh" "-c" "${pkgs.niri}/bin/niri msg action focus-column-left  && ${pkgs.niri}/bin/niri msg action center-focused-column"; }
        Mod+Right { spawn "sh" "-c" "${pkgs.niri}/bin/niri msg action focus-column-right && ${pkgs.niri}/bin/niri msg action center-focused-column"; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }

        // Column Resizing
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        // Media
        XF86AudioRaiseVolume { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        XF86AudioPlay { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
        XF86AudioNext { spawn "${pkgs.playerctl}/bin/playerctl" "next"; }
        XF86AudioPrev { spawn "${pkgs.playerctl}/bin/playerctl" "previous"; }

        Print { spawn "sh" "-c" "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"; }
        Mod+Print { spawn "sh" "-c" "${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy"; }

        ${
          if isLaptop then
            ''
              XF86MonBrightnessUp   { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "+5%"; }
              XF86MonBrightnessDown { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-"; }
            ''
          else
            ""
        }
    }

    environment {
        ${envToKdl waylandEnv}
    }

    cursor {
        xcursor-theme "${config.home.pointerCursor.name}"
        xcursor-size ${toString config.home.pointerCursor.size}
    }
  '';
}
