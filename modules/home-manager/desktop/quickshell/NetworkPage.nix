{ ... }:
''
  import Quickshell
  import Quickshell.Networking
  import QtQuick
  import QtQuick.Layouts
  import "."

  // Wi-Fi page of the control center: radio switch, live scan, connect, password entry, forget.
  ColumnLayout {
      id: page
      property bool active: false
      signal back()

      spacing: Style.space12

      readonly property var device: {
          var v = Networking.devices.values
          for (var i = 0; i < v.length; i++) if (v[i].type === DeviceType.Wifi) return v[i]
          return null
      }
      // Scan only while the page is on screen.
      onActiveChanged: if (device) device.scannerEnabled = active && Networking.wifiEnabled

      readonly property var networks: {
          if (!device || !Networking.wifiEnabled) return []
          var seen = {}, out = []
          var v = device.networks.values
          for (var i = 0; i < v.length; i++) {
              var n = v[i]
              if (!n.name || seen[n.name]) continue
              seen[n.name] = true
              out.push(n)
          }
          return out.sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (strength(b) - strength(a)))
      }

      property string expanded: ""   // name of the row showing its password field or actions

      function strength(n) { var s = n.signalStrength; return s > 1 ? s / 100 : s }
      function strengthIcon(n) {
          var s = strength(n)
          return s >= 0.75 ? "wifi" : s >= 0.5 ? "wifi-high" : s >= 0.25 ? "wifi-low" : "wifi-zero"
      }
      function isOpen(n) { return n.security === WifiSecurityType.Open || n.security === WifiSecurityType.Owe }

      PageHeader {
          Layout.fillWidth: true
          title: "Wi-Fi"
          checked: Networking.wifiEnabled
          busy: page.active && page.device !== null && page.device.scannerEnabled
          onBack: page.back()
          onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
      }

      Text {
          Layout.fillWidth: true
          Layout.topMargin: Style.space16; Layout.bottomMargin: Style.space16
          visible: page.networks.length === 0
          horizontalAlignment: Text.AlignHCenter
          text: !page.device ? "No Wi-Fi adapter" : !Networking.wifiEnabled ? "Wi-Fi is off" : "Searching for networks…"
          color: Colors.fgAlt
          font.family: Style.fontFamily; font.pixelSize: 13
      }

      Flickable {
          Layout.fillWidth: true
          Layout.preferredHeight: Math.min(contentHeight, 340)
          visible: page.networks.length > 0
          contentHeight: list.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds

          Column {
              id: list
              width: parent.width
              spacing: Style.space4

              Repeater {
                  model: ScriptModel { values: page.networks }
                  Item {
                      id: row
                      required property var modelData
                      readonly property var net: modelData
                      readonly property bool open: page.expanded === net.name
                      readonly property bool needsPassword: !net.known && !page.isOpen(net)
                      property string error: ""

                      width: list.width
                      implicitHeight: 52 + (open ? extra.implicitHeight + Style.space8 : 0)
                      clip: true
                      Behavior on implicitHeight { NumberAnimation { duration: Style.durBase; easing.type: Style.easeOut } }

                      function activate() {
                          error = ""
                          if (net.connected || needsPassword) page.expanded = open ? "" : net.name
                          else { page.expanded = ""; net.connect() }
                      }

                      Connections {
                          target: row.net
                          function onConnectionFailed(reason) {
                              row.error = (reason === ConnectionFailReason.NoSecrets || reason === ConnectionFailReason.WifiAuthTimeout)
                                  ? "Wrong password" : "Couldn't connect"
                              page.expanded = row.net.name
                          }
                          function onConnectedChanged() { if (row.net.connected) { row.error = ""; if (page.expanded === row.net.name) page.expanded = "" } }
                      }

                      Rectangle {
                          anchors.fill: parent
                          radius: Style.radiusMd
                          color: row.net.connected ? Colors.bgAlt : (rowMouse.containsMouse || row.open ? Colors.bgAlt : "transparent")
                          Behavior on color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                      }

                      // Main line
                      Item {
                          id: head
                          width: parent.width; height: 52
                          activeFocusOnTab: true
                          Accessible.role: Accessible.Button
                          Accessible.name: row.net.name
                          Keys.onReturnPressed: row.activate()
                          Keys.onSpacePressed: row.activate()

                          RowLayout {
                              anchors { fill: parent; leftMargin: Style.space12; rightMargin: Style.space12 }
                              spacing: Style.space12
                              Icon { name: page.strengthIcon(row.net); size: 18; color: row.net.connected ? Colors.accent : Colors.fg }
                              ColumnLayout {
                                  Layout.fillWidth: true
                                  spacing: Style.space2
                                  Text {
                                      Layout.fillWidth: true
                                      text: row.net.name
                                      elide: Text.ElideRight
                                      color: Colors.fg
                                      font.family: Style.fontFamily; font.pixelSize: 14; font.weight: row.net.connected ? Font.Medium : Font.Normal
                                  }
                                  Text {
                                      Layout.fillWidth: true
                                      text: row.error !== "" ? row.error
                                          : row.net.stateChanging ? (row.net.connected ? "Disconnecting…" : "Connecting…")
                                          : row.net.connected ? "Connected"
                                          : row.net.known ? "Saved"
                                          : page.isOpen(row.net) ? "Open" : "Secured"
                                      color: row.error !== "" ? Colors.statusCritical : row.net.connected ? Colors.accent : Colors.fgAlt
                                      font.family: Style.fontFamily; font.pixelSize: 12
                                  }
                              }
                              Icon { visible: !page.isOpen(row.net); name: "lock"; size: 14; color: Colors.fgMuted }
                          }
                          FocusRing { targetRadius: Style.radiusMd }
                          MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: row.activate() }
                      }

                      // Expanded: password field, or Disconnect / Forget for the current network.
                      ColumnLayout {
                          id: extra
                          anchors { left: parent.left; right: parent.right; top: head.bottom; leftMargin: Style.space12; rightMargin: Style.space12 }
                          opacity: row.open ? 1 : 0
                          visible: opacity > 0
                          spacing: Style.space8
                          Behavior on opacity { NumberAnimation { duration: Style.durBase; easing.type: Style.easeOut } }

                          RowLayout {
                              visible: row.needsPassword || row.error !== ""
                              Layout.fillWidth: true
                              spacing: Style.space8
                              Rectangle {
                                  Layout.fillWidth: true
                                  Layout.preferredHeight: 36
                                  radius: Style.radiusMd
                                  color: Colors.bg
                                  border.width: 1
                                  border.color: psk.activeFocus ? Colors.accent : Colors.borderStrong
                                  Behavior on border.color { ColorAnimation { duration: Style.durFast } }
                                  TextInput {
                                      id: psk
                                      anchors { left: parent.left; right: eye.left; verticalCenter: parent.verticalCenter; leftMargin: Style.space12; rightMargin: Style.space8 }
                                      color: Colors.fg
                                      echoMode: eye.shown ? TextInput.Normal : TextInput.Password
                                      font.family: Style.fontFamily; font.pixelSize: 14
                                      clip: true
                                      onAccepted: if (text.length > 0) { row.error = ""; row.net.connectWithPsk(text) }
                                      Text {
                                          visible: psk.text === ""
                                          anchors.verticalCenter: parent.verticalCenter
                                          text: "Password"
                                          color: Colors.fgMuted
                                          font: psk.font
                                      }
                                  }
                                  Item {
                                      id: eye
                                      property bool shown: false
                                      width: 28; height: 28
                                      anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                                      Icon { anchors.centerIn: parent; name: "eye"; size: 16; color: eye.shown ? Colors.accent : Colors.fgMuted }
                                      MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: eye.shown = !eye.shown }
                                  }
                              }
                              PillButton {
                                  text: "Connect"; primary: true
                                  enabled: psk.text.length > 0
                                  onClicked: { row.error = ""; row.net.connectWithPsk(psk.text) }
                              }
                          }

                          RowLayout {
                              visible: row.net.connected || (row.net.known && row.error !== "")
                              Layout.fillWidth: true
                              spacing: Style.space8
                              Item { Layout.fillWidth: true }
                              PillButton { visible: row.net.connected; text: "Disconnect"; onClicked: { page.expanded = ""; row.net.disconnect() } }
                              PillButton { text: "Forget"; danger: true; onClicked: { page.expanded = ""; row.net.forget() } }
                          }
                          Item { Layout.preferredHeight: 2 }
                      }

                      onOpenChanged: if (open && needsPassword) psk.forceActiveFocus()
                  }
              }
          }
      }
  }
''
