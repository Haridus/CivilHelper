import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Parijana.Core 0.1
import Parijana.Backend 0.1

//import QtQuick.Controls 1.4

Item {
    id: profile_page

    function autoFillForm()
    {
        helper_flag.checked = user.data(User.HelperFlag) ? user.data(User.HelperFlag) : false
        nameArea.text = user.data(User.Name) ? user.data(User.Name)    : "";
        snameArea.text = user.data(User.SName) ?  user.data(User.SName): "";
        fnameArea.text = user.data(User.FName) ? user.data(User.FName) : "";
        comboSex.currentIndex = user.data(User.Sex) ? user.data(User.Sex) : 0;
        birthArea.text = user.data(User.Birth) ? user.data(User.Birth) : "" ;
        comboDocType.currentIndex = user.data(User.DocType) ? user.data(User.DocType) : 0 ;
        doc_num_field.text = user.data(User.DocNum) ? user.data(User.DocNum) : "";
        doc_info_field.text = user.data(User.DocInfo) ? user.data(User.DocInfo) : "";
        //console.log("auto fill form")
    }

    function setHelperFlag(ok)
    {
        helper_flag.checked = ok
    }

    onVisibleChanged:
    {
        if( visible ){
            autoFillForm();
        }
    }

    Column{
        width: parent.width
        height: parent.height
        anchors.fill: parent
        spacing: 20
        RowLayout{
            width: parent.width/2
            anchors.horizontalCenter: parent.horizontalCenter
            Label{
                Layout.alignment: Qt.AlignLeft
                text:qsTr("Стать Helper'ом")
                font.pointSize: font_size_point_text_text_medium
            }
            Switch{
                id: helper_flag
                Layout.alignment: Qt.AlignRight
                checked: user.data(User.HelperFlag)
            }
        }
        TextField {
            id: nameArea
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: "Имя*"
            font.pointSize: font_size_point_text_text_medium
            text: user.data(User.Name)
        }
        TextField {
            id: snameArea
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: "Отчество"
            font.pointSize: font_size_point_text_text_medium
            text: user.data(User.SName)
        }
        TextField {
            id: fnameArea
            width:parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: "Фамилия"
            Layout.fillWidth: true
            font.pointSize: font_size_point_text_text_medium
            text: user.data(User.FName)
        }
        RowLayout {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                anchors.left: parent.left
                font.pointSize: font_size_point_text_text_medium
                text: "Пол"
            }
            ComboBox {
                id: comboSex
                anchors.right: parent.right
                model: ["Не определено","Мужской","Женский" ]
                currentIndex: user.data(User.Sex)
                font.pointSize: font_size_point_text_text_medium
                Layout.fillWidth: true
            }
        }
        RowLayout {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Label {
                anchors.left: parent.left
                font.pointSize: font_size_point_text_text_medium
                text: "День рождения*"
            }
            TextField {
                id: birthArea
                Layout.fillWidth: true
                font.pointSize: font_size_point_text_text_medium
                placeholderText: "Дата рождения YYYY-MM-dd"
                inputMethodHints : Qt.ImhDate
                //validator: RegExpValidator{regExp: /\d{4,4}-\d{1,2}-\d{1,2}/}
                text: user.data(User.Birth)
                onTextChanged: {
                    if( text.length >= 4 & text.length<7 ){
                        inputMask = "9999-99"
                    }
                    else if(text.length >=7){
                        inputMask = "9999-99-99"
                    }
                    else{
                        inputMask = ""
                    }
                    cursorPosition = text.length
                }
            }
            Rectangle{
                anchors.left: birthArea.right
                width: size_icon_common*2
                height: birthArea.height
                border.width: 1
                Image{
                    anchors.centerIn: parent
                    width: height
                    height: parent.height*2/3
                    source: "qrc:/images/calendar.svg"

                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        date_edit_popup.setup_year_model();
                        date_edit_popup.fill_from_text(birthArea.text);
                        date_edit_popup.open();
                    }
                }
            }
        }
        RowLayout {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                anchors.left: parent.left
                text: "Документ"
                font.pointSize: font_size_point_text_text_medium
            }
            ComboBox {
                id: comboDocType
                model: ["Не определено","Паспорт","Водительское удостоверение" ]
                currentIndex: user.data(User.DocType)
                Layout.fillWidth: true
                font.pointSize: font_size_point_text_text_medium
            }
            TextField{
                id: doc_num_field
                anchors.right: parent.right
                placeholderText: "Номер документа"
                text: user.data(User.DocNum)
                font.pointSize: font_size_point_text_text_medium
            }
        }
        Flickable {
              id: doc_info_container_field
              anchors.left: parent.left
              anchors.right: parent.right
              height: size_icon_common*3

              TextArea.flickable: TextArea {
                  font.pointSize: font_size_point_text_text_medium
                  id: doc_info_field
                  text: user.data(User.DocInfo)
                  height: parent.height
                  placeholderText: qsTr("Другая информация по документу")
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
        Label {
            id: errorMessage
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            color: "red"
            font.pointSize: font_size_point_text_text_medium
            text: ""
        }
        RowLayout {
            width: parent.width/2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Button {
                text: "Сохранить"
                Layout.alignment : Qt.AlignLeft
                font.pointSize: font_size_point_text_text_medium
                onClicked: {
                    // var rx_name = /\w+/ will not work due to Эквивалентен набору символов [A-Za-z0-9_].
                    var rx_date = /\d{4,4}-\d{1,2}-\d{1,2}/

                    var _name = nameArea.text
                    var _sname = snameArea.text
                    var _fname = fnameArea.text
                    var _sex = comboSex.currentIndex
                    var _birth = birthArea.text
                    var _helper_flag = helper_flag.checked ? 1 :0
                    var _docType = comboDocType.currentIndex
                    var _docNum  = doc_num_field.text
                    var _docInfo = doc_info_field.text

                    if( _name.length ===0 /*|| !rx_name.test(_name)*/ ){
                        errorMessage.text = "Неверно заполнено поле имя"
                        errorMessage.visible = true;
                        return
                    }
                    if( _birth.length > 0 && !rx_date.test(_birth) ){
                        errorMessage.text = "Неверно заполнена дата"
                        errorMessage.visible = true;
                        return
                    }
                    if(_helper_flag && ( _docType < 1 || _docNum.length === 0 /*|| _docInfo.length === 0*/ ) ){
                        errorMessage.text = "Необходимо заполнить информацию о документе удостоверяющем личность"
                        errorMessage.visible = true;
                        //TODO maybe here heed pop_up with reference for help file with more detailed description
                        return
                    }
                    errorMessage.text = ""
                    errorMessage.visible = false;

                    user.setData(User.Name,_name);
                    user.setData(User.SName,_sname);
                    user.setData(User.FName,_fname);
                    user.setData(User.Sex,_sex);
                    user.setData(User.Birth,_birth);
                    user.setData(User.DocType,_docType);
                    user.setData(User.DocNum,_docNum);
                    user.setData(User.DocInfo,_docInfo);
                    user.save();

                    var params = new Array()

//                    "name"
//                    "sName"
//                    "fName"
//                    "birth"
//                    "sex"
//                    "docType"
//                    "docNum"
//                    "docInfo"
//                    "docImage"
//                    "want_help"
//                    "checked"
//                    "admitted"
//                    "current_request"

                    params.push( user.data(User.UserStump) )

                    var _data_str = [];
                    _data_str.push("name="+_name)
                    _data_str.push("sName="+_sname)
                    _data_str.push("fName="+_fname)
                    _data_str.push("sex="+_sex)
                    _data_str.push("birth="+_birth)
                    _data_str.push("docType="+_docType)
                    _data_str.push("docNum="+_docNum)
                    _data_str.push("docInfo="+_docInfo)
                    _data_str.push("want_help="+_helper_flag)

                    params.push( backend.toPersentEncoding( _data_str.join("&") ) );

                    backend.sendRequest(Backend.CHANGE_PROFILE_DATA, params);

                    if( _helper_flag > 0 && ( user.data(User.DataChecked) < 1 ) ){
                        on_want_help_popup.open()
                    }
                    else{
                        stackView.pop()
                    }
                }
            }
            Button {
                text: "Отмена"
                Layout.alignment : Qt.AlignRight
                font.pointSize: font_size_point_text_text_medium
                onClicked: { stackView.pop() }
            }
        }
    }

    Popup{
        id: date_edit_popup
        x: profile_page.width/2  - width/2
        y: profile_page.height/2 - contentItem.height/2
        modal: false
        width: parent.width*2/3
        contentItem: Column{
            spacing: 10
            RowLayout{
                ComboBox{
                    id: day_box
                    font.pointSize: font_size_point_text_text_medium
                    model:[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
                }
                ComboBox{
                    id: month_box
                    font.pointSize: font_size_point_text_text_medium
                    model:["Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь"]
                }
                ComboBox{
                    id: year_box
                    font.pointSize: font_size_point_text_text_medium
                    property int max_year: new Date().getFullYear()
                    model: null
                }
            }
            Button{
                text: qsTr("OK")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: font_size_point_text_text_medium
                onClicked: {
                    var entryes = [];
                    entryes.push( year_box.currentText );
                    entryes.push( ( month_box.currentIndex+1 ) < 10 ? "0"+( month_box.currentIndex+1 ) : ( month_box.currentIndex+1 ) );
                    entryes.push( day_box.currentText < 10 ? "0"+day_box.currentText : day_box.currentText  );
                    var text = entryes.join("-");
                    birthArea.text = text;
                    date_edit_popup.close();
                }
            }
        }
        function setup_year_model()
        {
            if( !year_box.model ){
                var years = [];
                var current_date = new Date();
                for(var year = current_date.getFullYear(); year > 1800; year-- ){
                    years.push(year);
                }
                year_box.model = years;
            }
        }

        function fill_from_text(text){
            var date = new Date(text)
            if( !isNaN( date.valueOf() ) ){
                year_box.currentIndex = year_box.max_year-date.getFullYear();
                month_box.currentIndex = date.getMonth();
                day_box.currentIndex = date.getDate()-1;
            }
            //console.log("date check", text, date, year_box.currentIndex, year_box.currentText,month_box.currentIndex, month_box.currentText, day_box.currentIndex, day_box.currentText )
        }
    }

    Popup{
        id: on_want_help_popup
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
                    anchors.left: parent.left
                    anchors.right: parent.right
                    contentWidth: parent.width
                    contentHeight: parent.height*0.8
                    height: parent.height*0.8

                    TextArea.flickable: TextArea {
                        height: parent.height
                        wrapMode: TextArea.Wrap
                        readOnly: true
                        font.pointSize: font_size_point_text_text_medium
                        text: qsTr("Вы выставили флаг \"Стать Helper'ом\", это означает, что Вы \"Великая Душа\" и "
                                 + "хотите помогать другим. Желание Ваше неослабно и Вы уже преодолели множество препятствий. "
                                 + "Теперь с Вами свяжется наш администратор и завершит вашу регистрацию. "
                                 + "Добро пожаловать в Helper'ы!")

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

                Button{
                    text: qsTr("ок")
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: font_size_point_text_text_medium
                    onClicked: {
                        on_want_help_popup.close()
                        stackView.pop()
                    }
                }
            }
        }
    }
}
