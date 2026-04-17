{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import QtQuick
  import "."

  ShellRoot {
      id: root

      property int  processorPercentage:  0
      property real memoryGigabytes:   0
      property int  volumePercentage:  0
      property bool volumeMuted:    false
      property int  batteryPercentage:   0
      property bool batteryCharging: false
      property bool calendarVisible:   false
      property bool statisticsVisible: false
      property var  workspaceData:  []

      property int _lastIdle:  0
      property int _lastTotal: 0

      PanelWindow {
          id: calendarDismissWindow
          anchors.top: true; anchors.left: true; anchors.right: true; anchors.bottom: true
          color: "transparent"
          visible: root.calendarVisible
          WlrLayershell.layer: WlrLayer.Overlay
          WlrLayershell.exclusionMode: ExclusionMode.Ignore
          WlrLayershell.namespace: "calendar-dismiss"
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
          mask: Region {
              item: calendarDismissMask
              Region {
                  x:      calendarPopup.WlrLayershell.margins.left
                  y:      calendarPopup.WlrLayershell.margins.top
                  width:  calendarPopup.implicitWidth
                  height: calendarPopup.implicitHeight
                  intersection: Intersection.Subtract
              }
          }
          Rectangle { id: calendarDismissMask; anchors.fill: parent; color: "transparent"
              MouseArea { anchors.fill: parent; onClicked: root.calendarVisible = false } }
      }

      CalendarPopup { id: calendarPopup; visible: root.calendarVisible }

      PanelWindow {
          id: statisticsDismissWindow
          anchors.top:true; anchors.left:true; anchors.right:true; anchors.bottom:true
          color:"transparent"; visible:root.statisticsVisible
          WlrLayershell.layer:WlrLayer.Overlay; WlrLayershell.exclusionMode:WlrLayershell.Ignore
          WlrLayershell.namespace:"system-stats-dismiss"; WlrLayershell.keyboardFocus:WlrKeyboardFocus.None
          mask: Region {
              item: statisticsDismissMask
              Region {
                  x:      statisticsDismissWindow.width - statisticsPopup.WlrLayershell.margins.right - statisticsPopup.implicitWidth
                  y:      statisticsPopup.WlrLayershell.margins.top
                  width:  statisticsPopup.implicitWidth
                  height: statisticsPopup.implicitHeight
                  intersection: Intersection.Subtract
              }
          }
          Rectangle { id: statisticsDismissMask; anchors.fill:parent; color:"transparent"
              MouseArea { anchors.fill:parent; onClicked:root.statisticsVisible=false } }
      }

      StatisticsPopup { id:statisticsPopup; visible:root.statisticsVisible }

      AppLauncher { id: appLauncher; screen: Quickshell.screens[0] }

      PanelWindow {
          id: launcherDismissWindow
          anchors.top: true; anchors.left: true; anchors.right: true; anchors.bottom: true
          color: "transparent"
          visible: appLauncher.visible
          WlrLayershell.layer: WlrLayer.Overlay
          WlrLayershell.exclusionMode: ExclusionMode.Ignore
          WlrLayershell.namespace: "niri-launcher-dismiss"
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
          Rectangle { anchors.fill: parent; color: "transparent"
              MouseArea { anchors.fill: parent; onClicked: appLauncher.visible = false } }
      }

      IpcHandler {
          target: "launcher"
          function toggle(): void { appLauncher.visible = !appLauncher.visible }
          function open(): void   { appLauncher.visible = true  }
          function close(): void  { appLauncher.visible = false }
      }

      Process {
          id: cpuProcess
          command: ["sh", "-c", "head -1 /proc/stat"]
          stdout: SplitParser {
              onRead: data => {
                  if (!data) return
                  var p = data.trim().split(/\s+/)
                  var idle  = parseInt(p[4]) + parseInt(p[5])
                  var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                  if (root._lastTotal > 0 && total > root._lastTotal)
                      root.processorPercentage = Math.round(100 * (1 - (idle - root._lastIdle) / (total - root._lastTotal)))
                  root._lastIdle  = idle; root._lastTotal = total
              }
          }
          Component.onCompleted: running = true
      }
      Timer { interval: 2000; running: true; repeat: true; onTriggered: cpuProcess.running = true }

      Process {
          id: ramProcess
          command: ["sh", "-c", "free | grep Mem"]
          stdout: SplitParser {
              onRead: data => {
                  if (!data) return
                  var p = data.trim().split(/\s+/)
                  root.memoryGigabytes = (parseInt(p[2]) || 0) / 1048576.0
              }
          }
          Component.onCompleted: running = true
      }
      Timer { interval: 3000; running: true; repeat: true; onTriggered: ramProcess.running = true }

      Process {
          id: volProc
          command: ["sh", "-c", "wpctl get-volume @DEFAULT_SINK@"]
          stdout: SplitParser {
              onRead: data => {
                  if (!data) return
                  root.volumeMuted = data.indexOf("MUTED") !== -1
                  var m = data.match(/([\d.]+)/)
                  if (m) root.volumePercentage = Math.round(parseFloat(m[1]) * 100)
              }
          }
          Component.onCompleted: running = true
      }
      Timer { interval: 1000; running: true; repeat: true; onTriggered: volProc.running = true }

      Process {
          id: batProc
          command: ["sh", "-c", "upower -i $(upower -e | grep 'BAT' | head -n 1) | grep -E 'percentage|state'"]
          stdout: SplitParser {
              onRead: data => {
                  if (!data) return
                  var lines = data.split('\n')
                  for (var i = 0; i < lines.length; i++) {
                      var l = lines[i].trim()
                      if (l.indexOf("percentage:") !== -1) {
                          var m = l.match(/(\d+)%/)
                          if (m) root.batteryPercentage = parseInt(m[1])
                      } else if (l.indexOf("state:") !== -1) {
                          root.batteryCharging = l.indexOf("charging") !== -1 && l.indexOf("discharging") === -1
                      }
                  }
              }
          }
          Component.onCompleted: running = true
      }
      Timer { interval: 10000; running: true; repeat: true; onTriggered: batProc.running = true }

      Process {
          id: workspaceStream
          command: ["niri", "msg", "--json", "event-stream"]
          running: true
          stdout: SplitParser {
              onRead: data => {
                  try {
                      var e = JSON.parse(data)
                      if (e.WorkspacesChanged)       root.parseWorkspaces(e.WorkspacesChanged.workspaces)
                      else if (e.WorkspaceActivated) workspaceQuery.running = true
                  } catch(_) {}
              }
          }
          onRunningChanged: if (!running) workspaceRestart.start()
      }
      Timer { id: workspaceRestart; interval: 1500; onTriggered: workspaceStream.running = true }

      Process {
          id: workspaceQuery
          command: ["niri", "msg", "--json", "workspaces"]
          stdout: SplitParser {
              onRead: data => {
                  try {
                      var p = JSON.parse(data)
                      var list = (p.Ok && p.Ok.Workspaces) ? p.Ok.Workspaces
                               : Array.isArray(p) ? p
                               : (p.Ok && Array.isArray(p.Ok)) ? p.Ok : null
                      if (list) root.parseWorkspaces(list)
                  } catch(_) {}
              }
          }
          Component.onCompleted: running = true
      }

      function parseWorkspaces(list) {
          if (!Array.isArray(list)) return
          var a = []
          for (var i = 0; i < list.length; i++) {
              var w = list[i]
              a.push({ idx: w.idx !== undefined ? w.idx : i+1,
                       focused: !!w.is_focused,
                       occupied: w.active_window_id != null })
          }
          a.sort(function(x, y) { return x.idx - y.idx })
          root.workspaceData = a
      }

      Variants {
          model: Quickshell.screens
          NotificationPopup { required property var modelData; screen: modelData }
      }

      ControlCenter { 
          id: controlCenter; 
          screen: Quickshell.screens[0] 
          volumePercentage: root.volumePercentage
          volumeMuted: root.volumeMuted
      }

      PanelWindow {
          id: controlCenterDismissWindow
          anchors.top: true; anchors.left: true; anchors.right: true; anchors.bottom: true
          color: "transparent"; visible: controlCenter.visible
          WlrLayershell.layer: WlrLayer.Overlay
          WlrLayershell.exclusionMode: ExclusionMode.Ignore
          WlrLayershell.namespace: "controlcenter-dismiss"
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
          Rectangle { anchors.fill: parent; color: "transparent"
              MouseArea { anchors.fill: parent; onClicked: controlCenter.visible = false } }
      }

      IpcHandler { target: "controlcenter"; function toggle(): void { controlCenter.visible = !controlCenter.visible } }
      IpcHandler { target: "calendar"; function toggle(): void { root.calendarVisible = !root.calendarVisible } }
      IpcHandler { target: "stats"; function toggle(): void { root.statisticsVisible = !root.statisticsVisible } }

      Variants {
          model: Quickshell.screens
          ActionBar {
              required property var modelData
              screen:     modelData
              processorPercentage:     root.processorPercentage
              memoryGigabytes:      root.memoryGigabytes
              volumePercentage:     root.volumePercentage
              volumeMuted:    root.volumeMuted
              batteryPercentage:     root.batteryPercentage
              batteryCharging:       root.batteryCharging
              workspaceData:     root.workspaceData
              calendarVisible:   root.calendarVisible
              onCalendarVisibleChanged:   root.calendarVisible   = calendarVisible
              statisticsVisible: root.statisticsVisible
              onStatisticsVisibleChanged: root.statisticsVisible = statisticsVisible
          }
      }
  }
''
