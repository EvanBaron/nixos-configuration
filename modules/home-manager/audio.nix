{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # Guitar tools
    guitarix

    # Plugin Suites
    calf
    distrho-ports

    # Utilities
    playerctl
    pulsemixer
    pulseaudio
    alsa-utils
    crosspipe
  ];
}
