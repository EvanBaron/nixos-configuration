{ config, pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "custom";

    customColorScheme = {
      text = config.colorScheme.palette.base05;
      subtext = config.colorScheme.palette.base04;
      sidebar-text = config.colorScheme.palette.base05;
      main = config.colorScheme.palette.base00;
      sidebar = config.colorScheme.palette.base00;
      player = config.colorScheme.palette.base01;
      card = config.colorScheme.palette.base00;
      shadow = config.colorScheme.palette.base00;
      selected-row = config.colorScheme.palette.base02;
      button = config.colorScheme.palette.base0D;
      button-active = config.colorScheme.palette.base0D;
      button-disabled = config.colorScheme.palette.base03;
      tab-active = config.colorScheme.palette.base02;
      notification = config.colorScheme.palette.base0D;
      notification-error = config.colorScheme.palette.base08;
      misc = config.colorScheme.palette.base00;
    };
  };
}
