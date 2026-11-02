{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

let
  colors = config.colorScheme.palette;

  # One theme whose contents follow the active colour scheme: Obsidian reloads
  # the enabled theme's CSS when it changes on disk, so `theme-switch`
  # recolours open vaults without a restart.
  themeName = "NixOS Desktop";

  manifestContent = builtins.toJSON {
    name = themeName;
    version = "1.0.0";
    minAppVersion = "0.16.0";
    author = config.home.username;
  };

  themeCssContent = mylib.obsidian.generateThemeCSS colors;

  themeCssFile = pkgs.writeText "${config.colorScheme.slug}-theme.css" themeCssContent;
  manifestFile = pkgs.writeText "obsidian-theme-manifest.json" manifestContent;

  # Per-scheme themes installed by earlier generations of this module
  legacyThemes = map (t: (import ../../themes/${t}/palette.nix).name) (import ../../themes);

  vaultsRoot = "${config.home.homeDirectory}/Vaults";

  jq = lib.getExe pkgs.jq;
in
{
  programs.obsidian.enable = true;

  home.activation.installObsidianTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Replace FILE with SRC's contents in place (not a symlink swap), and only
    # when they differ, so Obsidian's watcher reloads the theme exactly once
    obsidianInstall() {
      if [ -L "$2" ]; then rm -f "$2"; fi
      if ! cmp -s "$1" "$2"; then
        cat "$1" > "$2"
      fi
    }

    if [ -n "''${DRY_RUN:-}" ]; then
      :
    elif [ -d "${vaultsRoot}" ]; then
      for vault in "${vaultsRoot}"/*/; do
        [ -d "$vault.obsidian" ] || continue

        TARGET_DIR="$vault.obsidian/themes/${themeName}"
        mkdir -p "$TARGET_DIR"
        obsidianInstall "${themeCssFile}" "$TARGET_DIR/theme.css"
        obsidianInstall "${manifestFile}" "$TARGET_DIR/manifest.json"

        for legacy in ${lib.escapeShellArgs legacyThemes}; do
          if [ -L "$vault.obsidian/themes/$legacy/theme.css" ]; then
            rm -rf "$vault.obsidian/themes/$legacy"
          fi
        done

        appearance="$vault.obsidian/appearance.json"
        [ -s "$appearance" ] || echo '{}' > "$appearance"
        updated=$(${jq} \
          --arg theme "${themeName}" \
          --arg accent "#${lib.toLower colors.base06}" \
          '.cssTheme = $theme | .accentColor = $accent' "$appearance")
        if [ "$updated" != "$(cat "$appearance")" ]; then
          printf '%s\n' "$updated" > "$appearance"
        fi
      done
    else
      echo "Warning: Vaults root not found at ${vaultsRoot}"
    fi
  '';
}
