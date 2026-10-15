{ config, ... }:

let
  p = config.colorScheme.palette;
  inherit (config.theme) ui;
  hex = c: if builtins.substring 0 1 c == "#" then c else "#${c}";
in

{
  programs.wofi = {
    enable = true;
    settings = {
      mode = "drun";
      width = 400;
      height = 500;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
      gtk_dark = true;
    };
    # Matches the Quickshell launcher: surface radius 14, search field radius 10, rows radius 10.
    style = ''
      * {
        font-family: "Fira Sans", sans-serif;
        font-size: 15px;
      }

      window {
        margin: 0px;
        border: 1px solid ${hex p.base02};
        border-radius: 14px;
        background-color: alpha(${hex p.base00}, 0.96);
      }

      #outer-box {
        margin: 12px;
        border: none;
        background-color: transparent;
      }

      #input {
        margin: 0 0 8px 0;
        padding: 10px 12px;
        border: 1px solid transparent;
        border-radius: 10px;
        color: ${hex p.base05};
        background-color: ${hex p.base01};
        box-shadow: none;
        outline: none;
      }

      #input:focus {
        border-color: ${hex ui.accent};
      }

      #inner-box,
      #scroll {
        margin: 0;
        border: none;
        background-color: transparent;
      }

      #entry {
        padding: 10px 12px;
        border-radius: 10px;
        transition: background-color 120ms cubic-bezier(0.33, 1, 0.68, 1);
      }

      #entry:selected {
        background-color: ${hex p.base02};
        outline: none;
      }

      #text {
        margin: 0 0 0 8px;
        border: none;
        color: ${hex p.base05};
      }

      #text:selected {
        color: ${hex p.base05};
      }
    '';
  };
}
