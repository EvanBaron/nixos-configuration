# ============================================================================
# SYSTEM-LEVEL SWAY CONFIGURATION
# ============================================================================
#

{
  pkgs,
  ...
}:
{
  # ========================================================================
  # SWAY PROGRAM CONFIGURATION
  # ========================================================================

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    # Essential packages available system-wide
    extraPackages = with pkgs; [
      # Core Wayland utilities
      swaylock
      swayidle
      wl-clipboard

      # Background and notifications
      swaybg
      mako

      # Terminal and launcher
      foot
      wmenu

      # Screenshot tools
      grim
      slurp

      # Additional useful tools
      wf-recorder
      kanshi
    ];
  };

  # ========================================================================
  # REQUIRED SYSTEM SERVICES
  # ========================================================================

  security.polkit.enable = true;
  services.dbus.enable = true;

  # ========================================================================
  # XDG DESKTOP PORTAL CONFIGURATION
  # ========================================================================

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # ========================================================================
  # WAYLAND SESSION DESKTOP ENTRY
  # ========================================================================

  environment.etc."wayland-sessions/sway.desktop".text = ''
    [Desktop Entry]
    Name=Sway
    Comment=An i3-compatible Wayland compositor
    Exec=sway --unsupported-gpu
    Type=Application
    Keywords=tiling;wm;windowmanager;wayland;compositor;
  '';

  # ========================================================================
  # SYSTEM-WIDE SWAY DEFAULTS
  # ========================================================================

  environment.etc."sway/config".text = ''
    # Minimal system fallback configuration
    # User-specific configuration should be managed through Home Manager

    # Set modifier key
    set $mod Mod4

    # Basic terminal binding as fallback
    bindsym $mod+Return exec ${pkgs.foot}/bin/foot

    # Exit binding
    bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'

    # Include user configuration from Home Manager
    include "$HOME/.config/sway/config.d/*"
  '';
}
