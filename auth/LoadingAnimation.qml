import QtQuick 2.15

Rectangle {
    id: loadingAnimation
    width: 50
    height: 50
    radius: 25
    color: "transparent"
    visible: false
    opacity: 0
    z: 20

    Behavior on opacity { NumberAnimation { duration: 300 } }

    RotationAnimation {
        target: loadingAnimation
        running: loadingAnimation.visible
        from: 0
        to: 360
        duration: 1000
        loops: Animation.Infinite
    }

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = "#3498db";
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.arc(width/2, height/2, width/2 - 2, 0, Math.PI * 1.5);
            ctx.stroke();
        }
    }
}
