{
  pkgs,
  wallpaper,
}:
let
  shader = import ./DeskShader.nix { inherit pkgs; };
in
''
  import Quickshell
  import Quickshell.Wayland
  import QtQuick
  import QtQuick.Particles
  import "."

  // The empty-workspace scene, one per monitor, on the Bottom layer (above swaybg,
  // below every window): the wallpaper redrawn through an audio-reactive shader, a
  // drifting particle field, a now-playing poster and synced lyrics. Only the poster
  // takes clicks.
  PanelWindow {
      id: desk

      // Set by Bar.qml: this monitor's active workspace has no windows.
      property bool desktopEmpty: false

      readonly property bool motion: !Style.reducedMotion
      readonly property bool sound: !DeskAudio.silent

      anchors.top: true
      anchors.bottom: true
      anchors.left: true
      anchors.right: true
      color: "transparent"
      visible: desktopEmpty || scene.opacity > 0

      WlrLayershell.namespace: "desk"
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      mask: Region { item: NowPlaying.hasTrack ? poster : null }

      Item {
          id: scene
          anchors.fill: parent
          opacity: desk.desktopEmpty ? 1 : 0
          Behavior on opacity {
              NumberAnimation {
                  duration: desk.desktopEmpty ? Style.durSlow : Style.durExit
                  easing.type: desk.desktopEmpty ? Style.easeOut : Style.easeIn
              }
          }

          // ── Living wallpaper ──
          Image {
              id: wall
              anchors.fill: parent
              source: "file://${wallpaper}"
              fillMode: Image.PreserveAspectCrop
              sourceSize: Qt.size(desk.width, desk.height)
              asynchronous: true
              visible: false
          }
          ShaderEffectSource { id: wallTex; sourceItem: wall; hideSource: true; visible: false }

          // Album-art colour for the tint.
          ColorQuantizer {
              id: quant
              source: NowPlaying.artUrl
              depth: 0
              rescaleSize: 32
          }

          ShaderEffect {
              id: fx
              anchors.fill: parent
              property variant source: wallTex
              property real time: 0
              property real bass: desk.motion ? DeskAudio.bass : 0
              property real treble: desk.motion ? DeskAudio.treble : 0
              property real glow: desk.motion ? Math.min(1, DeskAudio.level * 1.1 + DeskAudio.beat * 0.25) : 0
              property real tintMix: NowPlaying.hasTrack && quant.colors.length > 0 ? 1 : 0
              property real scrim: NowPlaying.hasTrack ? 1 : 0
              Behavior on scrim { NumberAnimation { duration: Style.durSlow; easing.type: Style.easeOut } }
              property color accent: Colors.accent
              property color tint: quant.colors.length > 0 ? quant.colors[0] : Colors.accent
              property size resolution: Qt.size(width, height)
              fragmentShader: "file://${shader}"
              Behavior on tintMix { NumberAnimation { duration: Style.durData } }

              // Time only advances while there is sound, so silence is a still image.
              NumberAnimation on time {
                  running: desk.desktopEmpty && desk.sound && desk.motion
                  from: 0; to: 3600; duration: 3600 * 1000; loops: Animation.Infinite
              }
          }

          // ── Generative field ──
          ParticleSystem {
              id: field
              running: desk.desktopEmpty && desk.motion
              // A short drift after the music stops, then everything holds still.
              paused: !desk.sound && !idleDrift.running
          }
          Timer { id: idleDrift; interval: 10000; running: !desk.sound && desk.desktopEmpty }

          ImageParticle {
              system: field
              groups: ["dust"]
              source: "qrc:///particleresources/glowdot.png"
              color: Colors.accent
              alpha: 0.35
              entryEffect: ImageParticle.Fade
          }
          ImageParticle {
              system: field
              groups: ["spark"]
              source: "qrc:///particleresources/glowdot.png"
              color: Colors.fg
              alpha: 0.5
              entryEffect: ImageParticle.Scale
          }
          Emitter {
              system: field
              group: "dust"
              anchors.fill: parent
              emitRate: 18
              lifeSpan: 14000
              lifeSpanVariation: 4000
              startTime: 14000             // the field is already full when it appears
              size: 4
              sizeVariation: 2
              velocity: AngleDirection {
                  angle: 0; angleVariation: 25
                  magnitude: 10 + DeskAudio.bass * 90
                  magnitudeVariation: 6
              }
          }
          Emitter {
              system: field
              group: "spark"
              anchors.fill: parent
              emitRate: DeskAudio.treble * 30
              lifeSpan: 600
              size: 6
              sizeVariation: 3
              endSize: 0
          }
          // Embers: each kick lifts a few glowing sparks off the lit ground. They rise
          // slowly, sway and burn out; no flash, nothing flies outward.
          ImageParticle {
              system: field
              groups: ["ember"]
              source: "qrc:///particleresources/glowdot.png"
              color: Qt.lighter(Colors.accent, 1.4)
              colorVariation: 0.06
              alpha: 0.8
              entryEffect: ImageParticle.Fade
          }
          // emitRate 0: it only emits through burst(), which places this emitter's own
          // shape at (x, y), so it is a short strip rather than the whole screen (a
          // disabled Emitter would ignore bursts).
          Emitter {
              id: embers
              system: field
              group: "ember"
              width: 240; height: 12
              emitRate: 0
              lifeSpan: 1800
              lifeSpanVariation: 600
              size: 8
              sizeVariation: 4
              endSize: 1
              velocity: AngleDirection { angle: 270; angleVariation: 18; magnitude: 60; magnitudeVariation: 30 }
              acceleration: PointDirection { y: -12 }
          }
          Wander { system: field; groups: ["ember"]; anchors.fill: parent; xVariance: 25; pace: 40 }
          Connections {
              target: DeskAudio
              function onBeatChanged() {
                  if (DeskAudio.beat !== 1 || !desk.desktopEmpty || !desk.motion) return
                  embers.burst(Math.round(8 + DeskAudio.level * 22),
                               desk.width * (0.05 + Math.random() * 0.9) - embers.width / 2,
                               desk.height - 24 - embers.height)
              }
          }

          Wander {
              system: field
              groups: ["dust"]
              anchors.fill: parent
              xVariance: 20
              yVariance: 25 + DeskAudio.bass * 70
              pace: 30 + DeskAudio.mid * 120
          }

          // ── Lyrics ──
          ListView {
              id: lyricsView
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: -60
              width: parent.width * 0.7
              height: 260
              clip: true
              interactive: false
              visible: NowPlaying.lyrics.length > 0
              opacity: visible ? 1 : 0
              Behavior on opacity { NumberAnimation { duration: Style.durSlow; easing.type: Style.easeOut } }
              model: NowPlaying.lyrics
              currentIndex: Math.max(0, NowPlaying.lineIndex)
              highlightRangeMode: ListView.StrictlyEnforceRange
              preferredHighlightBegin: height / 2 - 24
              preferredHighlightEnd: height / 2 + 24
              highlightMoveDuration: Style.durBase
              highlightMoveVelocity: -1
              spacing: Style.space16
              delegate: Text {
                  required property var modelData
                  required property int index
                  readonly property bool current: index === lyricsView.currentIndex && NowPlaying.lineIndex >= 0
                  width: lyricsView.width
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.Wrap
                  text: modelData.text === "" ? "♪" : modelData.text
                  color: current ? Colors.fg : Colors.fgMuted
                  font.family: Style.fontFamily
                  font.pixelSize: current ? 32 : 20
                  font.weight: current ? Font.Medium : Font.Normal
                  Behavior on font.pixelSize { NumberAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
                  Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
              }
          }

          // ── Now-playing poster ──
          Item {
              id: poster
              visible: NowPlaying.hasTrack
              x: 48
              y: parent.height - height - 56
              width: posterRow.implicitWidth
              height: posterRow.implicitHeight
              opacity: visible ? 1 : 0
              Behavior on opacity { NumberAnimation { duration: Style.durSlow; easing.type: Style.easeOut } }

              Row {
                  id: posterRow
                  spacing: 24
                  Rectangle {
                      width: 120; height: 120
                      radius: Style.radiusMd
                      color: Colors.bgAlt
                      clip: true
                      Icon { anchors.centerIn: parent; name: "music"; size: 40; color: Colors.fgAlt; visible: art.status !== Image.Ready }
                      Image {
                          id: art
                          anchors.fill: parent
                          source: NowPlaying.artUrl
                          fillMode: Image.PreserveAspectCrop
                          asynchronous: true
                          sourceSize: Qt.size(240, 240)
                      }
                  }
                  Column {
                      anchors.bottom: parent.bottom
                      spacing: 6
                      Text {
                          text: NowPlaying.title
                          color: Colors.fg
                          font.family: Style.fontFamily; font.pixelSize: 40; font.weight: Font.DemiBold
                          width: Math.min(implicitWidth, desk.width * 0.5); elide: Text.ElideRight
                      }
                      Text {
                          text: [NowPlaying.artist, NowPlaying.album].filter(s => s !== "").join(" · ")
                          color: Colors.fgAlt
                          font.family: Style.fontFamily; font.pixelSize: 18; font.weight: Font.Medium
                          width: Math.min(implicitWidth, desk.width * 0.5); elide: Text.ElideRight
                      }
                      Text {
                          function fmt(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }
                          text: NowPlaying.length > 0 ? fmt(NowPlaying.position) + " / " + fmt(NowPlaying.length) : ""
                          color: Colors.fgMuted
                          font.family: Style.fontFamily; font.pixelSize: 12
                          font.features: { "tnum": 1 }
                      }
                  }
              }

              MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: NowPlaying.togglePlaying()
              }
          }

          // Progress line along the bottom; brightens on each beat.
          Rectangle {
              visible: NowPlaying.hasTrack && NowPlaying.length > 0
              x: 48; width: parent.width - 96
              y: parent.height - 32; height: 2; radius: 1
              color: Qt.rgba(Colors.highlight.r, Colors.highlight.g, Colors.highlight.b, 0.8)
              Rectangle {
                  height: parent.height; radius: 1
                  width: parent.width * Math.min(1, NowPlaying.position / Math.max(1, NowPlaying.length))
                  color: Colors.accent
                  opacity: 0.7 + 0.3 * (desk.motion ? DeskAudio.beat : 0)
                  Behavior on width { NumberAnimation { duration: 250 } }
              }
          }
      }
  }
''
