{ ... }:
''
  import QtQuick
  import "."

  Item {
      id: slider
      property real  value:       50
      property real  maxValue:    100
      property color accentColor: Colors.accent
      signal moved(real v)

      implicitHeight: 24
      implicitWidth:  160

      Rectangle {
          id: track
          anchors.fill: parent
          radius: height / 2
          color: Colors.bgAlt
          border.color: Colors.border
          border.width: 1

          Rectangle {
              id: fill
              width: Math.max(height, parent.width * (slider.value / slider.maxValue))
              height: parent.height; radius: height / 2
              color: slider.accentColor
              
              // Glossy effect
              Rectangle {
                  anchors.fill: parent
                  anchors.margins: 2
                  radius: height / 2
                  color: "#FFFFFF"
                  opacity: 0.1
              }
          }
      }

      MouseArea {
          id: dragMa
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          preventStealing: true
          
          function handleUpdate(mouse) {
              var v = Math.round(Math.max(0, Math.min(slider.maxValue, (mouse.x / width) * slider.maxValue)))
              slider.moved(v)
          }

          onPressed: (mouse) => handleUpdate(mouse)
          onPositionChanged: (mouse) => { if (pressed) handleUpdate(mouse) }
      }
  }
''
