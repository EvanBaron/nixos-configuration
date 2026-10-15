{ palette, ui }:
let
  # Palette values may or may not carry a leading "#"; QML wants exactly one.
  hex = c: if builtins.substring 0 1 c == "#" then c else "#${c}";
in
''
  pragma Singleton
  import QtQuick

  QtObject {
      readonly property color base00: "${hex palette.base00}"
      readonly property color base01: "${hex palette.base01}"
      readonly property color base02: "${hex palette.base02}"
      readonly property color base03: "${hex palette.base03}"
      readonly property color base04: "${hex palette.base04}"
      readonly property color base05: "${hex palette.base05}"
      readonly property color base06: "${hex palette.base06}"
      readonly property color base07: "${hex palette.base07}"
      readonly property color base08: "${hex palette.base08}"
      readonly property color base09: "${hex palette.base09}"
      readonly property color base0A: "${hex palette.base0A}"
      readonly property color base0B: "${hex palette.base0B}"
      readonly property color base0C: "${hex palette.base0C}"
      readonly property color base0D: "${hex palette.base0D}"
      readonly property color base0E: "${hex palette.base0E}"
      readonly property color base0F: "${hex palette.base0F}"

      // Semantic roles, named as in the design system's tokens.
      readonly property color bg: base00            // ground of every surface
      readonly property color bgAlt: base01         // cards, inactive controls, hover on bg
      readonly property color highlight: base02     // selected, pressed, icon tiles, hover on bgAlt
      readonly property color fg: base05            // primary text
      readonly property color fgAlt: "${hex ui.fgAlt}"      // secondary text, 4.5:1 on bg/bgAlt/highlight
      readonly property color fgMuted: "${hex ui.fgMuted}"  // placeholders, counts, timestamps; not on highlight
      readonly property color accent: "${hex ui.accent}"    // the one UI hue, ink or fill
      readonly property color onAccent: base00      // text and icons on an accent fill
      readonly property color border: base02        // decorative 1px hairline
      readonly property color borderStrong: "${hex ui.borderStrong}" // control outlines, 3:1
      readonly property color focusRing: accent
      readonly property color statusOk: base0B
      readonly property color statusWarning: base0A
      readonly property color statusCritical: "${hex ui.critical}"
      readonly property color netUpload: base09
      readonly property color chartCpu: base0D
      readonly property color chartTemp: base0A
      readonly property color chartMemory: base0E
  }
''
