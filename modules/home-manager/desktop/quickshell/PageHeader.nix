{ ... }:
''
  import QtQuick
  import QtQuick.Layouts
  import "."

  // Header of a control-center detail page: back, title, optional busy spinner, and a Switch.
  RowLayout {
      id: header
      property string title: ""
      property bool checked: false
      property bool showSwitch: true
      property bool busy: false
      signal back()
      signal toggled()

      spacing: Style.space8

      Item {
          id: backBtn
          Layout.preferredWidth: 32; Layout.preferredHeight: 32
          activeFocusOnTab: true
          Accessible.role: Accessible.Button
          Accessible.name: "Back"
          Keys.onReturnPressed: header.back()
          Keys.onSpacePressed: header.back()
          Rectangle {
              anchors.fill: parent; radius: Style.radiusMd
              color: Colors.bgAlt
              opacity: backMouse.containsMouse ? 1 : 0
              Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
          }
          Icon { anchors.centerIn: parent; name: "chevron-left"; size: 18; color: backMouse.containsMouse ? Colors.fg : Colors.fgAlt }
          FocusRing { targetRadius: Style.radiusMd }
          MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: header.back() }
      }
      Text {
          text: header.title
          color: Colors.fg
          font.family: Style.fontFamily; font.pixelSize: 16; font.weight: Font.Medium
      }
      Icon {
          id: spinner
          name: "refresh-cw"; size: 14; color: Colors.fgMuted
          opacity: header.busy ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: Style.durBase } }
          RotationAnimation on rotation { running: header.busy && !Style.reducedMotion; from: 0; to: 360; duration: 1200; loops: Animation.Infinite }
      }
      Item { Layout.fillWidth: true }
      Switch {
          visible: header.showSwitch
          checked: header.checked
          accessibleName: header.title
          onToggled: header.toggled()
      }
  }
''
