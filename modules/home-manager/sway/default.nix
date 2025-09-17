# ============================================================================
# STRUCTURED SWAY CONFIGURATION - HOME MANAGER MODULE
# ============================================================================

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ========================================================================
  # WAYLAND SESSION ENVIRONMENT
  # ========================================================================

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # ========================================================================
  # SWAY WINDOW MANAGER CONFIGURATION
  # ========================================================================

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = {
      # ====================================================================
      # BASIC CONFIGURATION
      # ====================================================================

      modifier = "Mod4"; # Super/Windows key

      # Font configuration
      fonts = {
        names = [ "Fira Code Nerd Font" ];
        size = 11.0;
      };

      # ====================================================================
      # VISUAL APPEARANCE
      # ====================================================================

      # Window borders
      window = {
        border = 2;
        titlebar = false;
      };

      floating = {
        border = 2;
        titlebar = false;
      };

      # Hide borders when only one window is visible
      focus.followMouse = true;

      # Gaps configuration
      gaps = {
        inner = 8;
        outer = 4;
        smartGaps = true;
        smartBorders = "on";
      };

      # ====================================================================
      # COLOR SCHEME
      # ====================================================================

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

      # ====================================================================
      # KEYBINDINGS
      # ====================================================================

      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          # Application launching
          "${modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
          "${modifier}+d" =
            "exec ${pkgs.wmenu}/bin/wmenu-run -f 'Fira Code Nerd Font 11' -N '#${config.colorScheme.palette.base00}' -n '#${config.colorScheme.palette.base05}' -M '#${config.colorScheme.palette.base02}' -m '#${config.colorScheme.palette.base07}' -S '#${config.colorScheme.palette.base0D}' -s '#${config.colorScheme.palette.base07}'";

          # Window management
          "${modifier}+Shift+q" = "kill";
          "${modifier}+f" = "fullscreen";

          # System controls
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+e" =
            "exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";

          # Focus movement
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # Window movement
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # Container splitting
          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";

          # Layout modes
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";

          # Floating mode
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";

          # Scratchpad
          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          # Screenshots
          "Print" =
            "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
          "${modifier}+Print" = "exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy";

          # Volume controls with notifications
          "XF86AudioRaiseVolume" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ${pkgs.libnotify}/bin/notify-send 'Volume' \"$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%\"";
          "XF86AudioLowerVolume" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ${pkgs.libnotify}/bin/notify-send 'Volume' \"$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%\"";
          "XF86AudioMute" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ${pkgs.libnotify}/bin/notify-send 'Audio' 'Output $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo Muted || echo Unmuted)'";
          "XF86AudioMicMute" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && ${pkgs.libnotify}/bin/notify-send 'Audio' 'Microphone $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo Muted || echo Unmuted)'";

          # Alternative volume controls using Super key (unique keys to avoid conflicts)
          "${modifier}+bracketright" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ${pkgs.libnotify}/bin/notify-send 'Volume' \"$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%\"";
          "${modifier}+bracketleft" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ${pkgs.libnotify}/bin/notify-send 'Volume' \"$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%\"";
          "${modifier}+backslash" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ${pkgs.libnotify}/bin/notify-send 'Audio' 'Output $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo Muted || echo Unmuted)'";

          # Audio device switching
          "${modifier}+Shift+a" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-default $(${pkgs.wireplumber}/bin/wpctl status | grep 'Audio/Sink' | head -2 | tail -1 | awk '{print $2}' | sed 's/\.//') && ${pkgs.libnotify}/bin/notify-send 'Audio' 'Switched output device'";

          # Audio control GUI
          "${modifier}+a" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";

          # Media player controls
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "${modifier}+p" =
            "exec ${pkgs.playerctl}/bin/playerctl play-pause && ${pkgs.libnotify}/bin/notify-send 'Media' 'Play/Pause toggled'";
        };

      # ====================================================================
      # WORKSPACE CONFIGURATION
      # ====================================================================

      workspaceAutoBackAndForth = true;

      # ====================================================================
      # WINDOW RULES
      # ====================================================================

      # Window rules for common applications
      window.commands = [
        # Audio control GUI
        {
          command = "floating enable, resize set 800 600";
          criteria = {
            app_id = "pavucontrol";
          };
        }

        # Window borders for all applications
        {
          command = "border pixel 2";
          criteria = {
            class = ".*";
          };
        }
        {
          command = "border pixel 2";
          criteria = {
            app_id = ".*\ases";
          };
        }
      ];
    };
    extraConfig = ''
      exec waybar
    '';
  };

  # ========================================================================
  # COMMON PACKAGES
  # ========================================================================

  home.packages = with pkgs; [
    pavucontrol
    pulseaudio
    alsa-utils
    libnotify
    playerctl
    waybar
  ];
}
