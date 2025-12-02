{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.user.username = lib.mkOption {
    type = lib.types.str;
    default = "ebaron";
  };

  options.user.email = lib.mkOption {
    type = lib.types.str;
    default = "evanbaron.a4@gmail.com";
  };

  config = {
    users.groups.video.members = [ config.user.username ];
    users.users.${config.user.username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "fuse"

        "docker"

        # Android
        "kvm"
        "adbusers"
      ];

      packages = with pkgs; [
        tree
      ];
    };
  };
}
