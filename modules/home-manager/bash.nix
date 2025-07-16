{
  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(starship init bash)"
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$fill$nix_shell$nodejs$bun$golang$rust$package\n$character";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        style = "bold fg:cyan";
        home_symbol = "~";
        read_only = " ";
        format = "[$path$read_only]($style) ";
      };

      git_branch = {
        symbol = "";
        style = "bold fg:magenta";
        format = "[$symbol $branch]($style) ";
      };

      git_status = {
        style = "bold fg:red";
        format = "[$all_status$ahead_behind]($style) ";
        conflicted = "!";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "$";
        modified = "*";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      fill = {
        symbol = " ";
      };

      nix_shell = {
        symbol = "";
        style = "bold fg:blue";
        format = "[$symbol]($style) ";
      };
      nodejs = {
        symbol = "";
        style = "bold fg:green";
        format = "[$symbol($version)]($style) ";
      };
      bun = {
        symbol = "🥟";
        style = "bold fg:yellow";
        format = "[$symbol($version)]($style) ";
      };
      golang = {
        symbol = "";
        style = "bold fg:cyan";
        format = "[$symbol($version)]($style) ";
      };
      rust = {
        symbol = "";
        style = "bold fg:red";
        format = "[$symbol($version)]($style) ";
      };
      package = {
        symbol = "📦";
        style = "bold fg:white";
        format = "[$symbol($version)]($style) ";
      };
    };
  };
}