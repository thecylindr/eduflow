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

    property real blurHeight: 24
    property color startColor: "#2575fc"
    property color endColor: "#1a5fd8"
    property real blurRadius: 24
    property int blurSamples: 16
    property real blurOpacity: 0.8
    property bool isMobile: false

    visible: isMobile && parent.width < parent.height

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

    // Эффект размытия (только для производительных устройств)
    FastBlur {
        anchors.fill: blurSource
        source: blurSource
        radius: root.blurRadius
        opacity: root.blurOpacity
        visible: !isMobile || (isMobile && blurHeight > 10) // На мобильных только при достаточной высоте
    }

    // Упрощенный вариант для мобильных - простой градиент
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.3; color: "#40000000" }
            GradientStop { position: 1.0; color: "#80000000" }
        }
        opacity: isMobile ? 0.4 : 0.3
        visible: isMobile
    }
}
