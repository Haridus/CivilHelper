import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Page {
    id: aboutPage

    header: Rectangle{
        width: parent.width
        height: size_icon_common
        color: "green"
        RowLayout{
            anchors.fill: parent
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
                text: qsTr("<b>О программе</b>")
                color: "white"
                font.pointSize: font_size_point_toolbar_caption
            }
        }
     }

    contentItem: Flickable {
        id: about_page_flickable
        width: parent.width
        height: parent.height
        y: size_icon_common*3
        contentHeight: about_page_item.height
        contentWidth: parent.width

        ScrollBar.vertical: ScrollBar{}

        Pane{
            id: about_page_item
            width: parent.width

            Column{
                width: parent.width
                anchors.fill: parent
                spacing: 1

                Row{
                    width: parent.width
                    height: size_icon_common*2
                    Rectangle{
                        width: parent.width/3
                        height: parent.height
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            font.pointSize: font_size_point_text_text_medium
                            text: qsTr("<b>авторы</b>")
                        }
                    }
                    Rectangle{
                        width: parent.width*2/3
                        height: parent.height
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            id: author_text_field
                            width: parent.width
                            wrapMode: Text.Wrap
                            font.pointSize: font_size_point_text_text_medium
                            text: qsTr("Щелов Владимир(schelov@yandex.ru), Сидоренко Максим(sidormax@mail.ru)")
                        }
                    }
                }
                Row{
                    width: parent.width
                    height: size_icon_common
                    Rectangle{
                        width: parent.width/3
                        height: size_icon_common
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            font.pointSize: font_size_point_text_text_medium
                            text: qsTr("<b>версия</b>")
                        }
                    }
                    Rectangle{
                        width: parent.width*2/3
                        height: size_icon_common
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            wrapMode: Text.Wrap
                            font.pointSize: font_size_point_text_text_medium
                            text: backend.version_major+"."+backend.version_minor+"."+backend.build
                        }
                    }
                }
                Row{
                    width: parent.width
                    height: size_icon_common
                    Rectangle{
                        width: parent.width/3
                        height: size_icon_common
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            font.pointSize: font_size_point_text_text_medium
                            text: qsTr("<b>поддержка</b>")
                        }
                    }
                    Rectangle{
                        width: parent.width*2/3
                        height: size_icon_common
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            wrapMode: Text.Wrap
                            font.pointSize: font_size_point_text_text_medium
                            text: "<a href=\"mailto:support@parijana.org\">support@parijana.org</a>"
                        }
                    }
                }
                Row{
                    width: parent.width
                    height: size_icon_common
                    Rectangle{
                        width: parent.width/3
                        height: size_icon_common
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            font.pointSize: font_size_point_text_text_medium
                            text: qsTr("<b>год</b>")
                        }
                    }
                    Rectangle{
                        width: parent.width*2/3
                        height: size_icon_common
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            wrapMode: Text.Wrap
                            font.pointSize: font_size_point_text_text_medium
                            text: "2018"
                        }
                    }
                }
                Rectangle{
                    width: parent.width
                    height: size_icon_common
                    Text{
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        wrapMode: Text.Wrap
                        font.pointSize: font_size_point_text_text_medium
                        text: "© 2018 Parijana.org. Все права защищены."
                    }
                }
            }
        }
    }
}
