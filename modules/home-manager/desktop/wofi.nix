{ config, ... }:

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
    style = ''
      window {
        margin: 0px;
        border: 2px solid #${config.colorScheme.palette.base06};
        background-color: #${config.colorScheme.palette.base00};
        font-family: "Fira Code Nerd Font";
        font-size: 14px;
      }

      #input {
        margin: 5px;
        border: none;
        color: #${config.colorScheme.palette.base05};
        background-color: #${config.colorScheme.palette.base02};
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #${config.colorScheme.palette.base05};
      }

      #entry:selected {
        background-color: #${config.colorScheme.palette.base02};
      }
    '';
  };
}
