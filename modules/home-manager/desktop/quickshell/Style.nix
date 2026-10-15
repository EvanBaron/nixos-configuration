{ ... }:
''
  pragma Singleton
  import QtQuick

  // Non-colour tokens from the "NixOS Desktop" design system, plus the motion scale.
  QtObject {
      readonly property string fontFamily: "Fira Sans"

      // Spacing
      readonly property int space2:  2
      readonly property int space4:  4
      readonly property int space6:  6
      readonly property int space8:  8
      readonly property int space12: 12
      readonly property int space16: 16

      // Radius
      readonly property int radiusXs: 2
      readonly property int radiusSm: 6
      readonly property int radiusMd: 10
      readonly property int radiusLg: 14

      // Surfaces
      readonly property real opacitySurface:  0.96
      readonly property real opacityDisabled: 0.45

      // Sizes
      readonly property int barHeight:     30
      readonly property int popupTop:      barHeight + space6
      readonly property int toggleHeight:  56
      readonly property int sliderHeight:  24
      readonly property int segmentHeight: 36
      readonly property int searchHeight:  44
      readonly property int rowHeight:     52
      readonly property int iconTile:      32

      // Motion: things enter slower than they leave; nothing overshoots.
      readonly property bool reducedMotion: false
      readonly property int durFast: reducedMotion ? 0 : 120   // hover, press, colour
      readonly property int durBase: reducedMotion ? 0 : 200   // state change, selection glide, width
      readonly property int durSlow: reducedMotion ? 0 : 280   // popup enter, expand, list rise-in
      readonly property int durExit: reducedMotion ? 0 : 140   // popup exit
      readonly property int durData: reducedMotion ? 0 : 600   // meters, sparkline draw-in
      readonly property int easeOut: Easing.OutCubic
      readonly property int easeIn:  Easing.InCubic
  }
''
