import QtQuick

Text {
    color: Theme.fg
    font.family: Theme.textFont
    font.pixelSize: 13
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation { duration: 300 }
    }
}
