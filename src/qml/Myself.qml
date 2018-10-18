import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtLocation 5.3
import QtPositioning 5.2

MapQuickItem {
    anchorPoint.x: image.width/2
    anchorPoint.y: image.height
    sourceItem: Image {
        id: image;
        width: size_icon_common;
        height: size_icon_common;
        fillMode: Image.Stretch
        source: "qrc:/images/myLocation_color.svg"
    }
}
