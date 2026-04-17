{ palette }:
''
  pragma Singleton
  import QtQuick

  QtObject {
      readonly property color base00: "#${palette.base00}"
      readonly property color base01: "#${palette.base01}"
      readonly property color base02: "#${palette.base02}"
      readonly property color base03: "#${palette.base03}"
      readonly property color base04: "#${palette.base04}"
      readonly property color base05: "#${palette.base05}"
      readonly property color base06: "#${palette.base06}"
      readonly property color base07: "#${palette.base07}"
      readonly property color base08: "#${palette.base08}"
      readonly property color base09: "#${palette.base09}"
      readonly property color base0A: "#${palette.base0A}"
      readonly property color base0B: "#${palette.base0B}"
      readonly property color base0C: "#${palette.base0C}"
      readonly property color base0D: "#${palette.base0D}"
      readonly property color base0E: "#${palette.base0E}"
      readonly property color base0F: "#${palette.base0F}"

      // Semantic aliases for easier mapping
      readonly property color bg: base00
      readonly property color bgAlt: base01
      readonly property color fg: base05
      readonly property color fgAlt: base04
      readonly property color accent: base06
      readonly property color highlight: base02
      readonly property color border: base03
  }
''
