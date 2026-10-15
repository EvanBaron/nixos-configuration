{ ... }:
''
  import QtQuick
  import "."

  // Small text button: outline by default, accent fill when primary, critical on hover when danger.
  Item {
      id: btn
      property string text: ""
      property bool primary: false
      property bool danger: false
      signal clicked()

      implicitWidth: label.implicitWidth + 24
      implicitHeight: 32
      opacity: enabled ? 1 : Style.opacityDisabled
      activeFocusOnTab: enabled
      Accessible.role: Accessible.Button
      Accessible.name: text
      Keys.onReturnPressed: btn.clicked()
      Keys.onSpacePressed: btn.clicked()

      readonly property bool hot: mouse.containsMouse && enabled
      Rectangle {
          anchors.fill: parent
          radius: Style.radiusMd
          color: btn.primary ? Colors.accent
               : btn.hot ? (btn.danger ? Colors.statusCritical : Colors.highlight)
               : "transparent"
          border.width: btn.primary ? 0 : 1
          border.color: btn.hot && btn.danger ? Colors.statusCritical : Colors.borderStrong
          scale: mouse.pressed ? 0.97 : 1
          Behavior on color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
          Behavior on scale { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
      }
      Text {
          id: label
          anchors.centerIn: parent
          text: btn.text
          color: btn.primary || (btn.hot && btn.danger) ? Colors.onAccent : Colors.fg
          font.family: Style.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
      }
      FocusRing { targetRadius: Style.radiusMd }
      MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; enabled: btn.enabled; cursorShape: Qt.PointingHandCursor; onClicked: btn.clicked() }
  }
''
