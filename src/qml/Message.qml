import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

Rectangle {
    id: root
    width: main.swidth*0.75
    height: title.height*1.2
    color: "white"
    border.width: 1
    border.color: "black"
    opacity: 0.7
    radius: Math.min(width,height)/2

    property string text

    function show() {
        visible = true
    }

    Text {
        id: title
        width: parent.width*0.9
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: font_size_point_text_text_medium
        color: "black"
        wrapMode: Text.Wrap
        text: root.text
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
    }

    SequentialAnimation on visible {
        running: visible
        NumberAnimation { from: 1; to: 0; duration: 2000; easing.type: Easing.InQuart }
    }
}
