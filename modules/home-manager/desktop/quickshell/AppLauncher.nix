{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Widgets
  import QtQuick
  import QtQuick.Layouts
  import "."

  PanelWindow {
      id: launcher

      property bool open: false

      implicitWidth:  520
      implicitHeight: 560
      color: "transparent"
      visible: surface.shown

      WlrLayershell.namespace:     "niri-launcher"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.margins.top:  screen ? Math.round(screen.height / 2 - implicitHeight / 2) : 200
      WlrLayershell.margins.left: screen ? Math.round(screen.width  / 2 - implicitWidth  / 2) : 400

      property string query:  ""
      property int    selIdx: 0
      property int    generation: 0   // bumps on open and on each query so rows replay their rise-in
      readonly property int rowStep: Style.rowHeight + Style.space4

      // Name-prefix matches first, then name substrings, then generic name and description.
      ScriptModel {
          id: filtered
          values: {
              var all = [...DesktopEntries.applications.values]
                  .filter(d => d.name && !d.noDisplay)
                  .sort((a, b) => a.name.localeCompare(b.name))
              var q = launcher.query.trim().toLowerCase()
              if (q === "") return all
              function rank(d) {
                  var n = (d.name || "").toLowerCase()
                  if (n.indexOf(q) === 0) return 0
                  if (n.indexOf(q) > 0) return 1
                  if ((d.genericName || "").toLowerCase().indexOf(q) !== -1) return 2
                  if ((d.comment || "").toLowerCase().indexOf(q) !== -1) return 3
                  return -1
              }
              return all.map(d => ({ d: d, r: rank(d) }))
                  .filter(x => x.r >= 0)
                  .sort((a, b) => a.r - b.r)
                  .map(x => x.d)
          }
      }

      function escapeHtml(s) { return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;") }
      function marked(name) {
          var q = query.trim()
          var i = q ? name.toLowerCase().indexOf(q.toLowerCase()) : -1
          if (i < 0) return escapeHtml(name)
          return escapeHtml(name.slice(0, i)) + "<font color='" + Colors.accent + "'><b>" + escapeHtml(name.slice(i, i + q.length)) + "</b></font>" + escapeHtml(name.slice(i + q.length))
      }

      onOpenChanged: {
          if (open) {
              query = ""; selIdx = 0
              searchBox.text = ""
              listFlick.contentY = 0
              generation++
              searchBox.forceActiveFocus()
          }
      }

      function launch(entry) {
          if (!entry) return
          entry.execute()
          open = false
      }

      function moveSelection(d) {
          var n = filtered.values.length
          if (n === 0) return
          selIdx = ((selIdx + d) % n + n) % n
          var target = selIdx * rowStep - (listFlick.height / 2) + (Style.rowHeight / 2)
          scrollAnim.to = Math.max(0, Math.min(target, listFlick.contentHeight - listFlick.height))
          scrollAnim.restart()
      }

      PopupSurface {
          id: surface
          anchors.fill: parent
          open: launcher.open

          ColumnLayout {
              anchors.fill: parent
              spacing: Style.space8

              // Search
              Rectangle {
                  Layout.fillWidth: true
                  Layout.preferredHeight: Style.searchHeight
                  radius: Style.radiusMd
                  color: Colors.bgAlt
                  border.width: 1
                  border.color: searchBox.activeFocus ? Colors.accent : "transparent"
                  Behavior on border.color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }

                  RowLayout {
                      anchors { fill: parent; leftMargin: Style.space12; rightMargin: Style.space12 }
                      spacing: Style.space12
                      Icon { name: "search"; size: 16; color: Colors.fgMuted }
                      Item {
                          Layout.fillWidth: true
                          Layout.fillHeight: true
                          Text {
                              anchors.verticalCenter: parent.verticalCenter
                              text: "Search apps..."
                              color: Colors.fgMuted
                              font.family: Style.fontFamily; font.pixelSize: 16
                              visible: searchBox.text === ""
                          }
                          TextInput {
                              id: searchBox
                              anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                              color: Colors.fg
                              selectionColor: Colors.highlight
                              font.family: Style.fontFamily; font.pixelSize: 16
                              clip: true
                              onTextChanged: {
                                  launcher.query = text
                                  launcher.selIdx = 0
                                  listFlick.contentY = 0
                                  launcher.generation++
                              }
                              Keys.onUpPressed:     launcher.moveSelection(-1)
                              Keys.onDownPressed:   launcher.moveSelection(1)
                              Keys.onReturnPressed: launcher.launch(filtered.values[launcher.selIdx])
                              Keys.onEnterPressed:  launcher.launch(filtered.values[launcher.selIdx])
                              Keys.onEscapePressed: launcher.open = false
                              Keys.onTabPressed:    launcher.moveSelection(1)
                          }
                      }
                      Text {
                          text: launcher.query === "" ? filtered.values.length + " apps" : filtered.values.length + " found"
                          color: Colors.fgMuted
                          font.family: Style.fontFamily; font.pixelSize: 12; font.features: { "tnum": 1 }
                      }
                  }
              }

              // Results
              Flickable {
                  id: listFlick
                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  clip: true
                  contentHeight: listCol.implicitHeight
                  boundsBehavior: Flickable.StopAtBounds

                  NumberAnimation { id: scrollAnim; target: listFlick; property: "contentY"; duration: Style.durBase; easing.type: Style.easeOut }

                  // One highlight that glides between rows instead of each row repainting.
                  Rectangle {
                      width: listCol.width
                      height: Style.rowHeight
                      radius: Style.radiusMd
                      color: Colors.highlight
                      visible: filtered.values.length > 0
                      y: launcher.selIdx * launcher.rowStep
                      Behavior on y { NumberAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
                  }

                  Column {
                      id: listCol
                      width: listFlick.width
                      spacing: Style.space4

                      Repeater {
                          model: filtered
                          delegate: Item {
                              id: row
                              required property var modelData
                              required property int index
                              readonly property bool selected: index === launcher.selIdx
                              width: listCol.width
                              height: Style.rowHeight

                              // Rise-in: first 8 rows, 20ms apart, on open and on each new query.
                              property int gen: launcher.generation
                              onGenChanged: if (index < 8) rise.restart()
                              Component.onCompleted: if (index < 8) rise.restart()
                              opacity: 1
                              transform: Translate { id: lift; y: 0 }
                              SequentialAnimation {
                                  id: rise
                                  ScriptAction { script: { row.opacity = 0; lift.y = 6 } }
                                  PauseAnimation { duration: Style.reducedMotion ? 0 : row.index * 20 }
                                  ParallelAnimation {
                                      NumberAnimation { target: row; property: "opacity"; to: 1; duration: Style.durSlow; easing.type: Style.easeOut }
                                      NumberAnimation { target: lift; property: "y"; to: 0; duration: Style.durSlow; easing.type: Style.easeOut }
                                  }
                              }

                              RowLayout {
                                  anchors { fill: parent; leftMargin: Style.space12; rightMargin: Style.space12 }
                                  spacing: Style.space12

                                  AppIcon {
                                      size: 32
                                      icon: row.modelData.icon || ""
                                      name: row.modelData.name || ""
                                  }
                                  ColumnLayout {
                                      Layout.fillWidth: true
                                      spacing: Style.space2
                                      Text {
                                          Layout.fillWidth: true
                                          text: launcher.marked(modelData.name || "")
                                          textFormat: Text.StyledText
                                          color: Colors.fg
                                          elide: Text.ElideRight
                                          font.family: Style.fontFamily; font.pixelSize: 15
                                          font.weight: row.selected ? Font.Medium : Font.Normal
                                      }
                                      Text {
                                          Layout.fillWidth: true
                                          text: modelData.comment || modelData.genericName || ""
                                          visible: text !== ""
                                          color: Colors.fgAlt
                                          elide: Text.ElideRight
                                          font.family: Style.fontFamily; font.pixelSize: 13
                                      }
                                  }
                                  Rectangle {
                                      implicitWidth: hint.implicitWidth + 16
                                      implicitHeight: 24
                                      radius: Style.radiusSm
                                      color: Colors.bgAlt
                                      opacity: row.selected ? 1 : 0
                                      Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                                      Text {
                                          id: hint
                                          anchors.centerIn: parent
                                          text: "↵ open"
                                          color: Colors.fgAlt
                                          font.family: Style.fontFamily; font.pixelSize: 12
                                      }
                                  }
                              }

                              MouseArea {
                                  anchors.fill: parent
                                  hoverEnabled: true
                                  cursorShape: Qt.PointingHandCursor
                                  onEntered: launcher.selIdx = row.index
                                  onClicked: launcher.launch(row.modelData)
                              }
                          }
                      }
                  }

                  Text {
                      visible: filtered.values.length === 0
                      width: listFlick.width
                      topPadding: 32
                      horizontalAlignment: Text.AlignHCenter
                      text: "No apps match “" + launcher.query + "”"
                      color: Colors.fgAlt
                      font.family: Style.fontFamily; font.pixelSize: 13
                  }
              }

              // Footer
              Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Colors.border }
              Row {
                  Layout.alignment: Qt.AlignHCenter
                  spacing: Style.space16
                  Repeater {
                      model: [{ k: "↑↓", l: "navigate" }, { k: "↵", l: "open" }, { k: "Esc", l: "close" }]
                      Row {
                          required property var modelData
                          spacing: Style.space4
                          Rectangle {
                              anchors.verticalCenter: parent.verticalCenter
                              implicitWidth: key.implicitWidth + 10; implicitHeight: 18
                              radius: 4; color: Colors.bgAlt
                              Text { id: key; anchors.centerIn: parent; text: modelData.k; color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 11; font.weight: Font.Medium }
                          }
                          Text { anchors.verticalCenter: parent.verticalCenter; text: modelData.l; color: Colors.fgMuted; font.family: Style.fontFamily; font.pixelSize: 12 }
                      }
                  }
              }
          }
      }
  }
''
