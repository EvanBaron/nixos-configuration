{
  config,
  lib,
  pkgs,
  ...
}:

let
  colors = config.colorScheme.palette;
  themeName = config.colorScheme.name;
  themeSlug = config.colorScheme.slug;

  obsidianTheme = import ./lib/obsidian-theme.nix { inherit lib; };

  manifestContent = builtins.toJSON {
    name = themeName;
    version = "1.0.0";
    minAppVersion = "0.16.0";
    author = config.home.username;
  };

  themeCssContent = obsidianTheme.generateThemeCSS colors obsidianTheme.hexToRgb;

  themeCssFile = pkgs.writeText "${themeSlug}-theme.css" themeCssContent;
  manifestFile = pkgs.writeText "${themeSlug}-manifest.json" manifestContent;

  vaultsRoot = "${config.home.homeDirectory}/Vaults";

in
{
  programs.obsidian.enable = true;

  home.activation.installObsidianTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${vaultsRoot}" ]; then
      for vault in "${vaultsRoot}"/*/; do
        if [ -d "$vault" ]; then
          TARGET_DIR="$vault/.obsidian/themes/${themeName}"
          mkdir -p "$TARGET_DIR"

          ln -sf "${themeCssFile}" "$TARGET_DIR/theme.css"
          ln -sf "${manifestFile}" "$TARGET_DIR/manifest.json"
        fi
      done
    else
      echo "Warning: Vaults root not found at ${vaultsRoot}"
    fi
  '';
}
