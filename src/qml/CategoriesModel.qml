import QtQml.Models 2.2

ListModel{
    ListElement{
        //1
        name: qsTr("Только мужчина")
        image: "qrc:/images/categories/user_male.svg"
        value: 0x1
    }
    ListElement{
        //2
        name: qsTr("Только женщина")
        image: "qrc:/images/categories/user_female.svg"
        value: 0x2
    }
    ListElement{
        //3
        name: qsTr("Помощь по дому")
        image: "qrc:/images/categories/homework_drill.svg"
        value: 0x4
    }
    ListElement{
        //4
        name: qsTr("Помощь c детьми")
        image: "qrc:/images/categories/baby.svg"
        value: 0x8
    }
    ListElement{
        //5
        name: qsTr("Помощь с компьютером")
        image: "qrc:/images/categories/computer_color.svg"
        value: 0x10
    }
    ListElement{
        //6
        name: qsTr("Помощь с уроками")
        image: "qrc:/images/categories/school_schoolwork.svg"
        value: 0x20
    }
    ListElement{
        //6
        name: qsTr("Помощь с машиной")
        image: "qrc:/images/categories/car.svg"
        value: 0x40
    }
    ListElement{
        //7
        name: qsTr("Помощь с сумками")
        image: "qrc:/images/categories/bags_shoppig_bag.svg"
        value: 0x80
    }
    ListElement{
        //8
        name: qsTr("Помощь с техникой")
        image: "qrc:/images/categories/technick_fan.svg"
        value: 0x100
    }
    ListElement{
        //9
        name: qsTr("Помощь с телефоном")
        image: "qrc:/images/categories/tablet.svg"
        value: 0x200
    }
    ListElement{
        //10
        name: qsTr("Помощь с роботом")
        image: "qrc:/images/categories/robot.svg"
        value: 0x400
    }
    ListElement{
        //11
        name: qsTr("Помощь с питомцем")
        image: "qrc:/images/categories/pet_plush.svg"
        value: 0x800
    }
    ListElement{
        //12
        name: qsTr("Вместе за покупками")
        image: "qrc:/images/categories/shopping_cart.svg"
        value: 0x1000
    }
    ListElement{
        //13
        name: qsTr("Составить компанию")
        image: "qrc:/images/categories/company_carousel.svg"
        value: 0x2000
    }
    ListElement{
        //14
        name: qsTr("Разговор по душам")
        image: "qrc:/images/categories/chat_confectionery.svg"
        value: 0x4000
    }
    ListElement{
        //15
        name: qsTr("Награда")
        image: "qrc:/images/categories/reward_diamond.svg"
        value: 0x8000
    }
}
