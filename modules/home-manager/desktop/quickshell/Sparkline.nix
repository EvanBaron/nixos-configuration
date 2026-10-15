{ ... }:
''
  import QtQuick
  import "."

  // 1.75px line with a 3px end dot over the last samples (0–100). Draws in left to right over durData.
  Canvas {
      id: spark
      property var values: []
      property color lineColor: Colors.chartCpu
      property real progress: 1
      property bool active: true      // replays the draw-in each time this turns true
      onActiveChanged: if (active) replay()

      onValuesChanged: requestPaint()
      onProgressChanged: requestPaint()
      onLineColorChanged: requestPaint()
      onWidthChanged: requestPaint()

      function replay() { progress = 0; drawIn.restart() }
      NumberAnimation { id: drawIn; target: spark; property: "progress"; from: 0; to: 1; duration: Style.durData; easing.type: Style.easeOut }

      onPaint: {
          var c = getContext("2d")
          c.reset()
          var n = values.length
          if (n < 2) return
          var w = width - 4, h = height
          var last = Math.max(1, Math.floor((n - 1) * progress))
          function x(i) { return i / (n - 1) * w }
          function y(v) { return h - 3 - Math.max(0, Math.min(100, v)) / 100 * (h - 6) }
          c.strokeStyle = lineColor
          c.lineWidth = 1.75
          c.lineJoin = "round"; c.lineCap = "round"
          c.beginPath()
          for (var i = 0; i <= last; i++) i ? c.lineTo(x(i), y(values[i])) : c.moveTo(x(i), y(values[i]))
          c.stroke()
          c.fillStyle = lineColor
          c.beginPath(); c.arc(x(last), y(values[last]), 3, 0, Math.PI * 2); c.fill()
      }
  }
''
