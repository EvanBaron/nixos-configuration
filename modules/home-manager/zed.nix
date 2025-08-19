# Zed editor configuration with development extensions and theming
{ theme }:
{
  pkgs,
  lib,
  ...
}:

{
  programs.zed-editor = {
    enable = true;

    # Install useful extensions for development
    extensions = [
      "nix"
      "toml"
      "make"
    ];

    userSettings = {
      # Configure Node.js paths for JavaScript development
      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      # Terminal settings within Zed
      terminal = {
        env = {
          TERM = "foot";
        };

        font_family = "Fira Mono";
      };

      # Editor appearance settings
      vim_mode = false;
      ui_font_size = 12;
      buffer_font_size = 10;
      buffer_font_family = "FiraCode Nerd Font Mono";

      # Theme configuration
      theme = theme.zed;
    };
  };

  home.sessionVariables = {
    EDITOR = "zed";
  };
}
