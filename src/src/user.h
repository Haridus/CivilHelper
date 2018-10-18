#ifndef USER_H
#define USER_H

#include <QObject>
#include <QDebug>
#include <QVariant>

#include "privatestorage.h"
#include "keyvalue.h"

class UserPrivate;

class User : public QObject, public KeyValue<int, QVariant>
{
  Q_OBJECT
  Q_DISABLE_COPY(User)
  Q_DECLARE_PRIVATE(User)

public:
  enum DataField {
      DF_BEGIN     = 0,
      Login        = 1,
      Password     = 2,
      SessionStump = 3,
      RequestStump = 4,
      UserStump    = 5,
      State        = 6,
      Mail         = 7,
      MailConfirmed= 8,
      Phone        = 9,
      PhoneConfirmed = 10,
      Role         = 11,
      Rights       = 12,
      Name         = 13,
      SName        = 14,
      FName        = 15,
      Sex          = 16,
      Birth        = 17,
      BirthTime    = 18,
      BirthPlace   = 19,
      DocType      = 20,
      DocNum       = 21,
      DocInfo      = 22,
      RequestInfo  = 23,
      RequestData  = 24,
      HelperFlag   = 25,
      DataChecked  = 26,
      Admitted     = 27,
      HelperSearchRequestCategories = 28,
      DF_END
  };

  enum State{OutState = 0, InState = 1};

  Q_ENUM(DataField)

  User(QObject* parent = 0);
  ~User();

  Q_INVOKABLE void setData(int key, const QVariant& value);
  Q_INVOKABLE QVariant data(int key) const;
  Q_INVOKABLE bool isValid();
  Q_INVOKABLE bool isLoggedIn();
  Q_INVOKABLE bool isAdmitted();

  Q_INVOKABLE void save(); //save data to local storage
  Q_INVOKABLE void load(); //load data from local storage
  void clear();

  void setPrivateStorage(PrivateStorage* ps);
  PrivateStorage* privateStorage()const;

private:
  UserPrivate* d_ptr;
};

#endif // USER_H
