#include "backend.h"
#include "error.h"
#include <QTimer>
#include <qDebug>
#include <QHash>
#include <QVariant>
#include <QNetworkAccessManager>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <functional>
#include "version.h"
#include "general.h"

class QObjectDestructor
{
public:
    QObjectDestructor(QObject* obj = nullptr) : m_obj(obj)
    {}

    ~QObjectDestructor()
    {
        if( m_obj ){
            m_obj->deleteLater();
        }
    }

private:
    QObject* m_obj;
};

//----------------------------------
struct Operation
{
    Operation() : id(0)
    {}
    Operation(int _id, const QVariantList& _arguments) : id(_id), arguments(_arguments)
    {}

    int id;
    QVariantList arguments;

};

//----------------------------------------------------------------------------------
class BackendPrivate
{
public:
    BackendPrivate() : netio( nullptr ), ps(nullptr), user(nullptr), state(Backend::InitialState), pscreen(0)
    {
        QString baseUrl;
#ifdef _EXTERNAL_SERVER_
        baseUrl = "https://civilhelperback.parijana.org";
#else
        baseUrl = "http://localhost/civilhelper";
#endif
        requestMaker.setBaseUrl(baseUrl);
        DEBUG_SECTION( qDebug()<<"base url:"<<baseUrl; );
    }

    ~BackendPrivate()
    {}

public:
    Error lastError;
    NaradevaRequestMaker requestMaker;
    QNetworkAccessManager* netio;
    PrivateStorage* ps;
    User* user;
    Operation lastOperation;
    int state;
    QScreen* pscreen;

    QHash<int, std::function< void(int, int, QJsonObject& ) > > responceBackendProcessors;
};

//------------------------------------------
Backend::Backend(QObject *parent)
        :QObject(parent),
         d_ptr(new BackendPrivate)
{
    d_ptr->netio = new QNetworkAccessManager(this);
    connect(d_ptr->netio,SIGNAL(finished(QNetworkReply*)),this,SLOT(onRequestFinished(QNetworkReply*)));
    connect(d_ptr->netio,SIGNAL(networkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)), this,SLOT(onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)));
    DEBUG_SECTION(qDebug()<<"version:"<<QString("%1.%2.%3").arg(version_major()).arg(version_minor()).arg(build()););

    d_ptr->responceBackendProcessors[NaradevaRequestMaker::REGISTRATE] = [this](int operation, int status, QJsonObject& rootJsonObject)->void
    {
        Q_UNUSED(operation)
        if(status == 0){
            QVariant data = rootJsonObject.value("retValue").toVariant();
            d_ptr->user->setData(User::UserStump,data);
            d_ptr->user->save();
        }
    };

    d_ptr->responceBackendProcessors[NaradevaRequestMaker::LOGIN] = [this](int operation, int status, QJsonObject& rootJsonObject)->void
    {
        Q_UNUSED(operation)
        if(status == 0){
            QVariant data = rootJsonObject.value("retValue").toVariant();
            d_ptr->user->setData(User::SessionStump, data);
            d_ptr->requestMaker.setSession(data.toString());
        }
        else{
            d_ptr->user->setData(User::Login, "");
            d_ptr->user->setData(User::Password, "");
        }
        d_ptr->user->save();
    };

    d_ptr->responceBackendProcessors[NaradevaRequestMaker::LOGOUT] = [this](int operation, int status, QJsonObject& rootJsonObject)->void
    {
        Q_UNUSED(operation)
        if(status == 0){
            d_ptr->user->setData(User::SessionStump, QVariant());
            d_ptr->requestMaker.setSession(QString());
            d_ptr->user->save();
        }
    };

    d_ptr->responceBackendProcessors[NaradevaRequestMaker::ADD_REQUEST] = [this](int operation, int status, QJsonObject& rootJsonObject)->void
    {
        Q_UNUSED(operation)
        if(status == 0){
            QVariant data = rootJsonObject.value("retValue").toVariant();
            d_ptr->user->setData(User::RequestStump,data);
            d_ptr->user->save();
        }
    };

    d_ptr->responceBackendProcessors[NaradevaRequestMaker::GET_REQUEST_INFO] = [this](int operation, int status, QJsonObject& rootJsonObject)->void
    {
        Q_UNUSED(operation)
        if(status == 0){
            QJsonObject retValueObject = rootJsonObject.value("retValue").toObject();
            d_ptr->user->setData(User::RequestInfo, retValueObject.toVariantMap());
            d_ptr->user->save();
        }
    };

    d_ptr->responceBackendProcessors[NaradevaRequestMaker::GET_CURRENT_REQUEST] = [this](int operation, int status, QJsonObject& rootJsonObject)->void
    {
        Q_UNUSED(operation)
        if(status == 0){
            QVariant data = rootJsonObject.value("retValue").toVariant();
            d_ptr->user->setData(User::RequestStump, data);
            d_ptr->user->save();
        }
    };

    d_ptr->responceBackendProcessors[NaradevaRequestMaker::GET_USER] = [this](int operation, int status, QJsonObject& rootJsonObject)->void
    {
        Q_UNUSED(operation)
        if(status == 0){
            QVariant data = rootJsonObject.value("retValue").toVariant();
            d_ptr->user->setData(User::UserStump, data);
            d_ptr->user->save();
        }
    };

    d_ptr->responceBackendProcessors[NaradevaRequestMaker::GET_USER_INFO] = [this](int operation, int status, QJsonObject& rootJsonObject)->void
    {
        Q_UNUSED(operation)
        if(status == 0){
            QJsonObject retValueObject = rootJsonObject.value("retValue").toObject();
            d_ptr->user->setData(User::Mail,           retValueObject.value("mail"));
            d_ptr->user->setData(User::MailConfirmed,  retValueObject.value("mail_confirmed"));
            d_ptr->user->setData(User::Phone,          retValueObject.value("phone"));
            d_ptr->user->setData(User::PhoneConfirmed, retValueObject.value("phone_confirmed"));
            d_ptr->user->setData(User::Role,           retValueObject.value("role"));
            d_ptr->user->setData(User::Rights,         retValueObject.value("rights"));
            d_ptr->user->setData(User::Name,           retValueObject.value("name"));
            d_ptr->user->setData(User::SName,          retValueObject.value("sName"));
            d_ptr->user->setData(User::FName,          retValueObject.value("fName"));
            d_ptr->user->setData(User::Birth,          retValueObject.value("birth"));
            d_ptr->user->setData(User::Sex,            retValueObject.value("sex"));
            d_ptr->user->setData(User::BirthTime,      retValueObject.value("birth_time"));
            d_ptr->user->setData(User::BirthPlace,     retValueObject.value("birth_place"));
            d_ptr->user->setData(User::DocType ,       retValueObject.value("docType"));
            d_ptr->user->setData(User::DocNum ,        retValueObject.value("docNum"));
            d_ptr->user->setData(User::DocInfo,        retValueObject.value("docInfo"));
            d_ptr->user->setData(User::HelperFlag,     retValueObject.value("want_help"));
            d_ptr->user->setData(User::DataChecked,    retValueObject.value("checked"));
            d_ptr->user->setData(User::Admitted,       retValueObject.value("admitted"));
            d_ptr->user->save();
        }
    };
}

