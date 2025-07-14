# Before using this module, you need to configure rclone.
# Run `rclone config` in your terminal and follow the prompts to set up a new remote.
# For Google Drive, choose 'drive' as the storage type and follow the authentication steps.
# Make sure to name your remote 'gdrive' as it's referenced in the ExecStart command below.

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rclone
  ];

  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "rclone Google drive mount";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/ebaron/Sync";
      ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive:Sync /home/ebaron/Sync --dir-cache-time 48h --vfs-cache-max-age 48h --vfs-cache-mode full --vfs-cache-max-size 10G --vfs-read-chunk-size 16M --vfs-read-chunk-size-limit 1G --buffer-size 512M";
      ExecStop = "${pkgs.util-linux}/bin/umount /home/ebaron/Sync";
      Restart = "on-failure";
      RestartSec = "10s";
      Environment = [ "PATH=${pkgs.fuse}/bin:/run/wrappers/bin/:$PATH" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
