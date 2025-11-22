// FormattedText.qml
import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    height: textContent.height

    property string text: ""
    property var formats: []
    property string alignment: "left"
    property bool isMobile: false

    // Принудительное обновление при изменении ширины
    onWidthChanged: {
        Qt.callLater(updateLayout)
    }

    function updateLayout() {
        textContent.text = generateCorrectFormattedText(root.text, root.formats)
    }

    // Генерация форматированного текста
    function generateCorrectFormattedText(text, formats) {
        if (!formats || formats.length === 0) {
            return text;
        }

        var tags = [];
        for (var i = 0; i < formats.length; i++) {
            var format = formats[i];
            var start = Math.max(0, Math.min(format.start, text.length));
            var end = Math.max(0, Math.min(format.end, text.length));

            if (start >= end) continue;

            tags.push({ position: start, html: getOpeningTag(format.type), isOpening: true });
            tags.push({ position: end, html: getClosingTag(format.type), isOpening: false });
        }

        if (tags.length === 0) return text;

        tags.sort(function(a, b) {
            if (a.position !== b.position) return b.position - a.position;
            return a.isOpening ? 1 : -1;
        });

        var result = text;
        for (var j = 0; j < tags.length; j++) {
            var tag = tags[j];
            result = result.substring(0, tag.position) + tag.html + result.substring(tag.position);
        }

        return result;
    }

    function getOpeningTag(formatType) {
        switch(formatType) {
            case "bold": return "<b>";
            case "italic": return "<i>";
            case "bold_italic": return "<b><i>";
            case "header1": return '<span style="font-size: ' + (root.isMobile ? '20' : '22') + 'px; font-weight: bold;">';
            case "header2": return '<span style="font-size: ' + (root.isMobile ? '18' : '20') + 'px; font-weight: bold;">';
            case "header3": return '<span style="font-size: ' + (root.isMobile ? '16' : '18') + 'px; font-weight: bold;">';
            default: return "";
        }
    }

    function getClosingTag(formatType) {
        switch(formatType) {
            case "bold": return "</b>";
            case "italic": return "</i>";
            case "bold_italic": return "</i></b>";
            case "header1": return "</span>";
            case "header2": return "</span>";
            case "header3": return "</span>";
            default: return "";
        }
    }

    TextEdit {
        id: textContent
        width: parent.width
        text: root.generateCorrectFormattedText(root.text, root.formats)
        textFormat: TextEdit.RichText
        wrapMode: TextEdit.WordWrap
        readOnly: true
        selectByMouse: true
        selectionColor: "#3498db"
        color: "#2c3e50"

        // Увеличенный размер текста
        font.pixelSize: root.isMobile ? 16 : 17

        // Выравнивание
        horizontalAlignment: {
            switch(root.alignment) {
                case "left": return Text.AlignLeft;
                case "right": return Text.AlignRight;
                case "center": return Text.AlignHCenter;
                case "justify": return Text.AlignJustify;
                default: return Text.AlignLeft;
            }
        }

        // Обновление layout при изменении размеров
        onWidthChanged: {
            Qt.callLater(function() {
                var currentText = textContent.text;
                textContent.text = "";
                textContent.text = currentText;
            })
        }
    }
}
