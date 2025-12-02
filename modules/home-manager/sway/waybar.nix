{
  config,
  ...
}:
{
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "Fira Code Nerd Font";
        font-size: 12px;
      }

      #waybar {
        background-color: #${config.colorScheme.palette.base00};
        color: #${config.colorScheme.palette.base03};
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #${config.colorScheme.palette.base05};
        border-bottom: 2px solid transparent;
      }

      #workspaces button.focused {
        border-bottom: 2px solid #${config.colorScheme.palette.base05};
      }

      #mode {
        background-color: #${config.colorScheme.palette.base02};
        border-bottom: 1px solid #${config.colorScheme.palette.base05};
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
        color: #${config.colorScheme.palette.base05};
      }
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "battery"
          "tray"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };

        "sway/mode" = {
          format = "<span style='italic'>{}</span>";
        };

        clock = {
          format = " {:%H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " Muted";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
            ];
          };
        };

        network = {
          format-wifi = " {essid} ({signalStrength}%) ";
          format-ethernet = " {ifname}";
          format-disconnected = "⚠ Disconnected";
        };

        cpu = {
          format = " {usage}%";
        };

        memory = {
          format = " {used:0.1f}G/{total:0.1f}G";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        tray = {
          icon-size = 21;
          spacing = 10;
        };
      };
    };
  };
}
