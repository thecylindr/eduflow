import QtQuick
import Qt5Compat.GraphicalEffects

Repeater {
    id: polygonRepeater

    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Screen.width < 768
    property int polygonCount: isMobile ? 2 : 15

    model: isMobile ? 6 : polygonCount
    z: 1

    Item {
        id: polygonContainer
        property real startX: Math.random() * (parent.width + 120) - 60
        property real startY: Math.random() * (parent.height + 120) - 60
        property real targetX: Math.random() * (parent.width + 120) - 60
        property real targetY: Math.random() * (parent.height + 120) - 60
        property real polygonSize: isMobile ? (20 + Math.random() * 30) : (30 + Math.random() * 45)
        property color polygonColor: [
            "#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
            "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE",
            "#FFA500", "#AFEEEE", "#4169E1", "#FFFFF0", "#696969",
            "#CD853F", "#483D8B", "#FF8C00", "#006400", "#2E8B57"
        ][Math.floor(Math.random() * 20)]

        x: startX
        y: startY
        opacity: 0
        width: polygonSize * 2
        height: polygonSize * 2
        z: 0

        Canvas {
            id: polygonCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                drawPolygon(ctx);
            }

            function drawPolygon(ctx) {
                var sides = isMobile ? 6 : (6 + Math.floor(Math.random() * 3));
                var radius = polygonSize;
                var centerX = width / 2;
                var centerY = height / 2;

                if (!isMobile) {
                    ctx.shadowColor = polygonColor;
                    ctx.shadowBlur = 12;
                }

                ctx.beginPath();
                ctx.moveTo(centerX + radius * Math.cos(0), centerY + radius * Math.sin(0));

                for (var i = 1; i <= sides; i++) {
                    ctx.lineTo(centerX + radius * Math.cos(i * 2 * Math.PI / sides),
                              centerY + radius * Math.sin(i * 2 * Math.PI / sides));
                }

                ctx.closePath();
                ctx.fillStyle = polygonColor;
                ctx.fill();
            }
        }

        Glow {
            anchors.fill: polygonCanvas
            radius: isMobile ? 4 : 10
            samples: isMobile ? 6 : 12
            color: polygonContainer.polygonColor
            source: polygonCanvas
            opacity: polygonContainer.opacity * 0.6
            visible: !isMobile
        }

        SequentialAnimation {
            id: appearAnimation
            running: true
            loops: Animation.Infinite
            PauseAnimation { duration: index * (isMobile ? 5000 : 1200) }
            ParallelAnimation {
                NumberAnimation {
                    target: polygonContainer; property: "opacity"; from: 0; to: isMobile ? 0.4 : 0.6;
                    duration: isMobile ? 7000 : 3000; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: polygonContainer; property: "x"; from: startX; to: targetX;
                    duration: isMobile ? 18000 : 12000; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: polygonContainer; property: "y"; from: startY; to: targetY;
                    duration: isMobile ? 24000 : 12000; easing.type: Easing.InOutQuad }
                RotationAnimation {
                    target: polygonContainer; from: 0; to: isMobile ? (45 + Math.random() * 45) : (90 + Math.random() * 90);
                    duration: isMobile ? 22000 : 10000; easing.type: Easing.InOutQuad }
            }
            PauseAnimation { duration: isMobile ? 4000 : 3000 }
            ParallelAnimation {
                NumberAnimation {
                    target: polygonContainer; property: "opacity"; from: (isMobile ? 0.4 : 0.6); to: 0;
                    duration: isMobile ? 9000 : 4000; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: polygonContainer; property: "x"; from: targetX; to: targetX + (Math.random() - 0.5) * (isMobile ? 100 : 150);
                    duration: isMobile ? 9000 : 4000; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: polygonContainer; property: "y"; from: targetY; to: targetY + (Math.random() - 0.5) * (isMobile ? 100 : 150);
                    duration: isMobile ? 14000 : 4000; easing.type: Easing.InOutQuad }
            }
            PauseAnimation { duration: isMobile ? (3000 + Math.random() * 4000) : (2000 + Math.random() * 3000) }
            ScriptAction {
                script: {
                    polygonContainer.startX = polygonContainer.x;
                    polygonContainer.startY = polygonContainer.y;
                    polygonContainer.targetX = Math.random() * (parent.width + (isMobile ? 100 : 150)) - (isMobile ? 50 : 75);
                    polygonContainer.targetY = Math.random() * (parent.height + (isMobile ? 100 : 150)) - (isMobile ? 50 : 75);
                    polygonContainer.polygonColor = [
                            "#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
                            "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE",
                            "#FFA500", "#AFEEEE", "#4169E1", "#FFFFF0", "#696969",
                            "#CD853F", "#483D8B", "#FF8C00", "#006400", "#2E8B57"
                    ][Math.floor(Math.random() * 20)];
                    polygonCanvas.requestPaint();
                }
            }
        }
        Component.onCompleted: polygonCanvas.requestPaint()
    }
}
