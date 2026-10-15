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

    # XWayland support
    xwayland-satellite

    # Screenshot tools
    grim
    slurp
    jq

    wf-recorder
  ];

  security.polkit.enable = true;

  # PAM service for the Quickshell lock screen (PamContext config "quickshell").
  security.pam.services.quickshell = { };

  # Give sleep inhibitors (swayidle's before-sleep hook, see
  # desktop/niri.nix) more headroom before logind suspends anyway.
  # Default is 5s, which a network mount teardown could brush up against.
  services.logind.settings.Login = {
    InhibitDelayMaxSec = 10;
    # A short press opens the power menu (niri binds XF86PowerOff); holding the
    # key still powers off, as an escape hatch if the session is stuck.
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "poweroff";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
}
