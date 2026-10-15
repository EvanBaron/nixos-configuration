{ ... }:
''
  import Quickshell
  import Quickshell.Services.SystemTray
  import Quickshell.Widgets
  import QtQuick
  import QtQuick.Layouts
  import "."

  Row {
      id: trayRoot
      spacing: 8
      height: 20
      anchors.verticalCenter: parent.verticalCenter

      Repeater {
          model: SystemTray.items

          Item {
              id: trayItem
              required property var modelData
              width: 18; height: 18
              anchors.verticalCenter: parent.verticalCenter

              IconImage {
                  anchors.fill: parent
                  source: trayItem.modelData.icon || ""
                  smooth: true
              }

              MouseArea {
                  anchors.fill: parent
                  acceptedButtons: Qt.LeftButton | Qt.RightButton
                  cursorShape: Qt.PointingHandCursor
                  onClicked: (mouse) => {
                      if (mouse.button === Qt.LeftButton) {
                          trayItem.modelData.activate();
                      } else if (mouse.button === Qt.RightButton) {
                          trayItem.modelData.contextMenu();
                      }
                  }
              }

              // Tooltip: fades in and rises 4px after a 400ms hover; hides at once.
              Rectangle {
                  id: tooltip
                  property bool wanted: ma.containsMouse && (trayItem.modelData.tooltipTitle || "") !== ""
                  anchors.top: parent.bottom; anchors.topMargin: Style.space8 + (wanted ? 0 : 4)
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: lbl.implicitWidth + 16; height: lbl.implicitHeight + 8
                  color: Colors.bgAlt; border.color: Colors.border; border.width: 1; radius: Style.radiusSm; z: 100
                  opacity: 0
                  visible: opacity > 0
                  Behavior on anchors.topMargin { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                  states: State { name: "shown"; when: tooltip.wanted; PropertyChanges { tooltip.opacity: 1 } }
                  transitions: [
                      Transition { to: "shown"; SequentialAnimation { PauseAnimation { duration: 400 } NumberAnimation { property: "opacity"; duration: Style.durFast; easing.type: Style.easeOut } } },
                      Transition { from: "shown"; NumberAnimation { property: "opacity"; duration: 0 } }
                  ]
                  Text { id: lbl; anchors.centerIn: parent; text: trayItem.modelData.tooltipTitle || ""; color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 12 }
              }

              MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true }
          }
      }
  }
''
