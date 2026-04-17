{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import QtQuick
  import QtQuick.Layouts
  import "."

  PanelWindow {
      id: calendar

      anchors.top:   true
      anchors.left:  true
      anchors.right: false

      implicitWidth:  340
      implicitHeight: 460
      color: "transparent"
      visible: false

      WlrLayershell.namespace:     "calendar-popup"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.margins.top:   30
      WlrLayershell.margins.left:  60

      property int  viewYear:  0
      property int  viewMonth: 0

      readonly property var days:    ["Mo","Tu","We","Th","Fr","Sa","Su"]
      readonly property var months:  ["January","February","March","April","May","June",
                                      "July","August","September","October","November","December"]
      readonly property var dayNames:["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

      property string clockH:  "00"
      property string clockM:  "00"
      property string clockS:  "00"
      property string dayName: ""
      property string dateStr: ""

      Timer {
          interval: 1000; running: true; repeat: true; triggeredOnStart: true
          onTriggered: {
              var now = new Date()
              var h24 = now.getHours()
              var h12 = h24 % 12; if (h12 === 0) h12 = 12
              calendar.clockH  = h12.toString()
              calendar.clockM  = ("0" + now.getMinutes()).slice(-2)
              calendar.clockS  = ("0" + now.getSeconds()).slice(-2)
              calendar.dayName = calendar.dayNames[now.getDay()]
              var mo = calendar.months[now.getMonth()]
              calendar.dateStr = mo + " " + now.getDate()
              if (calendar.viewYear === 0) {
                  calendar.viewYear  = now.getFullYear()
                  calendar.viewMonth = now.getMonth() + 1
              }
          }
      }

      function daysInMonth(y, m) { return new Date(y, m, 0).getDate() }
      function firstWeekday(y, m) {
          var d = new Date(y, m-1, 1).getDay()
          return (d + 6) % 7
      }

      function prevMonth() {
          if (calendar.viewMonth === 1) { calendar.viewMonth = 12; calendar.viewYear-- }
          else calendar.viewMonth--
      }
      function nextMonth() {
          if (calendar.viewMonth === 12) { calendar.viewMonth = 1; calendar.viewYear++ }
          else calendar.viewMonth++
      }

      onVisibleChanged: {
          if (visible) {
              var now = new Date()
              viewYear  = now.getFullYear()
              viewMonth = now.getMonth() + 1
          }
      }

      Item {
          anchors.fill: parent
          opacity: 0.96
          Rectangle {
              anchors.fill: parent
              color: Colors.bg; radius: 10
              Rectangle {
                  anchors.top:   parent.top
                  anchors.left:  parent.left
                  anchors.right: parent.right
                  height: 10; color: Colors.bg
              }
          }
      }

      ColumnLayout {
          anchors { fill: parent; margins: 10 }
          spacing: 8

          Rectangle {
              Layout.fillWidth: true; height: 80; radius: 8; color: Colors.bgAlt

              Text {
                  anchors.left:           parent.left
                  anchors.leftMargin:     14
                  anchors.verticalCenter: parent.verticalCenter
                  text: calendar.clockH + ":" + calendar.clockM
                  color: Colors.fg; font.family: "Fira Sans"
                  font.pixelSize: 54; font.weight: Font.Medium
              }

              Text {
                  anchors.right:        parent.right
                  anchors.rightMargin:  14
                  anchors.top:          parent.top
                  anchors.topMargin:    14
                  text: calendar.dayName
                  color: Colors.fg; font.family: "Fira Sans"
                  font.pixelSize: 18; font.weight: Font.Medium
              }

              Text {
                  anchors.right:         parent.right
                  anchors.rightMargin:   14
                  anchors.bottom:        parent.bottom
                  anchors.bottomMargin:  14
                  text: calendar.dateStr
                  color: Colors.accent; font.family: "Fira Sans"
                  font.pixelSize: 17
              }
          }

          Rectangle {
              Layout.fillWidth: true
              id: calendarCard
              height: 348; radius: 8; color: Colors.bgAlt

              ColumnLayout {
                  anchors { fill: parent; margins: 12 }
                  spacing: 6

                  RowLayout {
                      Layout.fillWidth: true

                      Item { width: 28; height: 28
                          Text { anchors.centerIn: parent; text: "‹"
                              color: arL.containsMouse ? Colors.fg : Colors.base03
                              font.pixelSize: 20; font.weight: Font.Medium
                              Behavior on color { ColorAnimation { duration: 80 } } }
                          MouseArea { id: arL; anchors.fill: parent; hoverEnabled: true
                              cursorShape: Qt.PointingHandCursor; onClicked: calendar.prevMonth() }
                      }

                      Text {
                          Layout.fillWidth: true; text: calendar.months[calendar.viewMonth-1] + " " + calendar.viewYear
                          color: Colors.fg; font.family: "Fira Sans"
                          font.pixelSize: 18; font.weight: Font.Medium
                          horizontalAlignment: Text.AlignHCenter
                      }

                      Item { width: 28; height: 28
                          Text { anchors.centerIn: parent; text: "›"
                              color: arR.containsMouse ? Colors.fg : Colors.base03
                              font.pixelSize: 20; font.weight: Font.Medium
                              Behavior on color { ColorAnimation { duration: 80 } } }
                          MouseArea { id: arR; anchors.fill: parent; hoverEnabled: true
                              cursorShape: Qt.PointingHandCursor; onClicked: calendar.nextMonth() }
                      }
                  }

                  Row {
                      Layout.fillWidth: true
                      spacing: 0
                      Repeater {
                          model: calendar.days
                          Text {
                              required property var modelData
                              width: Math.floor((calendarCard.width - 24) / 7)
                              text: modelData
                              color: Colors.fgAlt; font.family: "Fira Sans"
                              font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter
                          }
                      }
                  }

                  Rectangle { Layout.fillWidth: true; height: 1; color: Colors.highlight; opacity: 0.3 }

                  Grid {
                      Layout.fillWidth: true
                      columns: 7
                      spacing: 0
                      horizontalItemAlignment: Grid.AlignHCenter

                      property int totalDays:  calendar.daysInMonth(calendar.viewYear, calendar.viewMonth)
                      property int startOff:   calendar.firstWeekday(calendar.viewYear, calendar.viewMonth)
                      property int todayDay:   new Date().getDate()
                      property int todayMonth: new Date().getMonth() + 1
                      property int todayYear:  new Date().getFullYear()
                      property int cellW:      Math.floor((calendarCard.width - 24) / 7)

                      Repeater {
                          model: 42
                          delegate: Item {
                              required property int index
                              width:  parent.cellW
                              height: 42

                              property int dayNum: index - parent.startOff + 1
                              property bool valid: dayNum >= 1 && dayNum <= parent.totalDays
                              property bool isToday: valid &&
                                  dayNum === parent.todayDay &&
                                  calendar.viewMonth === parent.todayMonth &&
                                  calendar.viewYear  === parent.todayYear

                              Rectangle {
                                  anchors.centerIn: parent
                                  width: 32; height: 32; radius: 16
                                  color: isToday ? Colors.accent : (dMa.containsMouse && valid ? Colors.highlight : "transparent")
                                  Behavior on color { ColorAnimation { duration: 80 } }
                              }

                              Text {
                                  anchors.centerIn: parent
                                  text: valid ? dayNum.toString() : ""
                                  color: Colors.fg
                                  font.family: "Fira Sans"; font.pixelSize: 16
                                  font.weight: isToday ? Font.Medium : Font.Normal
                              }

                              MouseArea {
                                  id: dMa; anchors.fill: parent
                                  hoverEnabled: true; cursorShape: valid ? Qt.PointingHandCursor : Qt.ArrowCursor
                              }
                          }
                      }
                  }
              }
          }

          Item { height: 2 }
      }
  }
''