Backend::~Backend()
{
    delete d_ptr->netio;
    delete d_ptr;
}

int Backend::version_major()const
{
    return VERSION_MAJOR;
}

int Backend::version_minor()const
{
    return VERSION_MINOR;
}

int Backend::build()const
{
    return VERSION_BUILD;
}

void Backend::setPrivateStorage(PrivateStorage* ps)
{
    d_ptr->ps = ps;
    if( d_ptr->user ){
        d_ptr->user->setPrivateStorage(ps);
    }
}

PrivateStorage* Backend::privateStorage()
{
    return d_ptr->ps;
}

void Backend::setUser(User *user)
{
    if( d_ptr->user ){
        d_ptr->user->setPrivateStorage(nullptr);
    }
    d_ptr->user = user;
    d_ptr->user->setPrivateStorage(d_ptr->ps);
}

User* Backend::user()
{
    return d_ptr->user;
}

void Backend::start()
{
    QTimer::singleShot(300,this,SIGNAL(readyToWork()));
}

QString Backend::toPersentEncoding(const QString& source)
{
    return QUrl::toPercentEncoding(source);
}

void Backend::sendRequest(int operation, const QVariantList& arguments)
{
    QVariantList args;

    args = arguments;
    d_ptr->lastOperation.id = operation;
    d_ptr->lastOperation.arguments = args;

    QString request =  d_ptr->requestMaker.request(d_ptr->lastOperation.id,d_ptr->lastOperation.arguments);
    DEBUG_SECTION( qDebug()<<"REQUEST: "<< request; );

    QNetworkReply* reply = d_ptr->netio->get( QNetworkRequest( QUrl( request ) ) );
    connect(reply,SIGNAL(error(QNetworkReply::NetworkError) ),this,SLOT(onNetworkError(QNetworkReply::NetworkError)));
}

void Backend::repeatLastOperation()
{
    QString request =  d_ptr->requestMaker.request(d_ptr->lastOperation.id,d_ptr->lastOperation.arguments);
    DEBUG_SECTION( qDebug()<<"REPEAT REQUEST: "<< request; )

    QNetworkReply* reply = d_ptr->netio->get( QNetworkRequest( QUrl( request ) ) );
    connect(reply,SIGNAL(error(QNetworkReply::NetworkError) ),this,SLOT(onNetworkError(QNetworkReply::NetworkError)));
}

