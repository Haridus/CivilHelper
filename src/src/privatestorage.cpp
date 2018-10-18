#include "privatestorage.h"
#include "simplecrypt.h"
#include <QHash>
#include <QMap>
#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QJsonDocument>
#include <QDebug>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>
#include "general.h"

typedef quint64 PrivateKey;

QHash<QString, PrivateKey> g_specialKeys;

inline bool initializeSpecialKeys()
{
  if( g_specialKeys.isEmpty() ){
      g_specialKeys["login"] = 812377167236;
      g_specialKeys["password"] = 18347180701;
      g_specialKeys["user_mail"] = 3894193471;
      g_specialKeys["user_name"] = 3894193471;
      g_specialKeys["user_sname"] = 3894193471;
      g_specialKeys["user_fname"] = 3894193471;
      g_specialKeys["user_phone"] = 2587425623;
      g_specialKeys["private_storage"]= 18902347124189;
    }
  return true;
}

#define PRIVATE_STORAGE_PATH "."
#define PRIVATE_STORAGE_NAME "thumb"

#define ORGANIZATION "Parijana.org"
#define APPLICATION  "CivilHelper"

//--------------------------------------------------------
class PrivateStoragePrivate
{
public:
  PrivateStoragePrivate() : syncMode(PrivateStorage::AutoSync), changed(false)
  {
    initializeSpecialKeys();

#ifdef _LOCAL_SETTINGS_THUMB_
    QDir dir(PRIVATE_STORAGE_PATH);
#else
    QString storageDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(storageDir);
    if( !dir.exists() ){
        dir.mkpath(dir.absolutePath());
    }
#endif
    if( dir.exists() ){
        storagePath = dir.absoluteFilePath(PRIVATE_STORAGE_NAME);
    }
    else{
        //cease to work
    }
    DEBUG_SECTION( qDebug()<<storagePath; )
  }

  ~PrivateStoragePrivate()
  {}

public:
  QString storagePath;
  QVariantMap data;
  QVariantMap storedData;

  int syncMode;

  bool changed;
};

//-----------------------------------------------------
PrivateStorage::PrivateStorage(QObject *parent)
               :QObject(parent),
                d_ptr(new PrivateStoragePrivate)
{
  sync();

  if( !d_ptr->data.contains("first_run") ){
      int syncMode = d_ptr->syncMode;
      d_ptr->syncMode = ManualSync;
      setValue("first_run", true);
      setValue("profile_filled", false); //NOTE: not nesessary false if user already registred in service earlier
      d_ptr->syncMode = syncMode;
      sync();
  }

}

PrivateStorage::~PrivateStorage()
{
  int syncMode = d_ptr->syncMode;
  d_ptr->syncMode = ManualSync;
  d_ptr->data["first_run"] = false;
  sync();
  d_ptr->syncMode = syncMode;

  delete d_ptr;
}

void PrivateStorage::setSyncMode(int mode)
{
  d_ptr->syncMode = mode;
}

int  PrivateStorage::syncMode()const
{
  return d_ptr->syncMode;
}

void PrivateStorage::setValue(const QString& key, const QVariant& value)
{
  QVariant tvalue = value;
  if( g_specialKeys.contains( key ) ){
    PrivateKey pkey = g_specialKeys[key];
    QString valueString = value.toString();

    SimpleCrypt sc(pkey);
    QString dcvalue = sc.encryptToString(valueString);

    tvalue = QVariant(dcvalue);
  }
  d_ptr->data[key] = tvalue;

  d_ptr->changed = true;
  switch (d_ptr->syncMode) {
    case AutoSync:
    case OnValueChangeSync:
      sync();
      break;
    case ManualSync:
    default:
      break;
    }
}

QVariant PrivateStorage::value(const QString& key, const QVariant& defValue)const
{
    QVariant value;
    if( d_ptr->data.contains(key) ){
        value = d_ptr->data[key];
        if( g_specialKeys.contains( key ) ){
          PrivateKey pkey = g_specialKeys[key];
          QString valueString = value.toString();

          SimpleCrypt sc(pkey);
          QString dcvalue = sc.decryptToString(valueString);

          value = QVariant(dcvalue);
        }
    }
    else{
        value = storedValue(key,defValue);
    }

    return value;
}

void PrivateStorage::storeValue(const QString& key, const QVariant& value)
{
    d_ptr->storedData[key] = value;
}

