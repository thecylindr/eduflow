import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }
    height: blurHeight

    property real blurHeight: 48
    property color startColor: "#2575fc"
    property color endColor: "#1a5fd8"
    property real blurRadius: 20
    property int blurSamples: 32
    property real blurOpacity: 0.925
    property bool isMobile: false

    visible: isMobile

    // Градиентный фон для блюра
    Rectangle {
        id: blurSource
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.startColor }
            GradientStop { position: 1.0; color: root.endColor }
        }
        visible: false
    }

    // Эффект размытия
    GaussianBlur {
        anchors.fill: blurSource
        source: blurSource
        radius: root.blurRadius
        samples: root.blurSamples
        opacity: root.blurOpacity
    }

    // Дополнительный затемняющий слой для лучшего эффекта
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "#60000000" }
        }
        opacity: 0.3
    }
}
