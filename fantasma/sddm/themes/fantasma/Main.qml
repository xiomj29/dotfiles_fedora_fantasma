import QtQuick 2.15
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#12101f"

    readonly property color cViolet:    "#c88ff0"
    readonly property color cVioletDim: "#b585de"
    readonly property color cRose:      "#ff7fb8"
    readonly property color cText:      "#e6e0ea"
    readonly property color cDim:       "#a89ec0"
    readonly property color cBox:       "#241b32"

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#151024" }
            GradientStop { position: 1.0; color: "#0f0c18" }
        }
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height * 0.02
        text: "幻"
        color: root.cViolet
        opacity: 0.07
        font.pixelSize: parent.height * 0.78
        font.family: "Noto Sans CJK JP"
        font.bold: true
    }

    Column {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: parent.height * 0.11
        spacing: 6
        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cText
            font.pixelSize: 68
            font.family: "Noto Sans Mono"
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cDim
            font.pixelSize: 17
            font.family: "Noto Sans Mono"
            text: Qt.formatDate(new Date(), "dddd MMMM d").toLowerCase()
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            clock.text = Qt.formatTime(new Date(), "HH:mm")
            dateText.text = Qt.formatDate(new Date(), "dddd MMMM d").toLowerCase()
        }
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * 0.04
        spacing: 18
        width: 340

        Item {
            width: 148; height: 148
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: avatarImg
                anchors.fill: parent
                source: "file:///var/lib/AccountsService/icons/xishay"
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 512
                sourceSize.height: 512
                smooth: true
                mipmap: true
                visible: false
            }
            Rectangle {
                id: avatarMask
                anchors.fill: parent
                radius: width / 2
                antialiasing: true
                visible: false
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4
                layer.textureSize: Qt.size(width * 4, height * 4)
            }
            MultiEffect {
                anchors.fill: parent
                source: avatarImg
                maskEnabled: true
                maskSource: avatarMask
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                visible: avatarImg.status === Image.Ready
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                radius: width / 2
                antialiasing: true
                color: "transparent"
                border.width: 3
                border.color: root.cVioletDim
            }
            Text {
                anchors.centerIn: parent
                visible: avatarImg.status !== Image.Ready
                text: "幻"
                color: root.cViolet
                font.pixelSize: 64
                font.family: "Noto Sans CJK JP"
                font.bold: true
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cText
            font.pixelSize: 21
            font.bold: true
            font.family: "Noto Sans Mono"
            text: userModel.lastUser !== "" ? userModel.lastUser : "user"
        }

        Rectangle {
            width: parent.width
            height: 46
            radius: 7
            color: root.cBox
            border.width: passwordInput.activeFocus ? 2 : 1
            border.color: passwordInput.activeFocus ? root.cViolet
                                                    : Qt.rgba(0.78, 0.56, 0.87, 0.35)
            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: root.cText
                font.pixelSize: 16
                font.family: "Noto Sans Mono"
                clip: true
                focus: true
                onAccepted: root.doLogin()
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 15
                text: "password"
                color: root.cDim
                font.pixelSize: 15
                font.family: "Noto Sans Mono"
                visible: passwordInput.text.length === 0
            }
        }

        Rectangle {
            width: parent.width
            height: 44
            radius: 7
            color: loginArea.containsMouse ? root.cViolet : root.cVioletDim
            Text {
                anchors.centerIn: parent
                text: "log in"
                color: "#14111f"
                font.pixelSize: 16
                font.bold: true
                font.family: "Noto Sans Mono"
            }
            MouseArea {
                id: loginArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.doLogin()
            }
        }

        Text {
            id: msg
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cRose
            font.pixelSize: 13
            font.family: "Noto Sans Mono"
            text: keyboard.capsLock ? "caps lock on" : ""
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 26
        spacing: 22
        Text {
            text: "shut down"
            color: powerOff.containsMouse ? root.cRose : root.cDim
            font.pixelSize: 14
            font.family: "Noto Sans Mono"
            MouseArea {
                id: powerOff; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }
        Text {
            text: "restart"
            color: reboot.containsMouse ? root.cRose : root.cDim
            font.pixelSize: 14
            font.family: "Noto Sans Mono"
            MouseArea {
                id: reboot; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }
    }

    function doLogin() {
        msg.text = ""
        sddm.login(userModel.lastUser, passwordInput.text, sessionModel.lastIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            msg.text = "wrong password"
            passwordInput.text = ""
            passwordInput.forceActiveFocus()
        }
    }

    Component.onCompleted: passwordInput.forceActiveFocus()
}
