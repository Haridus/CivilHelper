TEMPLATE = app

QT += qml quick network quickcontrols2 positioning location widgets gui core svg

CONFIG += c++11

SOURCES += main.cpp \
    src/backend.cpp \
    src/error.cpp \
    src/privatestorage.cpp \
    src/simplecrypt.cpp \
    src/user.cpp \
    src/naradevarequestmaker.cpp \
    src/keyvalue.cpp \
    src/general.cpp

RESOURCES += qml.qrc \
             images.qrc

OTHER_FILES += qml/*.qml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = qml

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    src/backend.h \
    src/error.h\
    src/privatestorage.h \
    src/simplecrypt.h \
    src/user.h \
    src/naradevarequestmaker.h \
    src/keyvalue.h \
    src/version.h \
    src/general.h

INCLUDEPATH += src \
               qml


DEPENDPATH  += src \
               qml

DISTFILES += \
    qml/ProfilePage.qml \
    qml/SettingsPage.qml \
    qml/LoginPage.qml \
    qml/RegistratePage.qml \
    qml/CountryPhoneCodesModel.qml \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = D:/support/PROJECTS/MyPro/CivilHelper/libcrypto.so D:/support/PROJECTS/MyPro/CivilHelper/libssl.so
}

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

CONFIG(debug, debug|release) {
    message("debug mode")
    DEFINES += _DEBUG_
#    DEFINES += _EXTERNAL_SERVER_
}
CONFIG(release, debug|release) {
    message("release mode")
}

win32{
    message("OS win32")
    DEFINES += _LOCAL_SETTINGS_THUMB_
}
linux:!android {
    message("OS Linux/Unix")
}
android {
    message("OS android")
    DEFINES += _EXTERNAL_SERVER_
#    DEFINES += _STORAGE_IN_SYSTEM_
    DEFINES += _ALIGN_BY_SCREEN_
}
macx{
    message("OS MacOS")
}
