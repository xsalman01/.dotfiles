import QtQuick

Text {
    anchors.fill: parent

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    text: Time.time

    font.pixelSize: Math.floor(height * 0.55)

    elide: Text.ElideRight
}
