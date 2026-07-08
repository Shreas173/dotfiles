import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../utils" as Utils
import "root:/"

RowLayout {
    id: root
    property string outputName: ""

    Rectangle {
        id: workspaceBar
        Layout.preferredWidth: Math.max(50, Utils.HyprlandUtils.workspaceIndicesForOutput(outputName).length * 25)
        Layout.preferredHeight: 23
        radius: 7
        color: Theme.get.barBgColor

        Row {
            anchors.centerIn: parent
            spacing: 15

            Repeater {
                model: Utils.HyprlandUtils.workspaceIndicesForOutput(outputName)

                delegate: Item {
                    required property int modelData
                    property bool focused: modelData === Utils.HyprlandUtils.activeWorkspaceForOutput(outputName)

                    width: workspaceText.width
                    height: workspaceText.height

                    Text {
                        id: workspaceText
                        text: modelData.toString()
                        color: "white"
                        font.pixelSize: 15
                        font.bold: focused
                    }

                    Rectangle {
                        visible: focused
                        anchors {
                            left: workspaceText.left
                            right: workspaceText.right
                            top: workspaceText.bottom
                            topMargin: -3
                        }
                        height: 2
                        color: "white"
                    }

                    DropShadow {
                        visible: focused
                        anchors.fill: workspaceText
                        horizontalOffset: 2
                        verticalOffset: 2
                        radius: 8.0
                        samples: 20
                        color: "#000000"
                        source: workspaceText
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Utils.HyprlandUtils.switchWorkspace(modelData)
                    }
                }
            }
        }
    }
}
