{ ... }:
''
  pragma Singleton
  import Quickshell
  import Quickshell.Io
  import QtQuick

  QtObject {
      id: root

      property real cpuPercentage:  0
      property real cpuTemperature: 0
      property real memoryPercentage:  0
      property real memoryGigabytes:   0
      property real receiveKilobytes:    0
      property real transmitKilobytes:    0

      property int  _cpuPrevIdle:  0
      property int  _cpuPrevTotal: 0
      property real _netPrevRx:    0
      property real _netPrevTx:    0
      property real _netPrevTs:    0

      // ── CPU ───────────────────────────────────────────────────────────
      property var _cpuFileView: FileView {
          id: cpuFileView; path: "/proc/stat"
          watchChanges: true
          onFileChanged: reload()
          onTextChanged: {
              var t = text()
              var line = t.split("\n")[0]
              var f = line.trim().split(/\s+/)
              if (f.length < 8) return
              var idle  = parseInt(f[4]) + parseInt(f[5])
              var total = 0
              for (var i = 1; i <= 7; i++) total += parseInt(f[i])
              var dIdle  = idle  - root._cpuPrevIdle
              var dTotal = total - root._cpuPrevTotal
              if (root._cpuPrevTotal > 0 && dTotal > 0)
                  root.cpuPercentage = Math.max(0, Math.min(100, Math.round(100 * (1 - dIdle / dTotal))))
              root._cpuPrevIdle  = idle
              root._cpuPrevTotal = total
          }
      }
      property var _cpuTimer: Timer {
          interval: 500; running: true; repeat: true
          onTriggered: cpuFileView.reload()
      }

      // ── Net ───────────────────────────────────────────────────────────
      property var _netFileView: FileView {
          id: netFileView; path: "/proc/net/dev"
          watchChanges: true
          onFileChanged: reload()
          onTextChanged: {
              var t = text()
              var now = Date.now()
              var elapsed = root._netPrevTs > 0 ? Math.max(0.1, (now - root._netPrevTs) / 1000.0) : 1.0
              root._netPrevTs = now
              var lines = t.split("\n")
              var rx = 0, tx = 0
              for (var i = 0; i < lines.length; i++) {
                  var l = lines[i].trim()
                  if (!l) continue
                  var ci = l.lastIndexOf(":")
                  if (ci < 0) continue
                  var iface = l.substring(0, ci).trim()
                  if (iface === "lo") continue
                  var nums = l.substring(ci + 1).trim().split(/\s+/)
                  if (nums.length < 9) continue
                  rx += parseFloat(nums[0]) || 0
                  tx += parseFloat(nums[8]) || 0
              }
              if (root._netPrevRx > 0 && rx > 0 && elapsed > 0) {
                  root.receiveKilobytes = Math.max(0, (rx - root._netPrevRx) / 1024.0 / elapsed)
                  root.transmitKilobytes = Math.max(0, (tx - root._netPrevTx) / 1024.0 / elapsed)
              }
              if (rx > 0) { root._netPrevRx = rx; root._netPrevTx = tx }
          }
      }
      property var _netTimer: Timer {
          interval: 500; running: true; repeat: true
          onTriggered: netFileView.reload()
      }

      // ── RAM ───────────────────────────────────────────────────────────
      property var _ramFileView: FileView {
          id: ramFileView; path: "/proc/meminfo"
          watchChanges: false
          onTextChanged: {
              var t = text()
              var lines = t.split("\n")
              var total = 0, avail = 0
              for (var i = 0; i < lines.length; i++) {
                  if (lines[i].indexOf("MemTotal:")    === 0) total = parseInt(lines[i].split(/\s+/)[1]) || 0
                  if (lines[i].indexOf("MemAvailable:") === 0) avail = parseInt(lines[i].split(/\s+/)[1]) || 0
              }
              if (total > 0) {
                  root.memoryGigabytes  = (total - avail) / 1048576.0
                  root.memoryPercentage = Math.round((total - avail) / total * 100)
              }
          }
      }
      property var _ramTimer: Timer {
          interval: 800; running: true; repeat: true; triggeredOnStart: true
          onTriggered: ramFileView.reload()
      }

      // ── Temp ──────────────────────────────────────────────────────────
      property var _temperatureProcess: Process {
          id: temperatureProcess
          command: ["sh", "-c",
              "for f in /sys/class/hwmon/hwmon*/temp*_input; do [ -f \"$f\" ] && cat \"$f\" && exit; done; " +
              "for f in /sys/class/thermal/thermal_zone*/temp; do [ -f \"$f\" ] && cat \"$f\" && exit; done; echo 0"]
          stdout: SplitParser {
              onRead: function(d) {
                  var raw = parseFloat(d.trim())
                  if (isNaN(raw) || raw <= 0) return
                  var t = raw > 1000 ? raw / 1000.0 : raw
                  if (t > 0 && t < 150) root.cpuTemperature = Math.round(t)
              }
          }
          Component.onCompleted: running = true
      }
      property var _tempTimer: Timer {
          interval: 1000; running: true; repeat: true
          onTriggered: { temperatureProcess.running = false; temperatureProcess.running = true }
      }

      function formatNetworkSpeed(kilobytes) {
          if (kilobytes >= 1024) return (kilobytes / 1024).toFixed(1) + " MB/s"
          if (kilobytes >= 1)    return Math.round(kilobytes) + " KB/s"
          return "0 B/s"
      }
  }
''
