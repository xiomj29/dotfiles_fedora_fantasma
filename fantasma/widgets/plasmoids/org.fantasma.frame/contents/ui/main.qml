import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property color cRose:   "#ff7fb8"
    readonly property color cViolet: "#c88ff0"
    readonly property color cCyan:   "#3ad6e6"
    readonly property color cBg:     "#161122"

    property string photosDir: "file:///home/xishay/Pictures/wallpaper"
    property int cycleMs: 12000

    component Bracket: Item {
        id: br
        property bool atTop: true
        property bool atLeft: true
        property color c: root.cCyan
        width: 16; height: 16
        Rectangle { width: 16; height: 2; color: br.c; y: br.atTop ? 0 : 14 }
        Rectangle { width: 2; height: 16; color: br.c; x: br.atLeft ? 0 : 14 }
    }

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: Item {
        id: win
        implicitWidth: Kirigami.Units.gridUnit * 18
        implicitHeight: Kirigami.Units.gridUnit * 14

        FolderListModel {
            id: folder
            folder: root.photosDir
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.JPEG", "*.PNG"]
            showDirs: false
            sortField: FolderListModel.Name
        }

        property bool showA: false
        function nextPhoto() {
            if (folder.count <= 0) return
            var p = folder.get(Math.floor(Math.random() * folder.count), "filePath")
            if (!p) return
            var url = "file://" + p
            if (showA) { imgB.source = url; showA = false }
            else       { imgA.source = url; showA = true }
        }

        Timer {
            interval: root.cycleMs; repeat: true; running: true
            onTriggered: win.nextPhoto()
        }
        Component.onCompleted: win.nextPhoto()
        Connections {
            target: folder
            function onCountChanged() {
                if (imgA.source == "" && imgB.source == "" && folder.count > 0)
                    win.nextPhoto()
            }
        }

        Rectangle {
            id: border
            anchors.fill: parent
            radius: 4
            color: "#12101e"
            border.width: 1
            border.color: Qt.rgba(0.227, 0.839, 0.902, 0.4)
        }

        Rectangle {
            id: inner
            anchors.fill: parent
            anchors.margins: 3
            radius: 2
            color: root.cBg
            clip: true

            Item {
                id: stage
                anchors.fill: parent

                    Image {
                        id: imgA
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        opacity: win.showA ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad } }
                    }
                    Image {
                        id: imgB
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        opacity: win.showA ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad } }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: folder.count === 0
                        text: "No photos in\n~/Pictures/wallpaper"
                        horizontalAlignment: Text.AlignHCenter
                        color: root.cViolet
                        font.pixelSize: win.height * 0.05
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.7; color: "transparent" }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.35) }
                        }
                    }
            }
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
        MouseArea {
            anchors.fill: parent
            onClicked: win.nextPhoto()
            cursorShape: Qt.PointingHandCursor
        }
    }
}