QVariant PrivateStorage::storedValue(const QString& key, const QVariant& defValue)const
{
    return d_ptr->storedData.value(key,defValue);
}

void PrivateStorage::saveStoredValues()
{
  int syncMode = d_ptr->syncMode;
  d_ptr->syncMode = ManualSync;

  QList<QString> keys = d_ptr->storedData.keys();
  for(int i = 0; i < keys.count(); i++ ){
      const QString& key = keys.at(i);
      QVariant value = d_ptr->storedData.take( key );
      setValue(key,value);
  }

  d_ptr->syncMode = syncMode;
  sync();
}

void PrivateStorage::cleanStoredValues()
{
    d_ptr->storedData.clear();
}

enum {LS_NONE = 0, LOAD = 1, SAVE = 2};


#ifdef _STORAGE_IN_SYSTEM_
//NOTE: for storage settings in system settings
//NOTE: may be not very good for debugging and mobile dev(because if we uninstall app they may clean up settings also)
void PrivateStorage::sync()
{
    int loadsave = LS_NONE;
    if( d_ptr->data.size() == 0 ){
        loadsave = LOAD;
    }
    else if( d_ptr->data.size() > 0 && d_ptr->changed ){
        loadsave = SAVE;
    }

    switch (loadsave) {
    case LOAD:
    {
        QSettings settings(ORGANIZATION,APPLICATION);
        QByteArray data = settings.value("private").toByteArray();

        PrivateKey pkey = g_specialKeys["private_storage"];
        SimpleCrypt sc(pkey);
        QByteArray ddata = sc.decryptToByteArray(data);

        QJsonDocument jdoc = QJsonDocument::fromBinaryData(ddata);
        d_ptr->data = jdoc.toVariant().toMap();
    }
        break;
    case SAVE:
    {
        QJsonDocument jdoc = QJsonDocument::fromVariant(d_ptr->data);
        QByteArray data = jdoc.toBinaryData();

        PrivateKey pkey = g_specialKeys["private_storage"];
        SimpleCrypt sc(pkey);
        QByteArray edata = sc.encryptToByteArray(data);

        QSettings settings(ORGANIZATION,APPLICATION);
        settings.setValue("private",edata);
        settings.sync();
    }
          break;
    case LS_NONE:
//NOTHING TO DO
        break;
        default:
            DEBUG_SECTION( qDebug()<<"[PrivateStorage][SYNC][ERROR]unknown load/save state"; );
        break;
    }
}
#else
//sync with file [obsolete]//but may be used further
void PrivateStorage::sync()
{
  int loadsave = LS_NONE;
  QFileInfo finf(  d_ptr->storagePath);
  if( finf.exists() && d_ptr->data.size() == 0 ){
      loadsave = LOAD;
  }
  else if( d_ptr->data.size() > 0 && d_ptr->changed ){
      loadsave = SAVE;
  }

  switch (loadsave) {
    case LOAD:
    {
        QFile file(d_ptr->storagePath);
        if( file.open(QFile::ReadOnly) ){
          QByteArray data = file.readAll();
          file.close();

          PrivateKey pkey = g_specialKeys["private_storage"];
          SimpleCrypt sc(pkey);
          QByteArray ddata = sc.decryptToByteArray(data);

          QJsonDocument jdoc = QJsonDocument::fromBinaryData(ddata);
          d_ptr->data = jdoc.toVariant().toMap();
        }
        else{
            DEBUG_SECTION( qDebug()<<"[PrivateStorage][SYNC][ERROR]fail to open storage to read"; );
        }
      }
      break;
    case SAVE:
    {
        QFile file(d_ptr->storagePath);
        if( !d_ptr->storagePath.isEmpty() && file.open(QFile::WriteOnly | QFile::Truncate) ){
          QJsonDocument jdoc = QJsonDocument::fromVariant(d_ptr->data);
          QByteArray data = jdoc.toBinaryData();

          PrivateKey pkey = g_specialKeys["private_storage"];
          SimpleCrypt sc(pkey);
          QByteArray edata = sc.encryptToByteArray(data);

          file.write(edata);
          file.close();
        }
        else{
           DEBUG_SECTION( qDebug()<<"[PrivateStorage][SYNC][ERROR]fail to open storage to write"; );
        }
    }
      break;
    default:
      if( !d_ptr->changed )
        DEBUG_SECTION( qDebug()<<"[PrivateStorage][SYNC][ERROR]unknown load/save state"; );
      break;
    }
}
#endif
