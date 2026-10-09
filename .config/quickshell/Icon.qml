import QtQuick

Text {
    color: Theme.fg
    font.family: Theme.iconFont
    font.pixelSize: 16
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.QtRendering

    Behavior on color {
        ColorAnimation { duration: 200 }
    }
}
