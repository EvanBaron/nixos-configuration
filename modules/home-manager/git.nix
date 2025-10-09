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
      # EPITA
      "ssh.cri.epita.fr" = {
        hostname = "ssh.cri.epita.fr";
        extraOptions = {
          GSSAPIAuthentication = "yes";
          GSSAPIDelegateCredentials = "yes";
          PreferredAuthentications = "gssapi-with-mic";
        };
      };
      "git.forge.epita.fr" = {
        hostname = "git.forge.epita.fr";
        user = "evan.baron";
        identityFile = "~/.ssh/id_ed25519_studies";
        identitiesOnly = true;
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "evan.baron";
        identityFile = "~/.ssh/id_ed25519_studies";
        identitiesOnly = true;
      };
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
