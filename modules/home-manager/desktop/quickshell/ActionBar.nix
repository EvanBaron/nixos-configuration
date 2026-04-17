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

  PanelWindow {
      id: bar

      property int processorPercentage:  0
      property real memoryGigabytes:   0
      property int volumePercentage:  0
      property bool volumeMuted: false
      property int batteryPercentage: 0
      property bool batteryCharging: false
      property var workspaceData:  []
      property bool calendarVisible: false
      property bool statisticsVisible: false

      anchors.top:    true
      anchors.left:   true
      anchors.right:  true
      implicitHeight: 30
      color: "transparent"

      WlrLayershell.namespace:     "action-bar"

      Process {
          id: toggleSwaync
          command: ["${pkgs.swaynotificationcenter}/bin/swaync-client", "-t", "-sw"]
      }

      function encodeSvg(paths, color) {
          var svg = "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='" + color + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>" + paths + "</svg>";
          return "data:image/svg+xml;charset=utf-8," + encodeURIComponent(svg);
      }

      function encodeColor(c) {
          var r = Math.round(c.r * 255).toString(16).padStart(2, '0');
          var g = Math.round(c.g * 255).toString(16).padStart(2, '0');
          var b = Math.round(c.b * 255).toString(16).padStart(2, '0');
          return "#" + r + g + b;
      }

      Rectangle {
          id: barBackground
          anchors.fill: parent
          color: Colors.bg
          opacity: 0.95
      }

      RowLayout {
          anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
          spacing: 12

          Row {
              spacing: 6
              Repeater {
                  model: bar.workspaceData
                  Rectangle {
                      width: 20; height: 4; radius: 2
                      anchors.verticalCenter: parent.verticalCenter
                      color: modelData.focused ? Colors.accent : (modelData.occupied ? Colors.fgAlt : Colors.highlight)
                      Behavior on color { ColorAnimation { duration: 150 } }
                  }
              }
          }

          Text {
              id: clock
              text: Qt.formatDateTime(new Date(), "HH:mm")
              color: Colors.fg; font.family: "Fira Sans"; font.pixelSize: 14; font.weight: Font.Medium
              Layout.alignment: Qt.AlignVCenter
              Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm") }
              MouseArea { anchors.fill: parent; onClicked: bar.calendarVisible = !bar.calendarVisible }
          }

          Item { Layout.fillWidth: true }

          Row {
              spacing: 12
              TrayPill {
                  iconSvg: "<path d='M12 2v10'/><path d='M18.4 6.6a9 9 0 1 1-12.77.04'/>"
                  valueText: bar.processorPercentage + "%"
                  accentColor: Colors.base05
                  onClicked: bar.statisticsVisible = !bar.statisticsVisible
              }
              TrayPill {
                  iconSvg: "<rect x='6' y='2' width='12' height='20' rx='2'/><path d='M10 7h4'/><path d='M10 12h4'/><path d='M10 17h4'/>"
                  valueText: bar.memoryGigabytes.toFixed(1) + "G"
                  accentColor: Colors.base05
              }
              TrayPill {
                  iconSvg: bar.batteryCharging ? "<path d='M13 22l-3-5h2l-3-5h7l-3 5h2l-3 5z'/>"
                         : bar.batteryPercentage < 20 ? "<rect x='2' y='7' width='16' height='10' rx='2'/><path d='M22 11v2'/>"
                         : "<rect x='2' y='7' width='16' height='10' rx='2'/><path d='M22 11v2'/>"
                  valueText: bar.batteryPercentage + "%"
                  accentColor: bar.batteryCharging ? Colors.base0B : (bar.batteryPercentage < 20 ? Colors.base08 : Colors.fg)
                  visible: true
              }
              TrayPill {
                  iconSvg: bar.volumeMuted ? "<path d='M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z'/><line x1='22' x2='16' y1='9' y2='15'/><line x1='16' x2='22' y1='9' y2='15'/>" : "<path d='M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z'/><path d='M16 9a5 5 0 0 1 0 6'/>"
                  valueText: bar.volumePercentage + "%"
                  accentColor: Colors.base05
              }
              TrayPill {
                  iconSvg: "<path d='M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9'/><path d='M13.73 21a2 2 0 0 1-3.46 0'/>"
                  valueText: ""
                  accentColor: Colors.accent
                  onClicked: toggleSwaync.running = true
              }
          }
      }
  }
''
