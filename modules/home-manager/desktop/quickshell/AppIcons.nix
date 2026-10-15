{ iconTheme }:
''
  pragma Singleton
  import Quickshell
  import Quickshell.Io
  import QtQuick

  // Which app icons the desktop's icon theme (${iconTheme.name}) draws itself.
  // AppIcon shows those as-is and gives everything else a matching tile.
  Singleton {
      id: root
      property var names: ({})
      property bool ready: false

      function inTheme(name) { return root.ready && root.names[name] === true }

      Process {
          id: lister
          running: true
          command: ["sh", "-c", "ls ${iconTheme.package}/share/icons/${iconTheme.name}/apps/scalable"]
          property var _seen: ({})
          stdout: SplitParser {
              onRead: data => {
                  var n = data.trim().replace(/\.svg$/, "")
                  if (n) lister._seen[n] = true
              }
          }
          onRunningChanged: if (!running) { root.names = _seen; root.ready = true }
      }
  }
''
