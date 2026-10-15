{ ... }:
''
  import QtQuick
  import "."

  // Mutually exclusive options with an accent thumb that slides over durBase.
  // model: [{ key, label, icon }]; one tab stop, Left/Right move and wrap.
  Item {
      id: seg
      property var    model: []
      property string currentKey: ""
      signal selected(string key)

      readonly property int currentIndex: {
          for (var i = 0; i < model.length; i++) if (model[i].key === currentKey) return i
          return -1
      }
      readonly property real cellWidth: (width - 6) / Math.max(1, model.length)

      implicitHeight: Style.segmentHeight
      activeFocusOnTab: true
      Accessible.role: Accessible.RadioButton
      Keys.onLeftPressed:  if (model.length) seg.selected(model[(Math.max(0, currentIndex) - 1 + model.length) % model.length].key)
      Keys.onRightPressed: if (model.length) seg.selected(model[(currentIndex + 1) % model.length].key)

      Rectangle { anchors.fill: parent; radius: Style.radiusMd; color: Colors.bgAlt }

      Rectangle {
          visible: seg.currentIndex >= 0
          x: 3 + seg.currentIndex * seg.cellWidth
          y: 3
          width: seg.cellWidth
          height: parent.height - 6
          radius: Style.radiusSm
          color: Colors.accent
          Behavior on x { NumberAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
      }

      Row {
          x: 3; y: 3
          Repeater {
              model: seg.model
              Item {
                  required property var modelData
                  required property int index
                  readonly property bool checked: index === seg.currentIndex
                  width: seg.cellWidth
                  height: seg.height - 6

                  Row {
                      anchors.centerIn: parent
                      spacing: Style.space4
                      Icon {
                          anchors.verticalCenter: parent.verticalCenter
                          name: modelData.icon || ""
                          size: 14
                          color: checked ? Colors.onAccent : (cellMouse.containsMouse ? Colors.fg : Colors.fgAlt)
                      }
                      Text {
                          anchors.verticalCenter: parent.verticalCenter
                          text: modelData.label
                          color: checked ? Colors.onAccent : (cellMouse.containsMouse ? Colors.fg : Colors.fgAlt)
                          font.family: Style.fontFamily; font.pixelSize: 12; font.weight: Font.Medium
                          Behavior on color { ColorAnimation { duration: Style.durBase; easing.type: Style.easeOut } }
                      }
                  }
                  MouseArea {
                      id: cellMouse
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: seg.selected(modelData.key)
                  }
              }
          }
      }

      FocusRing { targetRadius: Style.radiusMd }
  }
''
