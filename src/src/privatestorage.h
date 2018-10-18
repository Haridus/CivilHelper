#ifndef PRIVATESTORAGE_H
#define PRIVATESTORAGE_H

#include <QObject>
#include <QString>
#include <QVariant>

class PrivateStoragePrivate;

class PrivateStorage : public QObject
{
  Q_OBJECT
  Q_DISABLE_COPY(PrivateStorage)
  Q_DECLARE_PRIVATE(PrivateStorage)

public:
  enum SyncMode{AutoSync = 0/*defaut*/,
                ManualSync = 1,
                OnValueChangeSync = 2
               };

  Q_ENUM(SyncMode)

  explicit PrivateStorage(QObject *parent = 0);
  ~PrivateStorage();

  Q_INVOKABLE void setSyncMode(int mode);
  Q_INVOKABLE int  syncMode()const;

  Q_INVOKABLE void setValue(const QString& key, const QVariant& value);
  Q_INVOKABLE QVariant value(const QString& key, const QVariant& defValue = QVariant())const;

  Q_INVOKABLE void storeValue(const QString& key, const QVariant& value);
  Q_INVOKABLE QVariant storedValue(const QString& key, const QVariant& defValue = QVariant())const;

  Q_INVOKABLE void saveStoredValues();
  Q_INVOKABLE void cleanStoredValues();


  Q_INVOKABLE void sync();

private:
  PrivateStoragePrivate* d_ptr;
};

#endif // PRIVATESTORAGE_H
