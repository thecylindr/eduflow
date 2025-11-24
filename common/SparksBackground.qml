import QtQuick
import Qt5Compat.GraphicalEffects

Repeater {
    id: sparksRepeater

    property var colors: ["#f44336", "#ff9800", "#ffeb3b", "#4caf50", "#2196f3", "#9c27b0"]
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" || Qt.platform.os === "tvos"
    property real maxSparkSize: isMobile ? 4 : 6
    property real minSparkSize: isMobile ? 2 : 3
    property int sparkCount: 16

    model: isMobile ? 8 : sparkCount

    Rectangle {
        id: spark
        width: isMobile ? (minSparkSize + Math.random() * (maxSparkSize - 2 - minSparkSize)) :
                         (minSparkSize + Math.random() * (maxSparkSize - minSparkSize))
        height: width
        radius: width / 2
        color: colors[Math.floor(Math.random() * colors.length)]
        opacity: 0
        z: 0

        property real startX: Math.random() * parent.width
        property real startY: Math.random() * parent.height
        property real targetX: Math.random() * parent.width
        property real targetY: Math.random() * parent.height
        property real speed: isMobile ? (700 + Math.random() * 500) : (1000 + Math.random() * 2000)

        x: startX
        y: startY

        layer.enabled: !isMobile
        layer.effect: Glow {
            color: spark.color
            radius: 8
            samples: 16
            transparentBorder: true
        }

        SequentialAnimation {
            running: true
            loops: Animation.Infinite
            PauseAnimation { duration: Math.random() * (isMobile ? 14000 : 2000) }
            ParallelAnimation {
                NumberAnimation {
                    target: spark; property: "opacity"; from: 0; to: isMobile ? 0.6 : 0.8;
                    duration: isMobile ? 700 : 500; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: spark; property: "x"; from: startX; to: targetX; duration: speed; easing.type: Easing.InOutQuad }
                NumberAnimation {
                    target: spark; property: "y"; from: startY; to: targetY; duration: speed; easing.type: Easing.InOutQuad }
            }
            NumberAnimation {
                target: spark; property: "opacity"; to: 0; duration: isMobile ? 800 : 500; easing.type: Easing.InOutQuad }  // Медленнее исчезновение
            ScriptAction {
                script: {
                    spark.startX = Math.random() * parent.width;
                    spark.startY = Math.random() * parent.height;
                    spark.targetX = Math.random() * parent.width;
                    spark.targetY = Math.random() * parent.height;
                    spark.color = colors[Math.floor(Math.random() * colors.length)];
                    spark.speed = isMobile ? (1800 + Math.random() * 1500) : (1000 + Math.random() * 2000);
                }
            }
        }
    }
}
