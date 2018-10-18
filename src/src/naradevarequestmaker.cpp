#include "naradevarequestmaker.h"
#include <QRegExp>
#include <QString>
#include <QStringList>
#include <memory>

struct OperationMetadata
{
    int id;
    char name[64];
};

static OperationMetadata g_ops_metadata[]= {
                                    {NaradevaRequestMaker::LOGIN, "login"},
                                    {NaradevaRequestMaker::LOGOUT,"logout"},
                                    {NaradevaRequestMaker::REGISTRATE,"registrate"},
                   //                 {NaradevaRequestMaker::DELETE_USER,"delete_user"},
                                    {NaradevaRequestMaker::GET_USER,"get_user"},
                                    {NaradevaRequestMaker::GET_USER_INFO,"get_user_info"},
                   //                 {NaradevaRequestMaker::GET_USERS_COUNT,"get_users_count"},
                    //                {NaradevaRequestMaker::GET_USERS_LIST,"get_users_list"},
                                    {NaradevaRequestMaker::CHANGE_PASSWORD,"change_password"},
                                    {NaradevaRequestMaker::RESTORE_PASSWORD,"restore_passwor"},
                   //                 {NaradevaRequestMaker::CHANGE_CONTACT_DATA,"change_contact_data"},
                                    {NaradevaRequestMaker::CHANGE_PROFILE_DATA,"change_profile_data"},
//                                    {NaradevaRequestMaker::PROMOTE_TO_HELPER,"promote_to_helper"},
//                                    {NaradevaRequestMaker::CONFIRM_HELPER,"confirm_helper"},
//                                    {NaradevaRequestMaker::ADMITT_HELPER,"admitt_helper"},
//                                    {NaradevaRequestMaker::GET_HELPERS_CANDIDATES_COUNT,"get_helpers_candidates_count"},
//                                    {NaradevaRequestMaker::GET_HELPERS_CANDIDATES_LIST,"get_helpers_candidates_list"},
//                                    {NaradevaRequestMaker::GET_HELPERS_IN_REGION,"get_helpers_in_region"},
                                    {NaradevaRequestMaker::PULSE,"pulse"},
                                    {NaradevaRequestMaker::ADD_REQUEST,"add_request"},
                   //                 {NaradevaRequestMaker::CHANGE_REQUEST,"change_request"},
                                    {NaradevaRequestMaker::CLOSE_REQUEST,"close_request"},
                                    {NaradevaRequestMaker::GET_CURRENT_REQUEST,"get_current_request"},
                                    {NaradevaRequestMaker::GET_REQUEST_INFO,"get_request_info"},
                                    {NaradevaRequestMaker::GET_REQUESTS_LIST,"get_requests_list"},
                                    {NaradevaRequestMaker::TAKE_UP_CALL,"take_up_call"},
                                    {NaradevaRequestMaker::GIVE_UP_CALL,"give_up_call"}
                                   };


static QString g_appkey = QString("HIDEN");

static QHash<int, std::shared_ptr< QVariantHash > > g_opMetadataByIndex;
static QHash<QString, std::shared_ptr< QVariantHash > > g_opMetadataByName;

static void g_initialize()
{
    if( g_opMetadataByIndex.size() == 0 ){
        int size = sizeof( g_ops_metadata) / sizeof( g_ops_metadata[0] );
        for( int i = 0;  i  < size ; i++ ){
            std::shared_ptr<QVariantHash> metadata_ptr = std::shared_ptr<QVariantHash>(new QVariantHash);
            metadata_ptr->clear();

            int id = g_ops_metadata[i].id;
            QString name = QString(g_ops_metadata[i].name);

            metadata_ptr->insert("id",id);
            metadata_ptr->insert("name",name);

            g_opMetadataByIndex[id] = metadata_ptr;
            g_opMetadataByName[name] = metadata_ptr;
        }
    }
}

//-----------------------------------------------------------------------------
class NaradevaRequestMakerPrivate
{
public:
    NaradevaRequestMakerPrivate():currentOpInd(NaradevaRequestMaker::OP_BEGIN)
    {
        g_initialize();
    }

    ~NaradevaRequestMakerPrivate()
    {}

public:
    int currentOpInd;
    QList<QVariant> args;
    QString session;
    QString baseUrl;
};

//---------------------------------------------
NaradevaRequestMaker::NaradevaRequestMaker( const QString& baseUrl )
    :d_ptr(new NaradevaRequestMakerPrivate)
{
    setBaseUrl(baseUrl);
}

NaradevaRequestMaker::NaradevaRequestMaker(const QString& baseUrl, int operationIndex, const QList<QVariant>& arguments,const QString& session)
                     :d_ptr(new NaradevaRequestMakerPrivate)
{
    setBaseUrl(baseUrl);
    d_ptr->currentOpInd = operationIndex;
    d_ptr->args = arguments;
    d_ptr->session = session;
}

NaradevaRequestMaker::~NaradevaRequestMaker()
{
    delete d_ptr;
}

void NaradevaRequestMaker::setBaseUrl(const QString& url)
{
    d_ptr->baseUrl = url.trimmed().remove(QRegExp("[/,\\\\]*$"));
}

void NaradevaRequestMaker::setOperation(int index)
{
    d_ptr->currentOpInd = index;
}

void NaradevaRequestMaker::setArguments(const QList<QVariant>& values)
{
    d_ptr->args = values;
}

#include <QDebug>
void NaradevaRequestMaker::setSession(const QString& session)
{
    d_ptr->session = session;
}

QString NaradevaRequestMaker::request()const
{
    QString result = QString();

    int opInd = d_ptr->currentOpInd;
    if( opInd > OP_BEGIN && opInd < OP_END && d_ptr->baseUrl.size() > 0 ){
        QString baseUrl = d_ptr->baseUrl;
        QString opname  = operationName(opInd);

        QStringList vlist;
        for( int i = 0; i < d_ptr->args.size() ; i++ ){
            vlist << d_ptr->args[i].toString();
        }

        QStringList entryes = QStringList()<<QString("appkey=%1").arg(g_appkey)
                                           <<QString("operation=%1(%2)").arg(opname).arg(vlist.join(","));

        if( d_ptr->session.size() > 0 ){
            entryes << QString("session=%1").arg(d_ptr->session);
        }

        result = QString("%1/?%2").arg(baseUrl).arg(entryes.join("&"));
    }

    return result;
}

QString NaradevaRequestMaker::request(int operationIndex, const QList<QVariant>& arguments,const QString& session)const
{
    QString curr_session = !session.isEmpty() ? session : d_ptr->session;
    NaradevaRequestMaker maker(d_ptr->baseUrl,operationIndex,arguments,curr_session);
    return maker.request();
}

QString NaradevaRequestMaker::makeRequest(const QString& baseUrl, int operationIndex, const QList<QVariant>& arguments,const QString& session )
{
    NaradevaRequestMaker maker(baseUrl,operationIndex,arguments,session);
    return maker.request();
}

QString NaradevaRequestMaker::operationName(int index)
{
    QString name;
    if( g_opMetadataByIndex.contains(index) ){
        name = g_opMetadataByIndex[index]->value("name").toString();
    }
    return name;
}

int NaradevaRequestMaker::operationIndexByName(const QString& name)
{
    int index;
    if( g_opMetadataByName.contains(name) ){
        index = g_opMetadataByName[name]->value("id").toInt();
    }
    return index;
}

