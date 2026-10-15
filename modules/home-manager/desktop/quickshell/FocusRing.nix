{ ... }:
''
  import QtQuick
  import "."

  // 2px accent outline, 2px outside its parent, shown while the parent has keyboard focus.
  Rectangle {
      property Item target: parent
      property real targetRadius: Style.radiusMd
      anchors.fill: parent
      anchors.margins: -4
      radius: targetRadius + 4
      color: "transparent"
      border.color: Colors.focusRing
      border.width: 2
      opacity: target && target.activeFocus ? 1 : 0
      visible: opacity > 0
      Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
  }
''
