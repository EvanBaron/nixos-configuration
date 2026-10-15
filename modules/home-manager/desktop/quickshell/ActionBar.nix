{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import QtQuick
  import QtQuick.Layouts
  import "."

  PanelWindow {
      id: bar

      property int  processorPercentage: 0
      property real memoryGigabytes:     0
      property int  volumePercentage:    0
      property bool volumeMuted:         false
      property int  batteryPercentage:   0
      property bool batteryCharging:     false
      property var  workspaceData:       []
      property bool calendarOpen:        false
      property bool statisticsOpen:      false
      property bool controlCenterOpen:   false

      signal toggleCalendar()
      signal toggleStatistics()
      signal toggleControlCenter()
      signal toggleNotifications()
      signal togglePower()
      property bool notificationsOpen: false
      property bool powerOpen:         false

      anchors.top:    true
      anchors.left:   true
      anchors.right:  true
      implicitHeight: Style.barHeight
      color: "transparent"

      WlrLayershell.namespace: "action-bar"

      ListModel { id: workspaceModel }
      onWorkspaceDataChanged: syncWorkspaces()
      Component.onCompleted: syncWorkspaces()
      function syncWorkspaces() {
          var name = bar.screen ? bar.screen.name : ""
          var mine = workspaceData.filter(function(w) { return w.output === name })
          // Unknown output names (e.g. a nested session): show everything rather than nothing.
          if (mine.length === 0) mine = workspaceData
          for (var i = 0; i < mine.length; i++) {
              var w = mine[i]
              var row = { wsId: w.id, idx: w.idx, active: w.active, focused: w.focused, occupied: w.occupied }
              if (i < workspaceModel.count) {
                  for (var k in row)
                      if (workspaceModel.get(i)[k] !== row[k]) workspaceModel.setProperty(i, k, row[k])
              } else {
                  workspaceModel.append(row)
              }
          }
          if (workspaceModel.count > mine.length)
              workspaceModel.remove(mine.length, workspaceModel.count - mine.length)
      }

      Process { id: spawn }
      function run(cmd) { spawn.command = cmd; spawn.running = true }

      readonly property string batteryTone: batteryCharging ? "ok"
                                          : batteryPercentage <= 15 ? "critical"
                                          : batteryPercentage <= 30 ? "warning"
                                          : "normal"

      Rectangle {
          anchors.fill: parent
          color: Colors.bg
          opacity: Style.opacitySurface
      }

      RowLayout {
          anchors { fill: parent; leftMargin: Style.space12; rightMargin: Style.space12 }
          spacing: Style.space12

          // Workspaces on this monitor: the active dash widens to 32px (accent when it is the
          // focused one, fg on another monitor); click to focus. The model is updated in place
          // so the dashes survive niri events and their width/colour Behaviors run.
          Row {
              spacing: Style.space6
              Layout.alignment: Qt.AlignVCenter
              Repeater {
                  model: workspaceModel
                  Item {
                      id: wsItem
                      required property int idx
                      required property bool active
                      required property bool focused
                      required property bool occupied
                      width: dash.width; height: Style.barHeight
                      Rectangle {
                          id: dash
                          anchors.verticalCenter: parent.verticalCenter
                          width: wsItem.active ? 32 : 20
                          height: 4; radius: Style.radiusXs
                          color: wsItem.active ? (wsItem.focused ? Colors.accent : Colors.fg)
                               : wsItem.occupied ? Colors.fgAlt
                               : wsMouse.containsMouse ? Colors.borderStrong
                               : Colors.highlight
                          Behavior on width { NumberAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
                          Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
                      }
                      MouseArea {
                          id: wsMouse
                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor
                          onClicked: bar.run(["niri", "msg", "action", "focus-workspace", String(wsItem.idx)])
                      }
                  }
              }
          }

          Item {
              implicitWidth: clock.implicitWidth + 12
              implicitHeight: 22
              Layout.alignment: Qt.AlignVCenter
              Rectangle {
                  anchors.fill: parent
                  radius: Style.radiusSm
                  color: Colors.bgAlt
                  opacity: clockMouse.containsMouse || bar.calendarOpen ? 1 : 0
                  Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
              }
              Text {
                  id: clock
                  anchors.centerIn: parent
                  text: Qt.formatDateTime(new Date(), "HH:mm")
                  color: Colors.fg
                  font.family: Style.fontFamily; font.pixelSize: 14; font.weight: Font.Medium
                  font.features: { "tnum": 1 }
                  // Only HH:mm is shown; a short interval still catches up quickly after resume.
                  Timer { interval: 10000; running: true; repeat: true; onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm") }
              }
              MouseArea {
                  id: clockMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: bar.toggleCalendar()
              }
          }

          Item { Layout.fillWidth: true }

          Row {
              spacing: Style.space4
              Layout.alignment: Qt.AlignVCenter

              TrayPill {
                  iconName: "cpu"
                  valueText: bar.processorPercentage + "%"
                  accessibleName: "CPU " + bar.processorPercentage + " percent, open statistics"
                  active: bar.statisticsOpen
                  onClicked: bar.toggleStatistics()
              }
              TrayPill {
                  iconName: "memory-bar"
                  valueText: bar.memoryGigabytes.toFixed(1) + "G"
                  accessibleName: "Memory " + bar.memoryGigabytes.toFixed(1) + " gigabytes, open statistics"
                  active: bar.statisticsOpen
                  onClicked: bar.toggleStatistics()
              }
              TrayPill {
                  iconName: bar.batteryCharging ? "battery-charging"
                          : bar.batteryPercentage <= 15 ? "battery-warning"
                          : "battery"
                  valueText: bar.batteryPercentage + "%"
                  tone: bar.batteryTone
                  accessibleName: "Battery " + bar.batteryPercentage + " percent" + (bar.batteryCharging ? ", charging" : "")
                  active: bar.controlCenterOpen
                  onClicked: bar.toggleControlCenter()
              }
              TrayPill {
                  iconName: bar.volumeMuted ? "volume-x" : "volume-2"
                  valueText: bar.volumePercentage + "%"
                  accessibleName: "Volume " + bar.volumePercentage + " percent" + (bar.volumeMuted ? ", muted" : "")
                  active: bar.controlCenterOpen
                  onClicked: bar.toggleControlCenter()
                  onScrolled: (steps) => bar.run(["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_SINK@", (steps > 0 ? "5%+" : "5%-")])
              }
              TrayPill {
                  iconName: Notifications.dnd ? "bell-off" : "bell"
                  tone: Notifications.dnd ? "muted" : "normal"
                  badge: !Notifications.dnd && Notifications.unreadCount > 0
                  active: bar.notificationsOpen
                  accessibleName: Notifications.unreadCount + " unread notifications" + (Notifications.dnd ? ", do not disturb" : "")
                  onClicked: bar.toggleNotifications()
              }
              TrayPill {
                  iconName: "power"
                  active: bar.powerOpen
                  accessibleName: "Power menu"
                  onClicked: bar.togglePower()
              }
          }
      }
  }
''
