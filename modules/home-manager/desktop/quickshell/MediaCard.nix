{ ... }:
''
  import Quickshell.Services.Mpris
  import QtQuick
  import QtQuick.Layouts
  import "."

  // Now playing: art, title/artist, progress with times, prev / play-pause / next.
  // Expands and collapses over durSlow when a player appears or disappears.
  Item {
      id: card
      property var player: null
      property bool live: true   // poll position only while the card is on screen
      readonly property bool hasPlayer: player !== null
      readonly property bool playing: hasPlayer && player.isPlaying

      property real position: 0
      property real length: hasPlayer ? player.length : 0

      implicitHeight: hasPlayer ? content.implicitHeight + Style.space12 * 2 : 0
      clip: true
      opacity: hasPlayer ? 1 : 0
      Behavior on implicitHeight { NumberAnimation { duration: Style.durSlow; easing.type: Style.easeOut } }
      Behavior on opacity { NumberAnimation { duration: Style.durSlow; easing.type: Style.easeOut } }

      Timer {
          interval: 1000; repeat: true; triggeredOnStart: true
          running: card.live && card.hasPlayer
          onTriggered: { card.player.positionChanged(); card.position = card.player.position }
      }

      function fmt(s) {
          s = Math.max(0, Math.floor(s))
          return Math.floor(s / 60) + ":" + ("0" + (s % 60)).slice(-2)
      }

      Rectangle { anchors.fill: parent; radius: Style.radiusMd; color: Colors.bgAlt }

      ColumnLayout {
          id: content
          anchors { left: parent.left; right: parent.right; top: parent.top; margins: Style.space12 }
          spacing: Style.space12

          RowLayout {
              Layout.fillWidth: true
              spacing: Style.space12

              Rectangle {
                  Layout.preferredWidth: 56; Layout.preferredHeight: 56; radius: Style.radiusSm
                  color: Colors.highlight
                  clip: true
                  Icon { anchors.centerIn: parent; name: "music"; size: 22; color: Colors.fgAlt; visible: art.status !== Image.Ready }
                  Image {
                      id: art
                      anchors.fill: parent
                      source: card.hasPlayer ? (card.player.trackArtUrl || "") : ""
                      fillMode: Image.PreserveAspectCrop
                      asynchronous: true
                      visible: status === Image.Ready
                  }
              }
              ColumnLayout {
                  Layout.fillWidth: true
                  spacing: Style.space2
                  Text {
                      Layout.fillWidth: true
                      text: card.hasPlayer ? (card.player.trackTitle || "Unknown title") : ""
                      color: Colors.fg; elide: Text.ElideRight
                      font.family: Style.fontFamily; font.pixelSize: 14; font.weight: Font.Medium
                  }
                  Text {
                      Layout.fillWidth: true
                      text: card.hasPlayer ? [card.player.trackArtist, card.player.trackAlbum].filter(s => s).join(" — ") : ""
                      visible: text !== ""
                      color: Colors.fgAlt; elide: Text.ElideRight
                      font.family: Style.fontFamily; font.pixelSize: 12
                  }
              }
          }

          Rectangle {
              Layout.fillWidth: true
              visible: card.length > 0
              Layout.preferredHeight: 4; radius: Style.radiusXs
              color: Colors.highlight
              Rectangle {
                  height: parent.height; radius: Style.radiusXs
                  width: parent.width * Math.min(1, card.position / Math.max(1, card.length))
                  color: Colors.accent
                  Behavior on width { NumberAnimation { duration: 1000; easing.type: Easing.Linear } }
              }
          }

          RowLayout {
              Layout.fillWidth: true
              Text {
                  text: card.length > 0 ? card.fmt(card.position) : ""
                  color: Colors.fgMuted; font.family: Style.fontFamily; font.pixelSize: 11; font.features: { "tnum": 1 }
              }
              Item { Layout.fillWidth: true }
              Row {
                  spacing: Style.space4
                  Repeater {
                      model: [
                          { icon: "skip-back", primary: false, act: "prev" },
                          { icon: card.playing ? "pause" : "play", primary: true, act: "toggle" },
                          { icon: "skip-forward", primary: false, act: "next" }
                      ]
                      Item {
                          required property var modelData
                          width: 32; height: 32
                          activeFocusOnTab: true
                          Accessible.role: Accessible.Button
                          Accessible.name: modelData.act
                          function activate() {
                              if (!card.hasPlayer) return
                              if (modelData.act === "prev") card.player.previous()
                              else if (modelData.act === "next") card.player.next()
                              else card.player.togglePlaying()
                          }
                          Keys.onSpacePressed: activate()
                          Keys.onReturnPressed: activate()
                          Rectangle {
                              anchors.fill: parent; radius: 16
                              color: modelData.primary ? Colors.accent : Colors.highlight
                              opacity: modelData.primary ? 1 : (btn.containsMouse ? 1 : 0)
                              scale: btn.pressed ? 0.92 : 1
                              Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                              Behavior on scale { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                          }
                          Icon { anchors.centerIn: parent; name: modelData.icon; size: 16; color: modelData.primary ? Colors.onAccent : Colors.fg; animated: false }
                          FocusRing { targetRadius: 16 }
                          MouseArea { id: btn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.activate() }
                      }
                  }
              }
              Item { Layout.fillWidth: true }
              Text {
                  text: card.length > 0 ? card.fmt(card.length) : ""
                  color: Colors.fgMuted; font.family: Style.fontFamily; font.pixelSize: 11; font.features: { "tnum": 1 }
              }
          }
      }
  }
''
