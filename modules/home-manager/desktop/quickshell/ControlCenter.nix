{
  pkgs,
  ...
}:

''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import Quickshell.Services.Mpris
  import Quickshell.Widgets
  import QtQuick
  import QtQuick.Layouts
  import "."

  PanelWindow {
      id: controlCenter

      anchors.top:   true
      anchors.left:  false
      anchors.right: false

      implicitWidth:  360
      implicitHeight: mainCol.implicitHeight + 24
      color: "transparent"
      visible: false

      WlrLayershell.namespace:     "controlcenter"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.margins.top:   30

      property real   volumePercentage:       50
      property bool   volumeMuted:      false
      property real   brightnessPercentage:       80
      property bool   wifiOn:       false
      property string wifiName:     ""
      property bool   btOn:         false
      property string btDevice:     ""
      property string powerProfile: "balanced"
      property string hostname:     ""
      property string uptime:       ""
      property string avatarEmoji:  ""

      Process {
          id: sysInfoProc
          command: ["sh", "-c", "hostname && uptime -p | sed 's/up //'"]
          stdout: SplitParser {
              onRead: data => {
                  if (!data) return
                  var lines = data.trim().split('\n')
                  if (lines.length >= 1) controlCenter.hostname = lines[0] || ""
                  if (lines.length >= 2) controlCenter.uptime = lines[1] || ""
              }
          }
          Component.onCompleted: running = true
      }
      Timer { interval: 60000; running: true; repeat: true; onTriggered: sysInfoProc.running = true }

      Process {
          id: wifiProc
          command: ["sh", "-c", "nmcli radio wifi && nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2"]
          stdout: SplitParser {
              onRead: data => {
                  if (!data) returnbase08
                  var lines = data.trim().split('\n')
                  controlCenter.wifiOn = lines[0] === "enabled"
                  controlCenter.wifiName = lines[1] || ""
              }
          }
          Component.onCompleted: running = true
      }
      Timer { interval: 5000; running: true; repeat: true; onTriggered: wifiProc.running = true }

      Process {
          id: btProc
          command: ["sh", "-c", "bluetoothctl show | grep 'Powered: yes' && bluetoothctl devices Connected | head -1"]
          stdout: SplitParser {
              onRead: data => {
                  if (!data) { controlCenter.btOn = false; controlCenter.btDevice = ""; return }
                  controlCenter.btOn = data.indexOf("Powered: yes") !== -1
                  var m = data.match(/Device [^ ]+ (.*)/)
                  controlCenter.btDevice = (m && m[1]) ? m[1] : ""
              }
          }
          Component.onCompleted: running = true
      }
      Timer { interval: 5000; running: true; repeat: true; onTriggered: btProc.running = true }

      Process {
          id: powerProc
          command: ["powerprofilesctl", "get"]
          stdout: SplitParser {
              onRead: data => {
                  if (data) controlCenter.powerProfile = data.trim()
              }
          }
          Component.onCompleted: running = true
      }
      Timer { interval: 10000; running: true; repeat: true; onTriggered: powerProc.running = true }

      function toggleWifi() {
          var cmd = controlCenter.wifiOn ? "nmcli radio wifi off" : "nmcli radio wifi on"
          wifiToggleProc.command = ["sh", "-c", cmd]
          wifiToggleProc.running = true
      }
      Process { id: wifiToggleProc; onRunningChanged: if(!running) wifiProc.running = true }

      function toggleBt() {
          var cmd = controlCenter.btOn ? "bluetoothctl power off" : "bluetoothctl power on"
          btToggleProc.command = ["sh", "-c", cmd]
          btToggleProc.running = true
      }
      Process { id: btToggleProc; onRunningChanged: if(!running) btProc.running = true }

      function cyclePower() {
          var profiles = ["performance", "power-saver", "balanced"];
          var idx = profiles.indexOf(controlCenter.powerProfile);
          var next = profiles[(idx + 1) % profiles.length];
          powerToggleProc.command = ["powerprofilesctl", "set", next];
          powerToggleProc.running = true;
      }
      Process { id: powerToggleProc; onRunningChanged: if(!running) powerProc.running = true }

      readonly property var player: { var v = Mpris.players.values; for(var i=0;i<v.length;i++){if(v[i].trackTitle&&v[i].trackTitle!=="")return v[i]}; return v.length>0?v[0]:null }
      property real mediaPos: 0
      property real mediaLen: 0
      FrameAnimation {
          running: controlCenter.player !== null
          onTriggered: {
              if (controlCenter.player) {
                  controlCenter.player.positionChanged()
                  controlCenter.mediaPos = controlCenter.player.position
                  controlCenter.mediaLen = controlCenter.player.length
              }
          }
      }
      readonly property bool hasMedia: player !== null

      readonly property string iconWifi:   "<path d='M5 12.55a11 11 0 0 1 14.08 0'/><path d='M1.42 9a16 16 0 0 1 21.16 0'/><path d='M8.53 16.11a6 6 0 0 1 6.95 0'/><circle cx='12' cy='20' r='1'/>"
      readonly property string iconBluetooth:     "<polyline points='6.5 6.5 17.5 17.5 12 23 12 1 17.5 6.5 6.5 17.5'/>"
      readonly property string iconZap:    "<path d='M13 2 3 14h9l-1 8 10-12h-9l1-8z'/>"
      readonly property string iconLeaf:   "<path d='M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 3.5 1 9.8a7 7 0 0 1-9 8.2Zm0 0v-5-2'/>"
      readonly property string iconActivity: "<polyline points='22 12 18 12 15 21 9 3 6 12 2 12'/>"
      readonly property string iconPower:  "<path d='M12 2v10'/><path d='M18.4 6.6a9 9 0 1 1-12.77.04'/>"
      readonly property string iconX:      "<path d='M18 6 6 18'/><path d='m6 6 12 12'/>"
      readonly property string iconMore:   "<circle cx='12' cy='12' r='1'/><circle cx='19' cy='12' r='1'/><circle cx='5' cy='12' r='1'/>"
      readonly property string iconPencil: "<path d='M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z'/><path d='m15 5 4 4'/>"
      readonly property string iconChevronRight:  "<path d='m9 18 6-6-6-6'/>"
      readonly property string iconVolume3:   "<path d='M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z'/><path d='M16 9a5 5 0 0 1 0 6'/><path d='M19.364 18.364a9 9 0 0 0 0-12.728'/>"
      readonly property string iconVolumeX:   "<path d='M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z'/><line x1='22' x2='16' y1='9' y2='15'/><line x1='16' x2='22' y1='9' y2='15'/>"
      readonly property string iconBrightness:    "<path d='M12 13v1'/><path d='M17 2a1 1 0 0 1 1 1v4a3 3 0 0 1-.6 1.8l-.6.8A4 4 0 0 0 16 12v8a2 2 0 0 1-2 2H10a2 2 0 0 1-2-2v-8a4 4 0 0 0-.8-2.4l-.6-.8A3 3 0 0 1 6 7V3a1 1 0 0 1 1-1z'/><path d='M6 6h12'/>"
      readonly property string iconPlay:   "<polygon points='6 3 20 12 6 21 6 3'/>"
      readonly property string iconPause:  "<rect x='14' y='4' width='4' height='16' rx='1'/><rect x='6' y='4' width='4' height='16' rx='1'/>"
      readonly property string iconSkipBack:  "<polygon points='19 20 9 12 19 4 19 20'/><line x1='5' x2='5' y1='19' y2='5'/>"
      readonly property string iconSkipForward:  "<polygon points='5 4 15 12 5 20 5 4'/><line x1='19' x2='19' y1='5' y2='19'/>"
      readonly property string iconMusic:  "<path d='M9 18V5l12-2v13'/><circle cx='6' cy='18' r='3'/><circle cx='18' cy='16' r='3'/>"
      readonly property string iconCheck:  "<path d='M20 6 9 17l-5-5'/>"
      readonly property string iconProcessor:   "<rect x='4' y='4' width='16' height='16' rx='2'/><rect x='8' y='8' width='8' height='8' rx='1'/><path d='M12 2v2'/><path d='M12 20v2'/><path d='M2 12h2'/><path d='M20 12h2'/>"
      readonly property string iconCalendar: "<path d='M8 2v4'/><path d='M16 2v4'/><rect width='18' height='18' x='3' y='4' rx='2'/><path d='M3 10h18'/><path d='M8 14h.01'/><path d='M12 14h.01'/><path d='M16 14h.01'/><path d='M8 18h.01'/><path d='M12 18h.01'/><path d='M16 18h.01'/>"
      readonly property string iconUser:   "<path d='M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2'/><circle cx='12' cy='7' r='4'/>"

      function encodeSvg(paths, color) {
          var svg = "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='" + color + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>" + paths + "</svg>";
          return "data:image/svg+xml;charset=utf-8," + encodeURIComponent(svg);
      }

      function encodeColor(c) {
          var r = Math.round(c.r * 255).toString(16).padStart(2, '0');
          var g = Math.round(c.g * 255).toString(16).padStart(2, '0');
          var b = Math.round(c.b * 255).toString(16).padStart(2, '0');
          return "#" + r + g + b;
      }

      Rectangle {
          anchors.fill: parent;
          color: Colors.bg;
          opacity: 0.98;
          radius: 12;
          border.color: Colors.border;
          border.width: 1;
      }

      onVisibleChanged: {
          if (visible) {
              mainCol.forceActiveFocus()
          }
      }

      ColumnLayout {
          id: mainCol
          anchors { fill: parent; margins: 12 }
          spacing: 12
          focus: true
          Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Escape) {
                  controlCenter.visible = false;
                  event.accepted = true;
              }
          }

          RowLayout {
              Layout.fillWidth: true; spacing: 10
              Rectangle { width: 42; height: 42; radius: 21; color: Colors.highlight
                  Text { anchors.centerIn: parent; text: controlCenter.avatarEmoji; font.pixelSize: 22 }
              }
              Column {
                  Text { text: controlCenter.hostname; color: Colors.fg; font.family: "Fira Sans"; font.pixelSize: 16; font.weight: Font.Medium }
                  Text { text: "up " + controlCenter.uptime; color: Colors.fgAlt; font.family: "Fira Sans"; font.pixelSize: 11 }
              }
              Item { Layout.fillWidth: true }
              Rectangle { width: 32; height: 32; radius: 8; color: Colors.highlight
                  Image { anchors.centerIn: parent; width: 16; height: 16; source: controlCenter.encodeSvg(controlCenter.iconX, controlCenter.encodeColor(Colors.fgAlt)) }
                  MouseArea { anchors.fill: parent; onClicked: controlCenter.visible = false }
              }
          }

          GridLayout {
              columns: 2; rowSpacing: 8; columnSpacing: 8
              ControlCenterToggle {
                  Layout.fillWidth: true;
                  active: true;
                  label: controlCenter.wifiName || "Wi-Fi";
                  iconSvg: controlCenter.iconWifi;
                  onToggled: {
                      spawnProc.command = ["sh", "-c", "NM_DMENU_MENU='${pkgs.wofi}/bin/wofi --dmenu' ${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu"];
                      spawnProc.running = true;
                      controlCenter.visible = false
                  }
              }
              ControlCenterToggle {
                  Layout.fillWidth: true;
                  active: true;
                  label: controlCenter.btDevice || "Bluetooth";
                  iconSvg: controlCenter.iconBluetooth;
                  onToggled: {
                      spawnProc.command = ["${pkgs.blueman}/bin/blueman-manager"];
                      spawnProc.running = true;
                      controlCenter.visible = false
                  }
              }
              ControlCenterToggle {
                  Layout.fillWidth: true;
                  Layout.columnSpan: 2;
                  active: true;
                  label: controlCenter.powerProfile.charAt(0).toUpperCase() + controlCenter.powerProfile.slice(1).replace("-", " ");
                  iconSvg: controlCenter.powerProfile === "performance" ? controlCenter.iconZap
                         : controlCenter.powerProfile === "balanced"    ? controlCenter.iconActivity
                         : controlCenter.iconLeaf;
                  onToggled: controlCenter.cyclePower()
              }
          }

          Process { id: spawnProc }

          ColumnLayout {
              Layout.fillWidth: true; spacing: 12
              RowLayout {
                  Layout.fillWidth: true; spacing: 10
                  Image { width: 18; height: 18; source: controlCenter.encodeSvg(controlCenter.volumeMuted ? controlCenter.iconVolumeX : controlCenter.iconVolume3, controlCenter.encodeColor(Colors.base06)) }
                  ControlCenterSlider {
                      Layout.fillWidth: true;
                      accentColor: Colors.base06;
                      value: controlCenter.volumePercentage;
                      onMoved: (v) => {
                          controlCenter.volumePercentage = v
                          volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_SINK@", v + "%"]
                          volSetProc.running = true
                      }
                  }
                  Text { width: 28; text: Math.round(controlCenter.volumePercentage) + "%"; color: Colors.fg; font.family: "Fira Sans"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
              }
              RowLayout {
                  Layout.fillWidth: true; spacing: 10
                  Image { width: 18; height: 18; source: controlCenter.encodeSvg(controlCenter.iconBrightness, controlCenter.encodeColor(Colors.base03)) }
                  ControlCenterSlider {
                      Layout.fillWidth: true;
                      accentColor: Colors.base03;
                      value: controlCenter.brightnessPercentage;
                      onMoved: (v) => {
                          controlCenter.brightnessPercentage = v
                          brightSetProc.command = ["brightnessctl", "set", v + "%"]
                          brightSetProc.running = true
                      }
                  }
                  Text { width: 28; text: Math.round(controlCenter.brightnessPercentage) + "%"; color: Colors.fg; font.family: "Fira Sans"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
              }
          }

          Process { id: volSetProc }
          Process { id: brightSetProc }

          Process {
              id: brightGetProc
              command: ["brightnessctl", "g"]
              stdout: SplitParser {
                  onRead: data => {
                      if (data) {
                          var curr = parseInt(data)
                          brightnessMaxProc.running = true
                          brightnessMaxProc.currentValue = curr
                      }
                  }
              }
              Component.onCompleted: running = true
          }
          Process {
              id: brightnessMaxProc
              property int currentValue: 0
              command: ["brightnessctl", "m"]
              stdout: SplitParser {
                  onRead: data => {
                      if (data) {
                          var max = parseInt(data)
                          if (max > 0) controlCenter.brightnessPercentage = Math.round((brightnessMaxProc.currentValue / max) * 100)
                      }
                  }
              }
          }
          Timer { interval: 5000; running: true; repeat: true; onTriggered: brightGetProc.running = true }

          Rectangle {
              Layout.fillWidth: true; height: controlCenter.hasMedia ? 100 : 0; radius: 10; color: Colors.highlight; clip: true
              Behavior on height { NumberAnimation { duration: 150 } }
              ColumnLayout {
                  anchors { fill: parent; margins: 10 }
                  spacing: 4
                  visible: controlCenter.hasMedia
                  Text { Layout.fillWidth: true; text: controlCenter.player ? controlCenter.player.trackTitle : ""; color: Colors.fg; font.pixelSize: 14; font.weight: Font.Medium; elide: Text.ElideRight }
                  Text { Layout.fillWidth: true; text: controlCenter.player ? controlCenter.player.trackArtist : ""; color: Colors.fgAlt; font.pixelSize: 12; elide: Text.ElideRight }
                  RowLayout {
                      Layout.fillWidth: true; spacing: 15
                      Item { Layout.fillWidth: true }
                      Image { width: 16; height: 16; source: controlCenter.encodeSvg(controlCenter.iconSkipBack, controlCenter.encodeColor(Colors.fg)); MouseArea { anchors.fill: parent; onClicked: controlCenter.player.previous() } }
                      Image { width: 24; height: 24; source: controlCenter.encodeSvg(controlCenter.player && controlCenter.player.playbackStatus === Mpris.Playing ? controlCenter.iconPause : controlCenter.iconPlay, controlCenter.encodeColor(Colors.fg)); MouseArea { anchors.fill: parent; onClicked: controlCenter.player.playPause() } }
                      Image { width: 16; height: 16; source: controlCenter.encodeSvg(controlCenter.iconSkipForward, controlCenter.encodeColor(Colors.fg)); MouseArea { anchors.fill: parent; onClicked: controlCenter.player.next() } }
                      Item { Layout.fillWidth: true }
                  }
              }
          }
      }
  }
''
