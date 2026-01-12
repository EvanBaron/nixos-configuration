{
  config,
  pkgs,
  user,
  ...
}:

{
  home.packages = with pkgs; [
    git
    krb5
    sshfs-fuse
    openssh_gssapi
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = config.home.username;
    userEmail = user.email;

    extraConfig = {
      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      init.defaultBranch = "main";
      credential.helper = "store";
      pull.rebase = true;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Personal
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };
}
