// common/DisplayUtils.qml
import QtQuick

Item {
    // Функции для работы с размерами экрана

    function dp(value) {
        var screen = Screen
        var baseDpi = 160
        var density = screen.pixelDensity * 25.4
        return Math.round(value * (density / baseDpi))
    }

    function screenPercent(percent) {
        return Math.min(Screen.width, Screen.height) * percent / 100
    }

    function isTallScreen() {
        var ratio = Math.max(Screen.width, Screen.height) / Math.min(Screen.width, Screen.height)
        return ratio > 2.0
    }

    function hasHighDensity() {
        return Screen.pixelDensity > 3.0
    }

    function getNavigationType() {
        if (Qt.platform.os !== "android") return "desktop"

        if (isTallScreen() && hasHighDensity()) {
            return "gesture"
        } else {
            return "buttons"
        }
    }

    function calculateTopMargin() {
        if (Qt.platform.os !== "android") return 0

        var baseMargin = 24 // Базовый отступ для статус бара

        // Дополнительный отступ для устройств с вырезом/камерой
        if (hasNotch()) baseMargin += 16

        return dp(baseMargin)
    }

    function calculateBottomMargin() {
        if (Qt.platform.os !== "android") return 0

        var baseMargin = 0
        switch(getNavigationType()) {
            case "gesture": baseMargin = 32; break
            case "buttons": baseMargin = 48; break
            default: baseMargin = 0
        }

        return dp(baseMargin)
    }

    function hasNotch() {
        if (Qt.platform.os !== "android") return false

        var screen = Screen
        var isTallScreen = screen.height > 2000 // Высокий экран
        var isModernDevice = screen.pixelDensity > 2.5

        return isTallScreen && isModernDevice
    }
}
