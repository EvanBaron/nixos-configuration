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

    # SilentSDDM now defaults to kwin, which applies its own HiDPI scaling
    # on top of `scale` below; weston doesn't, so keep the old look.
    wayland = {
      enable = true;
      compositor = "weston";
    };

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
