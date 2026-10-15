{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import QtQuick
  import "."

  // Pop-up notifications under the bar's right end. Only the cards take input.
  PanelWindow {
      id: toasts

      anchors.top: true
      anchors.right: true
      implicitWidth: 400 + 16 + Style.space6
      implicitHeight: Math.max(1, column.implicitHeight + 24)
      color: "transparent"
      visible: Notifications.toasts.length > 0

      WlrLayershell.namespace:     "notification-toasts"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.margins.top:   Style.popupTop - 4

      mask: Region { item: column }

      Column {
          id: column
          x: 16
          y: 4
          width: 400
          spacing: Style.space8
          Repeater {
              model: ScriptModel { values: Notifications.toasts }
              NotificationCard {
                  required property var modelData
                  width: column.width
                  notification: modelData
                  toast: true
              }
          }
      }
  }
''