int Backend::lastOperationId()const
{
    return d_ptr->lastOperation.id;
}

QVariantList Backend::lastOperationArgs()const
{
    return d_ptr->lastOperation.arguments;
}

int Backend::lastErrorCode()const
{
    return d_ptr->lastError.code();
}

QString Backend::lastErrorMessage()const
{
    return d_ptr->lastError.message();
}

bool Backend::isLoggedIn()const
{
    return !d_ptr->user->data(User::SessionStump).isNull();
}

void Backend::onRequestFinished(QNetworkReply* reply)
{
    QObjectDestructor objD(reply);

    QByteArray  ba = reply->readAll();
//    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt(); // for future use

    if( ba.isEmpty() ){
        emit Backend::error(Error_Internal);
        emit responceArrived(d_ptr->lastOperation.id,Error_Internal, QVariant());
        return;
    }

    int jsonStart = ba.indexOf("{");
    int jsonEnd   = ba.lastIndexOf("}");
    ba = ba.mid(jsonStart,jsonEnd-jsonStart+1);
    ba.replace("\"[","[").replace("]\"","]");

    DEBUG_SECTION( qDebug()<<"REPLY DATA:"<<ba; );

    QJsonParseError error;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(ba, &error);

    if (jsonDocument.isEmpty()) {
        DEBUG_SECTION( qDebug() << "=ERROR= " << error.error
                                << error.errorString() << error.offset << " =ERROR="; )

        d_ptr->lastError = Error(error.error,error.errorString(),__FILE__,__LINE__);
        emit Backend::error(d_ptr->lastError.code());
        emit responceArrived(d_ptr->lastOperation.id,d_ptr->lastError.code(), QVariant());
        return;
    }

    QJsonObject jsonObject = jsonDocument.object();

    QString  operation = jsonObject.value("operation").toString();
    int operationIndex = NaradevaRequestMaker::operationIndexByName(operation);
    int        retCode = jsonObject.value("retCode").toString().toInt();

    if( d_ptr->responceBackendProcessors.contains(operationIndex) ){
        d_ptr->responceBackendProcessors[operationIndex](operationIndex,retCode,jsonObject);
    }

    QVariant  retValue = jsonObject.value("retValue").toVariant();
    emit responceArrived(operationIndex,retCode,retValue);
    DEBUG_SECTION( qDebug()<<"REPLY: "<<QString("%1(%2:%3):").arg(operation).arg(operationIndex).arg(retCode)<<retValue; )
}

void Backend::onNetworkError(QNetworkReply::NetworkError code)
{
    DEBUG_SECTION( qDebug()<<"net error"<<code; );
    emit error( Error_Network + int(code) );
}

void Backend::onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility accessible)
{
    DEBUG_SECTION( qDebug()<<"accessibility changed "<<accessible; );
    emit networkAccesibilityChanged( int(accessible) );
}

int Backend::networkAccesibility()const
{
    return int( d_ptr->netio->networkAccessible() );
}

bool Backend::alignByScreen()const
{
#ifdef _ALIGN_BY_SCREEN_
    return true;
#else
    return false;
#endif
}

int Backend::state()const
{
    return d_ptr->state;
}

void Backend::setState(int state)
{
    if(d_ptr->state != state){
        d_ptr->state = state;
        emit stateChanged(d_ptr->state);
    }
}

void Backend::setScreen(QScreen* screen)
{
    d_ptr->pscreen = screen;
}

int Backend::depth() const
{
    return d_ptr->pscreen ? d_ptr->pscreen->depth() : 0;
}

int Backend::devicePixelRatio() const
{
    return d_ptr->pscreen ? d_ptr->pscreen->devicePixelRatio() : 0;
}

qreal Backend::devicePixelRatioF() const
{
    return d_ptr->pscreen ? d_ptr->pscreen->devicePixelRatio() : 0;
}

int Backend::logicalDpiX() const
{
    return d_ptr->pscreen ? d_ptr->pscreen->logicalDotsPerInchX() : 0;
}

int Backend::logicalDpiY() const
{
    return d_ptr->pscreen ? d_ptr->pscreen->logicalDotsPerInchY() : 0;
}

int Backend::physicalDpiX() const
{
    return d_ptr->pscreen ? d_ptr->pscreen->physicalDotsPerInchX() : 0;
}

int Backend::physicalDpiY() const
{
    return d_ptr->pscreen ? d_ptr->pscreen->physicalDotsPerInchY() : 0;
}
