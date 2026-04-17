{ ... }:
''
  import QtQuick
  import "."

  Item {
      id: pill
      property string iconSvg:     ""
      property string valueText:   ""
      property color  accentColor: Colors.accent
      signal clicked()

      height: 19
      width: 18 + lbl.implicitWidth + 8

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

      Image {
          id: ico
          width: 17; height: 17
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          smooth: true
          source: pill.iconSvg !== ""
              ? pill.encodeSvg(pill.iconSvg, pill.encodeColor(pill.accentColor))
              : ""
      }

      Text {
          id: lbl
          text: pill.valueText
          color: pill.accentColor
          anchors.left: ico.right; anchors.leftMargin: 4
          anchors.verticalCenter: parent.verticalCenter
          font.family: "Fira Sans"; font.pixelSize: 14; font.weight: Font.Medium
      }

      MouseArea {
          anchors.fill: parent; cursorShape: Qt.PointingHandCursor
          onClicked: pill.clicked()
      }
  }
''
