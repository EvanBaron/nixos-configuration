{ pkgs, config, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      screenshot = true;
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";

      # Visual Indicator
      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;

      # Fonts
      font = "Fira Code Nerd Font";

      # Colors
      ring-color = "${config.colorScheme.palette.base0D}";
      key-hl-color = "${config.colorScheme.palette.base0B}";
      line-color = "00000000";
      inside-color = "00000088";
      separator-color = "00000000";

      text-color = "${config.colorScheme.palette.base05}";
      text-caps-lock-color = "${config.colorScheme.palette.base07}";
      ring-ver-color = "${config.colorScheme.palette.base0C}";
      inside-ver-color = "00000088";

      ring-wrong-color = "${config.colorScheme.palette.base08}";
      text-wrong-color = "${config.colorScheme.palette.base08}";
      inside-wrong-color = "00000088";
    };
  };
}
