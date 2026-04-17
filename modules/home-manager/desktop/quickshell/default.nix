# Config based on https://github.com/tahfizhabib/niriha

{
  config,
  pkgs,
  mylib,
  ...
}:

let
  palette = config.colorScheme.palette;

  files = {
    "Colors.qml" = import ./Colors.nix { inherit palette; };
    "Bar.qml" = import ./Bar.nix { };
    "ActionBar.qml" = import ./ActionBar.nix { };
    "AppLauncher.qml" = import ./AppLauncher.nix { };
    "ControlCenter.qml" = import ./ControlCenter.nix { inherit pkgs; };
    "StatisticsPopup.qml" = import ./StatisticsPopup.nix { };
    "SystemStats.qml" = import ./SystemStats.nix { };
    "CalendarPopup.qml" = import ./CalendarPopup.nix { };
    "NotificationPopup.qml" = import ./NotificationPopup.nix { };
    "NotificationService.qml" = import ./NotificationService.nix { };
    "ControlCenterSlider.qml" = import ./ControlCenterSlider.nix { };
    "ControlCenterToggle.qml" = import ./ControlCenterToggle.nix { };
    "TrayPill.qml" = import ./TrayPill.nix { };
    "SystemTray.qml" = import ./SystemTray.nix { };
  };

  qmldir = ''
    singleton Colors 1.0 Colors.qml
    Bar 1.0 Bar.qml
    ActionBar 1.0 ActionBar.qml
    AppLauncher 1.0 AppLauncher.qml
    ControlCenter 1.0 ControlCenter.qml
    StatisticsPopup 1.0 StatisticsPopup.qml
    singleton SystemStats 1.0 SystemStats.qml
    CalendarPopup 1.0 CalendarPopup.qml
    NotificationPopup 1.0 NotificationPopup.qml
    singleton NotificationService 1.0 NotificationService.qml
    ControlCenterSlider 1.0 ControlCenterSlider.qml
    ControlCenterToggle 1.0 ControlCenterToggle.qml
    TrayPill 1.0 TrayPill.qml
    SystemTray 1.0 SystemTray.qml
  '';

  quickshell-config = mylib.builders.mkQuickshellConfig {
    inherit files qmldir;
  };

in
{
  home.packages = with pkgs; [
    quickshell
    brightnessctl
    playerctl
    power-profiles-daemon
    procps
    upower
    blueman
    networkmanager_dmenu
  ];

  xdg.configFile."quickshell" = {
    source = quickshell-config;
    recursive = true;
  };
}
