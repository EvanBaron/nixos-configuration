{ ... }:
''
  import QtQuick
  import "."

  // Icon + value in one ink on a chip that appears on hover or while its popup is open.
  // tone: "normal" | "ok" | "warning" | "critical" | "muted"
  Item {
      id: pill
      property string iconName:  ""
      property string valueText: ""
      property string tone:      "normal"
      property bool   active:    false
      property bool   badge:     false
      property string accessibleName: valueText
      signal clicked()
      signal scrolled(int steps)

      readonly property color ink: tone === "ok"       ? Colors.statusOk
                                 : tone === "warning"  ? Colors.statusWarning
                                 : tone === "critical" ? Colors.statusCritical
                                 : tone === "muted"    ? Colors.fgMuted
                                 : Colors.fg

      implicitHeight: 22
      implicitWidth: row.implicitWidth + 12
      activeFocusOnTab: true
      Accessible.role: Accessible.Button
      Accessible.name: accessibleName
      Keys.onReturnPressed: pill.clicked()
      Keys.onSpacePressed: pill.clicked()

      Rectangle {
          anchors.fill: parent
          radius: Style.radiusSm
          color: Colors.bgAlt
          opacity: mouse.containsMouse || pill.active ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
      }

      Row {
          id: row
          anchors.centerIn: parent
          spacing: Style.space4

          Item {
              width: 16; height: 16
              anchors.verticalCenter: parent.verticalCenter
              Icon { anchors.fill: parent; name: pill.iconName; size: 16; color: pill.ink }
              Rectangle {
                  visible: pill.badge
                  width: 6; height: 6; radius: 3
                  color: Colors.accent
                  anchors { right: parent.right; top: parent.top; rightMargin: -1; topMargin: -1 }
              }
          }

          Text {
              visible: pill.valueText !== ""
              text: pill.valueText
              color: pill.ink
              anchors.verticalCenter: parent.verticalCenter
              font.family: Style.fontFamily; font.pixelSize: 14; font.weight: Font.Medium
              font.features: { "tnum": 1 }
              Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
          }
      }

      FocusRing { targetRadius: Style.radiusSm }

      MouseArea {
          id: mouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: pill.clicked()
          onWheel: (wheel) => pill.scrolled(wheel.angleDelta.y > 0 ? 1 : -1)
      }
  }
''
