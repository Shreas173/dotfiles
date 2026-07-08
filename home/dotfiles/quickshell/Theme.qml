pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property Item get: catppuccin

    Item {
        id: wallust

        readonly property var _theme: {
            var comp = Qt.createComponent("bar/theme/WallustTheme.qml")
            if (comp.status === Component.Ready) {
                var obj = comp.createObject(null)
                if (obj) return obj
            }
            return null
        }

        property string barBgColor: _theme ? _theme.barBgColor : "#cc191724"
        property string buttonBorderColor: _theme ? _theme.buttonBorderColor : "#26233a"
        property string buttonBackgroundColor: _theme ? _theme.buttonBackgroundColor : "#1f1d2e"
        property bool buttonBorderShadow: _theme ? _theme.buttonBorderShadow : true
        property bool onTop: _theme ? _theme.onTop : true
        property string iconColor: _theme ? _theme.iconColor : "#c4a7e7"
        property string iconPressedColor: _theme ? _theme.iconPressedColor : "#eb6f92"
    }

    Item {
        id: windowsXP

        property string barBgColor: "#88235EDC"
        property string buttonBorderColor: "#99000000"
        property bool buttonBorderShadow: false
        property string buttonBackgroundColor: "#1111CC"
        property bool onTop: false
        property string iconColor: "green"
        property string iconPressedColor: "green"
        property Gradient barGradient: black.barGradient
    }

    Item {
        id: black

        property string barBgColor: "#cc000000"
        property string buttonBorderColor: "#BBBBBB"
        property string buttonBackgroundColor: "#222222"
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "blue"
        property string iconPressedColor: "dark_blue"
    }

    Item {
        id: nordic

        property string barBgColor: "#aa2E3440"
        property string buttonBorderColor: "#4C566A"
        property string buttonBackgroundColor: "#3D4550"
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#88C0D0"
        property string iconPressedColor: "#81A1C1"
    }

    Item {
        id: cyberpunk

        property string barBgColor: "#881A0B2E"
        property string buttonBorderColor: "#FF2A6D"
        property string buttonBackgroundColor: "#1A1A2E"
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#05D9E8"
        property string iconPressedColor: "#FF2A6D"
    }

    Item {
        id: material

        property string barBgColor: "#cc1F1F1F"
        property string buttonBorderColor: "#2D2D2D"
        property string buttonBackgroundColor: "#2D2D2D"
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#90CAF9"
        property string iconPressedColor: "#64B5F6"
    }

    Item {
        id: catppuccin

        property string barBgColor: "#aa1E1E2E"
        property string buttonBorderColor: "#313244"
        property string buttonBackgroundColor: "#313244"
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#89B4FA"
        property string iconPressedColor: "#74C7EC"
    }

    Item {
        id: rosePine

        property string barBgColor: "#cc191724"
        property string buttonBorderColor: "#26233a"
        property string buttonBackgroundColor: "#1f1d2e"
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#c4a7e7"
        property string iconPressedColor: "#eb6f92"
    }
}
