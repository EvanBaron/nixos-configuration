{ ... }:
''
  import QtQuick
  import "."

  // Split button: the body turns the radio on/off, the chevron opens its settings.
  // On = accent fill with onAccent ink. Colours crossfade over durBase; the body presses to 0.97.
  Item {
      id: toggle
      property bool   on:        false
      property bool   available: true
      property string label:     ""
      property string status:    ""
      property string iconOn:    ""
      property string iconOff:   iconOn
      property bool   hasSettings: true
      signal toggled()
      signal openSettings()

      implicitHeight: Style.toggleHeight
      opacity: available ? 1 : Style.opacityDisabled

      readonly property color ink: on ? Colors.onAccent : Colors.fg
      readonly property color subInk: on ? Colors.onAccent : Colors.fgAlt

      Rectangle {
          id: fill
          anchors.fill: parent
          radius: Style.radiusMd
          color: toggle.on ? Colors.accent : Colors.bgAlt
          Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
      }

      // Body
      Item {
          id: body
          anchors { left: parent.left; top: parent.top; bottom: parent.bottom; right: more.visible ? more.left : parent.right }
          activeFocusOnTab: toggle.available
          Accessible.role: Accessible.CheckBox
          Accessible.name: toggle.label
          Accessible.checked: toggle.on
          Keys.onSpacePressed: toggle.toggled()
          Keys.onReturnPressed: toggle.toggled()

          Rectangle {
              anchors.fill: parent
              radius: Style.radiusMd
              color: toggle.on ? "#000000" : Colors.highlight
              opacity: bodyMouse.containsMouse ? (toggle.on ? 0.12 : 1) : 0
              Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
          }

          Row {
              anchors { left: parent.left; leftMargin: Style.space12; right: parent.right; rightMargin: Style.space8; verticalCenter: parent.verticalCenter }
              spacing: Style.space8
              scale: bodyMouse.pressed ? 0.97 : 1
              Behavior on scale { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }

              Icon {
                  anchors.verticalCenter: parent.verticalCenter
                  name: toggle.on ? toggle.iconOn : toggle.iconOff
                  color: toggle.on ? Colors.onAccent : Colors.fgAlt
                  size: 18
              }
              Column {
                  anchors.verticalCenter: parent.verticalCenter
                  width: parent.width - 26
                  spacing: Style.space2
                  Text {
                      width: parent.width
                      text: toggle.label
                      color: toggle.ink
                      elide: Text.ElideRight
                      font.family: Style.fontFamily; font.pixelSize: 14; font.weight: Font.Medium
                      Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
                  }
                  Text {
                      width: parent.width
                      text: toggle.status
                      visible: text !== ""
                      color: toggle.subInk
                      elide: Text.ElideRight
                      font.family: Style.fontFamily; font.pixelSize: 12
                      Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
                  }
              }
          }

          FocusRing { targetRadius: Style.radiusMd }

          MouseArea {
              id: bodyMouse
              anchors.fill: parent
              enabled: toggle.available
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: toggle.toggled()
          }
      }

      // Chevron
      Item {
          id: more
          visible: toggle.hasSettings && toggle.available
          width: 32
          anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
          activeFocusOnTab: visible
          Accessible.role: Accessible.Button
          Accessible.name: toggle.label + " settings"
          Keys.onSpacePressed: toggle.openSettings()
          Keys.onReturnPressed: toggle.openSettings()

          Rectangle {
              anchors.fill: parent
              radius: Style.radiusMd
              color: toggle.on ? "#000000" : Colors.highlight
              opacity: moreMouse.containsMouse ? (toggle.on ? 0.12 : 1) : 0
              Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
          }
          Rectangle {
              width: 1
              anchors { left: parent.left; top: parent.top; bottom: parent.bottom; topMargin: Style.space12; bottomMargin: Style.space12 }
              color: toggle.on ? Colors.onAccent : Colors.border
              opacity: toggle.on ? 0.3 : 1
          }
          Icon { anchors.centerIn: parent; name: "chevron-right"; size: 16; color: toggle.on ? Colors.onAccent : Colors.fgAlt }
          FocusRing { targetRadius: Style.radiusMd }
          MouseArea {
              id: moreMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: toggle.openSettings()
          }
      }
  }
''
