{
  pkgs,
  config,
  inputs,
  ...
}:

let
  inherit
    (inputs.nix-colors.lib-contrib {
      pkgs = pkgs // {
        nodePackages = {
          sass = pkgs.dart-sass;
        };
      };
    })
    gtkThemeFromScheme
    ;
in
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtk = {
    enable = true;

    font = {
      name = "Fira Sans";
      size = 11;
      package = pkgs.fira;
    };

    theme = {
      name = "${config.colorScheme.slug}";
      package = gtkThemeFromScheme { scheme = config.colorScheme; };
    };

    gtk3.theme = config.gtk.theme;
    gtk4.theme = config.gtk.theme;

    iconTheme = {
      name = "Reversal-grey-dark";
      package = pkgs.reversal-icon-theme.overrideAttrs (old: {
        installPhase =
          builtins.replaceStrings [ "./install.sh" ] [ "./install.sh -t grey" ]
            old.installPhase;
      });
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };

    gtk3.extraConfig = {
      "gtk-cursor-theme-name" = "Bibata-Modern-Ice";
      "gtk-application-prefer-dark-theme" = 1;
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-cursor-theme-name=Bibata-Modern-Ice
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = config.gtk.theme.name;
      icon-theme = config.gtk.iconTheme.name;
      cursor-theme = config.gtk.cursorTheme.name;
      font-name = "${config.gtk.font.name} ${toString config.gtk.font.size}";
      color-scheme = "prefer-dark";
    };
  };

  # Qt theming to match GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "gtk2";
  };
}
