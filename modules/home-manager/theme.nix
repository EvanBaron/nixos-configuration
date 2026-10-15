{
  pkgs,
  lib,
  ...
}:

let
  themes = import ../../themes;

  themeSwitch = pkgs.writeShellApplication {
    name = "theme-switch";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      base=/etc/home-manager-generation
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/theme"
      themes=(${lib.concatStringsSep " " themes})

      current() {
        local active
        active=$(readlink -f "$HOME/.local/state/home-manager/gcroots/current-home" 2>/dev/null || true)
        for t in "''${themes[@]}"; do
          if [ "$(readlink -f "$base/specialisation/$t")" = "$active" ]; then
            echo "$t"
            return
          fi
        done
      }

      activate() {
        local spec="$base/specialisation/$1"
        if [ ! -x "$spec/activate" ]; then
          echo "theme-switch: no specialisation for '$1' (try --list)" >&2
          exit 1
        fi
        "$spec/activate"
      }

      case "''${1:-}" in
        --list | -l | "")
          cur=$(current)
          for t in "''${themes[@]}"; do
            if [ "$t" = "$cur" ]; then echo "* $t"; else echo "  $t"; fi
          done
          ;;
        --restore)
          [ -s "$state" ] || exit 0
          t=$(cat "$state")
          [ -x "$base/specialisation/$t/activate" ] || exit 0
          activate "$t"
          ;;
        -*)
          echo "usage: theme-switch [--list | --restore | <theme>]" >&2
          exit 1
          ;;
        *)
          activate "$1"
          mkdir -p "$(dirname "$state")"
          echo "$1" > "$state"
          ;;
      esac
    '';
  };
in
{
  options.theme.switchPackage = lib.mkOption {
    type = lib.types.package;
    internal = true;
    readOnly = true;
    default = themeSwitch;
  };

  config = {
    specialisation = lib.genAttrs themes (
      name:
      let
        t = import ../../themes/${name}/palette.nix;
      in
      {
        configuration = {
          colorScheme = lib.mkForce { inherit (t) name slug palette; };
          theme.wallpaper = lib.mkForce t.wallpapers.desktop;
          theme.ui = lib.mkForce t.ui;
        };
      }
    );

    systemd.user.startServices = "sd-switch";

    home.packages = [ themeSwitch ];

    xdg.configFile."fish/completions/theme-switch.fish".text = ''
      complete -c theme-switch -f
      complete -c theme-switch -a "${lib.concatStringsSep " " themes}"
      complete -c theme-switch -l list -s l -d "List themes"
      complete -c theme-switch -l restore -d "Re-apply the saved theme"
    '';

    home.activation.reloadTheme = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
      if [ -z "''${DRY_RUN:-}" ]; then
        ${pkgs.procps}/bin/pkill -USR1 -x kitty || true
      fi
    '';
  };
}
