{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import QtQuick
  import QtQuick.Layouts
  import "."

  // Notification history, Do Not Disturb and Clear all, on the shared PopupSurface
  // (fade + 8px drop + 0.98 scale open over durSlow; reverse over durExit).
  PanelWindow {
      id: center

      property bool open: false
      signal closeRequested()

      anchors.top: true
      anchors.right: true
      implicitWidth: 400
      implicitHeight: Math.min(640, mainCol.implicitHeight + Style.space12 * 2)
      color: "transparent"
      visible: surface.shown

      WlrLayershell.namespace:     "notification-center"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.margins.top:   Style.popupTop
      WlrLayershell.margins.right: Style.space6

      onOpenChanged: if (open) focusRoot.forceActiveFocus()
      Shortcut { sequence: "Escape"; enabled: center.open; onActivated: center.closeRequested() }

      PopupSurface {
          id: surface
          anchors.fill: parent
          open: center.open

          FocusScope {
              id: focusRoot
              anchors.fill: parent

              ColumnLayout {
                  id: mainCol
                  anchors.fill: parent
                  spacing: Style.space8

                  // Title + Clear all
                  RowLayout {
                      Layout.fillWidth: true
                      Layout.leftMargin: Style.space4
                      Layout.bottomMargin: Style.space4
                      Text {
                          Layout.fillWidth: true
                          text: "Notifications"
                          color: Colors.fg
                          font.family: Style.fontFamily; font.pixelSize: 20; font.weight: Font.DemiBold
                      }
                      Item {
                          implicitWidth: clearLabel.implicitWidth + 24
                          implicitHeight: 30
                          visible: Notifications.history.length > 0
                          activeFocusOnTab: visible
                          Accessible.role: Accessible.Button
                          Accessible.name: "Clear all"
                          Keys.onReturnPressed: Notifications.clearAll()
                          Keys.onSpacePressed: Notifications.clearAll()
                          Rectangle {
                              anchors.fill: parent; radius: Style.radiusMd
                              color: clearMouse.containsMouse ? Colors.statusCritical : "transparent"
                              border.width: 1
                              border.color: clearMouse.containsMouse ? Colors.statusCritical : Colors.borderStrong
                              Behavior on color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                              Behavior on border.color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                          }
                          Text {
                              id: clearLabel
                              anchors.centerIn: parent
                              text: "Clear all"
                              color: clearMouse.containsMouse ? Colors.onAccent : Colors.fg
                              font.family: Style.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
                          }
                          FocusRing { targetRadius: Style.radiusMd }
                          MouseArea { id: clearMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Notifications.clearAll() }
                      }
                  }

                  // Do Not Disturb
                  Rectangle {
                      Layout.fillWidth: true
                      implicitHeight: dndRow.implicitHeight + Style.space12 * 2
                      radius: Style.radiusMd
                      color: Colors.bgAlt
                      RowLayout {
                          id: dndRow
                          anchors { fill: parent; margins: Style.space12 }
                          spacing: Style.space12
                          Icon { name: Notifications.dnd ? "bell-off" : "bell"; size: 18; color: Notifications.dnd ? Colors.accent : Colors.fgAlt }
                          ColumnLayout {
                              Layout.fillWidth: true
                              spacing: Style.space2
                              Text { text: "Do Not Disturb"; color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 14; font.weight: Font.Medium }
                              Text { text: "Silence pop-ups, keep history"; color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 12 }
                          }
                          Switch {
                              checked: Notifications.dnd
                              accessibleName: "Do Not Disturb"
                              onToggled: Notifications.dnd = !Notifications.dnd
                          }
                      }
                  }

                  // History. Recreated on each open so the cards rise in again.
                  Loader {
                      Layout.fillWidth: true
                      Layout.fillHeight: true
                      Layout.preferredHeight: item ? item.preferred : 0
                      active: surface.shown
                      sourceComponent: Flickable {
                          readonly property real preferred: Notifications.history.length > 0 ? listCol.implicitHeight : empty.implicitHeight
                          contentHeight: listCol.implicitHeight
                          clip: true
                          boundsBehavior: Flickable.StopAtBounds

                          Column {
                              id: listCol
                              width: parent.width
                              spacing: Style.space8
                              Repeater {
                                  model: ScriptModel { values: Notifications.history }
                                  NotificationCard {
                                      required property var modelData
                                      required property int index
                                      width: listCol.width
                                      notification: modelData
                                      enterDelay: Math.min(index, 8) * 20
                                  }
                              }
                          }

                          Column {
                              id: empty
                              visible: Notifications.history.length === 0
                              width: parent.width
                              topPadding: 24; bottomPadding: 24
                              spacing: Style.space8
                              Icon { anchors.horizontalCenter: parent.horizontalCenter; name: "inbox"; size: 24; color: Colors.fgMuted }
                              Text {
                                  anchors.horizontalCenter: parent.horizontalCenter
                                  text: "No notifications"
                                  color: Colors.fgAlt
                                  font.family: Style.fontFamily; font.pixelSize: 13
                              }
                          }
                      }
                  }
              }
          }
      }
  }
''
