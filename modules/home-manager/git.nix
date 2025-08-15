{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    userName = "ebaron";
    userEmail = "evanbaron.a4@gmail.com";

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
