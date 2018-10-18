import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

ApplicationWindow {
    id: main
    visible: true
    width: 1000*0.5//1200*0.5
    height: 1600*0.5//1920*0.5

    property int swidth: backend.alignByScreen ? Screen.width : main.width
    property int sheight: backend.alignByScreen ? Screen.height : main.height
    property real golden_section: 1.61803398875
    property real size_icon_intro: swidth*0.12
    property real size_icon_common: swidth*0.1
    property color color_intro_page: "#fcfded"
    property real bottom_drawer_default_position: 0.075
    property int  pulse_timeout_common_state: 1*60*1000//1 minute
    property int  pulse_timeout_helper_state: 1*60*1000//1 minute
    property int  pulse_timeout_helper_connected_state: 5*1000//5 seconds
    property int  get_request_info_timeout: 1*60*1000//1 minute
    property int  get_request_info_connected_state_timeout: 5*1000//5 seconds
    property int  requests_search_timeout: 1*60*1000;//1 minute

    property real resolution_k_font: 3.77/Screen.logicalPixelDensity

    property int font_size_pixel_toolbar_caption: size_icon_common*0.6*resolution_k_font//0.4
    property int font_size_pixel_toolbar_text: size_icon_common*0.4*resolution_k_font//0.25
    property int font_size_pixel_text_caption: size_icon_common*0.6*resolution_k_font//0.4
    property int font_size_pixel_text_text_large: size_icon_common*0.6*resolution_k_font//0.4
    property int font_size_pixel_text_text_medium: size_icon_common*0.35*resolution_k_font//0.2
    property int font_size_pixel_text_text_small: size_icon_common*0.15*resolution_k_font

    property int font_size_point_toolbar_caption: font_px_pt( font_size_pixel_toolbar_caption )
    property int font_size_point_toolbar_text: font_px_pt( font_size_pixel_toolbar_text )
    property int font_size_point_text_caption: font_px_pt( font_size_pixel_text_caption )
    property int font_size_point_text_text_large: font_px_pt( font_size_pixel_text_text_large)
    property int font_size_point_text_text_medium: font_px_pt( font_size_pixel_text_text_medium )
    property int font_size_point_text_text_small: font_px_pt( font_size_pixel_text_text_small )

    property bool isHelper: false
    property int  networkAccesible: backend.networkAccesibility > 0

    property MapComponent   mapItem: MapComponent{}
    property AskForHelpRequestDataPage askForHelpDataPageItem: AskForHelpRequestDataPage{}
    property ProfilePage    profilePage : ProfilePage{}
    property SettingsPage   settingsPage: SettingsPage{}
    property LoginPage      loginPage: LoginPage{}
    property RegistratePage registratePage: RegistratePage{}
    property HelperSearchOptionsPage helperSearchOptionsPage: HelperSearchOptionsPage{}
    property AboutPage aboutPage: AboutPage{}
    property HelpPage helpPage: HelpPage{}

    property int lastSearchCats: 0
    property string lastSearchSpecats: ""
    property var lastTakenRequest: null

    property var repeatOperationId: null
    property var repeatOperationArgs: null

    property var responceFrontEndProcessors: null

    function initializeProcessors()
    {
        responceFrontEndProcessors = {}
        responceFrontEndProcessors[Backend.LOGIN] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                backend.state = backend.state | Backend.LoggedInState;
                if( stackView.currentItem === loginPage ){
                    stackView.pop();
                }
                backend.sendRequest(Backend.GET_USER,new Array())
                repeatOperation();
            }
            else{
                if( stackView.currentItem === loginPage ){
                    loginPage.showError();
                }
            }
        }

        responceFrontEndProcessors[Backend.GET_USER] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                var params = new Array()
                params.push(user.data(User.UserStump));
                backend.sendRequest(Backend.GET_USER_INFO, params);
            }
            else{}
        }

        responceFrontEndProcessors[Backend.GET_USER_INFO] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                isHelper = userIsHelper()
            }
            else{}
        }

        responceFrontEndProcessors[Backend.LOGOUT] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                backend.state = backend.state & ~Backend.LoggedInState;
            }
            else{}
        }

        responceFrontEndProcessors[Backend.REGISTRATE] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                var _login = user.data(User.Login);
                var _password = user.data(User.Password)
                login(_login,_password)
                stackView.pop()
            }
            else{
                registration_page.showError();
            }
        }

        responceFrontEndProcessors[Backend.GET_USER_INFO] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                backend.state = backend.state & ~Backend.LoggedInState;
            }
            else{
                if( data["current_request"] && data["current_request"].length > 0 ){
                    takeUpCall( data["current_request"] )
                }
            }
        }

        responceFrontEndProcessors[Backend.CHANGE_PROFILE_DATA] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                var params = new Array()
                params.push(user.data(User.UserStump));
                backend.sendRequest(Backend.GET_USER_INFO, params);
            }
            else{}
        }

        responceFrontEndProcessors[Backend.ADD_REQUEST] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                backend.state  = backend.state | Backend.AskState;
            }
            else{}
        }

        responceFrontEndProcessors[Backend.CLOSE_REQUEST] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                backend.state = backend.state & ~(Backend.AskState | Backend.AskConnectedState);
                user.setData(User.RequestStump,null); //stay one not both
                user.setData(User.RequestInfo,null);
                user.setData(User.RequestData,null);
                user.save();
            }
            else{}
        }

        responceFrontEndProcessors[Backend.GET_REQUEST_INFO] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                //TODO place marker etc if go to connected state
                //console.log(JSON.stringify(data))
                if( ( backend.state & (Backend.AskState | Backend.AskConnectedState) ) === 0 ){
                    //getting info from stored request
                    backend.state = backend.state | Backend.AskState;
                    if( !( data["helpers"] && ( data["helpers"].length > 0 ) ) ){
                        var requestData = user.data(User.RequestData);
                        //console.log("stored req data", requestData)
                        var sh = requestData ? requestData["sh"] : null;
                        var dl = requestData ? requestData["dl"] : null;
                        mapItem.startSearchAnimationIn(sh,dl);
                    }
                }

                if( data["helpers"] && ( data["helpers"].length > 0 ) ){
                    backend.state = backend.state | Backend.AskConnectedState;
                    mapItem.stopSearchAnimation();
                    mapItem.addHelpers(data["helpers"])
                }
                else{
                    backend.state = backend.state & ~Backend.AskConnectedState;
                }
            }
            else{}
        }

        responceFrontEndProcessors[Backend.GET_REQUESTS_LIST] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                backend.state = backend.state | Backend.HelpState;
                mapItem.cleanRequests();
                mapItem.addRequests(data)
            }
            else{
                mapItem.cleanRequests();
            }
        }

        responceFrontEndProcessors[Backend.TAKE_UP_CALL] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                backend.state = backend.state | Backend.HelpConnectedState;
                mapItem.requestTakenUp(data);
            }
            else{
                lastTakenRequest = null;
            }
        }

        responceFrontEndProcessors[Backend.GIVE_UP_CALL] = function(_opId,_status,_data)
        {
            if( _status === 0 ){
                mapItem.requestGivenUp()
                backend.state = backend.state & ~Backend.HelpConnectedState;
                getRequestsList(lastSearchCats,lastSearchSpecats)
            }
            else{
                mapItem.requestGivenUp()
                backend.state = backend.state & ~Backend.HelpConnectedState;
                getRequestsList(lastSearchCats,lastSearchSpecats)
            }
        }
    }


    function font_px_pt(font_px)
    {
        return Math.floor(font_px*0.757-0.178)
    }

    function userIsHelper()
    {
        var _isHelper = user.isLoggedIn() &&
                ( user.data(User.HelperFlag) > 0 ) &&
                ( user.data(User.DataChecked) > 0 ) &&
                ( user.data(User.Admitted) > 0 );
        return _isHelper
    }

    function storeOperation(_opId, _opArgs)
    {
        repeatOperationId = _opId;
        repeatOperationArgs = _opArgs;
    }

    function repeatOperation()
    {
        if( !networkAccesible ){
            return
        }

        if( repeatOperationId && repeatOperationArgs ){
            backend.sendRequest(repeatOperationId,repeatOperationArgs);
        }
        repeatOperationId = null;
        repeatOperationArgs = null;
    }

    function login(_login, _password)
    {
        if( !networkAccesible ){
            return
        }

        if( _login && _password  ){
            var params = new Array()
            params.push("user")
            params.push(_login)
            params.push(_password)

            //console.log("saved login data:",_login,_password)
            backend.sendRequest(Backend.LOGIN, params)
        }
    }

    function autologin()
    {
        if( !networkAccesible ){
            return
        }

        var _login = user.data(User.Login)
        var _password = user.data(User.Password)
        //console.log("saved login data:",User.Login,_login,User.Password,_password)
        if( _login && _password ){
            login(_login,_password);
        }
    }

    function logout()
    {
        if( !networkAccesible ){
            return
        }

        var params = new Array();
        backend.sendRequest(Backend.LOGOUT,params);
    }

    function askForHelp(name_value, phone_value, cats, comment)
    {
        if( !networkAccesible ){
            return
        }
        //'key','user_name','user_phone','sh','dl','cats','specats','help_req','reward','text'
        var key = "HIDEN";
        var latitude = mapItem.myLocation.coordinate.latitude;
        var longitude = mapItem.myLocation.coordinate.longitude;
        var specats = '';
        var helpers_requested = 1;
        var reward = 5;
        phone_value = phone_value.replace(/[+\(\)-]{1,}/g,"").trim();

        var params = new Array();

        params.push(key);
        params.push(name_value);
        params.push(phone_value);
        params.push(latitude);
        params.push(longitude);
        params.push(cats);
        params.push(specats)
        params.push(helpers_requested)
        params.push(reward)
        params.push( backend.toPersentEncoding( comment ) );

        backend.sendRequest(Backend.ADD_REQUEST,params);

        //stored for future use after, to restore request info after closing and opening app
        var reqData = new Object;
        reqData["sh"] = latitude;
        reqData["dl"] = longitude;
        reqData["cats"] = cats;
        reqData["specats"] = specats;
        //console.log(JSON.stringify(reqData))
        user.setData(User.RequestData, reqData);
    }

    function closeRequest(stump, flag, comment, grade)
    {
        if( !networkAccesible ){
            return
        }

        get_reuqest_info_timer.stop();

        var params = new Array();
        params.push(stump);
        params.push(flag);
        params.push(backend.toPersentEncoding(comment));

        backend.sendRequest(Backend.CLOSE_REQUEST,params);
        user.setData(User.RequestData,null);
        user.setData(User.RequestInfo,null);
        user.setData(User.RequestStump,null);
    }

    function requestDone(stump,grade,comment)
    {
        if( !networkAccesible ){
            return
        }

        get_reuqest_info_timer.stop();
        var params = new Array();
        params.push(stump);
        params.push(Backend.RequestDone);
        params.push(backend.toPersentEncoding(comment));
        params.push(grade);

        backend.sendRequest(Backend.CLOSE_REQUEST,params);
        user.setData(User.RequestData,null);
        user.setData(User.RequestInfo,null);
        user.setData(User.RequestStump,null);
    }

    function getRequestsList(cats,specats)
    {
        if( !networkAccesible ){
            return
        }

        var _latitude = mapItem.myLocation.coordinate.latitude;
        var _longitude = mapItem.myLocation.coordinate.longitude;

        var params = new Array()
        params.push(_latitude)
        params.push(_longitude)
        params.push(cats)
        params.push(specats)

        backend.sendRequest(Backend.GET_REQUESTS_LIST,params)

        lastSearchCats = cats
        lastSearchSpecats = specats
    }

    function takeUpCall(stump)
    {
        if( !networkAccesible ){
            return
        }

        if( stump && stump.length > 0 ){
            var _params = new Array()
            _params.push(stump)
            backend.sendRequest(Backend.TAKE_UP_CALL,_params);
            lastTakenRequest = stump
        }
    }

    function giveUpCall(stump)
    {
        if( !networkAccesible ){
            return
        }

        if( stump && stump.length > 0 ){
            var _params = new Array();
            _params.push(stump)
            backend.sendRequest(Backend.GIVE_UP_CALL,_params);
        }
    }

    function getRequestInfo(_stump)
    {
        if( !networkAccesible ){
            return
        }

        if( _stump && _stump.length > 0 ){
            var params = new Array();
            params.push("U2FsdGZ94IG-xEuFGprFitp4bPOBRd9sqNVg")
            params.push(_stump)

            backend.sendRequest(Backend.GET_REQUEST_INFO,params)
        }
    }

    function getCurrentRequestInfo()
    {
        if( !networkAccesible ){
            return
        }

        if( ( backend.state & Backend.AskState ) === Backend.AskState ){
            var stamp = user.data( User.RequestStump );
            getRequestInfo(stamp);
        }
    }

    function pulse(){
        if( !networkAccesible ){ return}

        if( ( backend.state & Backend.LoggedInState) === Backend.LoggedInState ){
            var _latitude = mapItem.myLocation.coordinate.latitude;
            var _longitude = mapItem.myLocation.coordinate.longitude;
            var _state = 0

            var params = new Array();
            params.push(_latitude)
            params.push(_longitude)
            params.push(_state)

            backend.sendRequest(Backend.PULSE,params)
        }
    }

    function showInfoPopup(_text)
    {
        info_popup.setText(_text)
        info_popup.open()
    }

    StackView{
        id: stackView
        anchors.fill: parent
        initialItem: Intro{}
    }

    Connections
    {
        target: backend
        onReadyToWork:
        {
            initializeProcessors()

            var _argeenemt_accepted = privateStorage.value("agreement_accepted")
            if( (!_argeenemt_accepted) || (_argeenemt_accepted === 0) ){
                user_agreement_popup.open()
            }

            mapItem.initialize();
            stackView.push(mapItem);
            map_control_drawer.position = bottom_drawer_default_position
            mapItem.followMe();
            autologin();

            var savedRequest = privateStorage.value("request");
            //console.log( "saved request", savedRequest, user.data(User.RequestData), user.data(User.RequestInfo) );
            getRequestInfo(savedRequest);
        }
        onResponceArrived:
        {
            if( responceFrontEndProcessors && ( operation in responceFrontEndProcessors ) ){
                responceFrontEndProcessors[operation](operation,status,data)
            }
            /*
            if( status === Backend.Error_OK ){
                switch(operation){
                case Backend.LOGIN:
                    backend.state = backend.state | Backend.LoggedInState;
                    if( stackView.currentItem === loginPage ){
                        stackView.pop();
                    }
                    backend.sendRequest(Backend.GET_USER,new Array())
                    repeatOperation();
                    break;
                case Backend.GET_USER:
                    var params = new Array()
                    params.push(user.data(User.UserStump));
                    backend.sendRequest(Backend.GET_USER_INFO, params);
                    break;
                case Backend.GET_USER_INFO:
                    isHelper = userIsHelper()
                    break;
                case Backend.LOGOUT:
                    backend.state = backend.state & ~Backend.LoggedInState;
                    break;
                case Backend.REGISTRATE:
                    var _login = user.data(User.Login);
                    var _password = user.data(User.Password)
                    login(_login,_password)
                    stackView.pop()
                    break;
                case Backend.RESTORE_PASSWORD:
                    break;
                case Backend.CHANGE_PASSWORD:
                    break;
                case Backend.GET_USER_INFO:
                    if( data["current_request"] && data["current_request"].length > 0 ){
                        takeUpCall( data["current_request"] )
                    }
                    break;
                case Backend.CHANGE_PROFILE_DATA:
                    var params = new Array()
                    params.push(user.data(User.UserStump));
                    backend.sendRequest(Backend.GET_USER_INFO, params);
                    break;
                case Backend.ADD_REQUEST:
                    backend.state  = backend.state | Backend.AskState;
                    break;
                case Backend.CLOSE_REQUEST:
                    backend.state = backend.state & ~(Backend.AskState | Backend.AskConnectedState);
                    user.setData(User.RequestStump,null); //stay one not both
                    user.setData(User.RequestInfo,null);
                    user.setData(User.RequestData,null);
                    user.save();
                    break;
                case Backend.GET_REQUEST_INFO:
                    //TODO place marker etc if go to connected state
                    //console.log(JSON.stringify(data))
                    if( ( backend.state & (Backend.AskState | Backend.AskConnectedState) ) === 0 ){
                        //getting info from stored request
                        backend.state = backend.state | Backend.AskState;
                        if( !( data["helpers"] && ( data["helpers"].length > 0 ) ) ){
                            var requestData = user.data(User.RequestData);
                            //console.log("stored req data", requestData)
                            var sh = requestData ? requestData["sh"] : null;
                            var dl = requestData ? requestData["dl"] : null;
                            mapItem.startSearchAnimationIn(sh,dl);
                        }
                    }

                    if( data["helpers"] && ( data["helpers"].length > 0 ) ){
                        backend.state = backend.state | Backend.AskConnectedState;
                        mapItem.stopSearchAnimation();
                        mapItem.addHelpers(data["helpers"])
                    }
                    else{
                        backend.state = backend.state & ~Backend.AskConnectedState;
                    }
                    break;
                case Backend.GET_REQUESTS_LIST:
                    backend.state = backend.state | Backend.HelpState;
                    mapItem.cleanRequests();
                    mapItem.addRequests(data)
                    break;
                case Backend.TAKE_UP_CALL:
                    backend.state = backend.state | Backend.HelpConnectedState;
                    mapItem.requestTakenUp(data);
                    break;
                case Backend.GIVE_UP_CALL:
                    mapItem.requestGivenUp()
                    backend.state = backend.state & ~Backend.HelpConnectedState;
                    getRequestsList(lastSearchCats,lastSearchSpecats)
                    break;
                }
            }
            else{
                //console.log("Error in operation "+operation+" status "+ status);

                switch(status){
                    case Backend.Error_Session_Expired_Or_Closed:
                        repeatOperationId = backend.lastOperationId()
                        repeatOperationArgs = backend.lastOperationArgs()
                        autologin();
                        return;
                        break;
                    case Backend.Error_Request_Expired_Or_Closed:
                        user.setData(User.RequestStump,null);
                        user.setData(User.RequestInfo,null);
                        user.setData(User.RequestData,null);
                        user.save();

                        backend.state = backend.state & ~(Backend.AskState | Backend.AskConnectedState | Backend.HelpConnectedState)

                        //error handling error reporting
                        return;
                        break;
                }

                switch(operation){
                case Backend.LOGIN:
                    if( stackView.currentItem === loginPage ){
                        loginPage.showError();
                    }
                    break;
                case Backend.LOGOUT:
                    break;
                case Backend.REGISTRATE:
                    registration_page.showError();
                    break;
                case Backend.RESTORE_PASSWORD:
                    break;
                case Backend.CHANGE_PASSWORD:
                    break;
                case Backend.CHANGE_PROFILE_DATA:
                    break;
                case Backend.ADD_REQUEST:
                    break;
                case Backend.CLOSE_REQUEST:
                    break;
                case Backend.GET_REQUEST_INFO:
                    //TODO place marker etc if go to connected state
                    //if request expired remove search animation and back to initial state
                    break;
                case Backend.GET_REQUESTS_LIST:
                    mapItem.cleanRequests();
                    break;
                case Backend.TAKE_UP_CALL:
                    lastTakenRequest = null;
                    break;
                case Backend.GIVE_UP_CALL:
                    mapItem.requestGivenUp()
                    backend.state = backend.state & ~Backend.HelpConnectedState;
                    getRequestsList(lastSearchCats,lastSearchSpecats)
                    break;
                }
            }
            */
        }
        onStateChanged:
        {
            //console.log("state changed ",state)
            if( ( backend.state & Backend.LoggedInState) === Backend.LoggedInState ){
                pulse_timer.start()
            }
            else{
                pulse_timer.stop();
            }
            if( ( backend.state & Backend.AskState) === Backend.AskState ){
                if( ( backend.state & Backend.AskConnectedState) === Backend.AskConnectedState ){
                    get_reuqest_info_timer.interval = get_request_info_connected_state_timeout
                    get_reuqest_info_timer.restart();

                }
                else{
                    get_reuqest_info_timer.interval = get_request_info_timeout
                    get_reuqest_info_timer.start()
                    mapItem.cleanHelpers()
                    mapItem.startSearchAnimation();
                    map_control_drawer.position = 0;
                }
            }
            else{
                get_reuqest_info_timer.stop()
                mapItem.cleanHelpers()
                map_control_drawer.position = bottom_drawer_default_position;
                mapItem.stopSearchAnimation();
            }
            if( ( backend.state & Backend.HelpState) === Backend.HelpState ){
                if( ( backend.state & Backend.HelpConnectedState) === Backend.HelpConnectedState ){
                    pulse_timer.interval = pulse_timeout_helper_connected_state
                    pulse_timer.restart()
                    requests_search_timer.stop();
                    map_control_drawer.position = 0
                }
                else{
                    pulse_timer.interval = pulse_timeout_helper_state
                    pulse_timer.restart()

                    requests_search_timer.start();
                    map_control_drawer.position = bottom_drawer_default_position
                }
            }
            else{
                pulse_timer.interval = pulse_timeout_common_state
                pulse_timer.restart()

                requests_search_timer.stop();
                mapItem.cleanRequests();
            }
        }
        onError:
        {
            message.text = qsTr("Произошла ошибка")
            message.show()
        }
        onNetworkAccesibilityChanged:
        {
            if( accesibility > 0 ){
                networkAccesible = true
            }
            else{
                networkAccesible = false
                message.text = qsTr("Связь потеряна")
                message.show()
            }
        }
    }

    Timer{
        id: get_reuqest_info_timer
        interval: get_request_info_timeout // 1 minutes
        repeat: true
        running: false
        triggeredOnStart: true
        onTriggered: {
            getCurrentRequestInfo();
        }
    }

    Timer{
        id: pulse_timer
        interval: pulse_timeout_common_state // 1 minutes
        repeat: true
        running: false
        triggeredOnStart: true
        onTriggered: {
            pulse();
        }
    }

    Timer{
        id: requests_search_timer
        interval: requests_search_timeout
        repeat: true
        running: false
        triggeredOnStart: false
        onTriggered: {
            getRequestsList(lastSearchCats,lastSearchSpecats);
        }
    }

    Drawer{
        id: map_drawer
        width: Math.min(main.swidth, main.sheight) / 3 * 2
        height: main.sheight
        visible: false
        dragMargin: -1

        ListView {
            id: map_drawer_listView
            currentIndex: -1
            anchors.fill: parent

            header: Rectangle{
                width: parent.width
                height: parent.width
                color:"lightblue"
            }

            delegate: ItemDelegate {
                width: parent.width
                height: size_icon_common
                text: model.title
                font.pointSize: font_size_point_text_text_medium
                highlighted: ListView.isCurrentItem
                onClicked: {
                    if (map_drawer_listView.currentIndex != index) {
                        map_drawer_listView.currentIndex = index
                       //TODO:
                    }
                    switch(model.eid){
                    case "profileElement":
                        if( backend.isLoggedIn() ){
                            profilePage.autoFillForm()
                            stackView.push(profilePage);
                        }
                        else{
                            stackView.push(loginPage);
                        }
                        break;
                    case "settingsElement":
                        settingsPage.autofill()
                        stackView.push(settingsPage);
                        break;
                    case "helpElement":
                        stackView.push(helpPage)
                        break;
                    case "aboutElement":
                        stackView.push(aboutPage)
                        break;
                    case "eeElement":
                        if( !backend.isLoggedIn() ){
                            stackView.push(loginPage);
                        }
                        else{
                            backend.sendRequest(Backend.LOGOUT,new Array());
                        }
                        break;
                    }
                    map_drawer.close()
                }
            }

            model: ListModel {
                ListElement {eid: "profileElement" ; title: qsTr("Профиль"); }
                ListElement {eid: "settingsElement"; title: qsTr("Настройки"); }
                ListElement {eid: "helpElement"    ; title: qsTr("Помощь"); }
                ListElement {eid: "aboutElement"   ; title: qsTr("О программе"); }
                ListElement {eid: "eeElement"      ; title: qsTr("Вход/Выход"); }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    function setHelperMode()
    {
        var _login = user.data(User.Login)
        var _password = user.data(User.Password)
        if( !(_login && _password) ){
            info_not_registred_popup.open()
            return
        }

        var _helper_flag = user.data(User.HelperFlag)
        if( _helper_flag < 1 ){
            info_profile_not_filled_popup.open()
            return
        }

        var _checked = user.data(User.DataChecked)
        if( _checked < 1 ){
            info_popup.setText(
                              "Спасибо Вам за ваше желание помогать. "
                            + "Мы приняли Твою заявку, она находится в стадии рассмотрения, "
                            + "Как только мы ее рассмотрим тебе прийдет письмо с уведомлением, о том, что твои данные проверены и "
                            + "Ты можешь следить за запросами пользователей. "
                            + "\n\n"
                            + "P.S. Тебе должно было прийдти письмо от нас с разъяснениями, "
                            + "если оно не пришло, то пиши на support@parijana.org, мы разберемся в ситуации. "
                              )
            info_popup.open()
            return
        }

        var _admitted = user.data(User.Admitted)
        if( _admitted < 1 ){
            info_popup.setText(
                              "Спасибо Вам за ваше желание помогать. "
                            + "Мы приняли и рассмотрели Твою заявку! Ура! Остался последний штрих, "
                            + "но по всей видимости наш администратор не торопиться с тем, чтобы поставить галочку \"Одобрить\" напротив твоего имени. "
                            + "Не переживай! Напиши нам на support@parijana.org, и мы разберемся в ситуации. "
                              )
            info_popup.open()
            return
        }

        var _helper_cats = user.data(User.HelperSearchRequestCategories)
        if( !_helper_cats || (_helper_cats < 0) ){
            stackView.push(helperSearchOptionsPage)
            return
        }

        main.getRequestsList(_helper_cats,"")
    }

    function setAskForHelpMode()
    {
        var user_name  = user.data(User.Name);
        var user_phone = user.data(User.Phone);

        if(user_name && user_phone && user_name.length > 0 && user_phone.length > 0 ){
            stackView.push(askForHelpDataPageItem);
        }
        else{
            name_phone_data_reseaveer_popup.open();
        }
    }

    Drawer{
        id: map_control_drawer
        width: parent.width
        height: parent.height
        position: 0
        edge: Qt.BottomEdge
        dragMargin: parent.height*bottom_drawer_default_position
        modal: false

        MouseArea
        {
            anchors.top: parent.top
            height: size_icon_common
            width: parent.width
            onPressed: {
                map_control_drawer.modal = true
            }
            onReleased: {
                map_control_drawer.modal = false
            }
        }

        onClosed:
        {
            modal = false
            position = bottom_drawer_default_position
        }

        RowLayout{
            width: parent.width
            height:parent.height*bottom_drawer_default_position
            RowLayout{
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: width/5
                Button{
                    anchors.left: parent.left
                    text:qsTr("Помогать другим")
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        if( (backend.state & Backend.AskState) === Backend.AskState ){
                            info_triger_popup.setText( qsTr("Вы сейчас находитесь в режиме поиска помощи, при переключении в режим помошника ваша текущая сессия поиска помощи будет утеряна, а открытая сессия помощи будет закрыта. Продолжить?") )
                            info_triger_popup.setFunction( function(){
                                                                state = state & ~( Backend.AskState | Backend.AskConnectedState);
                                                                var requestStump = user.data(User.RequestStump);
                                                                if( requestStump.length > 0  ){
                                                                    closeRequest(requestStump,0,"closed by switch to helper state")
                                                                }
                                                                mapItem.stopSearchAnimation();
                                                                setHelperMode();
                                                           }
                                                         )
                            info_triger_popup.open();
                            return;
                        }

                        setHelperMode();
                    }
                }
                Button{
                    anchors.right: parent.right
                    text:qsTr("Запросить поддержку")
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        if( (backend.state & Backend.HelpConnectedState ) === Backend.HelpConnectedState ){
                            info_triger_popup.setText( qsTr("Вы сейчас находитесь в режиме помошника, при переключении в режим поиска помощи ваша текущая сессия помошника будет закрыта, поисковы запросы обнулены и Вы будете отключены от текущего запроса о помощи. Продолжить?") )

                            var _func = function(){
                                backend.state = backend.state & ~( Backend.HelpState | Backend.HelpConnectedState);
                                mapItem.cleanRequests()
                                if( lastTakenRequest ){
                                    giveUpCall( lastTakenRequest )
                                }
                                setAskForHelpMode();
                           }

                            info_triger_popup.setFunction( _func )
                            info_triger_popup.open()
                            return;
                        }
                        else if( (backend.state & Backend.HelpState) === Backend.HelpState ){
                            info_triger_popup.setText( qsTr("Вы сейчас находитесь в режиме помошника, при переключении в режим поиска помощи ваша текущая сессия помошника будет закрыта, поисковы запросы обнулены и Вы будете отключены от текущего запроса о помощи. Продолжить?") )

                            var _func = function(){
                                backend.state = backend.state & ~( Backend.HelpState | Backend.HelpConnectedState);
                                mapItem.cleanRequests();
                                setAskForHelpMode();
                            }

                            info_triger_popup.setFunction( _func )
                            info_triger_popup.open()
                            return;
                        }

                        setAskForHelpMode();
                    }
                }
            }
        }
    }

    Message{
        id: message
        x: main.swidth/2 - width/2
        y: main.sheight*3/4
        visible: false
    }

    Popup{
        id: name_phone_data_reseaveer_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - contentItem.height/2
        modal: false
        width: main.swidth*0.8
        contentItem: Column{
            anchors.fill: parent
            Label{
                text: qsTr("<b>Введите имя и телефон<b>")
                font.pointSize: font_size_point_text_text_medium
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }
            TextField{
                id: name_field
                width: parent.width*0.8
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: qsTr("Имя")
                font.pointSize: font_size_point_text_text_medium
                validator: RegExpValidator{regExp: /(?:[a-z]|[A-Z]|[a-я]|[А-Я]){1,30}/}
            }
            Row{
                width: parent.width*0.8
                height: size_icon_common
                anchors.horizontalCenter: parent.horizontalCenter
                ComboBox{
                    width: parent.width/3
                    id:country_phone_code
                    textRole: "code"
                    font.pointSize: font_size_point_text_text_medium
                    displayText: "+"+currentText
                    model:CountryPhoneCodesModel{}
                    currentIndex: 0
                    delegate: ItemDelegate {
                        width: country_phone_code.width
                        text: "+%1(%2)".arg(code).arg(country)
                        font.weight: country_phone_code.currentIndex === index ? Font.DemiBold : Font.Normal
                        highlighted: country_phone_code.highlightedIndex == index
                    }
                    /*:Item{
                        width: country_phone_code.width
                        height: country_phone_code.height
                        Text{
                            anchors.left: parent.left
                            text:"+"+code
                        }
                        Text{
                            anchors.right: parent.right
                            text: country
                            width: parent.width/2
                            wrapMode: Text.Wrap
                        }
                    }*/
                }
                TextField{
                    id: phone_field
                    width: parent.width*2/3
                    font.pointSize: font_size_point_text_text_medium
                    //inputMask:"0000000000000"
                    text:""
                }
            }
            TextField
            {
                id:phone_field_
                anchors.horizontalCenter: parent.horizontalCenter
                inputMask: "+7(999)999-99-99"
                font.pointSize: font_size_point_text_text_medium
                visible: false
            }
            Text{
                id: npd_message_field
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                visible: false
                color:"red"
                font.pointSize: font_size_point_text_text_medium
                text:""
            }
            Button{
                text: qsTr("Далее")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: font_size_point_text_text_medium
                onClicked:{
                    var name_value = name_field.text;
                    //Names check naive
                    if( name_value.length == 0){
                        npd_message_field.text = qsTr("Заполните поле имя")
                        npd_message_field.visible = true;
                        return;
                    }

                    var phone_value = country_phone_code.displayText+phone_field.text//phone_field.text;
                    //phone_check naive
                    phone_value = phone_value.replace(/[+\(\)-]{1,}/g,"");
                    if( phone_value.length < 11 ){
                        npd_message_field.text = qsTr("Неверный телефонный номер")
                        npd_message_field.visible = true;
                        return;
                    }
                    npd_message_field.text = "";
                    npd_message_field.visible = false;

                    var user_name = name_value;
                    var user_phone = phone_value;

                    user.setData(User.Name, user_name);
                    user.setData(User.Phone, user_phone);
                    user.save();

                    name_phone_data_reseaveer_popup.close();
                    stackView.push(askForHelpDataPageItem);
                }
            }
        }
    }

    Popup{
        id: info_not_registred_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - height/2
        modal: false
        width: main.swidth*2/3
        height: main.sheight/2
        contentItem: Item{
            anchors.fill: parent
            Column{
                anchors.fill: parent;
                spacing: 10

                Flickable {
                    id: info_not_registred_flick
                    width: parent.width;
                    height: parent.height*0.75;
                    contentWidth: info_not_registred_text.paintedWidth
                    contentHeight: info_not_registred_text.paintedHeight
                    clip: true

                    function ensureVisible(r)
                    {
                        if (contentX >= r.x)
                            contentX = r.x;
                        else if (contentX+width <= r.x+r.width)
                            contentX = r.x+r.width-width;
                        if (contentY >= r.y)
                            contentY = r.y;
                        else if (contentY+height <= r.y+r.height)
                            contentY = r.y+r.height-height;
                     }

                    Text {
                        id: info_not_registred_text
                        width: info_not_registred_flick.width
                        height: info_not_registred_flick.height
                        leftPadding: 2
                        rightPadding: 2
                        topPadding: 2
                        bottomPadding: 2
                        wrapMode: TextEdit.Wrap
                        text: qsTr("Здорово, что Вы хотите помогать другим! Спасибо Вам большое. "
                                 + "Однако, у нас строгие правила. "
                                 + "Поскольку мы хотим обеспечить набольшую безопасность пользователям, helper'ам и всем окружающим,"
                                 + "мы провим всем helper'ов пройти регистрацию и запонить профиль(не забудьте поставить галочку \"Стать Helper'ом\"). "
                                 + "Если Вы согласны, нажмите на кнопку \"Зарегистрироваться\"")
                        font.pointSize: font_size_point_text_text_medium

                        onLinkActivated: {
                            Qt.openUrlExternally(link)
                        }
                    }
                    ScrollBar.vertical: ScrollBar{}
                }
                Button{
                    text: qsTr("Зарегистрироваться")
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        stackView.push(registratePage)
                        info_not_registred_popup.close()
                    }
                }
            }
        }
    }

    Popup{
        id: info_profile_not_filled_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - height/2
        modal: false
        width: main.swidth*2/3
        height: main.sheight/2
        contentItem: Item{
            anchors.fill: parent
            Column{
                anchors.fill: parent;
                spacing: 10

                Flickable {
                    id: info_profile_not_filled_flick
                    width: parent.width;
                    height: parent.height*0.75;
                    contentWidth: info_profile_not_filled_text.paintedWidth
                    contentHeight: info_profile_not_filled_text.paintedHeight
                    clip: true

                    function ensureVisible(r)
                    {
                        if (contentX >= r.x)
                            contentX = r.x;
                        else if (contentX+width <= r.x+r.width)
                            contentX = r.x+r.width-width;
                        if (contentY >= r.y)
                            contentY = r.y;
                        else if (contentY+height <= r.y+r.height)
                            contentY = r.y+r.height-height;
                     }

                    Text {
                        id: info_profile_not_filled_text
                        width: info_profile_not_filled_flick.width
                        height: info_profile_not_filled_flick.height
                        leftPadding: 2
                        rightPadding: 2
                        topPadding: 2
                        bottomPadding: 2
                        wrapMode: TextEdit.Wrap
                        text: qsTr("Ваше желание помочь другим вызывает возхищение. Браво! "
                                   + "Теперь заполните профиль и обязательно выставить флаг \"Стать Helper'ом\". ")
                        font.pointSize: font_size_point_text_text_medium

                        onLinkActivated: {
                            Qt.openUrlExternally(link)
                        }
                    }

                    ScrollBar.vertical: ScrollBar{}
                }
                Button{
                    text: qsTr("Заполнить профиль")
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        profilePage.autoFillForm()
                        profilePage.setHelperFlag(true)
                        stackView.push(profilePage)
                        info_profile_not_filled_popup.close()
                    }
                }
            }
        }
    }


    Popup{
        id: info_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - height/2
        modal: false
        width: main.swidth*2/3
        height: main.sheight/2

        contentItem: Item{
            anchors.fill: parent
            Column{
                anchors.fill: parent;
                spacing: 10

                Flickable {   
                    id: info_popup_text_area_flick
                    width: parent.width;
                    height: parent.height*0.75;
                    contentWidth: info_popup_text_area.paintedWidth
                    contentHeight: info_popup_text_area.paintedHeight
                    clip: true

                    function ensureVisible(r)
                    {
                        if (contentX >= r.x)
                            contentX = r.x;
                        else if (contentX+width <= r.x+r.width)
                            contentX = r.x+r.width-width;
                        if (contentY >= r.y)
                            contentY = r.y;
                        else if (contentY+height <= r.y+r.height)
                            contentY = r.y+r.height-height;
                     }

                    Text {
                        id: info_popup_text_area
                        width: info_popup_text_area_flick.width
                        height: info_popup_text_area_flick.height
                        leftPadding: 2
                        rightPadding: 2
                        topPadding: 2
                        bottomPadding: 2
                        wrapMode: TextEdit.Wrap
                        text: user_agreement_popup.agreement_text
                        font.pointSize: font_size_point_text_text_medium

                        onLinkActivated: {
                            Qt.openUrlExternally(link)
                        }
                    }

                    ScrollBar.vertical: ScrollBar { }
                }
                Button{
                    text: qsTr("ОК")
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        info_popup.close()
                        info_popup_text_area.text = ""
                    }
                }
            }
        }
        function setText(_text)
        {
            info_popup_text_area.text = _text;
        }
    }

    Popup{
        id: info_triger_popup
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
                spacing: 10

                Flickable {
                    id: info_triger_popup_flick
                    width: parent.width;
                    height: parent.height*0.75;
                    contentWidth: info_triger_popup_text_area.paintedWidth
                    contentHeight: info_triger_popup_text_area.paintedHeight
                    clip: true

                    function ensureVisible(r)
                    {
                        if (contentX >= r.x)
                            contentX = r.x;
                        else if (contentX+width <= r.x+r.width)
                            contentX = r.x+r.width-width;
                        if (contentY >= r.y)
                            contentY = r.y;
                        else if (contentY+height <= r.y+r.height)
                            contentY = r.y+r.height-height;
                     }

                    Text {
                        id: info_triger_popup_text_area
                        width: info_triger_popup_flick.width
                        height: info_triger_popup_flick.height
                        leftPadding: 2
                        rightPadding: 2
                        topPadding: 2
                        bottomPadding: 2
                        wrapMode: TextEdit.Wrap
                        text: user_agreement_popup.agreement_text
                        font.pointSize: font_size_point_text_text_medium

                        onLinkActivated: {
                            Qt.openUrlExternally(link)
                        }
                    }
                    ScrollBar.vertical: ScrollBar{}
                }
                RowLayout{
                    width: parent.width* 3/ 4
                    height: size_icon_common
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button{
                        text: qsTr("ОК")
                        anchors.left: parent.left
                        font.pointSize: font_size_point_text_text_medium
                        onClicked: {
                            info_triger_popup.close()
                            if( info_triger_popup.triger ){
                                info_triger_popup.triger()
                            }
                            info_triger_popup.triger = null
                            info_triger_popup_text_area.text = ""
                        }
                    }
                    Button{
                        text: qsTr("Отмена")
                        anchors.right: parent.right
                        font.pointSize: font_size_point_text_text_medium
                        onClicked: {
                            info_triger_popup.close()
                            info_triger_popup.triger = null
                            info_triger_popup_text_area.text = ""
                        }
                    }
                }
            }
        }

        function setText(_text)
        {
            info_triger_popup_text_area.text = _text;
        }

        function setFunction(_function)
        {
            triger = _function;
        }
    }

    Popup {
        id: user_agreement_popup
        x: main.swidth/2 - width/2
        y: main.sheight/2 - height/2
        modal: true
        width: main.swidth
        height: main.sheight

        contentItem: Column{
            anchors.fill: parent
            spacing: 5
            Flickable {
                id: user_text_field_flick
                width: parent.width;
                height: parent.height*0.75;
                contentWidth: user_text_field.paintedWidth
                contentHeight: user_text_field.paintedHeight
                clip: true

                function ensureVisible(r)
                {
                    if (contentX >= r.x)
                        contentX = r.x;
                    else if (contentX+width <= r.x+r.width)
                        contentX = r.x+r.width-width;
                    if (contentY >= r.y)
                        contentY = r.y;
                    else if (contentY+height <= r.y+r.height)
                        contentY = r.y+r.height-height;
                 }

                Text {
                    id: user_text_field
                    width: user_text_field_flick.width
                    height: user_text_field_flick.height
                    leftPadding: 2
                    rightPadding: 2
                    topPadding: 2
                    bottomPadding: 2
                    wrapMode: TextEdit.Wrap
                    text: user_agreement_popup.agreement_text
                    font.pointSize: font_size_point_text_text_medium

                    onLinkActivated: {
                        Qt.openUrlExternally(link)
                    }
                }

                ScrollBar.vertical: ScrollBar { }
            }
        }
        CheckBox{
            id: agreed_box
            width: parent.width
            checked: false
            text: qsTr("Я согласен ")
            font.pointSize: font_size_point_text_text_medium
        }
        RowLayout{
            width: parent.width
            Button{
                text: qsTr("Ок")
                width: parent.width
                onClicked: {
                    if( agreed_box.checked ){
                        privateStorage.setValue("agreement_accepted",1)
                        user_agreement_popup.close()
                    }
                }
            }
        }

        property string agreement_text: "<p><b>ПОЛЬЗОВАТЕЛЬСКОЕ СОГЛАШЕНИЕ</b></p>"+
                                        "<p><b>ВНИМАТЕЛЬНО ПРОЧИТАЙТЕ НАСТОЯЩИЙ ДОКУМЕНТ</b><p>"+
    "<p>Настоящий документ в соответствии со ст.437 Гражданского кодекса Российской Федерации является публичной офертой (далее – «Оферта»), представляющей собой
    адресованное неограниченному кругу физических лиц, достигших возраста
    совершеннолетия, предложение сайта <a href=\"www.parijana.org\">parijana.org</a> (далее – «Правообладатель»),
    заключить лицензионное соглашение о предоставлении простой (неисключительной)
    лицензии (далее – «Соглашение») на мобильное приложение “Друг и Помошник”(Local
    Helper) (далее – «Мобильное приложение») на условиях, изложенных ниже, являющихся
    существенными условия Соглашения. Установка Мобильного приложения на настольный
    или карманный персональный компьютер, мобильный телефон, коммуникатор, смартфон
    (далее – «Абонентское устройство»), а также начало использования Мобильного
    приложения в любой форме признаются акцептом Оферты согласно ст.438 Гражданского
    кодекса Российской Федерации, что означает полное безоговорочное принятие
    Пользователем всех условий Соглашения без каких-либо изъятий или ограничений на
    условиях присоединения. Если Пользователь не согласен с настоящим Соглашением, а
    также условиями, положениями и правилами пользования Мобильным приложения, не
    хочет их соблюдать, то он должен не устанавливать Мобильное приложение,
    незамедлительно удалить его/любой его компонент с Абонентского устройства. В случае,
    если Пользователь по каким-либо причинам не согласны с условиями настоящего
    Соглашения, то это означает обязанность Пользователя по удалению Мобильного
    приложения с Абонентского устройства, на котором оно ранее было установлено.
    Использование Мобильного приложения на иных условиях не допускается. Перед
    установкой Мобильного приложения Пользователь обязуется ознакомиться с Офертой. В
    случае несогласия с условиями Соглашения, в целом или какой-либо их части,
    Пользователь не вправе использовать Мобильного приложения. Оферта, а также все
    последующие изменения или дополнения к ней, которые могут быть произведены
    Правообладателем в одностороннем порядке, без какого-либо специального
    уведомления Пользователя, размещаются на интернет-сайте: <a href=\"www.parijana.org\">www.parijana.org</a>, если иное
    не предусмотрено новой редакцией Оферты. Пользователь обязуется самостоятельно
    отслеживать любые возможные изменения.</p>
    <p><b>1.</b> Предмет Соглашения</p>
    <p><b>1.1.</b> Правообладатель обязуется предоставить Пользователю право использования
    Мобильного приложения (простую (неисключительную) лицензию), исключительное
    право на которое принадлежит Правообладателю, без предоставления Пользователю
    права передачи, сублицензирования, могущую быть полностью по усмотрению
    Правообладателя аннулированной, на использование Приложения на Абонентском
    устройстве, которым Пользователь владеет или распоряжается на законном основании.
    <b>1.2.</b> В объем права использования Мобильного приложения, предоставленного
    Пользователю, входит использование Мобильного приложения по его прямому
    функциональному назначению, том числе установка и воспроизведение Мобильного
    приложения на неограниченном числе Абонентских устройств, при условии сохранения в
    неизменном виде комбинации, состава и содержания Мобильного приложения по
    сравнению с тем, как они предоставляются для использования Правообладателем.</p>
    <p><b>1.3.</b> Территория действия настоящего Соглашения не ограничена.</p>
    <p><b>1.4.</b> Срок действия простой (неисключительной) лицензии на использование Мобильного
    приложения, равен сроку действия исключительного права на Мобильное приложение.
    При расторжении или прекращении действия Соглашения Пользователь утрачивает право
    использования Мобильного приложения. Правообладатель вправе в любой момент без
    объяснения причин расторгнуть настоящее Соглашение, прекратив использование
    Мобильного приложения Пользователем.</p>
    <p><b>2.</b> Запрещенные способы использования</p>
    <p><b>2.1.</b> Если в тексте Соглашения специально не указано иное, то Пользователь не можете
    без предварительного письменного согласия Правообладателя: (i) модифицировать,
    встраивать Мобильное приложение в другое программное обеспечение или объединять с
    ним, создавать переработанную версию любой части Мобильного приложения; (ii)
    продавать, выдавать лицензии (сублицензии), отдавать в аренду, переуступать,
    передавать, отдавать в залог, разделять права по настоящему Соглашению третьим
    лицам; (iii) использовать, копировать, распространять или воспроизводить Мобильное
    приложение в интересах третьих лиц, а также в коммерческих целях; (iv) обнародовать
    результаты какого-либо сопоставительного анализа касательно Мобильного приложения,
    использовать упомянутые результаты для какой-либо деятельности по разработке
    программного обеспечения; (v) модифицировать, дизассемблировать, декомпилировать,
    разбирать на составляющие коды, перерабатывать или усовершенствовать Мобильное
    приложение, пытаться получить исходный текст программы Мобильного приложения,
    иным способом нарушать нормальный ход его работы. (vi) копировать, воспроизводить,
    перерабатывать, распространять, размещать в свободном доступе (опубликование) в сети
    Интернет, использовать в средствах массовой информации и/или коммерческих целях
    любые материалы, размещенные в Мобильном приложении, в том числе как
    извлеченные из баз данных, включаемых в состав Мобильного приложения, так и
    полученных путем копирования результатов обработки данных с использованием
    Мобильного приложения, а также производных от таких материалов продуктов (с
    дополнениями, сокращениями и прочими переработками). Права и способы
    использования Мобильного приложения, в явном виде не предоставленные/не
    разрешенные Пользователю по Соглашению, считаются не
    предоставленными/запрещенными Правообладателем. Нарушение целостности
    Мобильного приложения, нарушение систем защиты Мобильного приложения, а также
    иные действия, нарушающие исключительное право Правообладателя на Мобильное
    приложение ,не допускаются и влекут гражданско-правовую, административную либо
    уголовную ответственность Пользователя в соответствии с законодательством Российской
    Федерации, в том числе обязанность исполнить решение суда по требованию
    Правообладателя о признании права, о пресечении действий, нарушающих право или
    создающих угрозу его нарушения, о возмещении убытков, о публикации решения суда о
    допущенном нарушении с указанием действительного Правообладателя, о возмещении
    убытков либо выплате компенсации.</p>
    <p><b>3.</b> Безвозмездность</p>
    <p><b>3.1.</b> Настоящее Соглашение не предусматривает взыскания с Пользователя каких-либо
    разовых или периодических платежей за право пользования Мобильным приложением.
    Простая (неисключительная) лицензия предоставляется на безвозмездной основе.
    Пользователь извещен, что при установке на Абонентское устройство Мобильного
    приложения организацией, предоставляющей услуги пользования Интернетом, может
    взиматься плата за использование Интернета согласно тарифу.</p>
    <p><b>4.</b>Исключительное право</p>
    <p><b>4.1.</b> Исключительное право на Мобильное приложение в целом и включаемые в его
    состав или используемые совместно с ним программы для ЭВМ, базы данных,
    картографические, справочноинформационные, аудиовизуальные, текстовые и прочие
    текстовые материалы, изображения и иные объекты авторских и/или смежных прав, а
    равно объекты патентных прав, товарные знаки, коммерческие обозначения и
    фирменные наименования, а также иные составляющие Мобильного приложения и
    (независимо от того, входят ли они в их состав или являются дополнительными
    компонентами, и возможно ли их извлечение из их состава и использование
    самостоятельно) в отдельности, защищены в соответствии с частью IV Гражданского
    кодекса Российской Федерации и принадлежат Правообладателю.</p>
    <p><b>5.</b> Обновление и поддержка</p>
    <p>Правообладатель по данному Соглашению не обязан предоставлять Пользователю
    поддержку, обслуживание, обновления, модификации и новые версии Мобильного
    приложения. Однако он может время от времени выпускать обновления для Мобильного
    приложения и автоматически путем электронной коммуникации обновлять его версию,
    установленную Абонентском устройстве. Пользователь по умолчанию соглашается на
    такое автоматическое обновление, а также принимает то, что условия и положения
    данного Соглашения будут иметь силу для указанных обновлений.</p>
    <p><b>6.</b> Отсутствие гарантий и ответственности</p>
    <p><b>6.1.</b> Мобильное приложение предоставляются на условиях «как есть», в связи с чем
    Пользователю не представляются какие-либо гарантии того, что Мобильное приложение
    будет соответствовать требованиям Пользователя, предоставляться непрерывно, быстро,
    надежно и без ошибок, результаты, которые могут быть получены с использованием
    Мобильного приложения, будут точными и надежными. Если Мобильное приложение
    содержит какое-либо программное обеспечение третьих лиц, такое программное
    обеспечение поставляется без гарантий качества, а его использование регулируется
    условиями и ограничениями, установленными упомянутыми третьими сторонами. Правообладатель не несет ответственности за задержки, перебои в работе и невозможность полноценного использования Мобильного приложения, происходящие
    прямо или косвенно по причине действия или бездействия третьих лиц и/или
    неработоспособностью информационных каналов (Интернет), находящихся за пределами собственных ресурсов Правообладателя. Пользователь соглашается с тем, что для установки и функционирования Мобильного приложения Пользователю необходимо использовать программное обеспечение (веб-браузеры, операционные системы и прочее) и оборудование (абонентские устройства, сетевое оборудование и прочее), произведенное и предоставленное третьими лицами, и Правообладатель не может нести ответственность за качество их работы. Пользователь самостоятельно несет все риски, связанные с использованием Мобильного приложения.</p>
    <p><b>7.</b> Ограниченная ответственность</p>
    <p><b>7.1.</b> Правообладатель не несет ответственности ни в силу договора, ни вследствие правонарушения (включая небрежность), а также в иных случаях перед Пользователем или третьими лицами за любой ущерб или убытки (учитывая косвенные, фактические, последующие), включая, помимо прочего, какой-либо ущерб или убытки в отношении дохода от коммерческой деятельности, неполученной прибыли, деловой репутации, поврежденных или утраченных данных либо документации, понесенные тем или иным лицом вследствие или в связи с использованием Мобильного приложения, даже если Правообладателю стало известно о возможности возникновения такого ущерба.</p>
    <p><b>7.2.</b> Если, несмотря на условия настоящего Соглашения, Правообладатель будет признан ответственным за ущерб, указанный в п.7.1 настоящего Соглашения, а также за любой другой ущерб, сумма возмещения не будет превышать десяти (10) долларов США или суммы в любой другой валюте, эквивалентной данному значению.</p>
    <p><b>8.</b> Гарантия от убытков</p>
    <p><b>8.1.</b> Пользователь несет самостоятельную ответственность за соблюдение при использовании Мобильного приложения требований действующего законодательства Российской Федерации(или той страны где он находится), а также всех прав и законных интересов третьих лиц. В случае предъявления третьими лицами к Правообладателю требований, вызванных действиями (бездействием) Пользователя при использовании Мобильного приложения, Пользователь самостоятельно урегулирует возникшие споры с третьими лицами, а также возмещает убытки и расходы Правообладателя по первом его требованию. При этом Пользователь обязуется защищать интересы Правообладателя (без каких-либо полномочий), освобождать его от ответственности, ограждать его от причинения ущерба в связи с любыми претензиями и обязательствами, возникшими вследствие действий или бездействия Пользователя.</p>
    <p><b>9.</b> Информирование</p>
    <p><b>9.1.</b> Правообладатель вправе информировать Пользователя о порядке и способах
    использования Мобильного приложения, о проводимых Правообладателем, его
    партнерами и клиентами маркетинговых, рекламных и иных мероприятиях, об условиях
    приобретения и потребления услуг третьих лиц с использованием Мобильного
    приложения, путем направления сообщений, в том числе содержащих рекламу, на
    Абонентское устройство, в том числе с использованием сети связи, включая мобильной,
    любым доступным Правообладателю способом. Также Пользователь соглашается на
    получение сервисных коротких текстовых сообщений, необходимых для реализации
    функционала Мобильного приложения или цели его использования.</p>
    <p><b>10.</b> Конфиденциальность и защита личной информации</p>
    <p><b>10.1.</b> Правообладатель обязуется соблюдать права Пользователей на неразглашение и
    сохранность личной информации, переданных Правообладателю (полученных
    Правообладателем). Такая информация в любом случае признается конфиденциальной, и
    Правообладатель примем достаточные меры, необходимые для ее защиты от
    несанкционированного доступа к ней третьим лицам, на основе стандартных отраслевых
    технологий и методов. Среди других способов информация, переданная Пользователем,
    защищена при помощи брандмауэра, шифрованного протокола (SSL) и зашифрованных
    данных. Однако Правообладатель не может гарантировать абсолютной защиты данных.
    Пользователь должен держать в секрете номер своей учетной записи и иную
    информацию о ней, рекомендуется время от времени менять пароль входа.</p>
    <p><b>10.2.</b> Используя Мобильное приложение, в том числе при регистрации учетной записи,
    Пользователь соглашается с тем, что они будут обрабатываться Правообладателем, его
    аффилированными лицами, подрядчиками, агентами, сотрудниками как с
    использованием средств автоматизации, так и без таковых. Правообладатель может
    собирать личную информацию, добровольно и сознательно предоставляемую
    Пользователями во время создания учетной записи, если таковая необходима для
    использования Мобильного приложения, а также во время такого использования, в том
    числе фамилия, имя, отчество, номер мобильного телефона, адрес электронной почты,
    возраст, покупательские предпочтения. Пользователь предупрежден о том, что
    Правообладатель в целях повышения качества обслуживания может собирать
    информацию о месте нахождения Пользователя, в том числе с использованием GPS,
    однако Пользователь не возражает против этого. Правообладатель может использовать
    личную информацию, чтобы: (i) предоставлять услуги Пользователю, в том числе в целях
    предоставления права использования Мобильным приложением; (ii) отправлять
    сообщения Пользователям; (iii) предоставлять пользователям поддержку; (iv) отправлять
    рекламные материалы для целевой аудитории и сообщать о льготных предложениях,
    акциях, маркетинговых, рекламных и иных мероприятий, проводимых
    Правообладателем, его партнерами и клиентами.</p>
    <p><b>10.3.</b> Правообладатель обязуется не разглашать какую-либо личную информацию,
    полученную от Пользователя. Однако Правообладатель будет вправе раскрывать
    подобную информацию в следующих случаях: (a) для соблюдения требований
    применимого закона, постановления, судебного процесса, судебной повестки или
    требований правительства; (б) для обеспечения контроля исполнения настоящего Соглашения; (в) для обнаружения, предотвращения или решения вопросов, связанных с обманом, безопасностью или техническими аспектами; (г) для ответов на просьбы Пользователей о поддержке; (д) для реагирования на претензии относительно того, что то или иное информационное наполнение нарушает права третьих лиц; (е) для реагирования на претензии относительно того, что контактная информация (например, имя, адрес и т.п.) третьей стороны были опубликованы или переданы без ее согласия или в качестве оскорбления; (ж) для защиты прав, собственности или безопасности Правообладателя, других Пользователей или широкой публики; (з) если у
    Правообладателя меняется система управления, включая случаи слияния, поглощения или покупки всего имущества Правообладателя либо значительной его части; (к) чтобы
    Пользователь мог наиболее эффективно и рационально использовать Мобильное приложения; (л) согласно вашему ясно выраженному предварительному разрешению.</p>
    <p><b>10.4.</b> Правообладатель может собирать анонимную (обезличенную) информацию, не касающуюся конкретно Пользователя, но предоставленную им. К такой информации относится любая нескрываемая информация, которая становится доступной Правообладателю в результате использования Пользователем Мобильного приложения, в том числе данные об идентификации браузера Пользователя, так же как и операционной системы, порядок посещения страниц Пользователем, время и дату подключения Пользователя и т.п. Данная информация собирается для ведения статистики и применяется для улучшения качества обслуживания Пользователя, а также усовершенствования интерфейса Мобильного приложения. Во избежание недоразумений Правообладатель может передавать и разглашать информацию, определяемую в настоящем пункте, третьим лицам по собственному усмотрению.</p>
    <p><b>10.5.</b> Если Пользователь желает заблокировать или уточнить личную информацию, переданную Правообладателю, или прекратить ее обработку Правообладателю, то он может обратиться непосредственно к Правообладателю по его официальному адресу местонахождения, указанному в настоящем Соглашении, также посредством Мобильного приложения. Пользователь предупрежден, что прекращение обработки его личной информации Правообладателем может повлечь прекращения права использования Мобильным приложением.</p>
    <p>Наиболее актуальная и полная версия пользовательского соглашения приведена на  <a href=\"www.parijana.org\">www.parijana.org</a></p>"
    }
}
