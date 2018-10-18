#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QList>
#include <QHash>
#include <QVariant>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QScreen>
#include "naradevarequestmaker.h"
#include "user.h"
#include "privatestorage.h"

class BackendPrivate;
class Backend : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Backend)
    Q_DECLARE_PRIVATE(Backend)
    Q_PROPERTY(int state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(int version_major READ version_major)
    Q_PROPERTY(int version_minor READ version_minor)
    Q_PROPERTY(int build READ build)
    Q_PROPERTY(int networkAccesibility READ networkAccesibility NOTIFY networkAccesibilityChanged)
    Q_PROPERTY(bool alignByScreen READ alignByScreen )
    Q_PROPERTY(int screenDepth READ depth)
    Q_PROPERTY(int screenDevicePixelRatio READ devicePixelRatio)
    Q_PROPERTY(qreal screenDevicePixelRatioF READ devicePixelRatioF)
    Q_PROPERTY(int screenLogicalDpiX  READ logicalDpiX)
    Q_PROPERTY(int screenLogicalDpiY  READ logicalDpiY)
    Q_PROPERTY(int screenPhysicalDpiX READ physicalDpiX)
    Q_PROPERTY(int screenPhysicalDpiY READ physicalDpiY)

public:
    enum Requests{
        LOGIN       = NaradevaRequestMaker::LOGIN,
        LOGOUT      = NaradevaRequestMaker::LOGOUT,
        REGISTRATE  =  NaradevaRequestMaker::REGISTRATE,
        RESTORE_PASSWORD = NaradevaRequestMaker::RESTORE_PASSWORD,
        CHANGE_PASSWORD  = NaradevaRequestMaker::CHANGE_PASSWORD,
        CHANGE_PROFILE_DATA = NaradevaRequestMaker::CHANGE_PROFILE_DATA,
        ADD_REQUEST = NaradevaRequestMaker::ADD_REQUEST,
        CLOSE_REQUEST = NaradevaRequestMaker::CLOSE_REQUEST,
        GET_USER = NaradevaRequestMaker::GET_USER,
        GET_USER_INFO = NaradevaRequestMaker::GET_USER_INFO,
        PULSE = NaradevaRequestMaker::PULSE,
        GET_CURRENT_REQUEST = NaradevaRequestMaker::GET_CURRENT_REQUEST,
        GET_REQUEST_INFO = NaradevaRequestMaker::GET_REQUEST_INFO,
        GET_REQUESTS_LIST = NaradevaRequestMaker::GET_REQUESTS_LIST,
        TAKE_UP_CALL = NaradevaRequestMaker::TAKE_UP_CALL,
        GIVE_UP_CALL = NaradevaRequestMaker::GIVE_UP_CALL
    };

    enum ResponceStatus{
        Responce_OK  = 0
    };

    enum ErrorCode{
        Error_OK = 0,
        Error_Internal = 1,   //1-99 all internal processing errors
        Error_Service = 100,  //base for all foreighn service errors
        Error_Session_Expired_Or_Closed = 310,
        Error_Request_Expired_Or_Closed = 460,
        Error_Network = 1000  //base for all network errors
    };

    enum NetworkAccesibility
    {
        UnknownAccessibility = QNetworkAccessManager::UnknownAccessibility,
        NotAccessible = QNetworkAccessManager::NotAccessible,
        Accessible = QNetworkAccessManager::Accessible
    };

    enum States
    {
        InitialState  = 0,
        LoggedInState = 0x1,
        AskState      = 0x10,
        AskConnectedState = 0x20,
        HelpState     = 0x100, //Exclusive with AskState
        HelpConnectedState     = 0x200,
    };

    enum RequestCloseStatus
    {
        RequestClose = 0,
        RequestDone  = 3
    };

    Q_ENUM(Requests)
    Q_ENUM(ResponceStatus)
    Q_ENUM(ErrorCode)
    Q_ENUM(NetworkAccesibility)
    Q_ENUM(States)
    Q_ENUM(RequestCloseStatus)

    explicit Backend(QObject *parent = 0);
    ~Backend();

    void setPrivateStorage(PrivateStorage* ps);
    PrivateStorage* privateStorage();

    void setUser(User* user);
    User* user();

    Q_INVOKABLE void start();

    Q_INVOKABLE void sendRequest(int operation, const QVariantList& arguments);
    Q_INVOKABLE void repeatLastOperation();

    Q_INVOKABLE int lastOperationId()const;
    Q_INVOKABLE QVariantList lastOperationArgs()const;

    Q_INVOKABLE int lastErrorCode()const;
    Q_INVOKABLE QString lastErrorMessage()const;

    Q_INVOKABLE bool isLoggedIn()const;

    Q_INVOKABLE QString toPersentEncoding(const QString& source);

    Q_INVOKABLE int version_major()const;
    Q_INVOKABLE int version_minor()const;
    Q_INVOKABLE int build()const;

    Q_INVOKABLE int networkAccesibility()const;

    bool alignByScreen()const;

    int state()const;
    void setState(int state);

    void setScreen(QScreen* screen);
    int depth() const;
    int devicePixelRatio() const;
    qreal devicePixelRatioF() const;
    int logicalDpiX() const;
    int logicalDpiY() const;
    int physicalDpiX() const;
    int physicalDpiY() const;

signals:
    void readyToWork();
    void error(int code);
    void responceArrived(int operation, int status, const QVariant& data);
    void networkAccesibilityChanged(int accesibility);
    void stateChanged(int state);

public slots:

protected slots:

private slots:
    void onRequestFinished(QNetworkReply* reply);
    void onNetworkError(QNetworkReply::NetworkError code);
    void onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility accessible);

private:
    BackendPrivate* d_ptr;
};

#endif // BACKEND_H
