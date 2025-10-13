// main/PolygonBackground.qml
import QtQuick 2.15

Canvas {
    id: canvas
    anchors.fill: parent
    renderTarget: Canvas.FramebufferObject
    renderStrategy: Canvas.Cooperative

    property var polygons: []
    property int maxPolygons: 8
    property bool initialized: false

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        for (var i = 0; i < polygons.length; i++) {
            drawPolygon(ctx, polygons[i])
        }
    }

    function initializePolygons() {
        if (initialized) return

        polygons = []
        for (var i = 0; i < maxPolygons; i++) {
            polygons.push(createPolygon())
        }
        initialized = true
        canvas.requestPaint()
    }

    function createPolygon() {
        var colors = ["#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
                     "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE"]
        return {
            x: Math.random() * width,
            y: Math.random() * height,
            size: 30 + Math.random() * 40,
            color: colors[Math.floor(Math.random() * colors.length)],
            rotation: Math.random() * 360,
            sides: 5 + Math.floor(Math.random() * 4),
            opacity: 0.3 + Math.random() * 0.3,
            speedX: (Math.random() - 0.5) * 0.5,
            speedY: (Math.random() - 0.5) * 0.5,
            rotationSpeed: (Math.random() - 0.5) * 0.5
        }
    }

    function drawPolygon(ctx, poly) {
        ctx.save()
        ctx.translate(poly.x, poly.y)
        ctx.rotate(poly.rotation * Math.PI / 180)
        ctx.globalAlpha = poly.opacity

        ctx.beginPath()
        for (var i = 0; i <= poly.sides; i++) {
            var angle = (i * 2 * Math.PI / poly.sides)
            var x = poly.size * Math.cos(angle)
            var y = poly.size * Math.sin(angle)

            if (i === 0) {
                ctx.moveTo(x, y)
            } else {
                ctx.lineTo(x, y)
            }
        }

        ctx.closePath()
        ctx.fillStyle = poly.color
        ctx.fill()
        ctx.restore()
    }

    function updatePolygons() {
        for (var i = 0; i < polygons.length; i++) {
            var poly = polygons[i]

            poly.x += poly.speedX
            poly.y += poly.speedY
            poly.rotation += poly.rotationSpeed

            // Wrap around edges
            if (poly.x < -poly.size) poly.x = width + poly.size
            if (poly.x > width + poly.size) poly.x = -poly.size
            if (poly.y < -poly.size) poly.y = height + poly.size
            if (poly.y > height + poly.size) poly.y = -poly.size
        }

        canvas.requestPaint()
    }

    Component.onCompleted: {
        initializePolygons()
        animationTimer.start()
    }

    Timer {
        id: animationTimer
        interval: 50 // 20 FPS вместо 60 для оптимизации
        running: false
        repeat: true
        onTriggered: updatePolygons()
    }

    onWidthChanged: {
        initialized = false
        initializePolygons()
    }

    onHeightChanged: {
        initialized = false
        initializePolygons()
    }
}
