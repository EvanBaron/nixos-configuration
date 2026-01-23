{ config, pkgs, ... }:

{
  home.packages = [ pkgs.gemini-cli ];

  home.file.".gemini/settings.json".text = builtins.toJSON {
    ui = {
      theme = "${config.colorScheme.name}";
      customThemes = {
        "${config.colorScheme.name}" = {
          name = "${config.colorScheme.name}";
          type = "custom";
          colors = {
            background = "#${config.colorScheme.palette.base00}";
            foreground = "#${config.colorScheme.palette.base05}";
            primary = "#${config.colorScheme.palette.base0D}";
            secondary = "#${config.colorScheme.palette.base0E}";
            accent = "#${config.colorScheme.palette.base0C}";
            error = "#${config.colorScheme.palette.base08}";
            warning = "#${config.colorScheme.palette.base0A}";
            info = "#${config.colorScheme.palette.base0D}";
            success = "#${config.colorScheme.palette.base0B}";
            text = "#${config.colorScheme.palette.base05}";
            textMuted = "#${config.colorScheme.palette.base03}";
            border = "#${config.colorScheme.palette.base01}";
            inputBackground = "#${config.colorScheme.palette.base01}";
            inputForeground = "#${config.colorScheme.palette.base05}";
            buttonBackground = "#${config.colorScheme.palette.base0D}";
            buttonForeground = "#${config.colorScheme.palette.base00}";
            scrollThumb = "#${config.colorScheme.palette.base02}";
            scrollTrack = "#${config.colorScheme.palette.base00}";
          };
        };
      };
    };
  };
}
