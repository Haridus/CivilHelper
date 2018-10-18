import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtLocation 5.3
import QtPositioning 5.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

MapQuickItem {
    property string user_name: ""
    property int request_cats: 0
    property string user_text: ""
    property CategoriesModel catsModel: CategoriesModel{}
    property int intext_icon_size : font_size_pixel_text_text_medium
    property string request_stump: ""
    property var request: null

    function build_user_text_string(cats, text)
    {
        var _user_text = "";
        _user_text += "<p>"+text+"</p>"
        _user_text += "<p>------------</p>"
        _user_text += "<p>"
        for( var i = 0; i < catsModel.count; i++){
            if( (cats & catsModel.get(i).value) > 0 ){
                var _image = catsModel.get(i).image;
                _user_text+= "<a href=\"\"><img src=\""+_image+"\" width=\""+intext_icon_size+"\" height=\""+intext_icon_size+"\"/></a>"
            }
        }
        _user_text += "</p>"

        return _user_text;
    }

    function fillFormRequestData(data)
    {
        request = data
        user_name = data["user_name"] ?  data["user_name"] : ""
        request_cats = data["categories"] ? data["categories"] : 0
        user_text = data["text"] ? data["text"] : ""
        request_stump = data["stump"] ? data["stump"] : ""

        user_name_field.text = "<b>"+user_name+"</b>";
        var _user_text_string = build_user_text_string(request_cats,user_text);
        //console.log(_user_text_string)
        user_text_field.text = _user_text_string;
    }

    anchorPoint.x : sourceItem.width /2
    anchorPoint.y : sourceItem.height

    sourceItem: Pane{
        width: main.swidth*0.45
        height: width*3/4

        property int ctWidth: width
        property int ctHeight: height*0.85

        background: Canvas {
            id: canvas
            width: parent.width
            height: parent.height
            antialiasing: true

            property int radius: Math.min(parent.width,parent.height)*0.05
            property double fh: (parent.height - parent.ctHeight)/parent.height
            property double fw: 0.1
            property color strokeStyle:  "#3a80ff" /*"#f8e38e"*/ /*"black"*/
            property color fillStyle: "#ecffff" /*"#fcfded"*/  /*"white"*/
            property int lineWidth: 2
            property bool fill: true
            property bool stroke: true
            property real alpha: 1.0

            onLineWidthChanged:requestPaint();
            onFillChanged:requestPaint();
            onStrokeChanged:requestPaint();
            onRadiusChanged:requestPaint();

            onPaint: {
                var ctx = getContext("2d");
                ctx.save();
                ctx.clearRect(0,0,canvas.width, canvas.height);

                ctx.strokeStyle = canvas.strokeStyle;
                ctx.lineWidth = canvas.lineWidth
                ctx.fillStyle = canvas.fillStyle
                ctx.globalAlpha = canvas.alpha

                ctx.beginPath();
                ctx.moveTo(canvas.width/2 , canvas.height)
                ctx.lineTo(canvas.width/2 - canvas.width*fw/2, canvas.height*(1-fh) )

                ctx.lineTo(radius, canvas.height*(1-fh) )
                ctx.arcTo(0,canvas.height*(1-fh),0,canvas.height*(1-fh)-radius,radius)

                ctx.lineTo(0,radius);
                ctx.arcTo(0,0,radius,0,radius);

                ctx.lineTo(canvas.width-radius,0);
                ctx.arcTo(canvas.width,0,canvas.width,radius,radius)

                ctx.lineTo(canvas.width,canvas.height*(1-fh) - radius)
                ctx.arcTo(canvas.width,canvas.height*(1-fh),canvas.width-radius,canvas.height*(1-fh),radius)

                ctx.lineTo(canvas.width/2 + canvas.width*fw/2, canvas.height*(1-fh))

                ctx.closePath();

                if (canvas.fill)
                    ctx.fill();

                if (canvas.stroke)
                    ctx.stroke();

                ctx.restore();
            }
        }


        Column{
            x:0; y: 0
            width: parent.width
            height: parent.height*0.80
            spacing: 2

            Text {
                id:user_name_field
                width: parent.width
                height: parent.height*0.15
                text: "<b>"+user_name+"</b>"
                font.pointSize: font_size_point_text_text_medium
            }

            Rectangle{
                width: parent.width
                height: parent.height*0.6
                color:"white"
                border.color: "black"
                border.width: 1
                radius: Math.min(width,height)*0.05

                Flickable {
                    id: user_text_field_flick
                    width: parent.width;
                    height: parent.height/**0.6*/;
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
                        text: user_text
                        font.pointSize: font_size_point_text_text_medium

                        onLinkActivated: {
                            //TODO: open Help file with legends
                        }
                    }

                    ScrollBar.vertical: ScrollBar { }
                }
            }

            Rectangle{
                x: parent.width/2 - width/2
                height: parent.height*0.25
                width: parent.width
                border.color: "green"
                border.width: 2
                color: color_intro_page
                radius: height*0.1
                Text{
                    width: parent.width
                    height: parent.height
                    x: parent.width/2 - width/2
                    y: parent.height/2 - height/2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text:"Помочь"
                    font.pointSize: font_size_point_text_text_medium
                }
                MouseArea{
                    width: parent.width
                    height: parent.height
                    onClicked: {
                        main.takeUpCall(request_stump)
                    }
                }
            }
        }
    }
}
