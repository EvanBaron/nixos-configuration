{ pkgs, lib, ... }:

{
  # Bundles a set of files into a directory derivation for Quickshell.
  mkQuickshellConfig =
    {
      name ? "quickshell-config",
      files,
      qmldir,
      main ? "shell.qml",
      # Quickshell pragmas for the root file, e.g. "Env NAME=value" (written as `//@ pragma …`).
      pragmas ? [ ],
    }:
    pkgs.runCommand name { } ''
      mkdir -p $out
      ${builtins.concatStringsSep "\n" (
        lib.mapAttrsToList (name: content: ''
          cat <<'EOF' > $out/${name}
          ${content}
          EOF
        '') files
      )}

      cat <<'EOF' > $out/qmldir
      ${qmldir}
      EOF

      cat <<'EOF' > $out/${main}
      ${builtins.concatStringsSep "\n" (map (p: "//@ pragma ${p}") pragmas)}
      import "."
      Bar {}
      EOF
    '';
}
