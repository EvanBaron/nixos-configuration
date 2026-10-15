{ ... }:

''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import Quickshell.Bluetooth
  import Quickshell.Networking
  import Quickshell.Services.UPower
  import QtQuick
  import QtQuick.Layouts
  import "."

  PanelWindow {
      id: controlCenter

      property bool open: false
      property real volumePercentage: 50
      property bool volumeMuted: false
      property real brightnessPercentage: 80
      property string page: "main"   // "main" | "wifi" | "bluetooth"

      anchors.top: true
      implicitWidth: 360
      implicitHeight: stack.implicitHeight + Style.space12 * 2
      color: "transparent"
      visible: surface.shown

      WlrLayershell.namespace:     "controlcenter"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.margins.top:   Style.popupTop

      // ── Identity: read from /proc so it never depends on optional binaries ──
      property string hostname: ""
      property string uptime: ""
      FileView { id: hostFile; path: "/proc/sys/kernel/hostname"; onTextChanged: controlCenter.hostname = text().trim() }
      FileView {
          id: uptimeFile; path: "/proc/uptime"
          onTextChanged: {
              var s = Math.floor(parseFloat(text()) || 0)
              var d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60)
              controlCenter.uptime = "Up " + (d > 0 ? d + " d " : "") + (d > 0 || h > 0 ? h + " h " : "") + m + " min"
          }
      }
      Timer { interval: 60000; running: controlCenter.open; repeat: true; triggeredOnStart: true; onTriggered: uptimeFile.reload() }

      // ── Wi-Fi and Bluetooth state from Quickshell's own services ──
      readonly property var wifiDevice: {
          var v = Networking.devices.values
          for (var i = 0; i < v.length; i++) if (v[i].type === DeviceType.Wifi) return v[i]
          return null
      }
      readonly property string wifiNetwork: {
          if (!wifiDevice) return ""
          var n = wifiDevice.networks.values
          for (var i = 0; i < n.length; i++) if (n[i].connected) return n[i].name
          return ""
      }
      readonly property string wifiIcon: {
          if (!wifiDevice) return "wifi"
          var n = wifiDevice.networks.values
          for (var i = 0; i < n.length; i++) if (n[i].connected) {
              var s = n[i].signalStrength > 1 ? n[i].signalStrength / 100 : n[i].signalStrength
              return s >= 0.75 ? "wifi" : s >= 0.5 ? "wifi-high" : s >= 0.25 ? "wifi-low" : "wifi-zero"
          }
          return "wifi"
      }
      readonly property var btAdapter: Bluetooth.defaultAdapter
      readonly property string btDevice: {
          if (!btAdapter) return ""
          var v = btAdapter.devices.values
          var c = v.filter(d => d.connected)
          if (c.length > 1) return c.length + " devices"
          return c.length ? (c[0].name || c[0].deviceName) : ""
      }


      // ── Volume and brightness ──
      Process { id: volSet }
      Process { id: muteSet; command: ["wpctl", "set-mute", "@DEFAULT_SINK@", "toggle"] }
      Process { id: brightSet }
      Process {
          id: brightGet
          command: ["sh", "-c", "echo $(brightnessctl g) $(brightnessctl m)"]
          stdout: SplitParser {
              onRead: data => {
                  var p = data.trim().split(" ")
                  var cur = parseInt(p[0]), max = parseInt(p[1])
                  if (max > 0) controlCenter.brightnessPercentage = Math.round(cur / max * 100)
              }
          }
      }
      Timer { interval: 5000; running: controlCenter.open; repeat: true; triggeredOnStart: true; onTriggered: brightGet.running = true }

      readonly property var profileKeys: ["saver", "balanced", "performance"]
      readonly property var profileEnums: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]

      onOpenChanged: {
          if (open) { hostFile.reload(); focusRoot.forceActiveFocus() }
          else pageReset.restart()
      }
      // Back to the main page once the exit animation has played.
      Timer { id: pageReset; interval: Style.durExit + 40; onTriggered: if (!controlCenter.open) controlCenter.page = "main" }

      Shortcut {
          sequence: "Escape"
          enabled: controlCenter.open
          onActivated: controlCenter.page !== "main" ? controlCenter.page = "main" : controlCenter.open = false
      }

      PopupSurface {
          id: surface
          anchors.fill: parent
          open: controlCenter.open

          FocusScope {
              id: focusRoot
              anchors.fill: parent
              focus: true

              // Page stack: the outgoing page slides 24px away and fades (durExit, InCubic), then the
              // incoming one enters from the other side (durBase, OutCubic); the height eases over durSlow.
              Item {
                  id: stack
                  anchors { left: parent.left; right: parent.right; top: parent.top }
                  readonly property Item current: controlCenter.page === "wifi" ? wifiPage
                                                : controlCenter.page === "bluetooth" ? btPage
                                                : mainCol
                  implicitHeight: current.implicitHeight
                  height: implicitHeight
                  Behavior on implicitHeight { NumberAnimation { duration: Style.durSlow; easing.type: Style.easeOut } }

                  NetworkPage {
                      id: wifiPage
                      width: parent.width
                      active: controlCenter.open && controlCenter.page === "wifi"
                      x: controlCenter.page === "wifi" ? 0 : 24
                      opacity: controlCenter.page === "wifi" ? 1 : 0
                      visible: opacity > 0
                      Behavior on x { SequentialAnimation { PauseAnimation { duration: controlCenter.page === "wifi" ? Style.durExit : 0 } NumberAnimation { duration: controlCenter.page === "wifi" ? Style.durBase : Style.durExit; easing.type: controlCenter.page === "wifi" ? Style.easeOut : Style.easeIn } } }
                      Behavior on opacity { SequentialAnimation { PauseAnimation { duration: controlCenter.page === "wifi" ? Style.durExit : 0 } NumberAnimation { duration: controlCenter.page === "wifi" ? Style.durBase : Style.durExit; easing.type: controlCenter.page === "wifi" ? Style.easeOut : Style.easeIn } } }
                      onBack: controlCenter.page = "main"
                  }
                  BluetoothPage {
                      id: btPage
                      width: parent.width
                      active: controlCenter.open && controlCenter.page === "bluetooth"
                      x: controlCenter.page === "bluetooth" ? 0 : 24
                      opacity: controlCenter.page === "bluetooth" ? 1 : 0
                      visible: opacity > 0
                      Behavior on x { SequentialAnimation { PauseAnimation { duration: controlCenter.page === "bluetooth" ? Style.durExit : 0 } NumberAnimation { duration: controlCenter.page === "bluetooth" ? Style.durBase : Style.durExit; easing.type: controlCenter.page === "bluetooth" ? Style.easeOut : Style.easeIn } } }
                      Behavior on opacity { SequentialAnimation { PauseAnimation { duration: controlCenter.page === "bluetooth" ? Style.durExit : 0 } NumberAnimation { duration: controlCenter.page === "bluetooth" ? Style.durBase : Style.durExit; easing.type: controlCenter.page === "bluetooth" ? Style.easeOut : Style.easeIn } } }
                      onBack: controlCenter.page = "main"
                  }

                  ColumnLayout {
                      id: mainCol
                      width: parent.width
                      spacing: Style.space16
                      x: controlCenter.page === "main" ? 0 : -24
                      opacity: controlCenter.page === "main" ? 1 : 0
                      visible: opacity > 0
                      Behavior on x { SequentialAnimation { PauseAnimation { duration: controlCenter.page === "main" ? Style.durExit : 0 } NumberAnimation { duration: controlCenter.page === "main" ? Style.durBase : Style.durExit; easing.type: controlCenter.page === "main" ? Style.easeOut : Style.easeIn } } }
                      Behavior on opacity { SequentialAnimation { PauseAnimation { duration: controlCenter.page === "main" ? Style.durExit : 0 } NumberAnimation { duration: controlCenter.page === "main" ? Style.durBase : Style.durExit; easing.type: controlCenter.page === "main" ? Style.easeOut : Style.easeIn } } }

                      // Header
                      RowLayout {
                          Layout.fillWidth: true
                          spacing: Style.space12
                          Rectangle {
                              Layout.preferredWidth: 40; Layout.preferredHeight: 40; radius: 20; color: Colors.highlight
                              Icon { anchors.centerIn: parent; name: "user"; size: 20; color: Colors.fg }
                          }
                          ColumnLayout {
                              Layout.fillWidth: true
                              spacing: 0
                              Text { Layout.fillWidth: true; elide: Text.ElideRight; text: controlCenter.hostname; color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 16; font.weight: Font.Medium }
                              Text { Layout.fillWidth: true; elide: Text.ElideRight; text: controlCenter.uptime; color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 12 }
                          }
                          Item {
                              Layout.preferredWidth: 32; Layout.preferredHeight: 32
                              activeFocusOnTab: true
                              Accessible.role: Accessible.Button
                              Accessible.name: "Close"
                              Keys.onReturnPressed: controlCenter.open = false
                              Keys.onSpacePressed: controlCenter.open = false
                              Rectangle {
                                  anchors.fill: parent; radius: Style.radiusMd
                                  color: closeMouse.pressed ? Colors.highlight : Colors.bgAlt
                                  opacity: closeMouse.containsMouse ? 1 : 0
                                  Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                              }
                              Icon { anchors.centerIn: parent; name: "x"; size: 16; color: closeMouse.containsMouse ? Colors.fg : Colors.fgAlt }
                              FocusRing { targetRadius: Style.radiusMd }
                              MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: controlCenter.open = false }
                          }
                      }

                      // Radios
                      GridLayout {
                          Layout.fillWidth: true
                          columns: 2; rowSpacing: Style.space8; columnSpacing: Style.space8
                          uniformCellWidths: true

                          ControlCenterToggle {
                              Layout.fillWidth: true
                              label: "Wi-Fi"
                              iconOn: controlCenter.wifiIcon; iconOff: "wifi-off"
                              available: controlCenter.wifiDevice !== null && Networking.wifiHardwareEnabled
                              on: Networking.wifiEnabled
                              status: !available ? "Unavailable" : !on ? "Off" : (controlCenter.wifiNetwork || "Not connected")
                              onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                              onOpenSettings: controlCenter.page = "wifi"
                          }
                          ControlCenterToggle {
                              Layout.fillWidth: true
                              label: "Bluetooth"
                              iconOn: "bluetooth"; iconOff: "bluetooth-off"
                              available: controlCenter.btAdapter !== null
                              on: available && controlCenter.btAdapter.enabled
                              status: !available ? "No adapter" : !on ? "Off" : (controlCenter.btDevice || "On")
                              onToggled: controlCenter.btAdapter.enabled = !controlCenter.btAdapter.enabled
                              onOpenSettings: controlCenter.page = "bluetooth"
                          }
                      }

                      // Power profile
                      ColumnLayout {
                          Layout.fillWidth: true
                          spacing: Style.space8
                          Text { text: "Power profile"; color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 11; font.weight: Font.Medium }
                          SegmentedControl {
                              Layout.fillWidth: true
                              model: PowerProfiles.hasPerformanceProfile
                                  ? [{ key: "saver", label: "Saver", icon: "leaf" }, { key: "balanced", label: "Balanced", icon: "activity" }, { key: "performance", label: "Performance", icon: "zap" }]
                                  : [{ key: "saver", label: "Saver", icon: "leaf" }, { key: "balanced", label: "Balanced", icon: "activity" }]
                              currentKey: controlCenter.profileKeys[controlCenter.profileEnums.indexOf(PowerProfiles.profile)] || ""
                              onSelected: (key) => PowerProfiles.profile = controlCenter.profileEnums[controlCenter.profileKeys.indexOf(key)]
                          }
                      }

                      // Volume and brightness
                      ColumnLayout {
                          Layout.fillWidth: true
                          spacing: Style.space12
                          RowLayout {
                              Layout.fillWidth: true
                              spacing: Style.space12
                              Item {
                                  Layout.preferredWidth: 18; Layout.preferredHeight: 18
                                  activeFocusOnTab: true
                                  Accessible.role: Accessible.Button
                                  Accessible.name: controlCenter.volumeMuted ? "Unmute" : "Mute"
                                  Keys.onSpacePressed: muteSet.running = true
                                  Keys.onReturnPressed: muteSet.running = true
                                  Icon { anchors.fill: parent; name: controlCenter.volumeMuted ? "volume-x" : "volume-2"; size: 18; color: muteMouse.containsMouse ? Colors.fg : Colors.fgAlt }
                                  FocusRing { targetRadius: Style.radiusSm }
                                  MouseArea { id: muteMouse; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: muteSet.running = true }
                              }
                              ControlCenterSlider {
                                  Layout.fillWidth: true
                                  value: controlCenter.volumePercentage
                                  muted: controlCenter.volumeMuted
                                  Accessible.name: "Volume"
                                  onMoved: (v) => {
                                      controlCenter.volumePercentage = v
                                      volSet.command = ["wpctl", "set-volume", "@DEFAULT_SINK@", v + "%"]
                                      volSet.running = true
                                  }
                              }
                              Text {
                                  Layout.preferredWidth: 34
                                  text: Math.round(controlCenter.volumePercentage) + "%"
                                  horizontalAlignment: Text.AlignRight
                                  color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 12; font.features: { "tnum": 1 }
                              }
                          }
                          RowLayout {
                              Layout.fillWidth: true
                              spacing: Style.space12
                              Icon { name: "brightness"; size: 18; color: Colors.fgAlt }
                              ControlCenterSlider {
                                  Layout.fillWidth: true
                                  value: controlCenter.brightnessPercentage
                                  Accessible.name: "Brightness"
                                  onMoved: (v) => {
                                      controlCenter.brightnessPercentage = v
                                      brightSet.command = ["brightnessctl", "set", v + "%"]
                                      brightSet.running = true
                                  }
                              }
                              Text {
                                  Layout.preferredWidth: 34
                                  text: Math.round(controlCenter.brightnessPercentage) + "%"
                                  horizontalAlignment: Text.AlignRight
                                  color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 12; font.features: { "tnum": 1 }
                              }
                          }
                      }
                  }
              }
          }
      }
  }
''
