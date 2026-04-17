{ hexToRgb }:

{
  generateThemeCSS = colors: wallpaper: ''
    @import url('https://mwittrien.github.io/BetterDiscordAddons/Themes/DiscordRecolor/DiscordRecolor.css');

    :root {
      --accentcolor: ${hexToRgb colors.base06};
      --accentcolor2: ${hexToRgb colors.base0E};
      --linkcolor: ${hexToRgb colors.base06};
      --mentioncolor: ${hexToRgb colors.base0A};
      --textbrightest: ${hexToRgb colors.base07};
      --textbrighter: ${hexToRgb colors.base05};
      --textbright: ${hexToRgb colors.base05};
      --textdark: ${hexToRgb colors.base04};
      --textdarker: ${hexToRgb colors.base03};
      --textdarkest: ${hexToRgb colors.base02};
      --font: gg sans;
      --backgroundaccent: ${hexToRgb colors.base00};
      --backgroundprimary: ${hexToRgb colors.base00};
      --backgroundsecondary: ${hexToRgb colors.base00};
      --backgroundsecondaryalt: ${hexToRgb colors.base01};
      --backgroundtertiary: ${hexToRgb colors.base00};
      --backgroundfloating: ${hexToRgb colors.base01};
      --settingsicons: 1;
    }
  '';
}
