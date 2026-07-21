import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: root

    readonly property color cRose:   "#ff7fb8"
    readonly property color cViolet: "#c88ff0"
    readonly property color cCyan:   "#3ad6e6"
    readonly property color cBg:     "#181322"
    readonly property color cBg2:    "#221a30"
    readonly property color cText:   "#e6e0ea"
    readonly property color cDim:    "#a89ec0"

    Mpris.Mpris2Model { id: mpris2 }
    readonly property var player: mpris2.currentPlayer
    readonly property bool hasPlayer: player !== null && player !== undefined
    readonly property bool isPlaying: hasPlayer && player.playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property string trackTitle: hasPlayer && player.track ? player.track : "Nothing playing"
    readonly property string trackArtist: hasPlayer && player.artist ? player.artist : "—"
    readonly property string artUrl: hasPlayer && player.artUrl ? player.artUrl : ""

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: Item {
        id: root2
        implicitWidth: Kirigami.Units.gridUnit * 22
        implicitHeight: Kirigami.Units.gridUnit * 9
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 7

        Rectangle {
            id: card
            anchors.fill: parent
            radius: 4
            color: root.cBg
            border.width: 1
            border.color: Qt.rgba(0.227, 0.839, 0.902, 0.4)
        }

        Bracket { anchors { top: parent.top; left: parent.left; topMargin: -1; leftMargin: -1 } }
        Bracket {
            atLeft: false
            anchors { top: parent.top; right: parent.right; topMargin: -1; rightMargin: -1 }
        }
        Bracket {
            atTop: false
            c: root.cRose
            anchors { bottom: parent.bottom; left: parent.left; bottomMargin: -1; leftMargin: -1 }
        }
        Bracket {
            atTop: false
            atLeft: false
            c: root.cRose
            anchors { bottom: parent.bottom; right: parent.right; bottomMargin: -1; rightMargin: -1 }
        }
        RowLayout {
            anchors.fill: parent
            anchors.margins: parent.height * 0.10
            spacing: parent.height * 0.10

            Item {
                id: discBox
                Layout.preferredWidth: root2.height * 0.80
                Layout.preferredHeight: root2.height * 0.80
                Layout.alignment: Qt.AlignVCenter

                Item {
                    id: disc
                    anchors.fill: parent

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "#0c0a12"
                        border.width: Math.max(1, width * 0.01)
                        border.color: Qt.rgba(root.cViolet.r, root.cViolet.g, root.cViolet.b, 0.35)
                    }
                    Repeater {
                        model: 5
                        Rectangle {
                            anchors.centerIn: parent
                            width: disc.width * (0.92 - index * 0.11)
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.04)
                        }
                    }
                    Image {
                        id: art
                        anchors.centerIn: parent
                        width: disc.width * 0.62
                        height: width
                        source: root.artUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        asynchronous: true
                        cache: true
                    }
                    Rectangle {
                        id: artMask
                        anchors.centerIn: parent
                        width: art.width
                        height: art.height
                        radius: width / 2
                        visible: false
                        layer.enabled: true
                    }
                    MultiEffect {
                        anchors.centerIn: parent
                        width: art.width
                        height: art.height
                        source: art
                        maskEnabled: true
                        maskSource: artMask
                        visible: root.artUrl !== ""
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: disc.width * 0.30
                        height: width
                        radius: width / 2
                        visible: root.artUrl === ""
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: root.cRose }
                            GradientStop { position: 1.0; color: root.cViolet }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "幻"
                            color: root.cBg
                            font.pixelSize: parent.width * 0.6
                            font.bold: true
                        }
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: disc.width * 0.05
                        height: width
                        radius: width / 2
                        color: root.cBg
                    }

                    RotationAnimator {
                        target: disc
                        from: 0; to: 360
                        duration: 6000
                        loops: Animation.Infinite
                        running: root.isPlaying
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: root2.height * 0.04

                Item { Layout.fillHeight: true }

                Item {
                    id: titleClip
                    Layout.fillWidth: true
                    Layout.preferredHeight: titleTxt.implicitHeight
                    clip: true
                    Text {
                        id: titleTxt
                        x: 0
                        text: root.trackTitle
                        color: root.cText
                        font.pixelSize: Math.max(13, root2.height * 0.11)
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        readonly property bool overflow: titleClip.width > 0 && implicitWidth > titleClip.width
                        onOverflowChanged: if (!overflow) x = 0
                        SequentialAnimation on x {
                            id: marquee
                            running: titleTxt.overflow && root.isPlaying
                            loops: Animation.Infinite
                            onRunningChanged: if (!running) titleTxt.x = 0
                            PropertyAction { target: titleTxt; property: "x"; value: 0 }
                            PauseAnimation { duration: 1200 }
                            NumberAnimation {
                                from: 0; to: Math.min(0, titleClip.width - titleTxt.implicitWidth)
                                duration: Math.max(2000, titleTxt.implicitWidth * 14)
                            }
                            PauseAnimation { duration: 1200 }
                            NumberAnimation { to: 0; duration: 400 }
                        }
                    }
                }

                Text {
                    text: root.trackArtist
                    color: root.cRose
                    font.pixelSize: Math.max(11, root2.height * 0.085)
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(3, root2.height * 0.03)
                    radius: height / 2
                    color: root.cBg2
                    Rectangle {
                        height: parent.height
                        radius: height / 2
                        width: parent.width * root.progress
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: root.cCyan }
                            GradientStop { position: 1.0; color: root.cRose }
                        }
                    }
                }

                RowLayout {
                    Layout.topMargin: root2.height * 0.03
                    spacing: root2.height * 0.06

                    CtrlButton { glyph: "󰒮"; enabled: root.hasPlayer; onClicked: if (root.hasPlayer) root.player.Previous() }
                    CtrlButton {
                        glyph: root.isPlaying ? "󰏤" : "󰐊"
                        big: true
                        enabled: root.hasPlayer
                        onClicked: if (root.hasPlayer) root.player.PlayPause()
                    }
                    CtrlButton { glyph: "󰒭"; enabled: root.hasPlayer; onClicked: if (root.hasPlayer) root.player.Next() }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    readonly property real progress: (hasPlayer && player.length > 0)
        ? Math.min(1, Math.max(0, player.position / player.length))
        : 0
    Timer {
        interval: 1000; repeat: true
        running: root.isPlaying && root.hasPlayer
        triggeredOnStart: true
        onTriggered: if (root.hasPlayer) root.player.updatePosition()
    }
    onIsPlayingChanged: if (isPlaying && hasPlayer) player.updatePosition()

    component Bracket: Item {
        id: br
        property bool atTop: true
        property bool atLeft: true
        property color c: root.cCyan
        width: 16; height: 16
        Rectangle { width: 16; height: 2; color: br.c; y: br.atTop ? 0 : 14 }
        Rectangle { width: 2; height: 16; color: br.c; x: br.atLeft ? 0 : 14 }
    }

    component CtrlButton: Rectangle {
        property string glyph: ""
        property bool big: false
        signal clicked()
        implicitWidth: big ? root2.height * 0.20 : root2.height * 0.15
        implicitHeight: implicitWidth
        radius: width / 2
        color: ma.containsMouse ? Qt.rgba(root.cViolet.r, root.cViolet.g, root.cViolet.b, 0.22) : "transparent"
        border.width: big ? 2 : 1
        border.color: big ? root.cRose : Qt.rgba(root.cViolet.r, root.cViolet.g, root.cViolet.b, 0.6)
        opacity: enabled ? 1 : 0.4
        Text {
            anchors.centerIn: parent
            text: parent.glyph
            color: parent.big ? root.cRose : root.cViolet
            font.pixelSize: parent.width * 0.5
            font.family: "JetBrainsMono Nerd Font"
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
