{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import QtQuick
  import QtQuick.Layouts
  import "."

  PanelWindow {
      id: statisticsPopup

      property bool open: false

      anchors.top: true
      anchors.right: true
      implicitWidth: 360
      implicitHeight: mainColumn.implicitHeight + Style.space12 * 2
      color: "transparent"
      visible: surface.shown

      WlrLayershell.namespace:     "statistics-popup"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.margins.top:   Style.popupTop
      WlrLayershell.margins.right: Style.space6

      property real loadAverage1:  0
      property real loadAverage5:  0
      property real loadAverage15: 0
      property string uptimeString: ""
      property string hostname: ""
      property string kernelVersion: ""

      // History: 20 real samples, one every 2s, kept while closed so graphs are full on open.
      readonly property int historyLength: 20
      property var cpuHistory: []
      property var temperatureHistory: []
      property var memoryHistory: []
      function pushHistory(arr, val) {
          var a = arr.slice(arr.length >= historyLength ? 1 : 0)
          a.push(val)
          return a
      }
      Timer {
          interval: 2000; running: true; repeat: true; triggeredOnStart: true
          onTriggered: {
              statisticsPopup.cpuHistory = statisticsPopup.pushHistory(statisticsPopup.cpuHistory, SystemStats.cpuPercentage)
              // 20–100 °C mapped onto the 0–100 graph range
              statisticsPopup.temperatureHistory = statisticsPopup.pushHistory(statisticsPopup.temperatureHistory, (SystemStats.cpuTemperature - 20) * 1.25)
              statisticsPopup.memoryHistory = statisticsPopup.pushHistory(statisticsPopup.memoryHistory, SystemStats.memoryPercentage)
          }
      }

      FileView {
          id: loadAverageFile; path: "/proc/loadavg"
          onTextChanged: {
              var p = text().trim().split(/\s+/)
              statisticsPopup.loadAverage1  = parseFloat(p[0]) || 0
              statisticsPopup.loadAverage5  = parseFloat(p[1]) || 0
              statisticsPopup.loadAverage15 = parseFloat(p[2]) || 0
          }
      }
      Timer { interval: 3000; running: statisticsPopup.open; repeat: true; triggeredOnStart: true; onTriggered: loadAverageFile.reload() }

      FileView {
          id: uptimeFile; path: "/proc/uptime"
          onTextChanged: {
              var secs = Math.floor(parseFloat(text()) || 0)
              var d = Math.floor(secs / 86400), h = Math.floor(secs % 86400 / 3600), m = Math.floor(secs % 3600 / 60)
              statisticsPopup.uptimeString = d > 0 ? (d + "d " + h + "h " + m + "m") : h > 0 ? (h + "h " + m + "m") : (m + "m")
          }
      }
      Timer { interval: 30000; running: statisticsPopup.open; repeat: true; triggeredOnStart: true; onTriggered: uptimeFile.reload() }

      FileView { id: hostFile; path: "/proc/sys/kernel/hostname"; onTextChanged: statisticsPopup.hostname = text().trim() }
      FileView { id: kernelFile; path: "/proc/sys/kernel/osrelease"; onTextChanged: statisticsPopup.kernelVersion = text().trim().split("-")[0] }

      // Disks: real block devices, largest first, at most three.
      property var diskList: []
      Process {
          id: diskProcess
          command: ["sh", "-c", "LC_ALL=C df -h --output=target,size,used,pcent -x tmpfs -x devtmpfs -x efivarfs -x overlay -x squashfs -x fuse.sshfs -x fuse.gvfsd-fuse -x fuse.portal 2>/dev/null | awk 'NR>1' | sort -k2 -h -r | head -3"]
          property var _rows: []
          stdout: SplitParser {
              onRead: data => {
                  var p = data.trim().split(/\s+/)
                  if (p.length >= 4) diskProcess._rows.push({ mount: p[0], total: p[1], used: p[2], percentage: parseInt(p[3]) || 0 })
              }
          }
          onRunningChanged: {
              if (running) _rows = []
              else statisticsPopup.diskList = _rows.slice()
          }
      }
      // Poll slowly while closed so the disk card is already there when the popup opens.
      Timer { interval: statisticsPopup.open ? 15000 : 120000; running: true; repeat: true; triggeredOnStart: true; onTriggered: diskProcess.running = true }

      component Label: Text {
          color: Colors.fgAlt
          font.family: Style.fontFamily; font.pixelSize: 11; font.weight: Font.Medium
      }
      component Value: Text {
          color: Colors.fg
          font.family: Style.fontFamily; font.pixelSize: 16; font.weight: Font.Medium
          font.features: { "tnum": 1 }
      }
      component Card: Rectangle {
          radius: Style.radiusMd
          color: Colors.bgAlt
      }

      PopupSurface {
          id: surface
          anchors.fill: parent
          open: statisticsPopup.open

          ColumnLayout {
              id: mainColumn
              anchors { left: parent.left; right: parent.right; top: parent.top }
              spacing: Style.space8

              // Graphs
              Card {
                  Layout.fillWidth: true
                  implicitHeight: graphCol.implicitHeight
                  ColumnLayout {
                      id: graphCol
                      anchors { left: parent.left; right: parent.right; leftMargin: Style.space12; rightMargin: Style.space12 }
                      spacing: 0
                      Repeater {
                          model: [
                              { icon: "cpu", label: "CPU", key: "cpu" },
                              { icon: "thermometer", label: "Temp", key: "temp" },
                              { icon: "memory", label: "Memory", key: "mem" }
                          ]
                          Item {
                              required property var modelData
                              required property int index
                              Layout.fillWidth: true
                              implicitHeight: Style.rowHeight
                              Rectangle { visible: index > 0; width: parent.width; height: 1; color: Colors.border }
                              RowLayout {
                                  anchors.fill: parent
                                  spacing: Style.space12
                                  Rectangle {
                                      Layout.preferredWidth: Style.iconTile; Layout.preferredHeight: Style.iconTile; radius: Style.radiusSm
                                      color: Colors.highlight
                                      Icon { anchors.centerIn: parent; name: modelData.icon; size: 16; color: Colors.fg }
                                  }
                                  ColumnLayout {
                                      Layout.preferredWidth: 64
                                      spacing: Style.space2
                                      Text {
                                          text: modelData.key === "cpu"  ? Math.round(SystemStats.cpuPercentage) + "%"
                                              : modelData.key === "temp" ? (SystemStats.cpuTemperature > 0 ? Math.round(SystemStats.cpuTemperature) + "°" : "--°")
                                              : SystemStats.memoryGigabytes.toFixed(1) + "G"
                                          color: modelData.key === "temp" && SystemStats.cpuTemperature > 80 ? Colors.statusWarning : Colors.fg
                                          font.family: Style.fontFamily; font.pixelSize: 15; font.weight: Font.Medium; font.features: { "tnum": 1 }
                                      }
                                      Label { text: modelData.label }
                                  }
                                  Sparkline {
                                      Layout.fillWidth: true
                                      Layout.preferredHeight: 32
                                      values: modelData.key === "cpu" ? statisticsPopup.cpuHistory
                                            : modelData.key === "temp" ? statisticsPopup.temperatureHistory
                                            : statisticsPopup.memoryHistory
                                      lineColor: modelData.key === "cpu" ? Colors.chartCpu
                                               : modelData.key === "temp" ? Colors.chartTemp
                                               : Colors.chartMemory
                                      active: statisticsPopup.open
                                  }
                              }
                          }
                      }
                  }
              }

              // Network
              RowLayout {
                  Layout.fillWidth: true
                  spacing: Style.space8
                  Repeater {
                      model: [
                          { label: "Download", icon: "download", up: false },
                          { label: "Upload", icon: "upload", up: true }
                      ]
                      Card {
                          required property var modelData
                          Layout.fillWidth: true
                          implicitHeight: netCol.implicitHeight + Style.space12 * 2
                          ColumnLayout {
                              id: netCol
                              anchors { fill: parent; margins: Style.space12 }
                              spacing: Style.space4
                              Row {
                                  spacing: Style.space4
                                  Icon { anchors.verticalCenter: parent.verticalCenter; name: modelData.icon; size: 12; color: modelData.up ? Colors.netUpload : Colors.statusOk }
                                  Label { text: modelData.label }
                              }
                              Value { text: SystemStats.formatNetworkSpeed(modelData.up ? SystemStats.transmitKilobytes : SystemStats.receiveKilobytes) }
                          }
                      }
                  }
              }

              // Disks
              Card {
                  Layout.fillWidth: true
                  visible: statisticsPopup.diskList.length > 0
                  implicitHeight: diskCol.implicitHeight + Style.space12 * 2
                  ColumnLayout {
                      id: diskCol
                      anchors { fill: parent; margins: Style.space12 }
                      spacing: Style.space8
                      Repeater {
                          model: statisticsPopup.diskList
                          ColumnLayout {
                              required property var modelData
                              Layout.fillWidth: true
                              spacing: Style.space8
                              RowLayout {
                                  Layout.fillWidth: true
                                  spacing: Style.space6
                                  Icon { name: "disk"; size: 14; color: Colors.fgAlt }
                                  Text { text: modelData.mount; color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 13; font.weight: Font.Medium }
                                  Item { Layout.fillWidth: true }
                                  Text {
                                      text: modelData.used + " of " + modelData.total + " · " + modelData.percentage + "%"
                                      color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 12; font.features: { "tnum": 1 }
                                  }
                              }
                              Rectangle {
                                  Layout.fillWidth: true
                                  Layout.preferredHeight: 4; radius: Style.radiusXs
                                  color: Colors.highlight
                                  Rectangle {
                                      height: parent.height; radius: Style.radiusXs
                                      width: statisticsPopup.open ? parent.width * Math.min(modelData.percentage, 100) / 100 : 0
                                      color: modelData.percentage >= 95 ? Colors.statusCritical
                                           : modelData.percentage >= 80 ? Colors.statusWarning
                                           : Colors.fgAlt
                                      Behavior on width { NumberAnimation { duration: Style.durData; easing.type: Style.easeOut } }
                                  }
                              }
                          }
                      }
                  }
              }

              // Load and uptime
              RowLayout {
                  Layout.fillWidth: true
                  spacing: Style.space8
                  Card {
                      Layout.fillWidth: true
                      implicitHeight: loadCol.implicitHeight + Style.space12 * 2
                      ColumnLayout {
                          id: loadCol
                          anchors { fill: parent; margins: Style.space12 }
                          spacing: Style.space4
                          Label { text: "Load average" }
                          Row {
                              spacing: Style.space12
                              Repeater {
                                  model: [
                                      { v: statisticsPopup.loadAverage1, l: "1 min" },
                                      { v: statisticsPopup.loadAverage5, l: "5 min" },
                                      { v: statisticsPopup.loadAverage15, l: "15 min" }
                                  ]
                                  Column {
                                      required property var modelData
                                      spacing: Style.space2
                                      Value { text: modelData.v.toFixed(2) }
                                      Text { text: modelData.l; color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 11 }
                                  }
                              }
                          }
                      }
                  }
                  Card {
                      Layout.fillWidth: true
                      Layout.fillHeight: true
                      implicitHeight: upCol.implicitHeight + Style.space12 * 2
                      ColumnLayout {
                          id: upCol
                          anchors { fill: parent; margins: Style.space12 }
                          spacing: Style.space4
                          Label { text: "Uptime" }
                          Value { text: statisticsPopup.uptimeString }
                          Text {
                              Layout.fillWidth: true
                              text: statisticsPopup.hostname + " · " + statisticsPopup.kernelVersion
                              elide: Text.ElideRight
                              color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 12
                          }
                      }
                  }
              }
          }
      }

  }
''
