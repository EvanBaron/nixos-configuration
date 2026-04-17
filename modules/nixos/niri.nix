{
  pkgs,
  ...
}:
{
  programs.niri = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Core Wayland utilities
    swaylock
    swayidle
    wl-clipboard
    swaybg

    # Screenshot tools
    grim
    slurp

    wf-recorder
  ];

  security.polkit.enable = true;
  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
}
