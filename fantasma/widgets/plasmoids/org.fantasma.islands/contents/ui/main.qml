// 幻 Fantasma — org.fantasma.islands
// Autor: xishay
// GitHub: https://github.com/xiomj29

import QtQuick
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.taskmanager as TaskManager
import org.kde.plasma.private.systemtray as SysTray
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property color cBg:      Qt.rgba(0.078, 0.067, 0.118, 0.86)
    readonly property color cSurface: Qt.rgba(0.180, 0.135, 0.235, 0.85)
    readonly property color cBorder:  Qt.rgba(0.902, 0.878, 0.918, 0.08)
    readonly property color cText:    "#e6e0ea"
    readonly property color cFaint:   "#776c92"
    readonly property color cRose:    "#ff7fb8"
    readonly property color cViolet:  "#c88ff0"
    readonly property color cCyan:    "#3ad6e6"
    readonly property color cAmber:   "#ffd88a"
    readonly property color cInk:     "#171226"

    readonly property string monoFont:  "JetBrainsMono Nerd Font"
    readonly property string kanjiFont: "Noto Sans CJK JP"
    readonly property var kanjiNum: ["一","二","三","四","五","六","七","八","九","十"]

    readonly property int barH: 40
    readonly property string helper: "$HOME/.local/bin/fantasma-islands"

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property int    cpu: 0
    property int    ram: 0
    property int    vol: 0
    property bool   muted: false
    property string netMode: "off"
    property string netName: ""
    property string btMode: "off"
    property string btName: ""
    property int    bat: -1
    property string batStatus: ""
    property string wxIcon: ""
    property string wxTemp: ""
    property bool   showSeconds: false

    property string timeStr: ""
    property string dateStr: ""
    property int    typeIdx: 0

    function updateClock() {
        var now = new Date()
        timeStr = Qt.formatTime(now, showSeconds ? "hh:mm:ss" : "hh:mm")
        var d = now.toLocaleDateString(Qt.locale("es_MX"), "ddd d MMM").toUpperCase()
        if (d !== dateStr) { dateStr = d; typeIdx = 0 }
    }
    Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.updateClock() }
    Timer {
        interval: 45
        running: root.readyC && root.typeIdx < root.dateStr.length
        repeat: true
        onTriggered: root.typeIdx += 1
    }

    property bool readyL: false
    property bool readyC: false
    property bool readyR: false
    Timer { interval: 350;  running: true; onTriggered: root.readyL = true }
    Timer { interval: 600;  running: true; onTriggered: root.readyC = true }
    Timer { interval: 850;  running: true; onTriggered: root.readyR = true }

    P5Support.DataSource {
        id: exec
        engine: "executable"
        onNewData: function(source, data) {
            disconnectSource(source)
            var out = (data.stdout || "")
            if (source.indexOf("fantasma-islands") < 0) return
            var lines = out.split("\n")
            for (var i = 0; i < lines.length; i++) {
                var sp = lines[i].indexOf(" ")
                if (sp < 1) continue
                var k = lines[i].substring(0, sp)
                var v = lines[i].substring(sp + 1).trim()
                switch (k) {
                case "CPU":  root.cpu = parseInt(v) || 0; break
                case "RAM":  root.ram = parseInt(v) || 0; break
                case "VOL":  root.vol = parseInt(v) || 0; break
                case "MUTE": root.muted = (v === "1"); break
                case "NET": {
                    var p = v.indexOf("|")
                    root.netMode = v.substring(0, p)
                    root.netName = v.substring(p + 1)
                    break
                }
                case "BT": {
                    var q = v.indexOf("|")
                    root.btMode = v.substring(0, q)
                    root.btName = v.substring(q + 1)
                    break
                }
                case "BAT":  root.bat = parseInt(v); break
                case "BATS": root.batStatus = v; break
                case "WX": {
                    var w = v.indexOf("|")
                    if (w > 0) {
                        root.wxIcon = v.substring(0, w).trim()
                        root.wxTemp = v.substring(w + 1).replace("+", "").trim()
                    }
                    break
                }
                }
            }
        }
    }
    function runCmd(cmd) { exec.connectSource(cmd) }
    function pollNow()   { exec.connectSource(root.helper) }

    Timer { interval: 3000;    running: true; repeat: true; triggeredOnStart: true; onTriggered: root.pollNow() }
    Timer { interval: 1800000; running: true; repeat: true; onTriggered: root.runCmd(root.helper + " weather") }
    Timer { interval: 2500;    running: true; onTriggered: root.runCmd(root.helper + " weather") }

    TaskManager.VirtualDesktopInfo { id: vdInfo }

    readonly property int wsCount: vdInfo.numberOfDesktops
    readonly property int activeWs: {
        var ids = vdInfo.desktopIds
        for (var i = 0; i < ids.length; i++)
            if (ids[i] === vdInfo.currentDesktop) return i
        return 0
    }
    function switchWs(i) {
        runCmd("qdbus org.kde.KWin /KWin org.kde.KWin.setCurrentDesktop " + (i + 1))
    }

    TaskManager.TasksModel {
        id: tasksModel
        filterByVirtualDesktop: false
        filterByScreen: false
        filterByActivity: false
    }
    property var occupied: ({})
    Timer {
        id: occTimer
        interval: 120
        onTriggered: {
            var m = {}
            for (var i = 0; i < occRep.count; i++) {
                var it = occRep.itemAt(i)
                if (!it || !it.vds) continue
                for (var j = 0; j < it.vds.length; j++) m[it.vds[j]] = true
            }
            root.occupied = m
        }
    }
    Item {
        visible: false
        Repeater {
            id: occRep
            model: tasksModel
            onCountChanged: occTimer.restart()
            delegate: Item {
                property var vds: model.VirtualDesktops
                onVdsChanged: occTimer.restart()
                Component.onCompleted: occTimer.restart()
                Component.onDestruction: occTimer.restart()
            }
        }
    }

    SysTray.StatusNotifierModel { id: sniModel }

    function volIcon() {
        if (muted) return "󰝟"
        if (vol < 34) return "󰕿"
        if (vol < 67) return "󰖀"
        return "󰕾"
    }
    function netIcon() {
        if (netMode === "wifi") return "󰤨"
        if (netMode === "eth")  return "󰈀"
        return "󰤭"
    }
    function btIcon() {
        if (btMode === "on")   return "󰂱"
        if (btMode === "idle") return "󰂯"
        return "󰂲"
    }
    function batIcon() {
        if (batStatus === "Charging") return "󰂄"
        if (bat <= 10) return "󰁺"
        if (bat <= 30) return "󰁼"
        if (bat <= 50) return "󰁾"
        if (bat <= 70) return "󰂀"
        if (bat <= 90) return "󰂂"
        return "󰁹"
    }
    function batColor() {
        if (batStatus === "Charging") return cAmber
        if (bat >= 0 && bat <= 20) return cRose
        return cText
    }

    component Isla: Rectangle {
        height: root.barH
        radius: 13
        color: root.cBg
        border.width: 1
        border.color: root.cBorder
        Rectangle { x: 14; y: 0; width: 16; height: 2; radius: 1; color: root.cRose; opacity: 0.5 }
    }

    component IconBtn: Rectangle {
        id: btn
        property string glyph
        property color hoverColor: root.cViolet
        property string fontName: root.monoFont
        property int glyphSize: 17
        signal activated()
        property bool isHovered: btnMouse.containsMouse
        width: 30; height: 30; radius: 9
        anchors.verticalCenter: parent.verticalCenter
        color: isHovered ? root.cSurface : "transparent"
        Behavior on color { ColorAnimation { duration: 180 } }
        Text {
            anchors.centerIn: parent
            text: btn.glyph
            font.family: btn.fontName
            font.pixelSize: btn.glyphSize
            color: btn.isHovered ? btn.hoverColor : root.cText
            Behavior on color { ColorAnimation { duration: 180 } }
            scale: btn.isHovered ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }
        }
        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }
    }

    component SysPill: Rectangle {
        id: pill
        property string glyph
        property string label: ""
        property color accent: root.cText
        property bool dim: false
        signal activated()
        signal wheeled(int delta)
        property bool isHovered: pillMouse.containsMouse
        height: 30
        radius: 9
        anchors.verticalCenter: parent.verticalCenter
        width: pillRow.implicitWidth + 18
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }
        color: isHovered ? root.cSurface : Qt.rgba(0.902, 0.878, 0.918, 0.05)
        Behavior on color { ColorAnimation { duration: 180 } }
        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 6
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: pill.glyph
                font.family: root.monoFont
                font.pixelSize: 15
                color: pill.dim ? root.cFaint : pill.accent
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: pill.label !== ""
                text: pill.label
                font.family: root.monoFont
                font.pixelSize: 11
                font.bold: true
                color: pill.dim ? root.cFaint : root.cText
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.activated()
            onWheel: function(wheel) { pill.wheeled(wheel.angleDelta.y > 0 ? 1 : -1) }
        }
    }

    fullRepresentation: Item {
        id: bar
        implicitWidth: 1536
        implicitHeight: 46

        Row {
            id: leftGroup
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            opacity: root.readyL ? 1 : 0
            transform: Translate {
                x: root.readyL ? 0 : -36
                Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
            }
            Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

            Isla {
                width: accionesRow.implicitWidth + 16
                anchors.verticalCenter: parent.verticalCenter
                Row {
                    id: accionesRow
                    anchors.centerIn: parent
                    spacing: 4
                    IconBtn {
                        glyph: "幻"
                        fontName: root.kanjiFont
                        glyphSize: 16
                        hoverColor: root.cRose
                        onActivated: root.runCmd("qdbus org.kde.krunner /App org.kde.krunner.App.display")
                    }
                    IconBtn {
                        glyph: "󰒓"
                        hoverColor: root.cViolet
                        onActivated: root.runCmd("systemsettings")
                    }
                    IconBtn {
                        glyph: "󰄀"
                        hoverColor: root.cCyan
                        onActivated: root.runCmd("spectacle")
                    }
                    IconBtn {
                        glyph: "󰐥"
                        glyphSize: 15
                        hoverColor: root.cRose
                        onActivated: root.runCmd("qdbus org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt.promptAll")
                    }
                }
            }

            Isla {
                id: wsIsla
                width: wsRow.implicitWidth + 20
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                readonly property real pillW: 28
                readonly property real pillSpacing: 6
                readonly property real stepSize: pillW + pillSpacing

                Rectangle {
                    id: activeHighlight
                    y: (wsIsla.height - 28) / 2
                    height: 28
                    radius: 9
                    color: root.cViolet
                    visible: root.wsCount > 0

                    property int prevIdx: 0
                    property int curIdx: root.activeWs
                    onCurIdxChanged: {
                        if (curIdx > prevIdx)      { rightAnim.duration = 190; leftAnim.duration = 360 }
                        else if (curIdx < prevIdx) { leftAnim.duration = 190; rightAnim.duration = 360 }
                        prevIdx = curIdx
                    }

                    property real targetLeft: wsRow.x + curIdx * wsIsla.stepSize
                    property real targetRight: targetLeft + wsIsla.pillW
                    property real actualLeft: targetLeft
                    property real actualRight: targetRight
                    Behavior on actualLeft  { NumberAnimation { id: leftAnim;  duration: 250; easing.type: Easing.OutExpo } }
                    Behavior on actualRight { NumberAnimation { id: rightAnim; duration: 250; easing.type: Easing.OutExpo } }
                    x: actualLeft
                    width: actualRight - actualLeft
                }

                Row {
                    id: wsRow
                    anchors.centerIn: parent
                    spacing: wsIsla.pillSpacing
                    Repeater {
                        model: root.wsCount
                        delegate: Item {
                            id: wsPill
                            required property int index
                            property bool isActive: index === root.activeWs
                            property bool isOccupied: root.occupied[vdInfo.desktopIds[index]] === true
                            property bool isHovered: wsMouse.containsMouse
                            width: wsIsla.pillW
                            height: 28

                            property bool risen: false
                            opacity: risen ? 1 : 0
                            transform: Translate {
                                y: wsPill.risen ? 0 : 14
                                Behavior on y { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }
                            }
                            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                            Timer {
                                interval: 100 + wsPill.index * 60
                                running: root.readyL
                                onTriggered: wsPill.risen = true
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 9
                                color: wsPill.isHovered && !wsPill.isActive
                                       ? Qt.rgba(0.902, 0.878, 0.918, 0.10)
                                       : (wsPill.isOccupied && !wsPill.isActive
                                          ? Qt.rgba(0.902, 0.878, 0.918, 0.06) : "transparent")
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: root.kanjiNum[wsPill.index] || (wsPill.index + 1)
                                font.family: root.kanjiFont
                                font.pixelSize: 13
                                font.bold: wsPill.isActive || wsPill.isOccupied
                                color: wsPill.isActive ? root.cInk
                                       : (wsPill.isOccupied || wsPill.isHovered ? root.cText : root.cFaint)
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            MouseArea {
                                id: wsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.switchWs(wsPill.index)
                            }
                        }
                    }
                }
            }
        }

        Isla {
            id: centroIsla
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: Math.max(0, (Screen.width - bar.width) / 2)
            anchors.verticalCenter: parent.verticalCenter
            width: centroRow.implicitWidth + 34
            property bool isHovered: centroMouse.containsMouse
            color: isHovered ? root.cSurface : root.cBg
            border.color: Qt.rgba(0.902, 0.878, 0.918, isHovered ? 0.14 : 0.08)

            opacity: root.readyC ? 1 : 0
            transform: Translate {
                y: root.readyC ? 0 : -26
                Behavior on y { NumberAnimation { duration: 700; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
            }
            Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            scale: isHovered ? 1.03 : 1.0
            Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
            Behavior on color { ColorAnimation { duration: 200 } }

            MouseArea {
                id: centroMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.showSeconds = !root.showSeconds
            }

            Row {
                id: centroRow
                anchors.centerIn: parent
                spacing: 16

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -1
                    Text {
                        text: root.timeStr
                        font.family: root.monoFont
                        font.pixelSize: 15
                        font.weight: Font.Black
                        color: root.cViolet
                    }
                    Text {
                        text: root.dateStr.substring(0, root.typeIdx)
                        font.family: root.monoFont
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1
                        color: root.cFaint
                    }
                }

                Rectangle {
                    visible: root.wxTemp !== ""
                    width: 1; height: 22
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.cBorder
                }

                Row {
                    visible: root.wxTemp !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.wxIcon
                        font.pixelSize: 14
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.wxTemp
                        font.family: root.monoFont
                        font.pixelSize: 13
                        font.weight: Font.Black
                        color: root.cAmber
                    }
                }
            }
        }

        Row {
            id: rightGroup
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            opacity: root.readyR ? 1 : 0
            transform: Translate {
                x: root.readyR ? 0 : 36
                Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
            }
            Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

            Isla {
                id: trayIsla
                anchors.verticalCenter: parent.verticalCenter
                width: trayRow.implicitWidth + 18
                visible: trayRow.implicitWidth > 8
                clip: true
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }

                Row {
                    id: trayRow
                    anchors.centerIn: parent
                    spacing: 4

                    Repeater {
                        model: sniModel
                        delegate: Rectangle {
                            id: sniPill
                            visible: String(model.Status) !== "Passive"
                            property bool isHovered: sniMouse.containsMouse
                            width: 28; height: 28; radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            color: isHovered ? root.cSurface : "transparent"
                            Behavior on color { ColorAnimation { duration: 180 } }

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 17; height: 17
                                source: model.IconName || model.decoration || "application-x-executable"
                                scale: sniPill.isHovered ? 1.15 : 1.0
                                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }
                            }
                            MouseArea {
                                id: sniMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                onClicked: function(mouse) {
                                    var src = String(model.DataEngineSource || "")
                                    var slash = src.indexOf("/")
                                    if (slash < 1) return
                                    var svc = src.substring(0, slash)
                                    var path = src.substring(slash)
                                    var op = mouse.button === Qt.RightButton ? "menu"
                                           : mouse.button === Qt.MiddleButton ? "secondary"
                                           : "activate"
                                    var p = sniPill.mapToGlobal(0, sniPill.height + 6)
                                    root.runCmd(root.helper + " sni " + svc + " " + path + " " + op
                                                + " " + Math.round(p.x) + " " + Math.round(p.y))
                                }
                            }
                        }
                    }
                }
            }

            Isla {
                id: sisIsla
                anchors.verticalCenter: parent.verticalCenter
                width: sisRow.implicitWidth + 20

            Row {
                id: sisRow
                anchors.centerIn: parent
                spacing: 6

                SysPill {
                    glyph: "󰻠"
                    label: root.cpu + "%"
                    accent: root.cpu > 80 ? root.cRose : root.cCyan
                    onActivated: root.runCmd("plasma-systemmonitor")
                }
                SysPill {
                    glyph: "󰍛"
                    label: root.ram + "%"
                    accent: root.ram > 85 ? root.cRose : root.cViolet
                    onActivated: root.runCmd("plasma-systemmonitor")
                }
                SysPill {
                    glyph: root.volIcon()
                    label: root.muted ? "MUTE" : root.vol + "%"
                    accent: root.cText
                    dim: root.muted
                    onActivated: {
                        root.runCmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
                        root.muted = !root.muted
                        pollTouch.restart()
                    }
                    onWheeled: function(delta) {
                        root.vol = Math.max(0, Math.min(100, root.vol + delta * 5))
                        root.runCmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " + root.vol + "%")
                        pollTouch.restart()
                    }
                }
                SysPill {
                    glyph: root.netIcon()
                    label: root.netMode === "wifi"
                           ? (root.netName.length > 12 ? root.netName.substring(0, 11) + "…" : root.netName)
                           : (root.netMode === "eth" ? "LAN" : "")
                    accent: root.cCyan
                    dim: root.netMode === "off"
                    onActivated: root.runCmd("plasmawindowed org.kde.plasma.networkmanagement")
                }
                SysPill {
                    glyph: root.btIcon()
                    label: root.btMode === "on"
                           ? (root.btName.length > 12 ? root.btName.substring(0, 11) + "…" : root.btName)
                           : ""
                    accent: root.cViolet
                    dim: root.btMode !== "on"
                    onActivated: root.runCmd("plasmawindowed org.kde.plasma.bluetooth")
                }
                SysPill {
                    visible: root.bat >= 0
                    glyph: root.batIcon()
                    label: root.bat + "%"
                    accent: root.batColor()
                    onActivated: root.runCmd("plasmawindowed org.kde.plasma.battery")
                }
                SysPill {
                    glyph: "󰅍"
                    accent: root.cAmber
                    onActivated: root.runCmd("plasmawindowed org.kde.plasma.clipboard")
                }
            }
            }
        }

        Timer { id: pollTouch; interval: 350; onTriggered: root.pollNow() }
    }
}
