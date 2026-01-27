{
  pkgs,
  ...
}:
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
    ];
  };

  services.gvfs.enable = true; # Mount, trash, etc
  services.tumbler.enable = true; # Thumbnails
}
