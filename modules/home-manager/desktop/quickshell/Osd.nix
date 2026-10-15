{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import QtQuick
  import "."

  // Level readout at the bottom centre after a volume, mute, mic or brightness change.
  // Shown only by show(); stays 1.2s after the last change. Never takes input.
  PanelWindow {
      id: osd

      property string kind: "volume"   // volume | brightness | mic
      property real value: 0           // 0..1
      property bool muted: false
      property bool open: false

      function show(k, v, m) {
          osd.kind = k
          osd.value = Math.max(0, Math.min(1, v))
          osd.muted = m
          osd.open = true
          hideTimer.restart()
      }

      Timer { id: hideTimer; interval: 1200; onTriggered: osd.open = false }

      anchors.bottom: true
      margins.bottom: 48
      implicitWidth: 300
      implicitHeight: 52
      color: "transparent"
      visible: open || card.opacity > 0

      WlrLayershell.namespace: "osd"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      mask: Region {}

      Rectangle {
          id: card
          width: parent.width
          height: parent.height
          radius: Style.radiusLg
          color: Qt.rgba(Colors.bg.r, Colors.bg.g, Colors.bg.b, Style.opacitySurface)
          border.width: 1
          border.color: Colors.border

          // Rises 8px and scales from 0.98 on enter; leaves faster than it came.
          opacity: osd.open ? 1 : 0
          y: osd.open ? 0 : 8
          scale: osd.open ? 1 : 0.98
          Behavior on opacity { NumberAnimation { duration: osd.open ? Style.durSlow : Style.durExit; easing.type: osd.open ? Style.easeOut : Style.easeIn } }
          Behavior on y       { NumberAnimation { duration: osd.open ? Style.durSlow : Style.durExit; easing.type: osd.open ? Style.easeOut : Style.easeIn } }
          Behavior on scale   { NumberAnimation { duration: osd.open ? Style.durSlow : Style.durExit; easing.type: osd.open ? Style.easeOut : Style.easeIn } }

          Row {
              anchors.fill: parent
              anchors.leftMargin: Style.space16
              anchors.rightMargin: Style.space16
              spacing: Style.space12

              Icon {
                  anchors.verticalCenter: parent.verticalCenter
                  size: 18
                  name: osd.kind === "brightness" ? "brightness"
                      : osd.kind === "mic" ? (osd.muted ? "mic-off" : "mic")
                      : (osd.muted ? "volume-x" : "volume-2")
                  color: osd.kind === "mic" && osd.muted ? Colors.statusCritical
                       : osd.muted ? Colors.fgAlt
                       : Colors.fg
              }

              // Microphone: a sentence instead of a level.
              Text {
                  visible: osd.kind === "mic"
                  anchors.verticalCenter: parent.verticalCenter
                  text: osd.muted ? "Microphone muted" : "Microphone on"
                  color: Colors.fg
                  font.family: Style.fontFamily; font.pixelSize: 14; font.weight: Font.Medium
              }

              Rectangle {
                  id: track
                  visible: osd.kind !== "mic"
                  anchors.verticalCenter: parent.verticalCenter
                  width: parent.width - 18 - 44 - 2 * Style.space12
                  height: 6
                  radius: 3
                  color: Colors.highlight
                  Rectangle {
                      width: track.width * osd.value
                      height: parent.height
                      radius: 3
                      color: osd.muted ? Colors.borderStrong : Colors.accent
                      Behavior on width { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                      Behavior on color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                  }
              }

              Text {
                  visible: osd.kind !== "mic"
                  anchors.verticalCenter: parent.verticalCenter
                  width: 44
                  horizontalAlignment: Text.AlignRight
                  text: osd.muted ? "Muted" : Math.round(osd.value * 100) + "%"
                  color: osd.muted ? Colors.fgAlt : Colors.fg
                  font.family: Style.fontFamily; font.pixelSize: 14; font.weight: Font.Medium
                  font.features: { "tnum": 1 }
              }
          }
      }
  }
''
