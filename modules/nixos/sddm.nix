{
  pkgs,
  config,
  inputs,
  ...
}:

let
  currentWallpaper =
    if config.networking.hostName == "monolith" then
      ../../hosts/monolith/wallpaper.png
    else
      ../../hosts/nomad/wallpaper.png;

  wallpaper = pkgs.runCommand "wallpaper.png" { } ''
    cp ${currentWallpaper} $out
  '';
in
{
  imports = [
    inputs.silentSDDM.nixosModules.default
  ];

  programs.silentSDDM = {
    enable = true;

    theme = "default";
    backgrounds = {
      wall = wallpaper;
    };

    settings = {
      General = {
        scale = 2.0;
      };

      LoginScreen = {
        background = "wallpaper.png";
      };
      LockScreen = {
        background = "wallpaper.png";
      };
    };
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
}
