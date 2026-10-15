{ ... }:
''
  import Quickshell
  import Quickshell.Bluetooth
  import QtQuick
  import QtQuick.Layouts
  import "."

  // Bluetooth page of the control center: radio switch, paired devices (connect / disconnect /
  // forget, battery), and nearby devices found while the page is open (pair, trust, connect).
  ColumnLayout {
      id: page
      property bool active: false
      signal back()

      spacing: Style.space12

      readonly property var adapter: Bluetooth.defaultAdapter
      readonly property bool on: adapter !== null && adapter.enabled

      // Discover only while the page is on screen.
      onActiveChanged: if (adapter && adapter.enabled) adapter.discovering = active
      onOnChanged: if (adapter && on && active) adapter.discovering = true

      readonly property var devices: adapter ? adapter.devices.values.filter(d => d.name || d.deviceName) : []
      readonly property var paired: devices.filter(d => d.paired)
          .sort((a, b) => (b.connected - a.connected) || (a.name || "").localeCompare(b.name || ""))
      readonly property var nearby: devices.filter(d => !d.paired && d.name && d.name.replace(/[-:]/g, "") !== d.address.replace(/[-:]/g, ""))

      function deviceIcon(d) {
          var i = d.icon || ""
          if (i.indexOf("audio") === 0) return "headphones"
          if (i === "input-mouse") return "mouse"
          if (i === "input-keyboard") return "keyboard"
          if (i === "phone") return "smartphone"
          if (i === "computer") return "laptop"
          return "bluetooth"
      }

      PageHeader {
          Layout.fillWidth: true
          title: "Bluetooth"
          checked: page.on
          showSwitch: page.adapter !== null
          busy: page.active && page.on && page.adapter.discovering
          onBack: page.back()
          onToggled: page.adapter.enabled = !page.adapter.enabled
      }

      Text {
          Layout.fillWidth: true
          Layout.topMargin: Style.space16; Layout.bottomMargin: Style.space16
          visible: !page.on
          horizontalAlignment: Text.AlignHCenter
          text: page.adapter === null ? "No Bluetooth adapter" : "Bluetooth is off"
          color: Colors.fgAlt
          font.family: Style.fontFamily; font.pixelSize: 13
      }

      component SectionLabel: Text {
          color: Colors.fgAlt
          font.family: Style.fontFamily; font.pixelSize: 11; font.weight: Font.Medium
      }

      component DeviceRow: Item {
          id: row
          required property var modelData
          readonly property var dev: modelData
          property bool wantConnect: false
          readonly property bool busy: dev.pairing || dev.state === BluetoothDeviceState.Connecting || dev.state === BluetoothDeviceState.Disconnecting

          width: parent ? parent.width : 0
          implicitHeight: 52

          function activate() {
              if (dev.paired) { dev.connected ? dev.disconnect() : dev.connect() }
              else { wantConnect = true; dev.pair() }
          }
          // After pairing: trust it and connect, so it reconnects on its own next time.
          Connections {
              target: row.dev
              function onPairedChanged() {
                  if (row.dev.paired && row.wantConnect) { row.wantConnect = false; row.dev.trusted = true; row.dev.connect() }
              }
          }

          Rectangle {
              anchors.fill: parent
              radius: Style.radiusMd
              color: row.dev.connected || rowMouse.containsMouse ? Colors.bgAlt : "transparent"
              Behavior on color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
          }
          Item {
              anchors.fill: parent
              activeFocusOnTab: true
              Accessible.role: Accessible.Button
              Accessible.name: row.dev.name
              Keys.onReturnPressed: row.activate()
              Keys.onSpacePressed: row.activate()

              RowLayout {
                  anchors { fill: parent; leftMargin: Style.space12; rightMargin: Style.space8 }
                  spacing: Style.space12
                  Icon { name: page.deviceIcon(row.dev); size: 18; color: row.dev.connected ? Colors.accent : Colors.fg }
                  ColumnLayout {
                      Layout.fillWidth: true
                      spacing: Style.space2
                      Text {
                          Layout.fillWidth: true
                          text: row.dev.name || row.dev.deviceName
                          elide: Text.ElideRight
                          color: Colors.fg
                          font.family: Style.fontFamily; font.pixelSize: 14; font.weight: row.dev.connected ? Font.Medium : Font.Normal
                      }
                      Text {
                          Layout.fillWidth: true
                          text: row.dev.pairing ? "Pairing…"
                              : row.dev.state === BluetoothDeviceState.Connecting ? "Connecting…"
                              : row.dev.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
                              : row.dev.connected ? ("Connected" + (row.dev.batteryAvailable ? " · " + Math.round(row.dev.battery > 1 ? row.dev.battery : row.dev.battery * 100) + "%" : ""))
                              : row.dev.paired ? "Not connected" : "Click to pair"
                          color: row.dev.connected ? Colors.accent : Colors.fgAlt
                          font.family: Style.fontFamily; font.pixelSize: 12
                      }
                  }
                  Icon {
                      visible: row.busy
                      name: "refresh-cw"; size: 14; color: Colors.fgMuted
                      RotationAnimation on rotation { running: row.busy && !Style.reducedMotion; from: 0; to: 360; duration: 1200; loops: Animation.Infinite }
                  }
                  // Forget, shown on hover for paired devices
                  Item {
                      visible: row.dev.paired
                      Layout.preferredWidth: 28; Layout.preferredHeight: 28
                      opacity: rowMouse.containsMouse || forgetMouse.containsMouse ? 1 : 0
                      Behavior on opacity { NumberAnimation { duration: Style.durFast } }
                      Rectangle { anchors.fill: parent; radius: Style.radiusSm; color: Colors.statusCritical; opacity: forgetMouse.containsMouse ? 1 : 0; Behavior on opacity { NumberAnimation { duration: Style.durFast } } }
                      Icon { anchors.centerIn: parent; name: "trash"; size: 14; color: forgetMouse.containsMouse ? Colors.onAccent : Colors.fgAlt }
                      MouseArea { id: forgetMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: row.dev.forget() }
                  }
              }
              FocusRing { targetRadius: Style.radiusMd }
          }
          MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: -1; onClicked: row.activate() }
      }

      Flickable {
          Layout.fillWidth: true
          Layout.preferredHeight: Math.min(contentHeight, 360)
          visible: page.on
          contentHeight: sections.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds

          Column {
              id: sections
              width: parent.width
              spacing: Style.space4

              SectionLabel { visible: page.paired.length > 0; text: "My devices"; bottomPadding: Style.space4 }
              Repeater { model: ScriptModel { values: page.paired } DeviceRow {} }

              SectionLabel { text: "Nearby"; topPadding: page.paired.length > 0 ? Style.space12 : 0; bottomPadding: Style.space4 }
              Repeater { model: ScriptModel { values: page.nearby } DeviceRow {} }
              Text {
                  visible: page.nearby.length === 0
                  width: parent.width
                  topPadding: Style.space8; bottomPadding: Style.space8
                  horizontalAlignment: Text.AlignHCenter
                  text: "Searching for devices…"
                  color: Colors.fgAlt
                  font.family: Style.fontFamily; font.pixelSize: 13
              }
          }
      }
  }
''
