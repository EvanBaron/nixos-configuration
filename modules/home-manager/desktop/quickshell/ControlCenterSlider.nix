{ ... }:
''
  import QtQuick
  import "."

  // Pill track with an accent fill and a small grip. Click, drag, wheel (±5), arrows (±5), Home/End.
  // Values from outside ease over durBase; while dragging the fill follows the pointer exactly.
  Item {
      id: slider
      property real  value:    50
      property real  maxValue: 100
      property bool  muted:    false
      signal moved(real v)

      implicitHeight: Style.sliderHeight
      implicitWidth:  160
      activeFocusOnTab: true
      Accessible.role: Accessible.Slider

      function set(v) { slider.moved(Math.round(Math.max(0, Math.min(slider.maxValue, v)))) }
      Keys.onRightPressed: set(value + 5)
      Keys.onUpPressed:    set(value + 5)
      Keys.onLeftPressed:  set(value - 5)
      Keys.onDownPressed:  set(value - 5)
      Keys.onPressed: (event) => {
          if (event.key === Qt.Key_Home) { set(0); event.accepted = true }
          else if (event.key === Qt.Key_End) { set(slider.maxValue); event.accepted = true }
      }

      Rectangle {
          id: track
          anchors.fill: parent
          radius: height / 2
          color: Colors.bgAlt
          border.color: Colors.borderStrong
          border.width: 1
      }

      Rectangle {
          id: fill
          height: parent.height
          radius: height / 2
          width: Math.max(height, parent.width * (slider.value / slider.maxValue))
          color: slider.muted ? Colors.highlight : Colors.accent
          Behavior on width { enabled: !drag.pressed; NumberAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
          Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }

          Rectangle {
              id: grip
              width: 4
              height: drag.containsMouse || drag.pressed ? 14 : 10
              radius: 2
              anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
              color: slider.muted ? Colors.fgAlt : Colors.onAccent
              opacity: drag.containsMouse || drag.pressed ? 0.8 : 0.55
              Behavior on height { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
          }
      }

      FocusRing { targetRadius: slider.height / 2 }

      MouseArea {
          id: drag
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          preventStealing: true
          function update(mouse) { slider.set(mouse.x / width * slider.maxValue) }
          onPressed: (mouse) => update(mouse)
          onPositionChanged: (mouse) => { if (pressed) update(mouse) }
          onWheel: (wheel) => slider.set(slider.value + (wheel.angleDelta.y > 0 ? 5 : -5))
      }
  }
''
