{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import Quickshell.Services.Pipewire
  import QtQuick
  import "."

  ShellRoot {
      id: root

      property int  volumePercentage:  0
      property bool volumeMuted:       false
      property int  batteryPercentage: 0
      property bool batteryCharging:   false
      property bool calendarVisible:   false
      property bool statisticsVisible: false
      property bool notificationsVisible: false
      property bool powerVisible: false
      property var  workspaceData:     []

      // One popup at a time: opening any of them closes the others.
      function only(which) {
          var next = {
              calendar:      which === "calendar"      && !root.calendarVisible,
              statistics:    which === "statistics"    && !root.statisticsVisible,
              controlCenter: which === "controlCenter" && !controlCenter.open,
              launcher:      which === "launcher"      && !appLauncher.open,
              notifications: which === "notifications" && !root.notificationsVisible,
              power:         which === "power"         && !root.powerVisible
          }
          root.calendarVisible   = next.calendar
          root.statisticsVisible = next.statistics
          controlCenter.open     = next.controlCenter
          appLauncher.open       = next.launcher
          root.notificationsVisible = next.notifications
          root.powerVisible      = next.power
      }
      function closeAll() { only("") }

      // Full-screen click catcher behind an open popup; `hole` is the popup's own rectangle.
      component DismissLayer: PanelWindow {
          id: layer
          property bool active: false
          property rect hole: Qt.rect(0, 0, 0, 0)
          anchors.top: true; anchors.left: true; anchors.right: true; anchors.bottom: true
          color: "transparent"
          visible: active
          WlrLayershell.layer: WlrLayer.Overlay
          WlrLayershell.exclusionMode: ExclusionMode.Ignore
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
          mask: Region {
              item: catcher
              Region { x: layer.hole.x; y: layer.hole.y; width: layer.hole.width; height: layer.hole.height; intersection: Intersection.Subtract }
          }
          Rectangle {
              id: catcher; anchors.fill: parent; color: "transparent"
              MouseArea { anchors.fill: parent; onClicked: root.closeAll() }
          }
      }

      CalendarPopup {
          id: calendarPopup
          open: root.calendarVisible
          onCloseRequested: root.calendarVisible = false
      }
      DismissLayer {
          WlrLayershell.namespace: "calendar-dismiss"
          active: root.calendarVisible
          hole: Qt.rect(calendarPopup.WlrLayershell.margins.left, calendarPopup.WlrLayershell.margins.top,
                        calendarPopup.implicitWidth, calendarPopup.implicitHeight)
      }

      StatisticsPopup { id: statisticsPopup; open: root.statisticsVisible }
      DismissLayer {
          id: statisticsDismiss
          WlrLayershell.namespace: "system-stats-dismiss"
          active: root.statisticsVisible
          hole: Qt.rect(statisticsDismiss.width - statisticsPopup.WlrLayershell.margins.right - statisticsPopup.implicitWidth,
                        statisticsPopup.WlrLayershell.margins.top, statisticsPopup.implicitWidth, statisticsPopup.implicitHeight)
      }

      AppLauncher { id: appLauncher; screen: Quickshell.screens[0] }
      DismissLayer { WlrLayershell.namespace: "niri-launcher-dismiss"; active: appLauncher.open }

      ControlCenter {
          id: controlCenter
          screen: Quickshell.screens[0]
          volumePercentage: root.volumePercentage
          volumeMuted: root.volumeMuted
      }
      DismissLayer { WlrLayershell.namespace: "controlcenter-dismiss"; active: controlCenter.open }

      NotificationToasts {}
      NotificationCenter {
          id: notificationCenter
          open: root.notificationsVisible
          onCloseRequested: root.notificationsVisible = false
      }
      Binding { target: Notifications; property: "centerOpen"; value: root.notificationsVisible }
      DismissLayer {
          id: notificationsDismiss
          WlrLayershell.namespace: "notification-center-dismiss"
          active: root.notificationsVisible
          hole: Qt.rect(notificationsDismiss.width - notificationCenter.WlrLayershell.margins.right - notificationCenter.implicitWidth,
                        notificationCenter.WlrLayershell.margins.top, notificationCenter.implicitWidth, notificationCenter.implicitHeight)
      }

      PowerMenu {
          id: powerMenu
          open: root.powerVisible
          onCloseRequested: root.powerVisible = false
      }
      DismissLayer { WlrLayershell.namespace: "power-menu-dismiss"; active: root.powerVisible }

      IpcHandler { target: "notifications"; function toggle(): void { root.only("notifications") } }
      IpcHandler {
          target: "power"
          function toggle(): void { root.only("power") }
          function open(): void   { if (!root.powerVisible) root.only("power") }
      }
      IpcHandler {
          target: "launcher"
          function toggle(): void { root.only("launcher") }
          function open(): void   { if (!appLauncher.open) root.only("launcher") }
          function close(): void  { appLauncher.open = false }
      }
      IpcHandler {
          target: "controlcenter"
          function toggle(): void { root.only("controlCenter") }
          // e.g. `quickshell ipc call controlcenter openPage wifi` (main | wifi | bluetooth)
          function openPage(name: string): void {
              if (!controlCenter.open) root.only("controlCenter")
              controlCenter.page = name
          }
      }
      IpcHandler { target: "calendar"; function toggle(): void { root.only("calendar") } }
      IpcHandler { target: "stats"; function toggle(): void { root.only("statistics") } }

      // Volume is pushed by PipeWire; battery is read from sysfs (no polling processes).
      PwObjectTracker { objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ] }
      readonly property var _sinkAudio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
      Binding { target: root; property: "volumePercentage"; value: root._sinkAudio ? Math.round(root._sinkAudio.volume * 100) : 0; when: root._sinkAudio !== null }
      Binding { target: root; property: "volumeMuted"; value: root._sinkAudio ? root._sinkAudio.muted : false; when: root._sinkAudio !== null }

      // OSD: volume and mic changes come from PipeWire; brightness from `quickshell ipc call osd brightness`
      // (run by the niri brightness binds). Changes in the first second after startup are ignored.
      Osd { id: osd; screen: Quickshell.screens[0] }
      LockScreen {}
      property bool _osdReady: false
      Timer { interval: 1000; running: true; onTriggered: root._osdReady = true }
      readonly property var _sourceAudio: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.audio : null
      Connections {
          target: root._sinkAudio
          function onVolumesChanged() { if (root._osdReady) osd.show("volume", root._sinkAudio.volume, root._sinkAudio.muted) }
          function onMutedChanged()   { if (root._osdReady) osd.show("volume", root._sinkAudio.volume, root._sinkAudio.muted) }
      }
      Connections {
          target: root._sourceAudio
          function onMutedChanged() { if (root._osdReady) osd.show("mic", 0, root._sourceAudio.muted) }
      }
      Process {
          id: brightnessQuery
          // e.g. "intel_backlight,backlight,12000,40%,30000"
          command: ["brightnessctl", "-m"]
          stdout: SplitParser {
              onRead: data => {
                  var f = data.split(",")
                  var cur = parseInt(f[2]), max = parseInt(f[4])
                  if (max > 0) osd.show("brightness", cur / max, false)
              }
          }
      }
      IpcHandler { target: "osd"; function brightness(): void { brightnessQuery.running = true } }

      // Network speed and fast sampling are only needed while the statistics popup is open.
      Binding { target: SystemStats; property: "detailed"; value: root.statisticsVisible }

      property string _batteryPath: ""
      Process {
          command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*; do [ -d \"$b\" ] && echo \"$b\" && exit; done"]
          stdout: SplitParser { onRead: data => root._batteryPath = data.trim() }
          Component.onCompleted: running = true
      }
      FileView {
          id: batCapacity
          path: root._batteryPath ? root._batteryPath + "/capacity" : ""
          onTextChanged: { var v = parseInt(text()); if (!isNaN(v)) root.batteryPercentage = v }
      }
      FileView {
          id: batStatus
          path: root._batteryPath ? root._batteryPath + "/status" : ""
          onTextChanged: { var t = text().trim(); root.batteryCharging = t === "Charging" }
      }
      Timer {
          interval: 30000; running: root._batteryPath !== ""; repeat: true
          onTriggered: { batCapacity.reload(); batStatus.reload() }
      }

      Process {
          id: workspaceStream
          command: ["niri", "msg", "--json", "event-stream"]
          running: true
          stdout: SplitParser {
              onRead: data => {
                  try {
                      var e = JSON.parse(data)
                      if (e.WorkspacesChanged) root.parseWorkspaces(e.WorkspacesChanged.workspaces)
                      else if (e.WorkspaceActivated || e.WorkspaceActiveWindowChanged) root.refreshWorkspaces()
                  } catch(_) {}
              }
          }
          onRunningChanged: if (!running) workspaceRestart.start()
      }
      Timer { id: workspaceRestart; interval: 1500; onTriggered: workspaceStream.running = true }

      // A query already in flight would swallow a second request; run once more when it ends.
      property bool _workspaceQueryPending: false
      function refreshWorkspaces() {
          if (workspaceQuery.running) root._workspaceQueryPending = true
          else workspaceQuery.running = true
      }
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
          onRunningChanged: if (!running && root._workspaceQueryPending) { root._workspaceQueryPending = false; running = true }
          Component.onCompleted: running = true
      }

      // Every niri workspace on every output; each ActionBar keeps its own monitor's slice.
      function parseWorkspaces(list) {
          if (!Array.isArray(list)) return
          var a = []
          for (var i = 0; i < list.length; i++) {
              var w = list[i]
              a.push({ id: w.id,
                       idx: w.idx !== undefined ? w.idx : i+1,
                       output: w.output || "",
                       active: !!w.is_active,
                       focused: !!w.is_focused,
                       occupied: w.active_window_id != null })
          }
          a.sort(function(x, y) { return x.output === y.output ? x.idx - y.idx : (x.output < y.output ? -1 : 1) })
          root.workspaceData = a
      }

      // True when the given monitor's active workspace has no windows.
      function desktopEmpty(output) {
          for (var i = 0; i < root.workspaceData.length; i++) {
              var w = root.workspaceData[i]
              if (w.output === output && w.active) return !w.occupied
          }
          return false
      }

      Variants {
          model: Quickshell.screens
          Desk {
              required property var modelData
              screen: modelData
              desktopEmpty: root.desktopEmpty(modelData.name)
          }
      }
      // cava, position polling and lyrics run only while some monitor shows its desk.
      readonly property bool anyDesktopEmpty: root.workspaceData.some(w => w.active && !w.occupied)
      Binding { target: DeskAudio; property: "wanted"; value: root.anyDesktopEmpty }
      Binding { target: NowPlaying; property: "active"; value: root.anyDesktopEmpty }

      Variants {
          model: Quickshell.screens
          ActionBar {
              required property var modelData
              screen: modelData
              processorPercentage: Math.round(SystemStats.cpuPercentage)
              memoryGigabytes:     SystemStats.memoryGigabytes
              volumePercentage:    root.volumePercentage
              volumeMuted:         root.volumeMuted
              batteryPercentage:   root.batteryPercentage
              batteryCharging:     root.batteryCharging
              hasBattery:          root._batteryPath !== ""
              workspaceData:       root.workspaceData
              calendarOpen:        root.calendarVisible
              statisticsOpen:      root.statisticsVisible
              controlCenterOpen:   controlCenter.open
              onToggleCalendar:      root.only("calendar")
              onToggleStatistics:    root.only("statistics")
              onToggleControlCenter: root.only("controlCenter")
              notificationsOpen:     root.notificationsVisible
              powerOpen:             root.powerVisible
              onToggleNotifications: root.only("notifications")
              onTogglePower:         root.only("power")
          }
      }
  }
''
