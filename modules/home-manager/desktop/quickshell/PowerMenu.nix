{
  pkgs,
  ...
}:
''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import QtQuick
  import QtQuick.Layouts
  import "."

  // Opened by the power key or the bar's power pill. Five tiles; every action runs immediately,
  // after the menu's exit animation so it never lingers on screen (e.g. under the lock screen).
  PanelWindow {
      id: menu

      property bool open: false
      signal closeRequested()

      implicitWidth: mainCol.implicitWidth + Style.space16 * 2
      implicitHeight: mainCol.implicitHeight + Style.space16 * 2
      color: "transparent"
      visible: surface.shown

      WlrLayershell.namespace:     "power-menu"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore

      property string hostname: ""
      property string uptime: ""
      FileView { id: hostFile; path: "/proc/sys/kernel/hostname"; onTextChanged: menu.hostname = text().trim() }
      FileView {
          id: uptimeFile; path: "/proc/uptime"
          onTextChanged: {
              var s = Math.floor(parseFloat(text()) || 0)
              var d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60)
              menu.uptime = "Up " + (d > 0 ? d + " d " : "") + (d > 0 || h > 0 ? h + " h " : "") + m + " min"
          }
      }

      readonly property var actions: [
          { key: "lock",     label: "Lock",      icon: "lock",       cmd: ["${pkgs.quickshell}/bin/quickshell", "ipc", "call", "lock", "lock"] },
          { key: "sleep",    label: "Sleep",     icon: "moon",       cmd: ["systemctl", "suspend"] },
          { key: "logout",   label: "Log out",   icon: "log-out",    cmd: ["${pkgs.niri}/bin/niri", "msg", "action", "quit", "--skip-confirmation"] },
          { key: "reboot",   label: "Reboot",    icon: "rotate-ccw", cmd: ["systemctl", "reboot"] },
          { key: "shutdown", label: "Shut down", icon: "power",      cmd: ["systemctl", "poweroff"], danger: true }
      ]

      Process { id: runner }
      property var _pending: null
      function run(action) {
          _pending = action.cmd
          menu.closeRequested()
          after.restart()
      }
      Timer { id: after; interval: Style.durExit + 60; onTriggered: { runner.command = menu._pending; runner.running = true } }

      onOpenChanged: if (open) {
          hostFile.reload(); uptimeFile.reload()
          Qt.callLater(() => tiles.itemAt(0).forceActiveFocus())
      }
      Shortcut { sequence: "Escape"; enabled: menu.open; onActivated: menu.closeRequested() }

      PopupSurface {
          id: surface
          anchors.fill: parent
          open: menu.open
          padding: Style.space16

          ColumnLayout {
              id: mainCol
              spacing: Style.space16

              RowLayout {
                  Layout.fillWidth: true
                  spacing: Style.space8
                  Text { text: menu.hostname; color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 16; font.weight: Font.Medium }
                  Text { Layout.fillWidth: true; text: menu.uptime; color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 12 }
              }

              Row {
                  spacing: Style.space8
                  Repeater {
                      id: tiles
                      model: menu.actions
                      Item {
                          id: tile
                          required property var modelData
                          required property int index
                          readonly property bool lit: tileMouse.containsMouse || activeFocus
                          width: 88; height: 88
                          activeFocusOnTab: true
                          Accessible.role: Accessible.Button
                          Accessible.name: modelData.label
                          Keys.onReturnPressed: menu.run(modelData)
                          Keys.onEnterPressed:  menu.run(modelData)
                          Keys.onSpacePressed:  menu.run(modelData)
                          Keys.onLeftPressed:  tiles.itemAt((index + tiles.count - 1) % tiles.count).forceActiveFocus()
                          Keys.onRightPressed: tiles.itemAt((index + 1) % tiles.count).forceActiveFocus()

                          Rectangle {
                              anchors.fill: parent
                              radius: Style.radiusMd
                              color: tile.lit ? (tile.modelData.danger ? Colors.statusCritical : Colors.highlight) : Colors.bgAlt
                              scale: tileMouse.pressed ? 0.97 : 1
                              Behavior on color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                              Behavior on scale { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                          }
                          Column {
                              anchors.centerIn: parent
                              spacing: Style.space8
                              Icon {
                                  anchors.horizontalCenter: parent.horizontalCenter
                                  name: tile.modelData.icon; size: 24
                                  color: tile.lit && tile.modelData.danger ? Colors.onAccent : Colors.fg
                              }
                              Text {
                                  anchors.horizontalCenter: parent.horizontalCenter
                                  text: tile.modelData.label
                                  color: tile.lit && tile.modelData.danger ? Colors.onAccent : (tile.lit ? Colors.fg : Colors.fgAlt)
                                  font.family: Style.fontFamily; font.pixelSize: 12; font.weight: Font.Medium
                                  Behavior on color { ColorAnimation { duration: Style.durFast } }
                              }
                          }
                          FocusRing { targetRadius: Style.radiusMd }
                          MouseArea { id: tileMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: menu.run(tile.modelData) }
                      }
                  }
              }

              Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: "←→ choose  ·  ↵ confirm  ·  Esc cancel"
                  color: Colors.fgMuted
                  font.family: Style.fontFamily; font.pixelSize: 12
              }
          }
      }
  }
''
