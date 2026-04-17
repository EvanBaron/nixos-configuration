{ config, ... }:
let
  palette = config.colorScheme.palette;
in
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      # Fish colors
      set -g fish_color_normal ${palette.base05}
      set -g fish_color_command ${palette.base06} --bold
      set -g fish_color_quote ${palette.base0B}
      set -g fish_color_redirection ${palette.base0C}
      set -g fish_color_end ${palette.base0E}
      set -g fish_color_error ${palette.base08}
      set -g fish_color_param ${palette.base06}
      set -g fish_color_comment ${palette.base03}
      set -g fish_color_match ${palette.base0D}
      set -g fish_color_selection --background=${palette.base02}
      set -g fish_color_search_match --background=${palette.base02}
      set -g fish_color_history_current ${palette.base0D}
      set -g fish_color_operator ${palette.base0C}
      set -g fish_color_escape ${palette.base0C}
      set -g fish_color_autosuggestion ${palette.base03}
      set -g fish_color_cwd ${palette.base0D}
      set -g fish_color_user ${palette.base0D}
      set -g fish_color_host ${palette.base0D}
      set -g fish_color_host_remote ${palette.base0B}
      set -g fish_color_cancel ${palette.base08}

      # Pager colors
      set -g fish_pager_color_prefix ${palette.base06}
      set -g fish_pager_color_completion ${palette.base05}
      set -g fish_pager_color_description ${palette.base03}
      set -g fish_pager_color_progress ${palette.base0C}
      set -g fish_pager_color_secondary ${palette.base01}

      starship init fish | source
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      add_newline = true;
      # Custom prompt format: directory, git info, dev tools on right, character on new line
      format = "$directory$git_branch$git_status$fill$nix_shell$nodejs$bun$golang$rust$package\n$character";

      # Prompt character styling
      character = {
        success_symbol = "[❯](bold fg:#${palette.base06})";
        error_symbol = "[❯](bold fg:#${palette.base08})";
      };

      # Current directory styling
      directory = {
        style = "bold fg:#${palette.base06}";
        home_symbol = "~";
        read_only = " ";
        format = "[$path$read_only]($style) ";
      };

      # Git branch indicator
      git_branch = {
        symbol = "";
        style = "bold fg:#${palette.base05}";
        format = "[$symbol $branch]($style) ";
      };

      # Git status indicators with symbols
      git_status = {
        style = "bold fg:#${palette.base08}";
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
        style = "bold fg:#${palette.base0D}";
        format = "[$symbol]($style) ";
      };
      # Development environment indicators
      nodejs = {
        symbol = "";
        style = "bold fg:#${palette.base0B}";
        format = "[$symbol($version)]($style) ";
      };
      bun = {
        symbol = "🥟";
        style = "bold fg:#${palette.base0A}";
        format = "[$symbol($version)]($style) ";
      };
      golang = {
        symbol = "";
        style = "bold fg:#${palette.base0C}";
        format = "[$symbol($version)]($style) ";
      };
      rust = {
        symbol = "";
        style = "bold fg:#${palette.base09}";
        format = "[$symbol($version)]($style) ";
      };
      package = {
        symbol = "📦";
        style = "bold fg:#${palette.base05}";
        format = "[$symbol($version)]($style) ";
      };
    };
  };
}
