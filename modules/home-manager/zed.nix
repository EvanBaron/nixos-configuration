# Zed editor configuration with development extensions and theming
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
      theme = {
        mode = "system";
        light = "Gruvbox Dark Soft";
        dark = "One Dark";
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "zed";
  };
}
