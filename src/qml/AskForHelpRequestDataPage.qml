import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Item {
    id: ask_for_help_request_data_page

    GridView{
        id: cats_view

        property int cats: 0

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: parent.width

        cellWidth: width*0.25
        cellHeight: width*0.25

        model: CategoriesModel{}

        delegate: Item {
            width: cats_view.cellWidth; height: cats_view.cellHeight
            property bool on: false

            Rectangle {
                anchors.fill: parent
                width: parent.width
                height: parent.height
                Image {
                    width: height;
                    height: parent.height*0.25;
                    source: image;
                    anchors.centerIn: parent
                }
                Text {
                    text: name;
                    width: parent.width
                    height: parent.height*0.25;
                    wrapMode: Text.Wrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: font_size_point_text_text_medium*0.85
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        on = !on;
                        if( on ){
                            parent.color = "lightblue"
                            //console.log(name,"on");
                            cats_view.cats |= value;

                        }
                        else{
                            parent.color = "white"
                            //console.log(name,"off");
                            cats_view.cats &= ~value;
                        }
                    }
                }
            }
        }
    }

    Item{
        anchors.bottom: parent.bottom
        width: parent.width
        height: ask_for_help_request_data_page.height - cats_view.height
        TextArea{
            id: comment_field
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height*0.65
            placeholderText: qsTr("Комментарий")
            font.pointSize: font_size_point_text_text_medium
            wrapMode: TextArea.Wrap

            background: Rectangle {
                anchors.fill: parent
                implicitWidth: parent.width
                implicitHeight: parent.height*0.65

                border.color: "#21be2b"//control.enabled ? "#21be2b" : "transparent"
                border.width: 3
            }
        }

        RowLayout{
            anchors.top: comment_field.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width*3/4
            height: parent.height*0.25
            spacing: width/4
            Button{
                anchors.left: parent.left
                text:qsTr("Отмена")
                font.pointSize: font_size_point_text_text_medium
                onClicked:
                {
                    //console.log("back");
                    stackView.pop();
                }
            }
            Button{
                anchors.right: parent.right
                text:qsTr("Запросить поддержку")
                font.pointSize: font_size_point_text_text_medium
                onClicked:
                {
                    var user_name = user.data(User.Name)
                    var user_phone = user.data(User.Phone)
                    var cats = cats_view.cats;
                    var comment = comment_field.text;
                    main.askForHelp(user_name,user_phone,cats,comment);
                    stackView.pop();
                }
            }
        }
    }

}
