{ ... }:
''
  import QtQuick
  import QtQuick.Layouts
  import "."

  Rectangle {
      id: toggle
      property bool   active:   false
      property bool   dimmed:   false
      property string label:    ""
      property string iconSvg:  ""
      signal toggled()

      implicitHeight: 56
      radius: 8
      color: active ? Colors.highlight : Colors.bgAlt

      Behavior on color { ColorAnimation { duration: 100 } }

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

      Column {
          anchors.centerIn: parent
          spacing: 5

          Image {
              anchors.horizontalCenter: parent.horizontalCenter
              width: 18; height: 18; smooth: true
              source: {
                  var c = toggle.active ? Colors.accent
                        : toggle.dimmed ? Colors.base03
                        : Colors.base04
                  return toggle.encodeSvg(toggle.iconSvg, toggle.encodeColor(c))
              }
          }

          Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: toggle.label
              color: toggle.active ? Colors.fg : Colors.fgAlt
              font.family: "Fira Sans"; font.pixelSize: 10
              elide: Text.ElideRight; width: toggle.width - 8
              horizontalAlignment: Text.AlignHCenter
              Behavior on color { ColorAnimation { duration: 100 } }
          }
      }

      MouseArea {
          anchors.fill: parent; cursorShape: Qt.PointingHandCursor
          onClicked: toggle.toggled()
      }
  }
''
