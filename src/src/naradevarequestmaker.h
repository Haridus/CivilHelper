#ifndef NARADEVAREQUESTMAKER_H
#define NARADEVAREQUESTMAKER_H

#include <QVariant>
#include <QHash>
#include <QList>

class NaradevaRequestMakerPrivate;

class NaradevaRequestMaker
{
  Q_GADGET
public:
    enum Operation{
                    OP_BEGIN = 0x0,

                    LOGIN, //1
                    LOGOUT,             //2
                    REGISTRATE,         //3
  //                  CREATE_USER,         //4
                    DELETE_USER,         //5
                    GET_USER,         //6
                    GET_USER_INFO,         //7

                    GET_USERS_COUNT,         //8
                    GET_USERS_LIST,         //9

                    CHANGE_PASSWORD,         //10
                    CHANGE_CONTACT_DATA,         //11
                    CHANGE_PROFILE_DATA,         //12
  //                  CHANGE_RIGHTS,         //13

                    PROMOTE_TO_HELPER,     //14
                    CONFIRM_HELPER,//15
                    ADMITT_HELPER,//16

                    GET_HELPERS_CANDIDATES_COUNT,//17
                    GET_HELPERS_CANDIDATES_LIST,//18
                    GET_HELPERS_IN_REGION,//19

                    PULSE,//20

                    ADD_REQUEST,//21
                    CHANGE_REQUEST,//22
                    CLOSE_REQUEST,//23
                    GET_CURRENT_REQUEST,//24
                    GET_REQUEST_INFO,//25

    //                ASK_TO_HELP_REQUEST,//26
                    GET_REQUESTS_LIST,//27
                    TAKE_UP_CALL,//28
                    GIVE_UP_CALL,//29

                    RESTORE_PASSWORD,         //32

                    OP_END
                  };

    Q_ENUM(Operation)

    NaradevaRequestMaker(const QString& baseUrl = QString());
    NaradevaRequestMaker(const QString& baseUrl,int operationIndex, const QList<QVariant>& arguments,const QString& session = QString());
    ~NaradevaRequestMaker();

    void setBaseUrl(const QString& url);
    void setOperation(int index);
    void setArguments(const QList<QVariant>& values);
    void setSession(const QString& session);

    QString request()const;
    QString request(int operationIndex, const QList<QVariant>& arguments,const QString& session = QString())const;

    static QString makeRequest(const QString& baseUrl,int operationIndex, const QList<QVariant>& arguments,const QString& session );

    static QString operationName(int index);
    static int operationIndexByName(const QString& name);

private:
    NaradevaRequestMakerPrivate* d_ptr;
};

#endif // NARADEVAREQUESTHANDLER_H
