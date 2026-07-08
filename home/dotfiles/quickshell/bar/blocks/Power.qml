import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"
import "root:/"

// Picks up polkit authentication agent; ensure polkit-gnome-authentication-agent-1 is running

BarBlock {
  id: root

  content: BarText {
    text: "󰐥"
    pointSize: 16
  }

  PopupWindow {
    id: menuWindow
    width: 150
    height: 130
    visible: false

    anchor {
      window: root.QsWindow?.window
      edges: Edges.Bottom
      gravity: Edges.Top
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onExited: {
        if (!containsMouse) {
          closeTimer.start()
        }
      }
      onEntered: closeTimer.stop()

      Timer {
        id: closeTimer
        interval: 500
        onTriggered: menuWindow.visible = false
      }

      Rectangle {
        anchors.fill: parent
        color: "#2c2c2c"
        border.color: "#3c3c3c"
        border.width: 1
        radius: 4

        Column {
          anchors.fill: parent
          anchors.margins: 5
          spacing: 5

          Repeater {
            model: [
              { text: "󰍃  Logout", action: () => { logoutProc.running = true; menuWindow.visible = false } },
              { text: "󰜉  Reboot", action: () => { rebootProc.running = true; menuWindow.visible = false } },
              { text: "⏻  Power Off", action: () => { poweroffProc.running = true; menuWindow.visible = false } }
            ]

            Rectangle {
              width: parent.width
              height: 35
              color: mouseArea.containsMouse ? "#3c3c3c" : "transparent"
              radius: 4

              Text {
                anchors.fill: parent
                anchors.leftMargin: 10
                text: modelData.text
                color: "white"
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
              }

              MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                  modelData.action()
                }
              }
            }
          }
        }
      }
    }
  }

  Process {
    id: logoutProc
    command: ["loginctl", "terminate-user", "$USER"]
    running: false
  }

  Process {
    id: rebootProc
    command: ["pkexec", "systemctl", "reboot"]
    running: false
  }

  Process {
    id: poweroffProc
    command: ["pkexec", "systemctl", "poweroff"]
    running: false
  }

  onClicked: function() {
    menuWindow.visible = !menuWindow.visible
  }
}
