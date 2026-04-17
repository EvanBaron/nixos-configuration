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

              // Tooltip on hover
              Rectangle {
                  id: tooltip
                  visible: ma.containsMouse && trayItem.modelData.tooltip !== ""
                  anchors.bottom: parent.top; anchors.bottomMargin: 10
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: lbl.implicitWidth + 12; height: lbl.implicitHeight + 8
                  color: Colors.bg; border.color: Colors.border; border.width: 1; radius: 4; z: 100
                  Text { id: lbl; anchors.centerIn: parent; text: trayItem.modelData.tooltip || ""; color: Colors.fg; font.family: "Fira Sans"; font.pixelSize: 11 }
              }

              MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true }
          }
      }
  }
''
