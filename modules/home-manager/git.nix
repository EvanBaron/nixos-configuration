{
  config,
  pkgs,
  user,
  ...
}:

{
  home.packages = with pkgs; [
    git
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
      "git.forge.epita.fr" = {
        hostname = "git.forge.epita.fr";
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
