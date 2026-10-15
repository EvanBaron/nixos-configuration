{ ... }:
''
  import QtQuick
  import "."

  // 40×22 switch: highlight track with a borderStrong outline; on = accent track, onAccent knob.
  // The knob slides and the track recolours over durBase.
  Item {
      id: sw
      property bool checked: false
      property string accessibleName: ""
      signal toggled()

      implicitWidth: 40
      implicitHeight: 22
      activeFocusOnTab: true
      Accessible.role: Accessible.CheckBox
      Accessible.name: accessibleName
      Accessible.checked: checked
      Keys.onSpacePressed: sw.toggled()
      Keys.onReturnPressed: sw.toggled()

      Rectangle {
          anchors.fill: parent
          radius: height / 2
          color: sw.checked ? Colors.accent : Colors.highlight
          border.width: 1
          border.color: sw.checked ? Colors.accent : Colors.borderStrong
          Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
          Behavior on border.color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
      }
      Rectangle {
          width: 16; height: 16; radius: 8
          y: 3
          x: sw.checked ? sw.width - width - 3 : 3
          color: sw.checked ? Colors.onAccent : Colors.fgAlt
          Behavior on x { NumberAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
          Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
      }
      FocusRing { targetRadius: sw.height / 2 }
      MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sw.toggled() }
  }
''
