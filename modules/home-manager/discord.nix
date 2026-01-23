{ config, pkgs, ... }:

{
  programs.nixcord = {
    enable = true;
    discord = {
      enable = true;
      vencord.enable = true;
    };

    config = {
      useQuickCss = true;
      frameless = true;
      plugins = {
        betterFolders.enable = true;
        memberListDecorations.enable = true;
        platformIndicators.enable = true;
      };
    };

    quickCss = ''
      :root {
        --background-primary: #${config.colorScheme.palette.base00};
        --background-secondary: #${config.colorScheme.palette.base01};
        --background-tertiary: #${config.colorScheme.palette.base00};
        --background-accent: #${config.colorScheme.palette.base02};
        --text-normal: #${config.colorScheme.palette.base05};
        --text-muted: #${config.colorScheme.palette.base04};
        --header-primary: #${config.colorScheme.palette.base0D};
        --header-secondary: #${config.colorScheme.palette.base05};
        --interactive-normal: #${config.colorScheme.palette.base05};
        --interactive-hover: #${config.colorScheme.palette.base0D};
        --interactive-active: #${config.colorScheme.palette.base0D};
        --interactive-muted: #${config.colorScheme.palette.base03};
        --brand-experiment: #${config.colorScheme.palette.base0D};
      }
    '';
  };
}
