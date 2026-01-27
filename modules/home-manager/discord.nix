{ ... }:

{
  programs.nixcord = {
    enable = true;
    discord = {
      enable = true;
      vencord.enable = true;
    };

    config = {
      useQuickCss = false;
      frameless = true;
      plugins = {
        betterFolders.enable = true;
        platformIndicators.enable = true;
      };
    };

    quickCss = "";
  };
}
