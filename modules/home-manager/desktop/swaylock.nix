{ pkgs, config, ... }:

let
  p = config.colorScheme.palette;
  inherit (config.theme) ui;
  # swaylock wants RRGGBB[AA] without a leading "#".
  c = x: if builtins.substring 0 1 x == "#" then builtins.substring 1 (-1) x else x;
in
{
  # Fallback lock (Mod+Ctrl+Shift+L, or when Quickshell's lock screen is unavailable),
  # styled after the Quickshell LockScreen: accent ring, critical when wrong.
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      timestr = "%H:%M";
      datestr = "%A %e %B";
      screenshot = true;
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";

      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 6;

      font = "Fira Sans";
      font-size = 28;

      line-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      line-clear-color = "00000000";
      separator-color = "00000000";

      inside-color = "${c p.base00}cc";
      inside-ver-color = "${c p.base00}cc";
      inside-wrong-color = "${c p.base00}cc";
      inside-clear-color = "${c p.base00}cc";

      ring-color = "${c p.base02}";
      ring-ver-color = "${c ui.accent}";
      ring-wrong-color = "${c ui.critical}";
      ring-clear-color = "${c ui.fgAlt}";
      key-hl-color = "${c ui.accent}";
      bs-hl-color = "${c ui.critical}";

      text-color = "${c p.base05}";
      text-ver-color = "${c p.base05}";
      text-wrong-color = "${c ui.critical}";
      text-clear-color = "${c ui.fgAlt}";
      text-caps-lock-color = "${c p.base0A}";
    };
  };
}
