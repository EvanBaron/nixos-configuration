{ ... }:
''
  import QtQuick
  import "."

  // A Lucide icon drawn in one ink, sized by `size` (also its implicit size inside layouts).
  // Colour changes animate over Style.durBase unless `animated` is false.
  Item {
      id: icon
      property string name: ""
      property color color: Colors.fg
      property int size: 18
      property bool animated: true

      implicitWidth: size
      implicitHeight: size
      visible: name !== ""

      property color _ink: color
      Behavior on _ink { enabled: icon.animated; ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }

      function _hex(c) {
          function h(x) { return Math.round(x * 255).toString(16).padStart(2, "0") }
          return "#" + h(c.r) + h(c.g) + h(c.b)
      }

      Image {
          anchors.fill: parent
          sourceSize: Qt.size(icon.size * 2, icon.size * 2)
          smooth: true
          source: {
              var p = Icons.paths[icon.name]
              if (!p) return ""
              var svg = "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='" + icon._hex(icon._ink) + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>" + p.replace(/"/g, "'") + "</svg>"
              return "data:image/svg+xml;charset=utf-8," + encodeURIComponent(svg)
          }
      }
  }
''
