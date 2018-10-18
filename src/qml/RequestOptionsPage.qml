import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtLocation 5.3
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Item {
    ListView{
        anchors.fill: parent
        currentIndex: -1

        delegate: ItemDelegate {
            width: parent.width
            text: model.title
            font.pointSize: font_size_point_text_text_medium
            highlighted: ListView.isCurrentItem
            onClicked: {
                switch(model.eid){
                case "close":
                    var requestStump = privateStorage.value("request")// user.data(User.RequestStump) ? strage but this dont work because he passes User.RequestStump as 0 to data function somehow
                    var flag = 1;//closed by user
                    var comment = 'closed by user';//add some text filler
                    //console.log(requestStump,flag,comment);
                    if(requestStump){
                        main.closeRequest(requestStump,flag,comment);
                    }
                    stackView.pop();
                    break;
                case "change":
                    //TODO : NOT IMPLEMENTED YET
                    break;
                case "quit":
                    stackView.pop();
                    break;
                }
            }
        }

        model: ListModel {
            ListElement {eid: "close"; title: qsTr("Снять запрос..."); }
            ListElement {eid: "change"; title: qsTr("Изменить запрос..."); }
            ListElement {eid: "quit"; title: qsTr("Закрыть..."); }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
    }
}
