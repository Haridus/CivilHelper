import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Page {
    id: helpPage

    header: Rectangle{
        width: parent.width
        height: size_icon_common
        color: "green"
        RowLayout{
            anchors.fill: parent
            height: parent.height
            width: parent.width
            Rectangle{
                anchors.left: parent.left
                height: parent.height*0.95
                width: height*1.2
                color: "green"
                Image {
                    height: parent.height*0.95
                    width: height
                    fillMode: Image.Stretch
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    source: "qrc:/images/chevron-left-white.svg"

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            stackView.pop();
                        }
                    }
                }
            }
            Text{
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("<b>Помощь</b>")
                color: "white"
                font.pointSize: font_size_point_toolbar_caption
            }
        }
    }

    contentItem: Flickable {
            id: help_page_flickable
            width: parent.width;
            height: parent.height*0.75;
            contentWidth: help_page_text.paintedWidth
            contentHeight: help_page_text.paintedHeight
            clip: true

            function ensureVisible(r)
            {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX+width <= r.x+r.width)
                    contentX = r.x+r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y+r.height)
                    contentY = r.y+r.height-height;
             }

            Text {
                id: help_page_text
                width: help_page_flickable.width
                height: help_page_flickable.height
                leftPadding: 2
                rightPadding: 2
                topPadding: 2
                bottomPadding: 2
                wrapMode: TextEdit.Wrap
                text: help_page_flickable.text
                font.pointSize: font_size_point_text_text_medium

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }

            ScrollBar.vertical: ScrollBar { }

            property string text: "<p>Наиболее свежую и полную версию справки можно получить на <a href=\"https://www.parijana.org\">www.parijana.org</a> в разделе помощь, или написав на <a href=\"mailto:support@parijana.org\">support@parijana.org</a>.</p>
                           <p>Мы будем рады любой информации или предложению, которые могут улучшить наш продукт и позитивный опыт пользователей. Спасибо.</p>"
        }
}

