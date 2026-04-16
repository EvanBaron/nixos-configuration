{
  pkgs,
  ...
}:

{
  services.easyeffects.enable = true;

  home.packages = with pkgs; [
    # DAWs and Guitar tools
    zrythm
    guitarix

    # Plugin Suites
    lsp-plugins
    calf
    distrho-ports
    vital

    # Utilities
    playerctl
    pulsemixer
    pulseaudio
    alsa-utils
    crosspipe
  ];
}
