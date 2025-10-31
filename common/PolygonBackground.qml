import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Repeater {
    id: polygonRepeater
    model: 15
    z: 1

    Item {
        id: polygonContainer
        property real startX: Math.random() * (parent.width + 120) - 60
        property real startY: Math.random() * (parent.height + 120) - 60
        property real targetX: Math.random() * (parent.width + 120) - 60
        property real targetY: Math.random() * (parent.height + 120) - 60
        property real polygonSize: 30 + Math.random() * 45
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
                var sides = 6 + Math.floor(Math.random() * 3);
                var radius = polygonSize;
                var centerX = width / 2;
                var centerY = height / 2;

                ctx.shadowColor = polygonColor;
                ctx.shadowBlur = 12;

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
            radius: 10
            samples: 12
            color: polygonContainer.polygonColor
            source: polygonCanvas
            opacity: polygonContainer.opacity * 0.6
        }

        SequentialAnimation {
            id: appearAnimation
            running: true
            loops: Animation.Infinite
            PauseAnimation { duration: index * 1200 }
            ParallelAnimation {
                NumberAnimation {
                    target: polygonContainer; property: "opacity"; from: 0; to: 0.6; duration: 3000; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: polygonContainer; property: "x"; from: startX; to: targetX; duration: 12000; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: polygonContainer; property: "y"; from: startY; to: targetY; duration: 12000; easing.type: Easing.InOutQuad }
                RotationAnimation {
                    target: polygonContainer; from: 0; to: 90 + Math.random() * 90; duration: 10000; easing.type: Easing.InOutQuad }
            }
            PauseAnimation { duration: 3000 }
            ParallelAnimation {
                NumberAnimation {
                    target: polygonContainer; property: "opacity"; from: 0.6; to: 0; duration: 4000; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: polygonContainer; property: "x"; from: targetX; to: targetX + (Math.random() - 0.5) * 150; duration: 4000; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: polygonContainer; property: "y"; from: targetY; to: targetY + (Math.random() - 0.5) * 150; duration: 4000; easing.type: Easing.InOutQuad }
            }
            PauseAnimation { duration: 2000 + Math.random() * 3000 }
            ScriptAction {
                script: {
                    polygonContainer.startX = polygonContainer.x;
                    polygonContainer.startY = polygonContainer.y;
                    polygonContainer.targetX = Math.random() * (parent.width + 150) - 75;
                    polygonContainer.targetY = Math.random() * (parent.height + 150) - 75;
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
