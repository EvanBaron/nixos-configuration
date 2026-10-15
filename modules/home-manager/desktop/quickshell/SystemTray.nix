{ ... }:
''
  import Quickshell
  import Quickshell.Services.SystemTray
  import Quickshell.Widgets
  import QtQuick
  import "."

  // StatusNotifier icons for the bar: 16px icons in 22px hover chips, 4px apart.
  // Left click activates (or opens the menu of menu-only items), right click opens the menu.
  Row {
      id: trayRoot
      // The bar window, used to place item menus.
      property var parentWindow: null
      readonly property int itemCount: repeater.count

      spacing: Style.space4

      Repeater {
          id: repeater
          model: SystemTray.items

          Item {
              id: trayItem
              required property var modelData
              width: 22; height: 22

              Rectangle {
                  anchors.fill: parent
                  radius: Style.radiusSm
                  color: Colors.bgAlt
                  opacity: ma.containsMouse ? 1 : 0
                  Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
              }

              IconImage {
                  anchors.centerIn: parent
                  implicitSize: 16
                  source: trayItem.modelData.icon || ""
              }

              function openMenu() {
                  if (!trayItem.modelData.hasMenu || !trayRoot.parentWindow) return
                  var p = trayItem.mapToItem(null, 0, trayItem.height + Style.space6)
                  trayItem.modelData.display(trayRoot.parentWindow, Math.round(p.x), Math.round(p.y))
              }

              MouseArea {
                  id: ma
                  anchors.fill: parent
                  hoverEnabled: true
                  acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                  cursorShape: Qt.PointingHandCursor
                  onClicked: (mouse) => {
                      if (mouse.button === Qt.RightButton || (mouse.button === Qt.LeftButton && trayItem.modelData.onlyMenu))
                          trayItem.openMenu()
                      else if (mouse.button === Qt.LeftButton)
                          trayItem.modelData.activate()
                      else
                          trayItem.modelData.secondaryActivate()
                  }
                  onWheel: (wheel) => trayItem.modelData.scroll(wheel.angleDelta.y, false)
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
          }
      }
  }
''
