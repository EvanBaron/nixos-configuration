{
  pkgs,
  inputs,
  themeData,
  ...
}:

let
  wallpaper = pkgs.runCommand "wallpaper.png" { } ''
    cp ${themeData.wallpapers.login} $out
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
