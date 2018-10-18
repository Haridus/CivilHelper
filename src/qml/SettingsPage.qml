import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1


Page{
    id: settings_page

    function autofill()
    {
        user_data_autofill_clean.enabled = !user.isLoggedIn()

        var _isHelper = user.isLoggedIn() &&
                ( user.data(User.HelperFlag) > 0 ) &&
                ( user.data(User.DataChecked) > 0 ) &&
                ( user.data(User.Admitted) > 0 );
        helper_data_cats_autofill_clean.enabled =  _isHelper;
        helper_data_cats_autofill_clean.update()
    }

    onVisibleChanged: {
        if( visible ){
            autofill()
        }
    }

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
                text: qsTr("<b>Настройки</b>")
                color: "white"
                font.pointSize: font_size_point_toolbar_caption
            }
        }
     }

    contentItem: Flickable {
        id: settings_page_flickable
        width: parent.width
        height: parent.height
        y: size_icon_common*3
        contentHeight: settings_page_item.height
        contentWidth: parent.width

        ScrollBar.vertical: ScrollBar{}

        Pane{
            id: settings_page_item
            width: parent.width

            Column{
                width: parent.width
                anchors.fill: parent
                spacing: 1

                Item{
                    width: parent.width
                    height: size_icon_common*1.5
                    Column{
                        anchors.fill: parent
                        spacing: 2
                        Text{
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: "<b>Сменить подложку карты</b>"
                            font.pointSize: font_size_point_text_text_medium
                        }
                        Text{
                            id: active_map_type_text
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: mapItem.activeMapType.name
                            font.pointSize: font_size_point_text_text_medium
                        }
                    }
                    Rectangle{
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        border.color: "black"
                        border.width: 1
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            map_types_combo_box.model = mapItem.mapTypesNames
                            var index = map_types_combo_box.find(mapItem.activeMapType.name,Qt.MatchExactly)
                            map_types_combo_box.currentIndex = index
                            map_type_choose_popup.open()
                        }
                    }
                }
                Item{
                    id: user_data_autofill_clean
                    width: parent.width
                    height: size_icon_common*1.5
                    enabled: !backend.isLoggedIn()
                    Column{
                        anchors.fill: parent
                        spacing: 2
                        Text{
                            width: parent.width
                            wrapMode: Text.Wrap
                            color : user_data_autofill_clean.enabled ? "black" : "lightGray"
                            text: "<b>Очистить данные автозаполнения пользователя</b>"
                            font.pointSize: font_size_point_text_text_medium
                        }
                        Text{
                            width: parent.width
                            wrapMode: Text.Wrap
                            color : user_data_autofill_clean.enabled ? "black" : "lightGray"
                            text: "Имя и телефон(только для незарегистрированных пользователей)"
                            font.pointSize: font_size_point_text_text_medium
                        }
                    }
                    Rectangle{
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        border.color: "black"
                        border.width: 1
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            if( enabled ){
                                ok_cancel_triger_popup.setText(qsTr("Вы действительнео хотите очистить данные автозаполнения пользователя?"))
                                ok_cancel_triger_popup.setFunction(
                                            function(){
                                                //console.log("user data cleared")
                                                user.setData(User.Name,null)
                                                user.setData(User.Phone,null)
                                                user.save()
                                            }
                                )
                                ok_cancel_triger_popup.open()
                            }
                        }
                    }
                }
                Item{
                    id: helper_data_cats_autofill_clean
                    width: parent.width
                    height: size_icon_common*1.5
                    enabled: false
                    Column{
                        anchors.fill: parent
                        spacing: 2
                        Text{
                            width: parent.width
                            wrapMode: Text.Wrap
                            color : helper_data_cats_autofill_clean.enabled ? "black" : "lightGray"
                            text: "<b>Очистить данные хэлпера</b>"
                            font.pointSize: font_size_point_text_text_medium
                        }
                        Text{
                            width: parent.width
                            wrapMode: Text.Wrap
                            color : helper_data_cats_autofill_clean.enabled ? "black" : "lightGray"
                            text: "Категории поиска запросов(только для хэлперов)"
                            font.pointSize: font_size_point_text_text_medium
                        }
                    }
                    Rectangle{
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        border.color: "black"
                        border.width: 1
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            if( enabled ){
                                ok_cancel_triger_popup.setText(qsTr("Вы действительнео хотите очистить данные поиска хэлпера?"))
                                ok_cancel_triger_popup.setFunction(
                                            function(){
                                                //console.log("helper data cleared")
                                                user.setData(User.HelperSearchRequestCategories, null)
                                                user.save()
                                            }
                                )
                                ok_cancel_triger_popup.open()
                            }
                        }
                    }
                }
            }
        }
    }


    Popup{
        id: map_type_choose_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - height/2
        modal: false
        width: main.swidth*2/3
        height: main.sheight/3

        contentItem: Item{
            anchors.fill: parent

            ColumnLayout{
                anchors.fill: parent
                spacing: 5
                RowLayout{
                    width: parent.width
                    spacing: 2
                    Text{
                        width: parent.width
                        text: "Подложка"
                        font.pointSize: font_size_point_text_text_medium
                    }
                    ComboBox{
                        Layout.fillWidth: true
                        id: map_types_combo_box
                        model: mapItem.mapTypesNames
                        currentIndex: 0
                        font.pointSize: font_size_point_text_text_medium
                        onActivated: {
                            mapItem.setMapTypeByName(currentText)
                            active_map_type_text.text = currentText
                            map_type_choose_popup.close()
                        }
                    }
                }
                Button{
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Закрыть")
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        map_type_choose_popup.close();
                    }
                }
            }
        }
    }

    Popup{
        id: ok_cancel_triger_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - height/2
        modal: false
        width: main.swidth*2/3
        height: main.sheight/3

        property var triger: null;

        contentItem: Item{
            anchors.fill: parent
            Column{
                anchors.fill: parent;
                spacing: 10

                Text{
                    id: ok_cancle_popup_text
                    width: parent.width
                    wrapMode: Text.Wrap
                    text:""
                    font.pointSize: font_size_point_text_text_medium
                }

                RowLayout{
                    width: parent.width*3/4
                    height: size_icon_common
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button{
                        text: qsTr("ОК")
                        anchors.left: parent.left
                        font.pointSize: font_size_point_text_text_medium
                        onClicked: {
                            ok_cancel_triger_popup.close()
                            if( ok_cancel_triger_popup.triger ){
                                ok_cancel_triger_popup.triger()
                            }
                            ok_cancel_triger_popup.triger = null
                            ok_cancle_popup_text.text = ""
                        }
                    }
                    Button{
                        text: qsTr("Отмена")
                        font.pointSize: font_size_point_text_text_medium
                        anchors.right: parent.right
                        onClicked: {
                            ok_cancel_triger_popup.close()
                            ok_cancel_triger_popup.triger = null
                            ok_cancle_popup_text.text = ""
                        }
                    }
                }
            }
        }

        function setText(_text)
        {
            ok_cancle_popup_text.text = _text;
        }

        function setFunction(_function)
        {
            ok_cancel_triger_popup.triger = _function;
        }
    }
}
