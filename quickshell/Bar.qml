import Quickshell

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }

            height: 30
            implicitHeight: height

            ClockWidget {
                anchors.fill: parent
                anchors.margins: 1
            }
        }
    }
}
