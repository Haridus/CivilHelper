import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtLocation 5.3
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

Map {
    id: map
    plugin: Plugin { name: "osm" }
    center: myself.coordinate
    zoomLevel: 16
    minimumZoomLevel: 1.0
    maximumZoomLevel: 32.0

    property Location myLocation:  Location{ coordinate:  myself.coordinate; } /*Location{coordinate{latitude: 55.70168; longitude: 37.81524}}*/
    property variant mapTypesNames: []
    property string default_map_type_name : "Terrain Map"; //[Satellite Map,Cycle Map,Transit Map,Night Transit Map,Hiking Map]
    property SearchAnimation searchAnimationObject : SearchAnimation {}
    property RequestOptionsPage requestOptionsPage: RequestOptionsPage{}
    property variant requests: []
    property variant currrent_request: null
    property variant helpers: []


    onVisibleChanged:
    {
        if( visible ){
            map_control_drawer.position = bottom_drawer_default_position;
        }
        else{
            map_control_drawer.position = 0;
        }
    }

    function setMapTypeByName(mapTypeName)
    {
        for (var i = 0; i<supportedMapTypes.length; i++) {
            if( supportedMapTypes[i].name === mapTypeName ){
                activeMapType = supportedMapTypes[i];
            }
        }
    }

    function initialize()
    {
        if( mapTypesNames.length === 0 ){
            for (var i = 0; i<supportedMapTypes.length; i++) {
                mapTypesNames.push(supportedMapTypes[i].name)
            }
        }
        //console.log(mapTypesNames)
        setMapTypeByName(default_map_type_name);
    }

    function followMe() {
        map.center = myself.coordinate
    }

    function startSearchAnimation() {
        //NOTE: center in geo-coordinates
        searchAnimationObject.center = myLocation.coordinate;
        addMapItem(searchAnimationObject);
        searchAnimationObject.visible = true;
        requestOptionsButton.visible = true
    }

    function startSearchAnimationIn(sh, dl) {
        searchAnimationObject.center = QtPositioning.coordinate(sh,dl);
        //console.log(startSearchAnimationIn.toString(), searchAnimationObject.center);
        addMapItem(searchAnimationObject);
        searchAnimationObject.visible = true;
        requestOptionsButton.visible = true

    }

    function stopSearchAnimation() {
        removeMapItem(searchAnimationObject);
        requestOptionsButton.visible = false
    }

    function addRequests(_requests)
    {
        //console.log(_requests,_requests.length)
        if( _requests && (_requests.length > 0) ){
            for(var _key in _requests ){
                var _request = _requests[_key]
                //console.log(JSON.stringify(_request))
                var item = Qt.createQmlObject('import QtLocation 5.3; MapRequestItem{}', map)
                item.coordinate.latitude = _request["sh"]
                item.coordinate.longitude = _request["dl"]
                item.fillFormRequestData(_request);

                requests.push(item);
                addMapItem(item);
            }
        }
    }

    function cleanRequests()
    {
        for( var i = 0; i < requests.length; i++ ){
            var item = requests[i];
            removeMapItem(item)
            item.destroy()
        }
        requests = [];
    }

    function requestTakenUp(request)
    {
        cleanRequests()
        currrent_request    = request
        callButton.visible  = true
        externMapButton.visible = true
        giveUpButton.visible= true
        target.coordinate = QtPositioning.coordinate(request["sh"],request["dl"])
        target.visible = true;

        //console.log(target.coordinate, request["sh"], request["dl"] )
    }

    function requestGivenUp()
    {
        cleanRequests()
        currrent_request = null
        callButton.visible  = false
        externMapButton.visible = false
        giveUpButton.visible= false
        target.visible = false;
    }

    function addHelpers(_helpers)
    {
        //console.log(_helpers,_helpers.length)
        helpers = _helpers;
        if( _helpers && (_helpers.length > 0) ){
            var _helper = _helpers[0];
            target.coordinate = QtPositioning.coordinate(_helper["sh"],_helper["dl"]);
            target.visible = true

            callButton.visible = true
            requestOptionsButton.visible = true
            requestDoneButton.visible = true
        }
        else{
            cleanHelpers();
        }
    }

    function cleanHelpers()
    {
        target.visible = false
        callButton.visible = false
        requestOptionsButton.visible = false
        requestDoneButton.visible = false
        target.coordinate = QtPositioning.coordinate(90.0,180.0);
    }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: true

        onPositionChanged: PropertyAnimation{target: myself; property: "coordinate"; to: positionSource.valid ? positionSource.position.coordinate : QtPositioning.coordinate(55.70168,37.81524)}
    }

    Myself{
        id: myself
        coordinate: positionSource.valid ? positionSource.position.coordinate : QtPositioning.coordinate(55.70168,37.81524)
    }

    Target{
        id: target
        visible: false
    }

    MapButton{
        id: menuButton
        source: "qrc:/images/menu.svg"
        x: size_icon_common/2
        y: size_icon_common/2
        MouseArea{
            anchors.fill: parent
            onClicked: {
                map_drawer.open()
            }
        }
    }

    MapButton{
        id: isHelperButton
        source: "qrc:/images/heart-empty.svg"
        width: size_icon_common
        height: width
        x: size_icon_common*2
        y: size_icon_common/2
        visible: isHelper
        MouseArea{
            anchors.fill: parent
            onClicked: {
                main.showInfoPopup(qsTr("Вы стали хэлпером! Поздравляем!"))
            }
        }
    }

    MapButton{
        id: networkAssesibleButton
        source: "qrc:/images/cloud_delete.svg"
        width: size_icon_common
        height: width
        x: parent.width - size_icon_common*3
        y: size_icon_common/2
        visible: !main.networkAccesible
        color: "orange"
        MouseArea{
            anchors.fill: parent
            onClicked: {
                main.showInfoPopup(qsTr("Сеть недоступна!"))
            }
        }
    }

    MapButton{
        id: toMyselfButton
        source: "qrc:/images/location.svg"
        y: parent.height*3/4
        x: parent.width - size_icon_common-size_icon_common/2

        MouseArea{
            anchors.fill: parent
            onClicked: {
                followMe();
            }
        }
    }

    MapButton{
        id: zoomInButton
        source: "qrc:/images/zoom-in.svg"
        y: size_icon_common/2
        x: parent.width - size_icon_common-size_icon_common/2

        MouseArea{
            anchors.fill: parent
            onClicked: {
                map.zoomLevel = map.zoomLevel + 1.0
            }
        }
    }

    MapButton{
        id: zoomOutButton
        source: "qrc:/images/zoom-out.svg"
        y: size_icon_common*2
        x: parent.width - size_icon_common-size_icon_common/2

        MouseArea{
            anchors.fill: parent
            onClicked: {
                map.zoomLevel = map.zoomLevel - 1.0
            }
        }
    }

    MapButton{
        id: requestOptionsButton
        height: size_icon_common*1.5
        width: size_icon_common*1.5
        source: "qrc:/images/essential-regular-14-grid-view.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height*3/4
        visible: false

        MouseArea{
            anchors.fill: parent
            onClicked: {
                stackView.push(requestOptionsPage);
            }
        }
    }

    MapButton{
        id: callButton
        source: "qrc:/images/call.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -parent.width/4
        width: size_icon_common*1.5
        height: size_icon_common*1.5
        color: "green"
        //x: parent.width/4 - width/2
        y: parent.height*3/4
        visible: false
        opacity: 0.85

        MouseArea{
            anchors.fill: parent
            onClicked: {
                if( (backend.state & Backend.HelpConnectedState) === Backend.HelpConnectedState ){
                    var _user_phone = currrent_request ? ( currrent_request["user_phone"] ? currrent_request["user_phone"] : "") : ""
                    //console.log(_user_phone)
                    var extLink = "tel:%1".arg(_user_phone);
                    Qt.openUrlExternally(extLink);
                }
                else if( (backend.state & Backend.AskConnectedState) === Backend.AskConnectedState ){
                    if( helpers.length > 0){
                        var _helper = helpers[0];
                        var _user_phone = _helper["phone"];
                        var extLink = "tel:%1".arg(_user_phone);
                        Qt.openUrlExternally(extLink);
                    }
                }
            }
        }
    }

    MapButton{
        id: externMapButton
        height: size_icon_common*1.5
        width: size_icon_common*1.5
        source: "qrc:/images/marker_geolocalizer.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height*3/4
        visible: false
        color: color_intro_page

        MouseArea{
            anchors.fill: parent
            onClicked: {
                if( (backend.state & Backend.HelpConnectedState) === Backend.HelpConnectedState ){
                    var _sh = currrent_request ? ( currrent_request["sh"] ? currrent_request["sh"] : "") : "";
                    var _dl = currrent_request ? ( currrent_request["dl"] ? currrent_request["dl"] : "") : "";
                    var _z  = zoomLevel;
                    //console.log(_sh, _dl, _z);
                    if( _sh && _dl && ( _sh.length > 0) && ( _dl.length > 0 )  ){
                        var _mySh = myLocation.coordinate.latitude;
                        var _myDl = myLocation.coordinate.longitude;

                        var extLink = "https://www.google.ru/maps/dir/%1,%2/'%3,%4'/@%1,%2,%5z/".arg(_mySh).arg(_myDl).arg(_sh).arg(_dl).arg(_z);
                        Qt.openUrlExternally(extLink);
                    }
                    else{
                        //error report
                    }
                }
            }
        }
    }

    MapButton{
        id: giveUpButton
        source: "qrc:/images/cancel.svg"
        width: size_icon_common*1.5
        height: size_icon_common*1.5
        color: "red"
        x: parent.width*3/4 - width/2
        y: parent.height*3/4
        visible: false
        opacity: 0.85

        MouseArea{
            anchors.fill: parent
            onClicked: {
                //TODO give up call
                var _stump = currrent_request ? ( currrent_request["stump"] ? currrent_request["stump"] : "") : ""
                main.giveUpCall(_stump)
            }
        }
    }

    MapButton{
        id: requestDoneButton
        source: "qrc:/images/checkmark.svg"
        width: size_icon_common*1.5
        height: size_icon_common*1.5
        color: "#c9f8c9"
        x: parent.width*3/4 - width/2
        y: parent.height*3/4
        visible: false
        opacity: 0.85

        MouseArea{
            anchors.fill: parent
            onClicked: {
               map_ok_cancel_triger_popup.setText(qsTr("Вы дейстивтельно хотите закрыть запрос и отметить его как выполненный?"))
               map_ok_cancel_triger_popup.setFunction(
                      function(){
                          grade_popup.open();
                      }
                )
               map_ok_cancel_triger_popup.open()
            }
        }
    }

    Popup{
        id: map_ok_cancel_triger_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - height/2
        modal: false
        width: main.swidth*2/3
        height: main.sheight/2

        property var triger: null;

        contentItem: Item{
            anchors.fill: parent
            Column{
                anchors.fill: parent;
                spacing: 5

                Text{
                    id: map_ok_cancle_popup_text
                    width: parent.width
                    wrapMode: Text.Wrap
                    text:""
                    font.pointSize: font_size_point_text_text_medium
                }

                RowLayout{
                    width: parent.width*3/4
                    height: size_icon_common*2
                    spacing: width/4
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button{
                        text: qsTr("ОК")
                        anchors.left: parent.left
                        font.pointSize: font_size_point_text_text_medium
                        onClicked: {
                            map_ok_cancel_triger_popup.close()
                            if( map_ok_cancel_triger_popup.triger ){
                                map_ok_cancel_triger_popup.triger()
                            }
                            map_ok_cancel_triger_popup.triger = null
                            map_ok_cancle_popup_text.text = ""
                        }
                    }
                    Button{
                        text: qsTr("Отмена")
                        font.pointSize: font_size_point_text_text_medium
                        anchors.right: parent.right
                        onClicked: {
                            map_ok_cancel_triger_popup.close()
                            map_ok_cancel_triger_popup.triger = null
                            map_ok_cancle_popup_text.text = ""
                        }
                    }
                }
            }
        }

        function setText(_text)
        {
            map_ok_cancle_popup_text.text = _text;
        }

        function setFunction(_function)
        {
            map_ok_cancel_triger_popup.triger = _function;
        }
    }

    Popup{
        id: grade_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - height/2
        modal: true
        width: main.swidth*2/3
        height: main.sheight/3

        contentItem: Column{
            Text{
                width: parent.width
                text: qsTr("<b>Оцените помощь<b>")
                font.pointSize: font_size_point_text_text_medium
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Qt.AlignHCenter
            }
            Text
            {
                id: grade_value_label
                width: parent.width
                text: "0"
                font.pointSize: font_size_point_text_caption
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Qt.AlignHCenter
            }
            Slider{
                id: grade_value_slider
                width: parent.width
                value: 0
                from: 0
                to: 5
                stepSize: 1
                snapMode: "SnapAlways"
                onValueChanged:{
                    grade_value_label.text = ""+Math.floor(value)
                }

                background: Rectangle {
                          x: grade_value_slider.leftPadding
                          y: grade_value_slider.topPadding + grade_value_slider.availableHeight / 2 - height / 2
                          implicitWidth: 200
                          implicitHeight: 4
                          width: grade_value_slider.availableWidth
                          height: implicitHeight
                          radius: 2
                          color: "#bdbebf"

                          Rectangle {
                              width: grade_value_slider.visualPosition * parent.width
                              height: parent.height
                              color: "#21be2b"
                              radius: 2
                          }
                      }

                      handle: Rectangle {
                          x: grade_value_slider.leftPadding + grade_value_slider.visualPosition * (grade_value_slider.availableWidth - width)
                          y: grade_value_slider.topPadding + grade_value_slider.availableHeight / 2 - height / 2
                          implicitWidth: 26
                          implicitHeight: 26
                          radius: 13
                          color: grade_value_slider.pressed ? "#f0f0f0" : "#f6f6f6"
                          border.color: "#bdbebf"
                      }
            }
            Flickable {
                  id: request_done_comment_container_field
                  width: parent.width
                  height: size_icon_common*3

                  TextArea.flickable: TextArea {
                      font.pointSize: font_size_point_text_text_medium
                      id: request_done_comment_field
                      height: parent.height
                      placeholderText: qsTr("Комментарий")
                      wrapMode: TextArea.Wrap

                      background: Rectangle {
                          anchors.fill: parent
                          implicitWidth: parent.width
                          implicitHeight: parent.height*0.65

                          border.color: "black"//control.enabled ? "#21be2b" : "transparent"
                          border.width: 1
                      }
                  }
                  ScrollBar.vertical: ScrollBar { }
            }
            RowLayout{
                width: parent.width*3/4
                height: size_icon_common
                spacing: width/4
                anchors.horizontalCenter: parent.horizontalCenter

                Button{
                    text: qsTr("ОК")
                    anchors.left: parent.left
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        var stump = privateStorage.value("request")
                        var grade = grade_value_slider.value
                        var comment = request_done_comment_field.text
                        main.requestDone( stump, grade, comment )
                        grade_popup.close()
                        grade_value_slider.value = 0
                        request_done_comment_field.text = ""
                    }
                }
                Button{
                    text: qsTr("Отмена")
                    font.pointSize: font_size_point_text_text_medium
                    anchors.right: parent.right
                    onClicked: {
                        grade_popup.close()
                        grade_value_slider.value = 0
                        request_done_comment_field.text = ""
                    }
                }
            }
        }
    }
}

