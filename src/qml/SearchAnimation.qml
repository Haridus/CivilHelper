import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtLocation 5.3
import QtPositioning 5.2

MapCircle {
    id: root
    color: '#89a11f'
    radius: 5
    opacity: 0.3
    border.width: 1

    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        NumberAnimation { target: root; property: "radius"; from: 5; to: 1500; duration: 2400 }
        NumberAnimation { target: root; property: "radius"; from: 1500; to: 5; duration: 2400 }
    }
}
