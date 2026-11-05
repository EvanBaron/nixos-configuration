{ ... }:
''
  import Quickshell
  import Quickshell.Services.Pipewire
  import QtQuick
  import QtQuick.Layouts
  import "."

  // App volume page of the control center: one row per application currently playing audio.
  // An app's PipeWire output streams (a browser opens one per tab) share a row: the slider and the
  // icon (mute) act on all of them.
  ColumnLayout {
      id: root
      property bool active: false
      signal back()

      spacing: Style.space12

      readonly property var streams: Pipewire.nodes.values.filter(n => n.type === PwNodeType.AudioOutStream)
      PwObjectTracker { objects: root.streams }

      function appName(n) {
          var p = n.properties || {}
          return p["application.name"] || n.description || n.nickname || n.name || "Unknown"
      }
      readonly property var apps: {
          var groups = [], byName = {}
          for (var i = 0; i < streams.length; i++) {
              var name = appName(streams[i])
              if (!(name in byName)) { byName[name] = groups.length; groups.push({ name: name, nodes: [] }) }
              groups[byName[name]].nodes.push(streams[i])
          }
          return groups
      }

      PageHeader {
          Layout.fillWidth: true
          title: "App volume"
          showSwitch: false
          onBack: root.back()
      }

      Text {
          Layout.fillWidth: true
          Layout.topMargin: Style.space16; Layout.bottomMargin: Style.space16
          visible: root.apps.length === 0
          horizontalAlignment: Text.AlignHCenter
          text: "No apps are playing audio"
          color: Colors.fgAlt
          font.family: Style.fontFamily; font.pixelSize: 13
      }

      Repeater {
          model: root.apps
          RowLayout {
              id: row
              required property var modelData
              readonly property string appName: modelData.name
              readonly property var nodes: modelData.nodes
              readonly property var props: nodes[0].properties || {}
              readonly property var audios: nodes.map(n => n.audio).filter(a => a)
              readonly property bool muted: audios.length > 0 && audios.every(a => a.muted)
              readonly property real percent: Math.round(Math.max(0, ...audios.map(a => a.volume)) * 100)
              readonly property string icon: {
                  var entry = DesktopEntries.heuristicLookup(appName)
                  return props["application.icon-name"] || (entry ? entry.icon : "") || props["application.process.binary"] || ""
              }
              function toggleMute() { var m = !muted; audios.forEach(a => a.muted = m) }
              function setVolume(v) { audios.forEach(a => a.volume = v / 100) }

              Layout.fillWidth: true
              spacing: Style.space12

              Item {
                  Layout.preferredWidth: 18; Layout.preferredHeight: 18
                  Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                  Layout.bottomMargin: (Style.sliderHeight - 18) / 2
                  activeFocusOnTab: true
                  Accessible.role: Accessible.Button
                  Accessible.name: (row.muted ? "Unmute " : "Mute ") + row.appName
                  Keys.onSpacePressed: row.toggleMute()
                  Keys.onReturnPressed: row.toggleMute()
                  AppIcon {
                      anchors.fill: parent
                      size: 18
                      icon: row.icon
                      name: row.appName
                      opacity: row.muted ? 0.35 : 1
                      Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                  }
                  Icon {
                      visible: row.muted
                      anchors { right: parent.right; bottom: parent.bottom; rightMargin: -4; bottomMargin: -4 }
                      name: "volume-x"; size: 11; color: Colors.fg
                  }
                  FocusRing { targetRadius: Style.radiusSm }
                  MouseArea { anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: row.toggleMute() }
              }

              ColumnLayout {
                  Layout.fillWidth: true
                  spacing: Style.space4
                  Text {
                      Layout.fillWidth: true
                      elide: Text.ElideRight
                      text: row.appName
                      color: row.muted ? Colors.fgAlt : Colors.fg
                      font.family: Style.fontFamily; font.pixelSize: 12
                  }
                  ControlCenterSlider {
                      Layout.fillWidth: true
                      value: row.percent
                      muted: row.muted
                      Accessible.name: row.appName + " volume"
                      onMoved: (v) => row.setVolume(v)
                  }
              }

              Text {
                  Layout.preferredWidth: 34
                  Layout.alignment: Qt.AlignBottom
                  Layout.bottomMargin: (Style.sliderHeight - height) / 2
                  text: row.percent + "%"
                  horizontalAlignment: Text.AlignRight
                  color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 12; font.features: { "tnum": 1 }
              }
          }
      }
  }
''
