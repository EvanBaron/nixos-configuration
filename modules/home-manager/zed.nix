{
  config,
  pkgs,
  lib,
  mylib,
  ...
}:

let
  # Install every scheme's theme so switching only has to change `theme` in
  # settings.json, which Zed hot-reloads; a theme file that appears at the
  # same moment is not picked up until restart.
  schemes = map (
    t:
    let
      p = import ../../themes/${t}/palette.nix;
    in
    {
      inherit (p) name;
      palette = lib.mapAttrs (_: lib.removePrefix "#") p.palette;
    }
  ) (import ../../themes);
in
{
  home.file = lib.listToAttrs (
    map (
      colorScheme:
      lib.nameValuePair ".config/zed/themes/${colorScheme.name}.json" {
        source = pkgs.writeText "zed-theme.json" (
          mylib.zed {
            inherit colorScheme;
            username = config.home.username;
          }
        );
        force = true;
      }
    ) schemes
  );

  home.packages = with pkgs; [
    texlab
    zathura
    texliveFull
  ];

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "make"
      "json"
      "markdown"
      "c"
      "cpp"
      "python"
      "latex"
    ];

    userSettings = {
      theme = config.colorScheme.name;
      buffer_font_fallbacks = [ "Symbols Nerd Font Mono" ];

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      terminal = {
        program = "fish";
        env = {
          TERM = "xterm-256color";
        };

        font_family = "Zed Mono";
        font_size = 10;
        line_height = "standard";
      };

      vim_mode = false;
      ui_font_size = 12;
      buffer_font_size = 10;
      buffer_font_family = "FiraCode Nerd Font Mono";

      format_on_save = "on";

      languages = {
        TypeScript = {
          code_actions_on_format = {
            "source.organizeImports" = true;
            "source.fixAll.eslint" = true;
          };
        };
        TSX = {
          code_actions_on_format = {
            "source.organizeImports" = true;
            "source.fixAll.eslint" = true;
          };
        };
        JavaScript = {
          code_actions_on_format = {
            "source.organizeImports" = true;
            "source.fixAll.eslint" = true;
          };
        };
        "JSON" = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        "JSONC" = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        Rust = {
          language_servers = [ "rust-analyzer" ];
        };
        C = {
          language_servers = [ "clangd" ];
          formatter = "language_server";
        };
        "C++" = {
          language_servers = [ "clangd" ];
          formatter = "language_server";
        };
        Go = {
          language_servers = [ "gopls" ];
          formatter = "language_server";
          code_actions_on_format = {
            "source.organizeImports" = true;
          };
        };
        Python = {
          language_servers = [ "basedpyright" ];
          formatter = {
            external = {
              command = "black";
              arguments = [ "-" ];
            };
          };
        };
        LaTeX = {
          language_servers = [ "texlab" ];
          format_on_save = "on";
        };
      };

      lsp = {
        rust-analyzer = {
          binary = {
            path = "rust-analyzer";
          };
        };
        clangd = {
          binary = {
            path = "clangd";
          };
        };
        gopls = {
          binary = {
            path_lookup = true;
          };
          initialization_options = {
            gofumpt = false;
            staticcheck = true;
            hints = {
              assignVariableTypes = true;
              compositeLiteralFields = true;
              constantValues = true;
              functionTypeParameters = true;
              parameterNames = true;
              rangeVariableTypes = true;
            };
          };
        };
        basedpyright = {
          binary = {
            path = "basedpyright-langserver";
          };
        };
        texlab = {
          binary = {
            path_lookup = true;
          };
          settings = {
            texlab = {
              build = {
                onSave = true;
                executable = "latexmk";
                args = [
                  "-pdf"
                  "-interaction=nonstopmode"
                  "-synctex=1"
                  "%f"
                ];
                forwardSearchAfter = false;
              };
              forwardSearch = {
                executable = "zathura";
                args = [
                  "--synctex-forward"
                  "%l:1:%f"
                  "%p"
                ];
              };
            };
          };
        };
      };
    };
  };
}
