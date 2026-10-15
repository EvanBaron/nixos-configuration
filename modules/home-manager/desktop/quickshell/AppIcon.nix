{ ... }:
''
  import Quickshell
  import Quickshell.Widgets
  import QtQuick
  import "."

  // An application icon in one uniform shape. Icons the theme draws (Reversal's rounded
  // squares) show as-is; any other icon sits small on a tile cut to the same shape, and an
  // app with no icon at all gets its initials on that tile.
  Item {
      id: root
      property string icon: ""   // desktop-entry Icon= value: a theme name or an absolute path
      property string name: ""   // app name, for the initials fallback
      property int size: 32

      readonly property bool isPath: icon.startsWith("/") || icon.startsWith("file:") || icon.startsWith("image:")
      readonly property bool themed: icon !== "" && !isPath && AppIcons.inTheme(icon)
      readonly property string source: icon === "" ? "" : isPath ? icon : Quickshell.iconPath(icon, true)
      readonly property string initials: {
          var w = name.replace(/[^\p{L}\p{N} ]/gu, " ").trim().split(/\s+/).filter(s => s)
          if (w.length === 0) return "?"
          return (w.length === 1 ? w[0].slice(0, 2) : w[0][0] + w[1][0]).toUpperCase()
      }

      implicitWidth: size
      implicitHeight: size

      IconImage {
          anchors.fill: parent
          visible: root.themed
          source: root.themed ? root.source : ""
          implicitSize: root.size
          asynchronous: true
          mipmap: true
      }

      // Tile: Reversal's geometry, a square inset 1/16 of the canvas with ~22% corners.
      Rectangle {
          visible: !root.themed
          anchors.fill: parent
          anchors.margins: Math.round(root.size / 16)
          radius: width * 0.22
          color: Colors.highlight
          border.width: 1
          border.color: Qt.lighter(Colors.highlight, 1.25)

          IconImage {
              anchors.centerIn: parent
              visible: root.source !== "" && status !== Image.Error
              width: Math.round(parent.width * 0.64); height: width
              implicitSize: width
              source: root.themed ? "" : root.source
              asynchronous: true
              mipmap: true
          }
          Text {
              anchors.centerIn: parent
              visible: root.source === ""
              text: root.initials
              color: Colors.fg
              font.family: Style.fontFamily
              font.pixelSize: Math.round(root.size * 0.34)
              font.weight: Font.DemiBold
          }
      }
  }
''
