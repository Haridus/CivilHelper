import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

import Parijana.Backend 0.1

Item {
    Rectangle{
        anchors.fill: parent
        width: parent.width
        height: parent.height
        color: color_intro_page

        Image{
            id: logo_image
            fillMode: Image.Stretch
            anchors.horizontalCenter: parent.horizontalCenter
            width: size_icon_intro
            height: size_icon_intro
            y: parent.height*0.25 - height/2.0//parent.height*(1-1/golden_section)/1.5 - height/2.0
            source: "qrc:/images/icon.png"
        }
        Label{
            id: title_label
            anchors.top: logo_image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            //anchors.topMargin: intro.width*0.5
            text: qsTr("Друг и Помошник")
            font.bold: true
            font.pointSize: font_size_point_text_caption*0.8
        }
        Label{
            id: sub_title_label
            anchors.top: title_label.bottom
            anchors.horizontalCenter: parent.horizontalCenter
           // anchors.topMargin: intro.width*0.3
            text: ""
            font.pointSize: font_size_point_text_text_medium
        }
    }
}
