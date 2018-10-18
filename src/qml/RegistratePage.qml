import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Item {
    id: registration_page

    property int offset: 10

    function showError() {
        errorMessage.visible = true
    }

    Rectangle {
        id: registration_page_mainArea
        anchors.fill: parent
        color: "#65a765"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Регистрация"
                color: "white"
                font.pointSize: font_size_point_text_caption
            }
            Label {
                elide: Label.ElideRight
                text: "Введите данные о себе:"
                Layout.fillWidth: true
                font.pointSize: font_size_point_text_text_medium
            }
            TextField {
                id: username
                focus: true
                placeholderText: "Логин"
                Layout.fillWidth: true
                font.pointSize: font_size_point_text_text_medium
                onFocusChanged: errorMessage.visible = false
            }
            TextField {
                id: password
                placeholderText: "Пароль"
                echoMode: TextField.Password
                Layout.fillWidth: true
                font.pointSize: font_size_point_text_text_medium
                onFocusChanged: errorMessage.visible = false
            }
            TextField {
                id: mail
                placeholderText: "Почта"
                Layout.fillWidth: true
                font.pointSize: font_size_point_text_text_medium
            }
            TextField {
                id: phone
                placeholderText: "Телефон"
                Layout.fillWidth: true
                font.pointSize: font_size_point_text_text_medium
                text: user.data(User.Phone)
            }
            RowLayout {
                spacing: width/6
                anchors.horizontalCenter: parent.horizontalCenter
                width: phone.width
                Button {
                    Layout.alignment: Qt.AlignLeft
                    text: "Да"
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        var _login = username.text
                        var _password = password.text
                        var _mail = mail.text
                        var _phone = phone.text

                        var params = new Array()
                        params.push("HIDEN")
                        params.push(_login)
                        params.push(_password)
                        params.push(_mail)
                        params.push(_phone)

                        user.setData(User.Login,_login)
                        user.setData(User.Password,_password)
                        user.setData(User.Mail,_mail)
                        user.setData(User.Phone,_phone)
                        user.save();

                        backend.sendRequest(Backend.REGISTRATE, params)
                    }
                }
                Button {
                    Layout.alignment: Qt.AlignRight
                    text: "Отмена"
                    font.pointSize: font_size_point_text_text_medium
                    onClicked:{
                        stackView.pop()
                    }
                }
            }
            Label {
                id: errorMessage
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                color: "red"
                font.pointSize: font_size_point_text_text_medium
                text: "Ошибка регистрации"
            }
        }
    }
}
