{ config, ... }:
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        margin-top = 8;
        margin-left = 8;
        margin-right = 8;
        mode = "dock";

        modules-left = [ "sway/workspaces" ];
        modules-center = [ ];
        modules-right = [
          "pulseaudio"
          "memory"
          "battery"
          "tray"
          "custom/notification"
          "clock#time"
        ];

        "clock#time" = {
          interval = 1;
          format = "{:%H:%M:%S}";
          tooltip = false;
        };

        memory = {
          interval = 5;
          format = "  {}%";
          states = {
            warning = 70;
            critical = 90;
          };
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
          states = {
            warning = 30;
            critical = 10;
          };
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = " 00%";
          format-icons = {
            default = [
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };

        "sway/workspaces" = {
          all-outputs = false;
          disable-scroll = true;
          format = "{icon} {name}";
          format-icons = {
            "1:www" = "龜";
            "2:mail" = "";
            "3:code" = "";
            "4:term" = "";
            "5:media" = "";
            urgent = "";
            focused = "";
            default = "";
          };
        };

        tray = {
          icon-size = 20;
          spacing = 12;
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };
      };
    };

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
        padding: 0 4px;
        background-color: transparent;
        color: #${config.colorScheme.palette.base05};
        border-bottom: 2px solid transparent;
      }

      #workspaces button.urgent {
        color: #${config.colorScheme.palette.base08};
      }

      #mode {
        background-color: #${config.colorScheme.palette.base02};
        border-bottom: 1px solid #${config.colorScheme.palette.base05};
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #pulseaudio,
      #tray,
      #custom-notification {
        padding: 0 8px;
        color: #${config.colorScheme.palette.base05};
      }

      /* Memory States */
      #memory.warning {
        color: #${config.colorScheme.palette.base0A};
      }
      #memory.critical {
        color: #${config.colorScheme.palette.base08};
      }

      /* Battery States */
      #battery.charging, #battery.plugged {
        color: #${config.colorScheme.palette.base0B};
      }
      #battery.warning:not(.charging) {
        color: #${config.colorScheme.palette.base0A};
      }
      #battery.critical:not(.charging) {
        color: #${config.colorScheme.palette.base08};
      }

      #pulseaudio.muted {
        color: #${config.colorScheme.palette.base03};
      }
    '';
  };
}
