# ============================================================================
# TUIGREET DISPLAY MANAGER MODULE
# ============================================================================

{
  pkgs,
  ...
}:

{
  # ========================================================================
  # REQUIRED PACKAGES
  # ========================================================================

  environment.systemPackages = with pkgs; [
    tuigreet
  ];

  # ========================================================================
  # GREETD SERVICE CONFIGURATION
  # ========================================================================

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd 'sway --unsupported-gpu'";
        user = "greeter";
      };
    };
  };

  # ========================================================================
  # SESSION ENVIRONMENTS
  # ========================================================================

  environment.etc."greetd/environments".text = ''
    sway
    bash
  '';

  # ========================================================================
  # GREETER USER CONFIGURATION
  # ========================================================================

  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
    home = "/var/lib/greeter";
    createHome = true;
    shell = pkgs.bash;
    extraGroups = [ "video" ];
  };

  users.groups.greeter = { };

  # ========================================================================
  # SYSTEMD SERVICE CONFIGURATION
  # ========================================================================

  systemd.services.greetd = {
    serviceConfig = {
      # Proper environment for Wayland
      Environment = [
        "XDG_SESSION_TYPE=wayland"
        "XDG_SESSION_DESKTOP=sway"
        "XDG_CURRENT_DESKTOP=sway"
        "WLR_NO_HARDWARE_CURSORS=1"
      ];
    };

    # Proper startup order
    after = [
      "systemd-user-sessions.service"
      "plymouth-quit-wait.service"
    ];

    # Ensure required services are available
    wants = [
      "dbus.service"
    ];
  };

  # ========================================================================
  # TTY CONFIGURATION
  # ========================================================================

  # Disable getty on tty1 since greetd will use it
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
