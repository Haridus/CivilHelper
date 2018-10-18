#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include "privatestorage.h"
#include "backend.h"
#include "user.h"

#include "keyvalue.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setAttribute(Qt::AA_EnableHighDpiScaling);

    qmlRegisterUncreatableType<PrivateStorage>("Parijana.Core", 0, 1, "PrivateStorage","PrivateStorage is private not creatable type!");
    qmlRegisterUncreatableType<Backend>("Parijana.Backend",0,1,"Backend","Backend is not creatable type!");
    qmlRegisterUncreatableType<User>("Parijana.Backend",0,1,"User","User is not creatable type!");

    PrivateStorage ps;
    Backend backend;
    User user;

    user.setPrivateStorage(&ps);
    backend.setPrivateStorage(&ps);
    backend.setUser(&user);

    backend.setScreen(app.primaryScreen());

    ps.sync();
    user.load();
//    QQuickStyle::setStyle("Material"); //for future use

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/qml");
    engine.rootContext()->setContextProperty("privateStorage", &ps);
    engine.rootContext()->setContextProperty("backend",&backend);
    engine.rootContext()->setContextProperty("user",&user);
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    backend.start();

    return app.exec();
}
