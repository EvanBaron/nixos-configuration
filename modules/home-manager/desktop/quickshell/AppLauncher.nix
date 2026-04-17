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

      anchors.top:    false
      anchors.left:   false
      anchors.right:  false
      anchors.bottom: false

      implicitWidth:  520
      implicitHeight: 560
      color: "transparent"
      visible: false

      WlrLayershell.namespace:     "niri-launcher"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.exclusionMode: ExclusionMode.Ignore

      WlrLayershell.margins.top:  screen ? Math.round(screen.height / 2 - implicitHeight / 2) : 200
      WlrLayershell.margins.left: screen ? Math.round(screen.width  / 2 - implicitWidth  / 2) : 400

      property string query:  ""
      property int    selIdx: 0

      function svg(paths, color, sz) {
          return "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='"+(sz||18)+"' height='"+(sz||18)+"' viewBox='0 0 24 24' fill='none' stroke='"+color+"' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>"+paths+"</svg>"
      }

      ScriptModel {
          id: filtered
          values: {
              var all = [...DesktopEntries.applications.values]
                  .filter(function(d){ return d.name && !d.noDisplay })
                  .sort(function(a,b){ return a.name.localeCompare(b.name) })
              var q = launcher.query.trim().toLowerCase()
              if (q === "") return all
              return all.filter(function(d){
                  return (d.name||"").toLowerCase().indexOf(q) !== -1 ||
                         (d.genericName||"").toLowerCase().indexOf(q) !== -1
              })
          }
      }

      onVisibleChanged: {
          if (visible) {
              query   = ""
              selIdx  = 0
              searchBox.text = ""
              searchBox.forceActiveFocus()
          } else {
              searchBox.focus = false
          }
      }

      function launch(entry) {
          if (!entry) return
          entry.execute()
          visible = false
      }

      function moveSelection(d) {
          var n = filtered.values.length
          if (n === 0) return
          selIdx = ((selIdx + d) % n + n) % n
          var cellH = 54
          var y0 = selIdx * cellH
          var target = y0 - (listFlick.height / 2) + (cellH / 2)
          target = Math.max(0, Math.min(target, listFlick.contentHeight - listFlick.height))
          scrollAnim.to = target
          scrollAnim.restart()
      }

      Rectangle { anchors.fill: parent; color: Colors.bg; opacity: 0.97; radius: 14 }

      ColumnLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 8

          Rectangle {
              Layout.fillWidth: true; height: 44; radius: 10; color: Colors.bgAlt

              Row {
                  anchors.left: parent.left
                  anchors.leftMargin: 14
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 10

                  Image {
                      width: 16; height: 16; smooth: true
                      anchors.verticalCenter: parent.verticalCenter
                      source: launcher.svg("<circle cx='11' cy='11' r='8'/><path d='m21 21-4.35-4.35'/>", encodeURIComponent(Colors.base03), 16)
                  }

                  Item {
                      width: launcher.implicitWidth - 100
                      height: 44

                      Text {
                          anchors.verticalCenter: parent.verticalCenter
                          text: "Search apps..."
                          color: Colors.base03
                          font.family: "Fira Sans"
                          font.pixelSize: 16
                          visible: searchBox.text === ""
                      }

                      TextInput {
                          id: searchBox
                          anchors.left: parent.left
                          anchors.right: parent.right
                          anchors.verticalCenter: parent.verticalCenter
                          color: Colors.fg
                          font.family: "Fira Sans"
                          font.pixelSize: 16
                          onTextChanged: {
                              launcher.query  = text
                              launcher.selIdx = 0
                              listFlick.contentY = 0
                          }
                          Keys.onUpPressed:     launcher.moveSelection(-1)
                          Keys.onDownPressed:   launcher.moveSelection(1)
                          Keys.onReturnPressed: launcher.launch(filtered.values[launcher.selIdx])
                          Keys.onEscapePressed: launcher.visible = false
                      }
                  }
              }

              Text {
                  anchors.right: parent.right
                  anchors.rightMargin: 14
                  anchors.verticalCenter: parent.verticalCenter
                  text: filtered.values.length + " apps"
                  color: Colors.base03
                  font.family: "Fira Sans"
                  font.pixelSize: 12
                  visible: launcher.query === ""
              }
          }

          Flickable {
              id: listFlick
              Layout.fillWidth: true
              Layout.fillHeight: true
              clip: true
              contentHeight: listCol.implicitHeight
              boundsBehavior: Flickable.StopAtBounds

              NumberAnimation {
                  id: scrollAnim
                  target: listFlick
                  property: "contentY"
                  duration: 130
                  easing.type: Easing.OutCubic
              }

              Column {
                  id: listCol
                  width: listFlick.width
                  spacing: 3

                  Repeater {
                      model: filtered
                      delegate: Item {
                          required property var modelData
                          required property int index
                          width: parent.width
                          height: 54

                          Rectangle {
                              anchors.fill: parent
                              anchors.leftMargin: 2
                              anchors.rightMargin: 2
                              radius: 10
                              color: index === launcher.selIdx ? Colors.highlight : (hov.containsMouse ? Colors.bgAlt : "transparent")
                              Behavior on color { ColorAnimation { duration: 80 } }

                              Row {
                                  anchors.left: parent.left
                                  anchors.leftMargin: 10
                                  anchors.right: parent.right
                                  anchors.rightMargin: 10
                                  anchors.verticalCenter: parent.verticalCenter
                                  spacing: 12

                                  IconImage {
                                      width: 36; height: 36
                                      implicitSize: 36
                                      anchors.verticalCenter: parent.verticalCenter
                                      source: Quickshell.iconPath(modelData.icon || "", true)
                                      asynchronous: true
                                      mipmap: true
                                  }

                                  Column {
                                      anchors.verticalCenter: parent.verticalCenter
                                      width: parent.width - 36 - 12 - (index === launcher.selIdx ? 70 : 0)
                                      spacing: 2

                                      Text {
                                          width: parent.width
                                          text: modelData.name || ""
                                          color: Colors.fg
                                          font.family: "Fira Sans"
                                          font.pixelSize: 16
                                          font.weight: index === launcher.selIdx ? Font.Medium : Font.Normal
                                          elide: Text.ElideRight
                                      }
                                      Text {
                                          width: parent.width
                                          text: modelData.comment || modelData.genericName || ""
                                          color: Colors.fgAlt
                                          font.family: "Fira Sans"
                                          font.pixelSize: 13
                                          elide: Text.ElideRight
                                          visible: text !== ""
                                      }
                                  }

                                  Rectangle {
                                      visible: index === launcher.selIdx
                                      anchors.verticalCenter: parent.verticalCenter
                                      width: 58; height: 24; radius: 7
                                      color: Colors.bgAlt
                                      Text {
                                          anchors.centerIn: parent
                                          text: "↵ open"
                                          color: Colors.base06
                                          font.family: "Fira Sans"
                                          font.pixelSize: 12
                                      }
                                  }
                              }

                              MouseArea {
                                  id: hov; anchors.fill: parent
                                  hoverEnabled: true
                                  cursorShape: Qt.PointingHandCursor
                                  onEntered: launcher.selIdx = index
                                  onClicked: launcher.launch(modelData)
                              }
                          }
                      }
                  }
              }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.border }
          Text {
              text: "↑↓ navigate  ·  ↵ open  ·  Esc close"
              color: Colors.base03
              font.family: "Fira Sans"
              font.pixelSize: 11
              Layout.alignment: Qt.AlignHCenter
          }
      }
  }
''
