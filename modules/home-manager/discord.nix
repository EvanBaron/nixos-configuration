{ config, ... }:

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
        platformIndicators.enable = true;
      };
    };

    quickCss = ''
      :root {
          --base00: #${config.colorScheme.palette.base00};
          --base01: #${config.colorScheme.palette.base01};
          --base02: #${config.colorScheme.palette.base02};
          --base03: #${config.colorScheme.palette.base03};
          --base04: #${config.colorScheme.palette.base04};
          --base05: #${config.colorScheme.palette.base05};
          --base06: #${config.colorScheme.palette.base06};
          --base07: #${config.colorScheme.palette.base07};
          --base08: #${config.colorScheme.palette.base08};
          --base09: #${config.colorScheme.palette.base09};
          --base0A: #${config.colorScheme.palette.base0A};
          --base0B: #${config.colorScheme.palette.base0B};
          --base0C: #${config.colorScheme.palette.base0C};
          --base0D: #${config.colorScheme.palette.base0D};
          --base0E: #${config.colorScheme.palette.base0E};
          --base0F: #${config.colorScheme.palette.base0F};

          --primary-630: var(--base00);
          --primary-660: var(--base00);
      }

      body, #app-mount {
          background-color: var(--base00) !important;
          background: var(--base00) !important;
      }

      .theme-light, .theme-dark {
          --search-popout-option-fade: none;
          --bg-overlay-2: var(--base00);
          --home-background: var(--base00);
          --background-primary: var(--base00);
          --background-secondary: var(--base01);
          --background-secondary-alt: var(--base01);
          --channeltextarea-background: var(--base01);
          --background-tertiary: var(--base00);
          --background-accent: var(--base0E);
          --background-floating: var(--base01);
          --background-modifier-selected: var(--base00);
          --text-normal: var(--base05);
          --text-secondary: var(--base00);
          --text-muted: var(--base03);
          --text-link: var(--base0C);
          --interactive-normal: var(--base05);
          --interactive-hover: var(--base0C);
          --interactive-active: var(--base0A);
          --interactive-muted: var(--base03);
          --header-primary: var(--base06);
          --header-secondary: var(--base03);
          --scrollbar-thin-track: transparent;
          --scrollbar-auto-track: transparent;
      }
    '';
  };
}
