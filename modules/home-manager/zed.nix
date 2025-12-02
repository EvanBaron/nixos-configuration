{
  config,
  pkgs,
  lib,
  ...
}:

let
  stdenv = pkgs.stdenv;
  # Generate the theme content using the library function
  zedThemeContent = import ./lib/zed-theme.nix {
    inherit (config) colorScheme;
    username = config.home.username;
  };

  zedTheme = pkgs.writeText "zed-theme.json" zedThemeContent;

  clang_args = builtins.concatStringsSep " " [
    (builtins.readFile "${stdenv.cc}/nix-support/libc-crt1-cflags")
    (builtins.readFile "${stdenv.cc}/nix-support/libc-cflags")
    (builtins.readFile "${stdenv.cc}/nix-support/cc-cflags")
    (builtins.readFile "${stdenv.cc}/nix-support/libcxx-cxxflags")
    (lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc.lib}/lib/clang/${lib.getVersion stdenv.cc.cc}/include")
    (lib.optionalString stdenv.cc.isGNU "-isystem ${lib.getDev stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include")
  ];
in
{
  # Place the generated theme file in the correct location
  home.file.".config/zed/themes/${config.colorScheme.name}.json" = {
    source = zedTheme;
    executable = false;
  };

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "rust-analyzer"
      "toml"
      "make"
      "json"
      "markdown"
      "c"
      "cpp"
      "python"
    ];

    userSettings = {
      theme = config.colorScheme.name;

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      terminal = {
        env = {
          TERM = "foot";
        };

        font_family = "Fira Mono";
      };

      vim_mode = false;
      ui_font_size = 12;
      buffer_font_size = 10;
      buffer_font_family = "FiraCode Nerd Font Mono";

      languages = {
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
            arguments = [ clang_args ];
          };
        };
        "C++" = {
          language_server = {
            external = true;
            command = "clangd";
            arguments = [ clang_args ];
          };
        };
        Python = {
          language_server = {
            external = true;
            command = "basedpyright-langserver";
          };
          formatter = {
            external = {
              command = "black";
              arguments = [ "-" ];
            };
          };
        };
      };
    };
  };
}
