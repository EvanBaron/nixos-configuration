{ ... }:
''
  import Quickshell
  import Quickshell.Widgets
  import Quickshell.Services.Notifications
  import QtQuick
  import QtQuick.Effects
  import QtQuick.Layouts
  import "."

  // One notification. Toasts: bg + border + shadow, slide in 24px from the right over durSlow.
  // History: bgAlt card that rises in. Dismiss (×, swipe right past 80px, Clear all) slides out
  // 32px and fades over durBase, then collapses its height over durBase.
  Item {
      id: card
      property var  notification: null
      property bool toast: false
      property int  enterDelay: 0
      property string _leaveKind: ""
      readonly property bool leaving: _leaveKind !== ""
      readonly property bool hovered: hover.hovered
      readonly property var defaultAction: {
          if (!notification) return null
          var a = notification.actions
          for (var i = 0; i < a.length; i++) if (a[i].identifier === "default") return a[i]
          return null
      }
      readonly property var buttons: notification ? Array.from(notification.actions).filter(a => a.identifier !== "default" && a.text !== "") : []

      property real heightFactor: 1
      implicitHeight: body.implicitHeight * heightFactor
      implicitWidth: 400
      clip: !toast

      function leave(kind) {
          if (leaving) return
          _leaveKind = kind
          leaveAnim.start()
      }

      // "dismiss": gone from history too. "timeout": toast hides, history keeps it.
      function finish() {
          if (!notification) return
          if (_leaveKind === "timeout") Notifications.dropToast(notification)
          else notification.dismiss()
      }

      Component.onCompleted: enterAnim.start()

      SequentialAnimation {
          id: enterAnim
          ScriptAction { script: { body.opacity = 0; body.x = card.toast ? 24 : 0; rise.y = card.toast ? 0 : 6 } }
          PauseAnimation { duration: Style.reducedMotion ? 0 : card.enterDelay }
          ParallelAnimation {
              NumberAnimation { target: body; property: "opacity"; to: 1; duration: Style.durSlow; easing.type: Style.easeOut }
              NumberAnimation { target: body; property: "x"; to: 0; duration: Style.durSlow; easing.type: Style.easeOut }
              NumberAnimation { target: rise; property: "y"; to: 0; duration: Style.durSlow; easing.type: Style.easeOut }
          }
      }
      SequentialAnimation {
          id: leaveAnim
          ScriptAction { script: enterAnim.stop() }
          ParallelAnimation {
              NumberAnimation { target: body; property: "x"; to: Math.max(body.x + 32, 32); duration: Style.durBase; easing.type: Style.easeIn }
              NumberAnimation { target: body; property: "opacity"; to: 0; duration: Style.durBase; easing.type: Style.easeIn }
          }
          NumberAnimation { target: card; property: "heightFactor"; to: 0; duration: Style.durBase; easing.type: Style.easeOut }
          ScriptAction { script: card.finish() }
      }
      NumberAnimation { id: snapBack; target: body; property: "x"; to: 0; duration: Style.durBase; easing.type: Style.easeOut }

      Connections {
          target: Notifications
          enabled: !card.toast
          function onClearRequested() { clearDelay.start() }
      }
      Timer { id: clearDelay; interval: Style.reducedMotion ? 0 : card.enterDelay * 2; onTriggered: card.leave("dismiss") }

      Timer {
          interval: card.notification ? Notifications.timeoutFor(card.notification) : 0
          running: card.toast && interval > 0 && !card.hovered && !card.leaving && !drag.pressed
          onTriggered: card.leave("timeout")
      }

      Item {
          id: body
          width: parent.width
          implicitHeight: content.implicitHeight + Style.space12 * 2
          height: implicitHeight
          transform: Translate { id: rise; y: 0 }

          RectangularShadow {
              visible: card.toast
              anchors.fill: bg
              offset.y: 4
              blur: 16
              radius: bg.radius
              color: Qt.rgba(0, 0, 0, 0.35)
          }
          Rectangle {
              id: bg
              anchors.fill: parent
              radius: Style.radiusMd
              color: card.toast ? Colors.bg : (card.hovered ? Colors.highlight : Colors.bgAlt)
              border.width: card.toast ? 1 : 0
              border.color: card.notification && card.notification.urgency === NotificationUrgency.Critical ? Colors.statusCritical : Colors.border
              Behavior on color { ColorAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
          }

          HoverHandler { id: hover }

          MouseArea {
              id: drag
              anchors.fill: parent
              cursorShape: card.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
              drag.target: body
              drag.axis: Drag.XAxis
              drag.minimumX: 0
              drag.maximumX: body.width
              drag.threshold: 6
              onReleased: {
                  if (body.x > 80) card.leave("dismiss")
                  else if (body.x > 0) snapBack.start()
              }
              onClicked: {
                  if (drag.active) return
                  if (card.defaultAction) { card.defaultAction.invoke(); card.leave("dismiss") }
                  else if (card.toast) card.leave("timeout")
              }
          }

          RowLayout {
              id: content
              anchors { left: parent.left; right: parent.right; top: parent.top; margins: Style.space12 }
              spacing: Style.space12

              // A content image (album art, avatar) as-is; otherwise the app's icon in the uniform
              // AppIcon shape; a bell tile when the notification names no app at all.
              Item {
                  Layout.alignment: Qt.AlignTop
                  Layout.preferredWidth: 40; Layout.preferredHeight: 40
                  readonly property var n: card.notification
                  readonly property string appIcon: n ? (n.appIcon || n.desktopEntry || "") : ""
                  Rectangle {
                      anchors.fill: parent
                      visible: parent.n !== null && parent.n.image !== ""
                      radius: Style.radiusSm
                      color: Colors.highlight
                      clip: true
                      Image { anchors.fill: parent; source: parent.visible ? parent.parent.n.image : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true }
                  }
                  AppIcon {
                      anchors.fill: parent
                      visible: parent.n !== null && parent.n.image === "" && parent.appIcon !== ""
                      size: 40
                      icon: parent.appIcon
                      name: parent.n ? parent.n.appName : ""
                  }
                  Rectangle {
                      anchors.fill: parent
                      visible: parent.n !== null && parent.n.image === "" && parent.appIcon === ""
                      radius: Style.radiusSm
                      color: Colors.highlight
                      Icon { anchors.centerIn: parent; name: "bell"; size: 20; color: Colors.fg }
                  }
              }

              ColumnLayout {
                  Layout.fillWidth: true
                  spacing: Style.space2

                  RowLayout {
                      Layout.fillWidth: true
                      Layout.rightMargin: 24
                      spacing: Style.space8
                      Text {
                          Layout.fillWidth: true
                          text: card.notification ? (card.notification.summary || card.notification.appName) : ""
                          color: Colors.fg; elide: Text.ElideRight; maximumLineCount: 1
                          font.family: Style.fontFamily; font.pixelSize: 15; font.weight: Font.DemiBold
                      }
                      Text {
                          text: card.notification ? Notifications.ago(card.notification, Notifications.now) : ""
                          color: card.hovered && !card.toast ? Colors.fgAlt : Colors.fgMuted
                          font.family: Style.fontFamily; font.pixelSize: 12
                      }
                  }
                  Text {
                      Layout.fillWidth: true
                      visible: text !== ""
                      text: card.notification ? card.notification.body : ""
                      textFormat: Text.StyledText
                      wrapMode: Text.Wrap
                      maximumLineCount: 2
                      elide: Text.ElideRight
                      color: Colors.fgAlt
                      font.family: Style.fontFamily; font.pixelSize: 13
                      lineHeight: 1.1
                  }
                  Flow {
                      Layout.fillWidth: true
                      Layout.topMargin: Style.space8
                      visible: card.buttons.length > 0
                      spacing: Style.space8
                      Repeater {
                          model: card.buttons
                          Item {
                              required property var modelData
                              implicitWidth: actLabel.implicitWidth + 20
                              implicitHeight: 28
                              activeFocusOnTab: true
                              Keys.onReturnPressed: { modelData.invoke(); card.leave("dismiss") }
                              Rectangle {
                                  anchors.fill: parent; radius: Style.radiusSm
                                  color: actMouse.containsMouse ? Colors.highlight : "transparent"
                                  border.width: 1; border.color: Colors.borderStrong
                                  Behavior on color { ColorAnimation { duration: Style.durFast } }
                              }
                              Text { id: actLabel; anchors.centerIn: parent; text: modelData.text; color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 12; font.weight: Font.Medium }
                              FocusRing { targetRadius: Style.radiusSm }
                              MouseArea { id: actMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { modelData.invoke(); card.leave("dismiss") } }
                          }
                      }
                  }
              }
          }

          // Dismiss ×: appears on hover
          Item {
              width: 22; height: 22
              anchors { top: parent.top; right: parent.right; margins: 10 }
              opacity: card.hovered || activeFocus ? 1 : 0
              activeFocusOnTab: true
              Accessible.role: Accessible.Button
              Accessible.name: "Dismiss"
              Keys.onReturnPressed: card.leave("dismiss")
              Keys.onSpacePressed: card.leave("dismiss")
              Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
              Rectangle {
                  anchors.fill: parent; radius: 11
                  color: Colors.statusCritical
                  opacity: closeMouse.containsMouse ? 1 : 0
                  Behavior on opacity { NumberAnimation { duration: Style.durFast } }
              }
              Icon { anchors.centerIn: parent; name: "x"; size: 12; color: closeMouse.containsMouse ? Colors.onAccent : Colors.fgAlt }
              FocusRing { targetRadius: 11 }
              MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: card.leave("dismiss") }
          }
      }
  }
''
