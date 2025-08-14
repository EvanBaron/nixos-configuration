# Bash shell configuration with Starship prompt
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
      # Custom prompt format: directory, git info, dev tools on right, character on new line
      format = "$directory$git_branch$git_status$fill$nix_shell$nodejs$bun$golang$rust$package\n$character";

      # Prompt character styling
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      # Current directory styling
      directory = {
        style = "bold fg:cyan";
        home_symbol = "~";
        read_only = " ";
        format = "[$path$read_only]($style) ";
      };

      # Git branch indicator
      git_branch = {
        symbol = "";
        style = "bold fg:magenta";
        format = "[$symbol $branch]($style) ";
      };

      # Git status indicators with symbols
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

      # Nix shell indicator
      nix_shell = {
        symbol = "";
        style = "bold fg:blue";
        format = "[$symbol]($style) ";
      };
      # Development environment indicators
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
