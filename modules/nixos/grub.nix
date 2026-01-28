{
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
in
{
  imports = [ inputs.grub2-themes.nixosModules.default ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 10;
    };

    grub2-theme = {
      enable = true;
      theme = "stylish";
      icon = "white";
      screen = "2k";
      footer = true;
      splashImage = currentWallpaper;
    };
  };
}
