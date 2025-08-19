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
}
