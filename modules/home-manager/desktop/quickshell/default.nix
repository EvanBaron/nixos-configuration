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
    "Colors.qml" = import ./Colors.nix {
      inherit palette;
      inherit (config.theme) ui;
    };
    "Style.qml" = import ./Style.nix { };
    "Icons.qml" = import ./Icons.nix { };
    "Icon.qml" = import ./Icon.nix { };
    "FocusRing.qml" = import ./FocusRing.nix { };
    "PopupSurface.qml" = import ./PopupSurface.nix { };
    "SegmentedControl.qml" = import ./SegmentedControl.nix { };
    "Sparkline.qml" = import ./Sparkline.nix { };
    "AppIcons.qml" = import ./AppIcons.nix { inherit (config.gtk) iconTheme; };
    "AppIcon.qml" = import ./AppIcon.nix { };
    "Switch.qml" = import ./Switch.nix { };
    "PillButton.qml" = import ./PillButton.nix { };
    "PageHeader.qml" = import ./PageHeader.nix { };
    "NetworkPage.qml" = import ./NetworkPage.nix { };
    "BluetoothPage.qml" = import ./BluetoothPage.nix { };
    "Notifications.qml" = import ./Notifications.nix { };
    "NotificationCard.qml" = import ./NotificationCard.nix { };
    "NotificationToasts.qml" = import ./NotificationToasts.nix { };
    "NotificationCenter.qml" = import ./NotificationCenter.nix { };
    "PowerMenu.qml" = import ./PowerMenu.nix { inherit pkgs; };
    "DeskAudio.qml" = import ./DeskAudio.nix { inherit pkgs; };
    "NowPlaying.qml" = import ./NowPlaying.nix { };
    "Desk.qml" = import ./Desk.nix {
      inherit pkgs;
      inherit (config.theme) wallpaper;
    };
    "Osd.qml" = import ./Osd.nix { };
    "LockScreen.qml" = import ./LockScreen.nix { inherit (config.theme) wallpaper; };
    "Bar.qml" = import ./Bar.nix { };
    "ActionBar.qml" = import ./ActionBar.nix { };
    "AppLauncher.qml" = import ./AppLauncher.nix { };
    "ControlCenter.qml" = import ./ControlCenter.nix { };
    "StatisticsPopup.qml" = import ./StatisticsPopup.nix { };
    "SystemStats.qml" = import ./SystemStats.nix { };
    "CalendarPopup.qml" = import ./CalendarPopup.nix { };
    "ControlCenterSlider.qml" = import ./ControlCenterSlider.nix { };
    "ControlCenterToggle.qml" = import ./ControlCenterToggle.nix { };
    "TrayPill.qml" = import ./TrayPill.nix { };
    "SystemTray.qml" = import ./SystemTray.nix { };
  };

  qmldir = ''
    singleton Colors 1.0 Colors.qml
    singleton Style 1.0 Style.qml
    singleton Icons 1.0 Icons.qml
    Icon 1.0 Icon.qml
    FocusRing 1.0 FocusRing.qml
    PopupSurface 1.0 PopupSurface.qml
    SegmentedControl 1.0 SegmentedControl.qml
    Sparkline 1.0 Sparkline.qml
    singleton AppIcons 1.0 AppIcons.qml
    AppIcon 1.0 AppIcon.qml
    Switch 1.0 Switch.qml
    PillButton 1.0 PillButton.qml
    PageHeader 1.0 PageHeader.qml
    NetworkPage 1.0 NetworkPage.qml
    BluetoothPage 1.0 BluetoothPage.qml
    singleton Notifications 1.0 Notifications.qml
    NotificationCard 1.0 NotificationCard.qml
    NotificationToasts 1.0 NotificationToasts.qml
    NotificationCenter 1.0 NotificationCenter.qml
    PowerMenu 1.0 PowerMenu.qml
    singleton DeskAudio 1.0 DeskAudio.qml
    singleton NowPlaying 1.0 NowPlaying.qml
    Desk 1.0 Desk.qml
    Osd 1.0 Osd.qml
    LockScreen 1.0 LockScreen.qml
    Bar 1.0 Bar.qml
    ActionBar 1.0 ActionBar.qml
    AppLauncher 1.0 AppLauncher.qml
    ControlCenter 1.0 ControlCenter.qml
    StatisticsPopup 1.0 StatisticsPopup.qml
    singleton SystemStats 1.0 SystemStats.qml
    CalendarPopup 1.0 CalendarPopup.qml
    ControlCenterSlider 1.0 ControlCenterSlider.qml
    ControlCenterToggle 1.0 ControlCenterToggle.qml
    TrayPill 1.0 TrayPill.qml
    SystemTray 1.0 SystemTray.qml
  '';

  quickshell-config = mylib.builders.mkQuickshellConfig {
    inherit files qmldir;
    # Use the desktop's icon theme (Quickshell otherwise only searches hicolor).
    pragmas = [ "IconTheme ${config.gtk.iconTheme.name}" ];
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
  ];

  xdg.configFile."quickshell" = {
    source = quickshell-config;
    recursive = true;
  };
}
