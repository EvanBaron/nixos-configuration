# ============================================================================
# SWAY WINDOW MANAGER CONFIGURATION
# ============================================================================
#
{
  pkgs,
  lib,
  config,
  ...
}:
{
  # ========================================================================
  # SWAY PROGRAM CONFIGURATION
  # ========================================================================

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      swaybg
      mako
      foot
      wmenu
      wofi
    ];
  };

  # ========================================================================
  # REQUIRED SYSTEM SERVICES
  # ========================================================================

  security.polkit.enable = true;
  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # ========================================================================
  # SWAY CONFIGURATION
  # ========================================================================

  environment.etc."sway/config".text = ''
    # ======================================================================
    # BASIC CONFIGURATION
    # ======================================================================

    # Set modifier key to Super/Windows key
    set $mod Mod4

    # Font for window titles and UI elements
    font pango:Fira Code Nerd Font 10

    # ======================================================================
    # WINDOW APPEARANCE AND LAYOUT
    # ======================================================================

    # Window border configuration
    default_border pixel 2          # 2px borders for tiled windows
    default_floating_border pixel 2 # 2px borders for floating windows
    hide_edge_borders smart         # Hide borders when only one window

    # Gap configuration for modern tiling appearance
    gaps inner 8  # 8px gaps between windows
    gaps outer 4  # 4px gaps around screen edges

    # Window colors will be configured per-host to match wallpaper themes
    # This allows each machine to have its own color scheme

    # ======================================================================
    # INPUT CONFIGURATION
    # ======================================================================

    # Use Mouse + Super key to drag floating windows
    floating_modifier $mod

    # ======================================================================
    # CORE KEYBINDINGS
    # ======================================================================

    # Application launching
    bindsym $mod+Return exec foot     # Launch terminal
    # Application launcher configured per-host with theming

    # Window management
    bindsym $mod+Shift+q kill         # Close focused window
    bindsym $mod+f fullscreen         # Toggle fullscreen

    # System controls
    bindsym $mod+Shift+c reload       # Reload Sway configuration
    bindsym $mod+Shift+e exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'swaymsg exit'

    # ======================================================================
    # FOCUS AND MOVEMENT KEYBINDINGS
    # ======================================================================

    # Focus movement (arrow keys)
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # Window movement (Shift + arrow keys)
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    # ======================================================================
    # WORKSPACE MANAGEMENT
    # ======================================================================

    # Switch to workspace (number keys)
    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3
    bindsym $mod+4 workspace number 4
    bindsym $mod+5 workspace number 5
    bindsym $mod+6 workspace number 6
    bindsym $mod+7 workspace number 7
    bindsym $mod+8 workspace number 8
    bindsym $mod+9 workspace number 9
    bindsym $mod+0 workspace number 10

    # Move window to workspace (Shift + number keys)
    bindsym $mod+Shift+1 move container to workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9
    bindsym $mod+Shift+0 move container to workspace number 10

    # ======================================================================
    # LAYOUT MANAGEMENT
    # ======================================================================

    # Container splitting
    bindsym $mod+b splith            # Split horizontally
    bindsym $mod+v splitv            # Split vertically

    # Layout modes
    bindsym $mod+s layout stacking   # Stacking layout
    bindsym $mod+w layout tabbed     # Tabbed layout
    bindsym $mod+e layout toggle split # Toggle between split layouts

    # Floating mode
    bindsym $mod+Shift+space floating toggle # Toggle floating mode
    bindsym $mod+space focus mode_toggle      # Toggle focus between floating/tiled

    # ======================================================================
    # SCRATCHPAD (HIDDEN WORKSPACE)
    # ======================================================================

    # Move window to scratchpad (hidden)
    bindsym $mod+Shift+minus move scratchpad
    # Show scratchpad window
    bindsym $mod+minus scratchpad show

    # ======================================================================
    # WINDOW RULES AND BEHAVIOR
    # ======================================================================

    # Ensure all windows have consistent borders
    for_window [class=".*"] border pixel 2    # X11 applications
    for_window [app_id="^.*"] border pixel 2  # Wayland applications

    # Floating window rules for common applications
    for_window [app_id="pavucontrol"] floating enable      # Volume control
    for_window [app_id="blueman-manager"] floating enable  # Bluetooth manager
    for_window [app_id="nm-connection-editor"] floating enable # Network manager

    # ======================================================================
    # HOST-SPECIFIC CONFIGURATION INCLUSION
    # ======================================================================

    # Include all host-specific configuration files
    # This allows each host to define:
    # - Custom wallpapers
    # - Themed colors and styling
    # - Host-specific status bars
    # - Custom application launcher theming
    include /etc/sway/config.d/*
  '';
}
