import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Item{
    property int cats: 0
    property bool editable: false

    GridView{
        anchors.fill: parent
        cellWidth:  width*0.25
        cellHeight: width*0.25

        model:CategoriesModel{}

        delegate:Item{
                width: parent.cellWidth
                height: parent.cellHeight

                Rectangle {
                    anchors.fill: parent
                    property bool on: (cats & value) > 0
                    color: on ? "lightblue" : "white"

                    Image {
                        width: height;
                        height: parent.height*0.25;
                        source: image;
                        anchors.centerIn: parent
                    }
                    Item{
                        width: parent.width;
                        height: parent.height*0.25;
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        Label {
                            text: name+image;
                            verticalAlignment: Text.AlignVCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            if( editable ){
                                var _on = !on;
                                if( _on ){
                              //      parent.color = "lightblue"
                                    //console.log(name,"on");
                                    cats |= value;

                                }
                                else{
                              //      parent.color = "white"
                              //      console.log(name,"off");
                                    cats &= ~value;
                                }
                            }
                        }
                    }
            }
        }
    }
}

