# Google Drive sync via rclone configuration
# Setup: Run `rclone config` and create a 'gdrive' remote for Google Drive

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rclone
  ];

  # Auto-mount Google Drive at login
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "rclone Google drive mount";
      After = [ "network-online.target" ]; # Wait for internet connection
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/Sync"; # Create mount directory
      # Mount with aggressive caching for performance
      ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive:Sync ${config.home.homeDirectory}/Sync --dir-cache-time 48h --vfs-cache-max-age 48h --vfs-cache-mode full --vfs-cache-max-size 10G --vfs-read-chunk-size 16M --vfs-read-chunk-size-limit 1G --buffer-size 512M";
      ExecStop = "${pkgs.util-linux}/bin/umount ${config.home.homeDirectory}/Sync";
      Restart = "on-failure";
      RestartSec = "10s";
      Environment = [ "PATH=${pkgs.fuse}/bin:/run/wrappers/bin/:$PATH" ]; # Include FUSE in PATH
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
