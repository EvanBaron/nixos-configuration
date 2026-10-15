{ ... }:
''
  import QtQuick
  import "."

  // The floating surface every popup sits on: bg at opacitySurface, 1px border, radiusLg.
  // Enter: fade + 8px drop + 0.98 scale from the top edge over durSlow (OutCubic).
  // Exit: the reverse over durExit (InCubic). `shown` stays true until the exit finishes,
  // so the owning window can stay mapped while it plays.
  Item {
      id: surface
      property bool open: false
      readonly property bool shown: open || opacity > 0
      property int padding: Style.space12
      default property alias content: body.data

      opacity: 0
      scale: 0.98
      transformOrigin: Item.Top
      transform: Translate { id: drop; y: -8 }

      Rectangle {
          anchors.fill: parent
          radius: Style.radiusLg
          color: Colors.bg
          opacity: Style.opacitySurface
      }
      Rectangle {
          anchors.fill: parent
          radius: Style.radiusLg
          color: "transparent"
          border.color: Colors.border
          border.width: 1
      }

      Item {
          id: body
          anchors.fill: parent
          anchors.margins: surface.padding
      }

      states: State {
          name: "open"; when: surface.open
          PropertyChanges { surface.opacity: 1; surface.scale: 1; drop.y: 0 }
      }
      transitions: [
          Transition {
              to: "open"
              ParallelAnimation {
                  NumberAnimation { target: surface; properties: "opacity,scale"; duration: Style.durSlow; easing.type: Style.easeOut }
                  NumberAnimation { target: drop; property: "y"; duration: Style.durSlow; easing.type: Style.easeOut }
              }
          },
          Transition {
              from: "open"
              ParallelAnimation {
                  NumberAnimation { target: surface; properties: "opacity,scale"; duration: Style.durExit; easing.type: Style.easeIn }
                  NumberAnimation { target: drop; property: "y"; duration: Style.durExit; easing.type: Style.easeIn }
              }
          }
      ]
  }
''
