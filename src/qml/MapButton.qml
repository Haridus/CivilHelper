import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtLocation 5.3
import QtPositioning 5.2
import QtGraphicalEffects 1.0

Rectangle {
    property string source: ""

    width:  size_icon_common
    height: size_icon_common
    radius: size_icon_common
    opacity: 1.0
    color: "white"

    Image {
        anchors.centerIn: parent
        width: parent.width*0.5
        height: parent.height*0.5
        fillMode: Image.Stretch
        source: parent.source
    }

    layer.enabled: true

    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 2
        verticalOffset: 2
    }
}
