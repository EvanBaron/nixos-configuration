{ wallpaper }:
''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import Quickshell.Services.Pam
  import QtQuick
  import "."

  // Session lock: dimmed wallpaper, clock and date, and a password card on every screen.
  // `quickshell ipc call lock lock` locks; `isLocked` reports once the compositor confirms it.
  Scope {
      id: lockRoot

      // Shared by every screen's field.
      property string password: ""
      property string phase: "idle"   // idle | checking | wrong | unlocking
      property bool capsLock: false
      property int shakeCount: 0
      property string _pending: ""

      function lock() {
          if (sessionLock.locked) return
          lockRoot.password = ""
          lockRoot.phase = "idle"
          sessionLock.locked = true
      }

      function submit() {
          if (lockRoot.phase === "checking" || lockRoot.phase === "unlocking" || lockRoot.password === "") return
          lockRoot._pending = lockRoot.password
          lockRoot.phase = "checking"
          if (!pam.start()) fail()
      }

      function fail() {
          lockRoot.password = ""
          lockRoot._pending = ""
          lockRoot.phase = "wrong"
          lockRoot.shakeCount++
      }

      PamContext {
          id: pam
          // security.pam.services.quickshell in modules/nixos/niri.nix
          config: "quickshell"
          onResponseRequiredChanged: {
              if (responseRequired && lockRoot._pending !== "") {
                  respond(lockRoot._pending)
                  lockRoot._pending = ""
              }
          }
          onCompleted: result => {
              if (result === PamResult.Success) {
                  lockRoot.password = ""
                  lockRoot.phase = "unlocking"
                  unlockTimer.start()
              } else {
                  lockRoot.fail()
              }
          }
          onError: lockRoot.fail()
      }

      // Let the fade-out play before the lock is released.
      Timer { id: unlockTimer; interval: Style.durExit + 20; onTriggered: { sessionLock.locked = false; lockRoot.phase = "idle" } }

      IpcHandler {
          target: "lock"
          function lock(): void { lockRoot.lock() }
          function isLocked(): bool { return sessionLock.secure }
      }

      WlSessionLock {
          id: sessionLock
          locked: false

          WlSessionLockSurface {
              id: surface
              color: Colors.bg

              property date now: new Date()
              Timer { interval: 1000; running: true; repeat: true; onTriggered: surface.now = new Date() }

              Image {
                  anchors.fill: parent
                  source: "file://${wallpaper}"
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
              }
              Rectangle { anchors.fill: parent; color: "#161819"; opacity: 0.55 }

              Item {
                  id: content
                  anchors.fill: parent
                  opacity: 0
                  transform: Translate { id: rise; y: 8; Behavior on y { NumberAnimation { duration: Style.durSlow; easing.type: Style.easeOut } } }
                  Component.onCompleted: { opacity = 1; rise.y = 0 }
                  states: State {
                      name: "out"; when: lockRoot.phase === "unlocking"
                      PropertyChanges { content.opacity: 0 }
                  }
                  Behavior on opacity {
                      NumberAnimation {
                          duration: lockRoot.phase === "unlocking" ? Style.durExit : Style.durSlow
                          easing.type: lockRoot.phase === "unlocking" ? Style.easeIn : Style.easeOut
                      }
                  }

                  Column {
                      id: clockColumn
                      anchors.horizontalCenter: parent.horizontalCenter
                      anchors.bottom: card.top
                      anchors.bottomMargin: 56
                      spacing: Style.space8
                      Text {
                          anchors.horizontalCenter: parent.horizontalCenter
                          text: Qt.formatDateTime(surface.now, "HH:mm")
                          color: Colors.fg
                          font.family: Style.fontFamily; font.pixelSize: 96; font.weight: Font.Medium
                          font.features: { "tnum": 1 }
                      }
                      Text {
                          anchors.horizontalCenter: parent.horizontalCenter
                          text: Qt.formatDateTime(surface.now, "dddd d MMMM")
                          color: Colors.fgAlt
                          font.family: Style.fontFamily; font.pixelSize: 18; font.weight: Font.Medium
                      }
                  }

                  Rectangle {
                      id: card
                      width: 320
                      height: cardColumn.implicitHeight + 2 * Style.space16
                      // Grows downward only, so the clock above never moves.
                      anchors.horizontalCenter: parent.horizontalCenter
                      anchors.top: parent.verticalCenter
                      anchors.topMargin: -40
                      radius: Style.radiusLg
                      color: Qt.rgba(Colors.bg.r, Colors.bg.g, Colors.bg.b, Style.opacitySurface)
                      border.width: 1
                      border.color: Colors.border
                      transform: Translate { id: shake }

                      SequentialAnimation {
                          id: shakeAnim
                          NumberAnimation { target: shake; property: "x"; to: -8; duration: Style.durSlow * 0.2; easing.type: Style.easeOut }
                          NumberAnimation { target: shake; property: "x"; to: 8;  duration: Style.durSlow * 0.2; easing.type: Style.easeOut }
                          NumberAnimation { target: shake; property: "x"; to: -5; duration: Style.durSlow * 0.2; easing.type: Style.easeOut }
                          NumberAnimation { target: shake; property: "x"; to: 3;  duration: Style.durSlow * 0.2; easing.type: Style.easeOut }
                          NumberAnimation { target: shake; property: "x"; to: 0;  duration: Style.durSlow * 0.2; easing.type: Style.easeOut }
                      }
                      Connections { target: lockRoot; function onShakeCountChanged() { shakeAnim.restart() } }

                      Column {
                          id: cardColumn
                          anchors.fill: parent
                          anchors.margins: Style.space16
                          spacing: Style.space8

                          Row {
                              spacing: Style.space12
                              bottomPadding: Style.space4
                              Rectangle {
                                  width: 40; height: 40; radius: 20
                                  color: Colors.highlight
                                  Icon { anchors.centerIn: parent; name: "user"; size: 18; color: Colors.fg }
                              }
                              Column {
                                  anchors.verticalCenter: parent.verticalCenter
                                  spacing: Style.space2
                                  Text { text: userName.text; color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 16; font.weight: Font.Medium }
                                  Text { text: hostName.text().trim(); color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 12 }
                              }
                          }

                          Text { text: "Password"; color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 11; font.weight: Font.Medium }

                          Rectangle {
                              width: parent.width
                              height: Style.searchHeight
                              radius: Style.radiusMd
                              color: Colors.bgAlt
                              border.width: 1
                              border.color: lockRoot.phase === "wrong" ? Colors.statusCritical
                                          : field.activeFocus ? Colors.accent
                                          : Colors.border
                              Behavior on border.color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }

                              Icon {
                                  id: lockIcon
                                  anchors.left: parent.left; anchors.leftMargin: 12
                                  anchors.verticalCenter: parent.verticalCenter
                                  size: 18
                                  name: lockRoot.phase === "checking" ? "refresh-cw" : "lock"
                                  color: lockRoot.phase === "checking" ? Colors.accent : Colors.fgAlt
                                  RotationAnimation on rotation {
                                      running: lockRoot.phase === "checking"
                                      from: 0; to: 360; duration: 800; loops: Animation.Infinite
                                      onRunningChanged: if (!running) lockIcon.rotation = 0
                                  }
                              }

                              TextInput {
                                  id: field
                                  anchors.left: lockIcon.right; anchors.leftMargin: 10
                                  anchors.right: parent.right; anchors.rightMargin: 12
                                  anchors.verticalCenter: parent.verticalCenter
                                  echoMode: TextInput.Password
                                  passwordCharacter: "•"
                                  readOnly: lockRoot.phase === "checking" || lockRoot.phase === "unlocking"
                                  focus: true
                                  color: Colors.fg
                                  selectionColor: Colors.highlight
                                  font.family: Style.fontFamily; font.pixelSize: 16
                                  text: lockRoot.password
                                  onTextEdited: {
                                      lockRoot.password = text
                                      if (lockRoot.phase === "wrong") lockRoot.phase = "idle"
                                  }
                                  onAccepted: lockRoot.submit()
                                  Keys.onEscapePressed: lockRoot.password = ""
                                  // Infer Caps Lock from letters typed without Shift.
                                  Keys.onPressed: event => {
                                      var t = event.text
                                      if (t.length === 1 && t.toLowerCase() !== t.toUpperCase()) {
                                          var shift = (event.modifiers & Qt.ShiftModifier) !== 0
                                          var upper = t === t.toUpperCase()
                                          lockRoot.capsLock = upper !== shift
                                      }
                                  }
                                  Component.onCompleted: forceActiveFocus()

                                  Text {
                                      anchors.verticalCenter: parent.verticalCenter
                                      visible: field.text === ""
                                      text: "Enter password"
                                      color: Colors.fgMuted
                                      font: field.font
                                  }
                              }
                          }

                          Item {
                              width: parent.width
                              height: 16
                              Text {
                              anchors.left: parent.left
                              anchors.verticalCenter: parent.verticalCenter
                              text: lockRoot.phase === "checking" ? "Checking…"
                                  : lockRoot.phase === "wrong" ? "Wrong password, try again"
                                  : lockRoot.capsLock ? "Caps Lock is on"
                                  : ""
                              color: lockRoot.phase === "wrong" ? Colors.statusCritical
                                   : lockRoot.phase === "checking" ? Colors.fgAlt
                                   : Colors.statusWarning
                              font.family: Style.fontFamily; font.pixelSize: 12
                              }
                          }
                      }
                  }
              }
          }
      }

      FileView { id: hostName; path: "/proc/sys/kernel/hostname" }
      Process {
          id: userQuery
          command: ["id", "-un"]
          running: true
          stdout: SplitParser { onRead: data => userName.text = data.trim() }
      }
      QtObject { id: userName; property string text: "" }
  }
''
