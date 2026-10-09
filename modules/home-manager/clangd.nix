# Global clangd config so C projects work without a per-project shell.nix
{ pkgs, ... }:

let
  # Libraries whose headers clangd should always find (resolved via pkg-config)
  libs = with pkgs; [
    gtk3
    criterion
  ];
  pkgConfigNames = [
    "gtk+-3.0"
    "criterion"
  ];

  clangdConfig =
    pkgs.runCommand "clangd-config.yaml"
      {
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = libs;
      }
      ''
        flags=$(pkg-config --cflags ${toString pkgConfigNames})
        {
          echo "CompileFlags:"
          echo "  Add:"
          for f in $flags; do echo "    - \"$f\""; done
          echo "Diagnostics:"
          echo "  UnusedIncludes: Strict"
        } > $out
      '';
in
{
  xdg.configFile."clangd/config.yaml".source = clangdConfig;
}
