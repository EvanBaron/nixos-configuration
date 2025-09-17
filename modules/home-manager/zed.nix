# Zed editor configuration with development extensions and theming
{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Generate a Zed theme from the nix-colors scheme
  zedTheme = pkgs.writeText "zed-theme.json" (
    builtins.toJSON {
      name = config.colorScheme.name;
      author = config.home.username;
      themes = [
        {
          name = config.colorScheme.name;
          appearance = "dark";
          style = {
            # UI Colors
            background = "#${config.colorScheme.palette.base00}";
            border = "#${config.colorScheme.palette.base02}";
            elevated_surface.background = "#${config.colorScheme.palette.base00}";
            surface.background = "#${config.colorScheme.palette.base00}";
            element.background = "#${config.colorScheme.palette.base01}";
            element.hover = "#${config.colorScheme.palette.base02}";
            element.active = null;
            element.selected = "#${config.colorScheme.palette.base02}";
            element.disabled = null;
            drop_target.background = "#${config.colorScheme.palette.base02}";
            ghost_element.background = null;
            ghost_element.hover = "#${config.colorScheme.palette.base01}";
            ghost_element.active = null;
            ghost_element.selected = "#${config.colorScheme.palette.base02}";
            ghost_element.disabled = null;
            text = "#${config.colorScheme.palette.base05}";
            status_bar.background = "#${config.colorScheme.palette.base00}";
            title_bar.background = "#${config.colorScheme.palette.base00}";
            toolbar.background = "#${config.colorScheme.palette.base00}";
            tab_bar.background = "#${config.colorScheme.palette.base00}";
            tab.inactive_background = "#${config.colorScheme.palette.base01}";
            tab.active_background = "#${config.colorScheme.palette.base00}";
            search.match_background = "#${config.colorScheme.palette.base02}";
            panel.background = "#${config.colorScheme.palette.base00}";
            panel.focused_border = "#${config.colorScheme.palette.base02}";
            pane.focused_border = null;
            scrollbar.thumb.background = "#${config.colorScheme.palette.base02}";
            scrollbar.thumb.hover_background = "#${config.colorScheme.palette.base03}";
            scrollbar.thumb.border = "#${config.colorScheme.palette.base02}6f";
            scrollbar.track.background = "#${config.colorScheme.palette.base00}";
            scrollbar.track.border = null;
            editor.foreground = "#${config.colorScheme.palette.base05}";
            editor.background = "#${config.colorScheme.palette.base00}";
            editor.gutter.background = "#${config.colorScheme.palette.base00}";
            editor.subheader.background = "#${config.colorScheme.palette.base00}";
            editor.active_line.background = "#${config.colorScheme.palette.base01}";
            editor.highlighted_line.background = null;
            editor.line_number = "#${config.colorScheme.palette.base03}";
            editor.active_line_number = "#${config.colorScheme.palette.base06}";
            editor.invisible = null;
            editor.wrap_guide = "#${config.colorScheme.palette.base01}";
            editor.active_wrap_guide = "#${config.colorScheme.palette.base03}";
            editor.document_highlight.read_background = "#${config.colorScheme.palette.base01}";
            editor.document_highlight.write_background = "#${config.colorScheme.palette.base01}";
            terminal.background = "#${config.colorScheme.palette.base00}";
            terminal.foreground = null;
            terminal.bright_foreground = null;
            terminal.dim_foreground = null;
            terminal.ansi.black = "#${config.colorScheme.palette.base00}";
            terminal.ansi.bright_black = "#${config.colorScheme.palette.base03}";
            terminal.ansi.dim_black = null;
            terminal.ansi.red = "#${config.colorScheme.palette.base08}";
            terminal.ansi.bright_red = "#${config.colorScheme.palette.base08}";
            terminal.ansi.dim_red = null;
            terminal.ansi.green = "#${config.colorScheme.palette.base0B}";
            terminal.ansi.bright_green = "#${config.colorScheme.palette.base0B}";
            terminal.ansi.dim_green = null;
            terminal.ansi.yellow = "#${config.colorScheme.palette.base0A}";
            terminal.ansi.bright_yellow = "#${config.colorScheme.palette.base0A}";
            terminal.ansi.dim_yellow = null;
            terminal.ansi.blue = "#${config.colorScheme.palette.base0D}";
            terminal.ansi.bright_blue = "#${config.colorScheme.palette.base0D}";
            terminal.ansi.dim_blue = null;
            terminal.ansi.magenta = "#${config.colorScheme.palette.base0E}";
            terminal.ansi.bright_magenta = "#${config.colorScheme.palette.base0E}";
            terminal.ansi.dim_magenta = null;
            terminal.ansi.cyan = "#${config.colorScheme.palette.base0C}";
            terminal.ansi.bright_cyan = "#${config.colorScheme.palette.base0C}";
            terminal.ansi.dim_cyan = null;
            terminal.ansi.white = "#${config.colorScheme.palette.base05}";
            terminal.ansi.bright_white = "#${config.colorScheme.palette.base07}";
            terminal.ansi.dim_white = null;
            link_text.hover = "#${config.colorScheme.palette.base0C}";
            conflict = "#${config.colorScheme.palette.base0A}";
            created = "#${config.colorScheme.palette.base0B}";
            deleted = "#${config.colorScheme.palette.base08}";
            error = "#${config.colorScheme.palette.base08}";
            hidden = "#${config.colorScheme.palette.base03}";
            hint = "#${config.colorScheme.palette.base05}";
            ignored = "#${config.colorScheme.palette.base03}";
            info = "#${config.colorScheme.palette.base0C}";
            modified = "#${config.colorScheme.palette.base0D}";
            predictive = "#${config.colorScheme.palette.base03}";
            renamed = "#${config.colorScheme.palette.base0A}";
            success = "#${config.colorScheme.palette.base0B}";
            unreachable = "#${config.colorScheme.palette.base0A}";
            warning = "#${config.colorScheme.palette.base0A}";
            players = [
              {
                cursor = "#${config.colorScheme.palette.base05}";
                selection = "#${config.colorScheme.palette.base02}";
                background = null;
              }
            ];

            # Syntax Highlighting
            syntax = {
              attribute = {
                color = "#${config.colorScheme.palette.base0D}";
                font_style = null;
                font_weight = null;
              };
              boolean = {
                color = "#${config.colorScheme.palette.base0A}";
                font_style = null;
                font_weight = null;
              };
              comment = {
                color = "#${config.colorScheme.palette.base03}";
                font_style = "italic";
                font_weight = null;
              };
              "comment.doc" = {
                color = "#${config.colorScheme.palette.base03}";
                font_style = "italic";
                font_weight = null;
              };
              constant = {
                color = "#${config.colorScheme.palette.base0A}";
                font_style = null;
                font_weight = null;
              };
              constructor = {
                color = "#${config.colorScheme.palette.base08}";
                font_style = null;
                font_weight = null;
              };
              emphasis = {
                color = "#${config.colorScheme.palette.base08}";
                font_style = "italic";
                font_weight = null;
              };
              "emphasis.strong" = {
                color = "#${config.colorScheme.palette.base08}";
                font_style = null;
                font_weight = 700;
              };
              function = {
                color = "#${config.colorScheme.palette.base0D}";
                font_style = null;
                font_weight = null;
              };
              keyword = {
                color = "#${config.colorScheme.palette.base0E}";
                font_style = null;
                font_weight = null;
              };
              label = {
                color = "#${config.colorScheme.palette.base0A}";
                font_style = null;
                font_weight = null;
              };
              "link_text" = {
                color = "#${config.colorScheme.palette.base08}";
                font_style = null;
                font_weight = null;
              };
              "link_uri" = {
                color = "#${config.colorScheme.palette.base08}";
                font_style = null;
                font_weight = null;
              };
              number = {
                color = "#${config.colorScheme.palette.base09}";
                font_style = null;
                font_weight = null;
              };
              operator = {
                color = "#${config.colorScheme.palette.base03}";
                font_style = null;
                font_weight = null;
              };
              punctuation = {
                color = "#${config.colorScheme.palette.base03}";
                font_style = null;
                font_weight = null;
              };
              "punctuation.bracket" = {
                color = "#${config.colorScheme.palette.base03}";
                font_style = null;
                font_weight = null;
              };
              "punctuation.delimiter" = {
                color = null;
                font_style = null;
                font_weight = null;
              };
              "punctuation.list_marker" = {
                color = "#${config.colorScheme.palette.base03}";
                font_style = null;
                font_weight = null;
              };
              "punctuation.special" = {
                color = "#${config.colorScheme.palette.base08}";
                font_style = null;
                font_weight = null;
              };
              string = {
                color = "#${config.colorScheme.palette.base0B}";
                font_style = null;
                font_weight = null;
              };
              "string.escape" = {
                color = "#${config.colorScheme.palette.base09}";
                font_style = null;
                font_weight = null;
              };
              "string.regex" = {
                color = "#${config.colorScheme.palette.base0B}";
                font_style = null;
                font_weight = null;
              };
              "string.special" = {
                color = "#${config.colorScheme.palette.base0B}";
                font_style = null;
                font_weight = null;
              };
              "string.special.symbol" = {
                color = "#${config.colorScheme.palette.base0B}";
                font_style = null;
                font_weight = null;
              };
              tag = {
                color = "#${config.colorScheme.palette.base08}";
                font_style = null;
                font_weight = null;
              };
              "text.literal" = {
                color = "#${config.colorScheme.palette.base0B}";
                font_style = null;
                font_weight = null;
              };
              title = {
                color = "#${config.colorScheme.palette.base0A}";
                font_style = null;
                font_weight = null;
              };
              type = {
                color = "#${config.colorScheme.palette.base0A}";
                font_style = null;
                font_weight = null;
              };
              variable = {
                color = null;
                font_style = null;
                font_weight = null;
              };
              "variable.special" = {
                color = "#${config.colorScheme.palette.base08}";
                font_style = "italic";
                font_weight = null;
              };
            };
          };
        }
      ];
    }
  );
in

{
  # Place the generated theme file in the correct location
  home.file.".config/zed/themes/${config.colorScheme.name}.json" = {
    source = zedTheme;
    executable = false;
  };

  programs.zed-editor = {
    enable = true;

    # Install useful extensions for development
    extensions = [
      "nix"
      "rust-analyzer"
      "toml"
      "make"
      "json"
      "markdown"
      "c"
      "cpp"
    ];

    userSettings = {
      # Set the theme to the generated theme
      theme = config.colorScheme.name;

      # Configure Node.js paths for JavaScript development
      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      # Terminal settings within Zed
      terminal = {
        env = {
          TERM = "foot";
        };

        font_family = "Fira Mono";
      };

      # Editor appearance settings
      vim_mode = false;
      ui_font_size = 12;
      buffer_font_size = 10;
      buffer_font_family = "FiraCode Nerd Font Mono";

      language_overrides = {
        Rust = {
          language_server = {
            external = true;
            command = "rust-analyzer";
          };
        };
        C = {
          language_server = {
            external = true;
            command = "clangd";
          };
        };
        "C++" = {
          language_server = {
            external = true;
            command = "clangd";
          };
        };
      };
    };
  };

}
