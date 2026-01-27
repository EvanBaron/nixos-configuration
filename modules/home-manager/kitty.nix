{ config, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font Mono";
      size = 10;
    };
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      confirm_os_window_close = 0;
      background_opacity = "1.0";

      # Colors based on Nix-Colors palette
      foreground = "#${config.colorScheme.palette.base05}";
      background = "#${config.colorScheme.palette.base00}";
      selection_foreground = "#${config.colorScheme.palette.base00}";
      selection_background = "#${config.colorScheme.palette.base05}";

      color0 = "#${config.colorScheme.palette.base00}";
      color8 = "#${config.colorScheme.palette.base03}";

      color1 = "#${config.colorScheme.palette.base08}";
      color9 = "#${config.colorScheme.palette.base08}";

      color2 = "#${config.colorScheme.palette.base0B}";
      color10 = "#${config.colorScheme.palette.base0B}";

      color3 = "#${config.colorScheme.palette.base0A}";
      color11 = "#${config.colorScheme.palette.base0A}";

      color4 = "#${config.colorScheme.palette.base0D}";
      color12 = "#${config.colorScheme.palette.base0D}";

      color5 = "#${config.colorScheme.palette.base0E}";
      color13 = "#${config.colorScheme.palette.base0E}";

      color6 = "#${config.colorScheme.palette.base0C}";
      color14 = "#${config.colorScheme.palette.base0C}";

      color7 = "#${config.colorScheme.palette.base05}";
      color15 = "#${config.colorScheme.palette.base07}";
    };
  };
}
