import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Item {
    id: login_page

    Rectangle {
        id: login_mainArea
        anchors.fill: parent
        color: "#65a765"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Вход")
                color: "white"
                font.pointSize: font_size_point_text_caption
            }
            Label {
                elide: Label.ElideRight
                text: "Введите логин и пароль:"
                Layout.fillWidth: true
                font.pointSize: font_size_point_text_text_medium
            }
            TextField {
                id: username
                focus: true
                placeholderText: "Логин"
                Layout.fillWidth: true
                text: user.data(User.Login)
                font.pointSize: font_size_point_text_text_medium

                onFocusChanged: errorMessage.visible = false
            }
            TextField {
                id: password
                placeholderText: "Пароль"
                font.pointSize: font_size_point_text_text_medium
                echoMode: TextField.Password
                Layout.fillWidth: true
                text:user.data(User.Password)

                onFocusChanged: errorMessage.visible = false
            }
            RowLayout {
                spacing: 20
                width: password.width
                Text {
                    Layout.alignment: Qt.AlignLeft
                    text: "Регистрация"
                    font.pointSize: font_size_point_text_text_medium
                    color: "blue"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push("qrc:/qml/RegistratePage.qml")
                        }
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignRight
                    text: "Забыли пароль?"
                    font.pointSize: font_size_point_text_text_medium
                    color: "blue"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push("qrc:/qml/RestorePasswordPage.qml")
                        }
                    }
                }
            }
            RowLayout {
                spacing: width/6
                width: password.width
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    Layout.alignment: Qt.AlignLeft
                    anchors.left: parent.left
                    text: "Войти"
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        var _login = username.text
                        var _password = password.text

                        user.setData(User.Login,_login)
                        user.setData(User.Password,_password)

                        main.login(_login,_password)
                    }
                }
                Button {
                    text: "Отмена"
                    anchors.right: parent.right
                    Layout.alignment: Qt.AlignRight
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {stackView.pop();}
                }
            }

            Label {
                id: errorMessage
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                color: "red"
                text: "Не верный логин/пароль!"
                font.pointSize: font_size_point_text_text_medium
            }
        }
    }

    function showError(_show)
    {
        errorMessage.visible = _show;
    }

    function cleanForm()
    {
        errorMessage.visible = false;
        username.clear();
        password.clear();
    }
}

