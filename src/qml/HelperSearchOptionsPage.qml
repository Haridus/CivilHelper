import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Item {
    Column{
        width: parent.width
        height: parent.height

        spacing: 5

        GridView{
            id: cats_view
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.width
            cellWidth: width*0.25
            cellHeight: width*0.25

            property int cats: 0

            model: CategoriesModel{}

            delegate: Item {
                width: cats_view.cellWidth;
                height: cats_view.cellHeight;
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

        CheckBox{
            id: save_flag
            text: qsTr("Сохранить выбор")
            font.pointSize: font_size_point_text_text_medium
            width: parent.width
            anchors.left: parent.left
        }

        RowLayout{
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width/2
            height: parent.height*0.25
            Button{
                anchors.left: parent.left
                text:qsTr("Отмена")
                font.pointSize: font_size_point_text_text_medium
                onClicked: {
                    stackView.pop();
                }
            }
            Button{
                anchors.right: parent.right
                text: qsTr("Далее")
                font.pointSize: font_size_point_text_text_medium
                onClicked: {
                    var _cats = cats_view.cats
                    if( save_flag.checked ){
                        user.setData(User.HelperSearchRequestCategories, _cats)
                        user.save()
                    }
                    main.getRequestsList(_cats,"")
                    stackView.pop()
                }
            }
        }
    }
}
