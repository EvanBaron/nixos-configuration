{
  pkgs,
  lib,
  ...
}:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "toml"
      "make"
    ];

    userSettings = {
      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      terminal = {
        env = {
          TERM = "foot";
        };

        font_family = "Fira Mono";
      };

      vim_mode = false;
      ui_font_size = 12;
      buffer_font_size = 10;
      buffer_font_family = "FiraCode Nerd Font Mono";

      theme = {
        mode = "system";
        light = "Gruvbox Dark Soft";
        dark = "One Dark";
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "zeditor";
  };
}
