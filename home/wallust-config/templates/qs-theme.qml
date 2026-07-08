import QtQuick

Item {
    id: wallustColors

    property string barBgColor: "{{background | hexa}}"
    property string buttonBorderColor: "{{color8}}"
    property string buttonBackgroundColor: "{{background | darken(0.3)}}"
    property bool buttonBorderShadow: true
    property bool onTop: true
    property string iconColor: "{{color4}}"
    property string iconPressedColor: "{{color5}}"
}
