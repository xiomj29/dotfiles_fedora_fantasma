import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property color cRose:   "#ff7fb8"
    readonly property color cViolet: "#c88ff0"
    readonly property color cCyan:   "#3ad6e6"
    readonly property color cText:   "#e6e0ea"

    property date now: new Date()
    Timer {
        interval: 1000; repeat: true; running: true
        onTriggered: root.now = new Date()
    }

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: Item {
        id: face
        implicitWidth: Kirigami.Units.gridUnit * 24
        implicitHeight: Kirigami.Units.gridUnit * 11

        readonly property real unit: Math.min(width / 5.2, height / 2.0)

        ColumnLayout {
            anchors.centerIn: parent
            spacing: -face.unit * 0.12

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 0
                Text {
                    text: Qt.formatDateTime(root.now, "HH")
                    color: root.cViolet
                    font.pixelSize: face.unit
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    text: ":"
                    color: root.cRose
                    font.pixelSize: face.unit
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    opacity: (root.now.getSeconds() % 2 === 0) ? 1.0 : 0.35
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }
                Text {
                    text: Qt.formatDateTime(root.now, "mm")
                    color: root.cRose
                    font.pixelSize: face.unit
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: face.unit * 0.16
                spacing: face.unit * 0.14

                Text {
                    text: "幻"
                    color: root.cCyan
                    font.pixelSize: face.unit * 0.24
                }
                Text {
                    textFormat: Text.StyledText
                    text: root.now.toLocaleDateString(Qt.locale("en_US"), "dddd").toUpperCase()
                          + " <font color=\"" + root.cCyan + "\">|</font> "
                          + root.now.toLocaleDateString(Qt.locale("en_US"), "MMMM d").toUpperCase()
                    color: root.cText
                    opacity: 0.8
                    font.pixelSize: face.unit * 0.16
                    font.letterSpacing: 3
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: face.unit * 0.10
                width: face.unit * 2.2
                height: Math.max(2, face.unit * 0.03)
                radius: height / 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.cRose }
                    GradientStop { position: 1.0; color: root.cViolet }
                }
            }
        }
    }
}
