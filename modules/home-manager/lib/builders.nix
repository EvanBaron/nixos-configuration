{ pkgs, lib, ... }:

{
  # Bundles a set of files into a directory derivation for Quickshell.
  mkQuickshellConfig =
    {
      name ? "quickshell-config",
      files,
      qmldir,
      main ? "shell.qml",
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
      import "."
      Bar {}
      EOF
    '';
}
