{
  inputs,
  config,
  mylib,
  ...
}:

{
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    vesktop.enable = true;
    config = {
      useQuickCss = false;
      enabledThemes = [ "base16-nix.css" ];
      plugins = {
        # General
        relationshipNotifier.enable = true;
        shikiCodeblocks.enable = true;
        vencordToolbox.enable = true;
        voiceChatDoubleClick.enable = true;

        # Visual
        anonymiseFileNames.enable = true;
        fakeProfileThemes.enable = true;
        memberCount.enable = true;
        typingIndicator.enable = true;

        # Chat
        callTimer.enable = true;
        CopyUserURLs.enable = true;
        favoriteGifSearch.enable = true;
        noDevtoolsWarning.enable = true;
        petpet.enable = true;
        validUser.enable = true;
      };
    };
  };

  home.file.".config/vesktop/themes/base16-nix.css".text =
    mylib.discord.generateThemeCSS config.colorScheme.palette config.theme.wallpaper;

  xdg.desktopEntries.discord = {
    name = "Discord";
    exec = "vesktop %U";
    icon = "discord";
    terminal = false;
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];
    mimeType = [ "x-scheme-handler/discord" ];
  };
}
