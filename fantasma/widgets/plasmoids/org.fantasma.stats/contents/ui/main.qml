import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property color cRose:   "#ff7fb8"
    readonly property color cViolet: "#c88ff0"
    readonly property color cCyan:   "#3ad6e6"
    readonly property color cAmber:  "#ffd88a"
    readonly property color cText:   "#e6e0ea"
    readonly property color cFaint:  "#776c92"
    readonly property color cLine:   "#2b2040"
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    property int    cpu:  0
    property string freq: "–"
    property string gpu:  "–"
    property int    ram:  0
    property string ramu: "–"
    property string ramt: "–"
    property string temp: "–"
    property string ssd:  "–"
    property string ssdf: "–"
    property string netd: "0.0"
    property string netu: "0.0"
    property string bat:  "–"
    property string bats: "–"
    property string up:   "–"

    readonly property int maxN: 56
    readonly property int pollMs: 1500
    property var hCpu:  []
    property var hGpu:  []
    property var hRam:  []
    property var hTemp: []
    property int sampleTick: 0
    property real scrollPx: 0

    function pushSample(c, g, r, t) {
        hCpu.push(c); hGpu.push(g); hRam.push(r); hTemp.push(t)
        if (hCpu.length > maxN) {
            hCpu.shift(); hGpu.shift(); hRam.shift(); hTemp.shift()
        }
        sampleTick++
    }

    readonly property string helper: "/home/xishay/.local/bin/fantasma-stats"

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    P5Support.DataSource {
        id: exec
        engine: "executable"
        onNewData: function(source, data) {
            disconnectSource(source)
            if (source === root.helper) {
                var lines = (data.stdout || "").split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var sp = lines[i].indexOf(" ")
                    if (sp < 1) continue
                    var k = lines[i].substring(0, sp)
                    var v = lines[i].substring(sp + 1).trim()
                    switch (k) {
                    case "CPU":  root.cpu  = parseInt(v) || 0; break
                    case "FREQ": root.freq = v; break
                    case "GPU":  root.gpu  = v; break
                    case "RAM":  root.ram  = parseInt(v) || 0; break
                    case "RAMU": root.ramu = v; break
                    case "RAMT": root.ramt = v; break
                    case "TEMP": root.temp = v; break
                    case "SSD":  root.ssd  = v; break
                    case "SSDF": root.ssdf = v; break
                    case "NETD": root.netd = v; break
                    case "NETU": root.netu = v; break
                    case "BAT":  root.bat  = v; break
                    case "BATS": root.bats = v; break
                    case "UP":   root.up   = v; break
                    }
                }
                root.pushSample(root.cpu,
                                parseInt(root.gpu)  || 0,
                                root.ram,
                                parseInt(root.temp) || 0)
            }
        }
    }
    Timer {
        interval: root.pollMs; running: true; repeat: true; triggeredOnStart: true
        onTriggered: exec.connectSource(root.helper)
    }

    component Vital: Item {
        id: vit
        property string v
        property string l
        property color c: root.cText
        property bool sep: true
        Column {
            anchors.centerIn: parent
            spacing: 1
            Text {
                text: vit.v
                color: vit.c
                font.family: root.monoFont
                font.pixelSize: 13
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: vit.l
                color: root.cFaint
                font.family: root.monoFont
                font.pixelSize: 8
                font.letterSpacing: 1.5
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Rectangle {
            visible: vit.sep
            width: 1
            color: root.cLine
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        }
    }

    component Bracket: Item {
        id: br
        property bool atTop: true
        property bool atLeft: true
        property color c: root.cCyan
        width: 16; height: 16
        Rectangle { width: 16; height: 2; color: br.c; y: br.atTop ? 0 : 14 }
        Rectangle { width: 2; height: 16; color: br.c; x: br.atLeft ? 0 : 14 }
    }

    fullRepresentation: Item {
        id: panel
        implicitWidth: 400
        implicitHeight: 240

        Rectangle {
            anchors.fill: parent
            radius: 4
            color: "#12101e"
            opacity: 0.93
            border.color: Qt.rgba(0.227, 0.839, 0.902, 0.4)
            border.width: 1
        }

        Item {
            id: header
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 1 }
            height: 28

            Row {
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                spacing: 12
                Repeater {
                    model: [
                        { c: root.cRose,   l: "CPU"  },
                        { c: root.cAmber,  l: "GPU"  },
                        { c: root.cViolet, l: "RAM"  },
                        { c: root.cCyan,   l: "TEMP" }
                    ]
                    Row {
                        spacing: 5
                        required property var modelData
                        Rectangle {
                            width: 6; height: 6; radius: 2
                            color: parent.modelData.c
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: parent.modelData.l
                            color: root.cFaint
                            font.family: root.monoFont
                            font.pixelSize: 8
                            font.letterSpacing: 2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            Row {
                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                spacing: 8
                Rectangle {
                    width: 7; height: 7; radius: 3.5
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.cRose
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.25; duration: Math.max(250, 550 - root.cpu * 4) }
                        NumberAnimation { to: 1.0;  duration: Math.max(250, 550 - root.cpu * 4) }
                    }
                }
                Text {
                    text: "SYS ALIVE"
                    color: root.cCyan
                    font.family: root.monoFont
                    font.pixelSize: 10
                    font.letterSpacing: 3
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1; color: root.cLine
            }
        }

        Column {
            id: vitals
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: 1 }

            Rectangle { width: parent.width; height: 1; color: root.cLine }
            Row {
                id: row1
                width: parent.width
                height: 39
                Vital { width: row1.width / 4; height: row1.height; v: root.cpu + "%";   l: "CPU · " + root.freq + " GHZ";                c: root.cRose }
                Vital { width: row1.width / 4; height: row1.height; v: root.gpu + "%";   l: "GPU";                                        c: root.cAmber }
                Vital { width: row1.width / 4; height: row1.height; v: root.ram + "%";   l: "RAM · " + root.ramu + "/" + root.ramt + "G"; c: root.cViolet }
                Vital { width: row1.width / 4; height: row1.height; v: root.temp + "°C"; l: "TEMP";                                       c: root.cCyan; sep: false }
            }
            Rectangle { width: parent.width; height: 1; color: root.cLine }
            Row {
                id: row2
                width: parent.width
                height: 39
                Vital { width: row2.width / 4; height: row2.height; v: root.ssd + "%"; l: "SSD · " + root.ssdf + "G FREE" }
                Vital { width: row2.width / 4; height: row2.height; v: "↓" + root.netd + " ↑" + root.netu; l: "NET MB/S" }
                Vital { width: row2.width / 4; height: row2.height; v: root.bat + "%"; l: "BAT · " + root.bats.toUpperCase() }
                Vital { width: row2.width / 4; height: row2.height; v: root.up; l: "UPTIME"; sep: false }
            }
        }

        Item {
            anchors { top: header.bottom; bottom: vitals.top; left: parent.left; right: parent.right; leftMargin: 1; rightMargin: 1 }
            clip: true

            Canvas {
                id: scope
                anchors.fill: parent
                property int lastTick: 0
                readonly property real stepPx: (width - 10) / (root.maxN - 1)

                Timer {
                    interval: 40; running: scope.visible; repeat: true
                    onTriggered: {
                        if (scope.lastTick !== root.sampleTick) {
                            scope.lastTick = root.sampleTick
                            root.scrollPx -= scope.stepPx
                        }
                        root.scrollPx = Math.min(root.scrollPx + scope.stepPx * 40 / root.pollMs,
                                                 scope.stepPx)
                        scope.requestPaint()
                    }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    var w = width, h = height
                    if (w <= 0 || h <= 0) return
                    ctx.clearRect(0, 0, w, h)

                    ctx.strokeStyle = "rgba(200,143,240,0.055)"
                    ctx.lineWidth = 1
                    ctx.beginPath()
                    for (var gx = 39.5; gx < w; gx += 40) { ctx.moveTo(gx, 0); ctx.lineTo(gx, h) }
                    for (var gy = 19.5; gy < h; gy += 20) { ctx.moveTo(0, gy); ctx.lineTo(w, gy) }
                    ctx.stroke()

                    if (root.hCpu.length < 2) return

                    var n = root.hCpu.length
                    var full = (n >= root.maxN)
                    var step = full ? scope.stepPx : (w - 10) / (n - 1)
                    var scroll = full ? root.scrollPx : 0
                    var pad = 6
                    var span = h - pad * 2

                    function yFor(v) {
                        var c = Math.max(0, Math.min(100, v))
                        return pad + (1 - c / 100) * span
                    }
                    function trace(arr, colr, lw, alpha) {
                        ctx.strokeStyle = colr
                        ctx.globalAlpha = alpha
                        ctx.lineWidth = lw
                        ctx.lineJoin = "round"
                        ctx.beginPath()
                        for (var i = 0; i < n; i++) {
                            var x = 5 + i * step - scroll
                            var y = yFor(arr[i])
                            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                        }
                        ctx.stroke()
                        ctx.globalAlpha = 1
                    }

                    trace(root.hTemp, "#3ad6e6", 4.0, 0.10); trace(root.hTemp, "#3ad6e6", 1.6, 0.85)
                    trace(root.hRam,  "#c88ff0", 4.0, 0.10); trace(root.hRam,  "#c88ff0", 1.6, 0.85)
                    trace(root.hGpu,  "#ffd88a", 4.0, 0.10); trace(root.hGpu,  "#ffd88a", 1.6, 0.85)
                    trace(root.hCpu,  "#ff7fb8", 4.5, 0.14); trace(root.hCpu,  "#ff7fb8", 1.8, 1.0)
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
            cursorShape: Qt.PointingHandCursor
            onClicked: exec.connectSource("plasma-systemmonitor")
        }
    }
}
