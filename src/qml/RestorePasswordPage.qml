import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Item {
    id: restore_password_page
    Rectangle {
        id: restore_password_page_mainArea
        anchors.fill: parent
        color: "#65a765"

        ColumnLayout {
            anchors.centerIn: parent
            width: parent*0.8
            spacing: 20

            TextField {
                id: lmp
                focus: true
                placeholderText: "Логин, Email или Телефон"
                Layout.fillWidth: true
                width: parent.width
                font.pointSize: font_size_point_text_text_medium
            }

            RowLayout {
                spacing: 5
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    text: "Восстановить пароль"
                    font.pointSize: font_size_point_text_text_medium
                    anchors.left: parent.left
                    onClicked: {
                        var params = new Array()
                        params.push("U2FsdGVkX1-rmRPyFr5Cy0nQ9O7EFDUbPOBRd9sqNVg")
                        params.push(lmp.text)
                        backend.sendRequest(Backend.RESTORE_PASSWORD, params)
                        stackView.pop()
                    }
                }
                Button {
                    text: "Отмена"
                    font.pointSize: font_size_point_text_text_medium
                    anchors.right: parent.right
                    onClicked: {
                        stackView.pop()
                    }
                }
            }
        }
    }
}

