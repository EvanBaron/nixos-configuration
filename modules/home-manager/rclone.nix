# Before using this module, you need to configure rclone.
# Run `rclone config` in your terminal and follow the prompts to set up a new remote.
# For Google Drive, choose 'drive' as the storage type and follow the authentication steps.
# Make sure to name your remote 'gdrive' as it's referenced in the ExecStart command below.

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rclone
  ];

  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "rclone Google drive mount";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: %h/GoogleDrive --vfs-cache-mode writes";
      ExecStop = "${pkgs.util-linux}/bin/umount %h/GoogleDrive";
      Restart = "always";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
