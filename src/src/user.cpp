#include "user.h"
#include <QHash>
#include <QVariant>
#include <memory>
#include <unordered_map>
#include <QJsonValue>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJSValue>

#define FN_NOT_USED ""

struct FieldMetadata
{
    int id;
    char name[64];
};

class UserFieldMetadata : public FieldMetadata
{
public:
    UserFieldMetadata(int _id = 0, const char* _name = "", bool _storable = false)
    {
        id = _id;
        strcpy(name,_name);
        storable = _storable;
    }

public:
    bool storable;
};

//------------------------------------------------
std::unordered_map<int, std::shared_ptr< UserFieldMetadata > > g_userFieldMetadataById;

static void g_initialzieUserFieldsMetadata()
{
    if( g_userFieldMetadataById.size() == 0 ){
#define INSERT_FIELD_METADATA(id,name,storable,defval) g_userFieldMetadataById[id] = std::shared_ptr< UserFieldMetadata >(new UserFieldMetadata(id ,name,storable) );

        INSERT_FIELD_METADATA(User::Login       ,"login"     , true  ,"");
        INSERT_FIELD_METADATA(User::Password    ,"password"  , true ,"");
        INSERT_FIELD_METADATA(User::RequestStump,"request"   , true ,"");
        INSERT_FIELD_METADATA(User::UserStump   ,"user_stump", true ,"");
        INSERT_FIELD_METADATA(User::State       ,"state"     , false,"");
        INSERT_FIELD_METADATA(User::Mail        ,"user_mail" , true ,"");
        INSERT_FIELD_METADATA(User::MailConfirmed,FN_NOT_USED, false,"");
        INSERT_FIELD_METADATA(User::Phone       ,"user_phone", true ,"");
        INSERT_FIELD_METADATA(User::PhoneConfirmed,FN_NOT_USED, false,"");
        INSERT_FIELD_METADATA(User::Role        ,"role"      ,false ,"");
        INSERT_FIELD_METADATA(User::Rights      ,"rights"    ,false ,"");
        INSERT_FIELD_METADATA(User::Name        ,"user_name" ,true  ,"");
        INSERT_FIELD_METADATA(User::SName       ,"user_sname",true  ,"");
        INSERT_FIELD_METADATA(User::FName       ,"user_fname",true  ,"");
        INSERT_FIELD_METADATA(User::Sex         ,"sex"       ,true  ,"");
        INSERT_FIELD_METADATA(User::Birth       ,"birth"     ,true  ,"");
        INSERT_FIELD_METADATA(User::BirthTime   ,FN_NOT_USED ,false ,"");
        INSERT_FIELD_METADATA(User::BirthPlace  ,FN_NOT_USED ,false ,"");
        INSERT_FIELD_METADATA(User::DocType     ,"user_doc_type",true,"");
        INSERT_FIELD_METADATA(User::DocNum      ,"user_doc_num" ,true,"");
        INSERT_FIELD_METADATA(User::DocInfo     ,"user_doc_info",true,"");
        INSERT_FIELD_METADATA(User::RequestInfo ,"request_info" ,false,"");
        INSERT_FIELD_METADATA(User::RequestData ,"request_data" ,true,"");
        INSERT_FIELD_METADATA(User::HelperFlag  ,"want_help"    ,true,"");
        INSERT_FIELD_METADATA(User::DataChecked ,"dataChecked"  ,true,"");
        INSERT_FIELD_METADATA(User::Admitted    ,"admitted"     ,false,"");
        INSERT_FIELD_METADATA(User::HelperSearchRequestCategories,"helper_cats",true,"");

#undef INSERT_FIELD_METADATA
    }
}

class UserPrivate
{
public:
    UserPrivate() : ps(nullptr)
    {
        g_initialzieUserFieldsMetadata();
    }

    ~UserPrivate()
    {}

public:
    PrivateStorage* ps;
};

User::User(QObject *parent)
     :QObject(parent),
      d_ptr(new UserPrivate)
{}

User::~User()
{
    if(d_ptr){delete d_ptr;}
}

void User::setData(int key, const QVariant &value)
{
    QVariant val;
    if( value.canConvert<QJSValue>() ){
        if( value.canConvert<QVariantHash>() ){
            val = value.toHash();
        }
        else if( value.canConvert<QVariantMap>() ){
            val = value.toMap();
        }
        else if( value.canConvert<QVariantList>()){
            val = value.toList();
        }
        else{
            val = value;
        }
    }
    else{
        val = value;
    }
    setValue(key,val);
}

QVariant User::data(int key) const
{
    return value(key);
}

void User::clear()
{
    KeyValue::clear();
}

bool User::isValid()
{
    return KeyValue::count() != 0;
}

bool User::isLoggedIn()
{
    return !value(SessionStump).isNull();
}

bool User::isAdmitted()
{
    return value(Admitted).toInt() > 0;
}

void User::save()
{
    if( isValid() ){
        for( auto ei : g_userFieldMetadataById ){
            if( ei.second->storable ){
                d_ptr->ps->storeValue( ei.second->name, value( ei.second->id ) );
            }
        }
        d_ptr->ps->saveStoredValues();
    }
}

void User::load()
{
    d_ptr->ps->sync();
    for( auto ei : g_userFieldMetadataById ){
        if( ei.second->storable ){
            setValue(ei.second->id, d_ptr->ps->value(ei.second->name));
        }
    }
}

void User::setPrivateStorage(PrivateStorage* ps)
{
    d_ptr->ps = ps;
}

PrivateStorage* User::privateStorage()const
{
    return d_ptr->ps;
}
