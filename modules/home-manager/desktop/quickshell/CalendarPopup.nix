{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import QtQuick
  import QtQuick.Layouts
  import "."

  PanelWindow {
      id: calendar

      property bool open: false
      signal closeRequested()

      anchors.top:  true
      anchors.left: true
      implicitWidth:  320
      implicitHeight: mainCol.implicitHeight + Style.space12 * 2
      color: "transparent"
      visible: surface.shown

      WlrLayershell.namespace:     "calendar-popup"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.margins.top:   Style.popupTop
      WlrLayershell.margins.left:  Style.space6

      readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
      readonly property var months: ["January", "February", "March", "April", "May", "June",
                                     "July", "August", "September", "October", "November", "December"]
      readonly property var dayNames: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

      property date today: new Date()
      property int viewYear: today.getFullYear()
      property int viewMonth: today.getMonth()   // 0-based

      Timer { interval: 60000; running: calendar.open; repeat: true; onTriggered: calendar.today = new Date() }

      function isoWeek(d) {
          var t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
          var day = t.getUTCDay() || 7
          t.setUTCDate(t.getUTCDate() + 4 - day)
          var y0 = new Date(Date.UTC(t.getUTCFullYear(), 0, 1))
          return Math.ceil(((t - y0) / 86400000 + 1) / 7)
      }

      // Month change: slide 12px out and fade (durExit, InCubic), swap, enter from the other side (durBase).
      property int _dir: 1
      function step(dir) {
          if (monthAnim.running) return
          _dir = dir
          monthAnim.restart()
      }
      function applyStep() {
          if (_dir === 0) { viewYear = today.getFullYear(); viewMonth = today.getMonth(); return }
          var m = viewMonth + _dir
          viewYear += Math.floor(m / 12)
          viewMonth = ((m % 12) + 12) % 12
      }
      SequentialAnimation {
          id: monthAnim
          ParallelAnimation {
              NumberAnimation { target: gridShift; property: "x"; to: calendar._dir >= 0 ? -12 : 12; duration: Style.durExit; easing.type: Style.easeIn }
              NumberAnimation { target: days; property: "opacity"; to: 0; duration: Style.durExit; easing.type: Style.easeIn }
          }
          ScriptAction { script: { calendar.applyStep(); gridShift.x = calendar._dir >= 0 ? 12 : -12 } }
          ParallelAnimation {
              NumberAnimation { target: gridShift; property: "x"; to: 0; duration: Style.durBase; easing.type: Style.easeOut }
              NumberAnimation { target: days; property: "opacity"; to: 1; duration: Style.durBase; easing.type: Style.easeOut }
          }
      }

      onOpenChanged: if (open) {
          today = new Date()
          viewYear = today.getFullYear()
          viewMonth = today.getMonth()
          keyRoot.forceActiveFocus()
      }

      Shortcut { sequence: "Escape"; enabled: calendar.open; onActivated: calendar.closeRequested() }

      component NavButton: Item {
          id: nav
          property string iconName: ""
          property string text: ""
          signal clicked()
          implicitWidth: text !== "" ? navLabel.implicitWidth + 16 : 28
          implicitHeight: 28
          activeFocusOnTab: true
          Accessible.role: Accessible.Button
          Keys.onReturnPressed: nav.clicked()
          Keys.onSpacePressed: nav.clicked()
          Rectangle {
              anchors.fill: parent; radius: Style.radiusSm
              color: Colors.highlight
              opacity: navMouse.containsMouse ? 1 : 0
              Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
          }
          Icon { anchors.centerIn: parent; visible: nav.text === ""; name: nav.iconName; size: 16; color: navMouse.containsMouse ? Colors.fg : Colors.fgAlt }
          Text {
              id: navLabel
              anchors.centerIn: parent
              visible: nav.text !== ""
              text: nav.text
              color: Colors.accent
              font.family: Style.fontFamily; font.pixelSize: 12; font.weight: Font.Medium
          }
          FocusRing { targetRadius: Style.radiusSm }
          MouseArea { id: navMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nav.clicked() }
      }

      PopupSurface {
          id: surface
          anchors.fill: parent
          open: calendar.open

          FocusScope {
              id: keyRoot
              anchors.fill: parent
              Keys.onLeftPressed: calendar.step(-1)
              Keys.onRightPressed: calendar.step(1)

              ColumnLayout {
                  id: mainCol
                  anchors { left: parent.left; right: parent.right; top: parent.top }
                  spacing: Style.space8

                  // Today
                  Rectangle {
                      Layout.fillWidth: true
                      implicitHeight: headRow.implicitHeight + Style.space12 * 2
                      radius: Style.radiusMd
                      color: Colors.bgAlt
                      RowLayout {
                          id: headRow
                          anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Style.space16; rightMargin: Style.space16 }
                          spacing: Style.space16
                          Text {
                              text: calendar.today.getDate()
                              color: Colors.fg
                              font.family: Style.fontFamily; font.pixelSize: 48; font.weight: Font.Medium; font.features: { "tnum": 1 }
                          }
                          ColumnLayout {
                              Layout.fillWidth: true
                              spacing: Style.space4
                              Text { text: calendar.dayNames[calendar.today.getDay()]; color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 18; font.weight: Font.Medium }
                              Text {
                                  text: calendar.months[calendar.today.getMonth()] + " " + calendar.today.getFullYear() + " · Week " + calendar.isoWeek(calendar.today)
                                  color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 13
                              }
                          }
                      }
                  }

                  // Month
                  Rectangle {
                      id: monthCard
                      Layout.fillWidth: true
                      implicitHeight: monthCol.implicitHeight + Style.space12 * 2
                      radius: Style.radiusMd
                      color: Colors.bgAlt
                      clip: true

                      ColumnLayout {
                          id: monthCol
                          anchors { fill: parent; margins: Style.space12 }
                          spacing: Style.space6

                          RowLayout {
                              Layout.fillWidth: true
                              spacing: Style.space2
                              NavButton { iconName: "chevron-left"; Accessible.name: "Previous month"; onClicked: calendar.step(-1) }
                              Text {
                                  Layout.fillWidth: true
                                  horizontalAlignment: Text.AlignHCenter
                                  text: calendar.months[calendar.viewMonth] + " " + calendar.viewYear
                                  color: Colors.fg; font.family: Style.fontFamily; font.pixelSize: 15; font.weight: Font.Medium
                              }
                              NavButton {
                                  text: "Today"
                                  visible: calendar.viewMonth !== calendar.today.getMonth() || calendar.viewYear !== calendar.today.getFullYear()
                                  onClicked: calendar.step(0)
                              }
                              NavButton { iconName: "chevron-right"; Accessible.name: "Next month"; onClicked: calendar.step(1) }
                          }

                          Row {
                              Layout.fillWidth: true
                              Repeater {
                                  model: calendar.weekdays
                                  Text {
                                      required property var modelData
                                      width: (monthCard.width - Style.space12 * 2) / 7
                                      height: 24
                                      text: modelData
                                      horizontalAlignment: Text.AlignHCenter
                                      verticalAlignment: Text.AlignVCenter
                                      color: Colors.fgAlt; font.family: Style.fontFamily; font.pixelSize: 11; font.weight: Font.Medium
                                  }
                              }
                          }
                          Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Colors.border }

                          Item {
                              Layout.fillWidth: true
                              implicitHeight: days.implicitHeight
                              transform: Translate { id: gridShift; x: 0 }
                              Grid {
                                  id: days
                                  width: parent.width
                                  columns: 7

                                  readonly property int startOff: (new Date(calendar.viewYear, calendar.viewMonth, 1).getDay() + 6) % 7
                                  readonly property int count: new Date(calendar.viewYear, calendar.viewMonth + 1, 0).getDate()
                                  readonly property int prevCount: new Date(calendar.viewYear, calendar.viewMonth, 0).getDate()

                                  Repeater {
                                      model: 42
                                      Item {
                                          required property int index
                                          readonly property int n: index - days.startOff + 1
                                          readonly property bool inMonth: n >= 1 && n <= days.count
                                          readonly property int label: n < 1 ? days.prevCount + n : n > days.count ? n - days.count : n
                                          readonly property bool isToday: inMonth && n === calendar.today.getDate()
                                              && calendar.viewMonth === calendar.today.getMonth() && calendar.viewYear === calendar.today.getFullYear()
                                          readonly property bool weekend: index % 7 > 4
                                          width: days.width / 7
                                          height: 38

                                          Rectangle {
                                              anchors.centerIn: parent
                                              width: 32; height: 32; radius: 16
                                              color: isToday ? Colors.accent : Colors.highlight
                                              opacity: isToday ? 1 : (dayMouse.containsMouse ? 1 : 0)
                                              Behavior on opacity { NumberAnimation { duration: Style.durFast; easing.type: Style.easeOut } }
                                          }
                                          Text {
                                              anchors.centerIn: parent
                                              text: label
                                              color: isToday ? Colors.onAccent : !inMonth ? Colors.fgMuted : weekend ? Colors.fgAlt : Colors.fg
                                              font.family: Style.fontFamily; font.pixelSize: 14
                                              font.weight: isToday ? Font.DemiBold : Font.Normal
                                              font.features: { "tnum": 1 }
                                          }
                                          MouseArea { id: dayMouse; anchors.fill: parent; hoverEnabled: true }
                                      }
                                  }
                              }
                          }
                      }

                      MouseArea {
                          anchors.fill: parent
                          acceptedButtons: Qt.NoButton
                          onWheel: (wheel) => calendar.step(wheel.angleDelta.y < 0 ? 1 : -1)
                      }
                  }
              }
          }
      }
  }
''
