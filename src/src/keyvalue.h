#ifndef KEYVALUE_H
#define KEYVALUE_H

#include <unordered_map>
#include <vector>
#include <memory>

template<typename Key, typename Value>
class KeyValueInterface
{
public:
    virtual ~KeyValueInterface(){}

    virtual void setValue(const Key& key, const Value& value) = 0;
    virtual Value value(const Key& key, const Value& defValue = Value())const = 0;
};

template<typename Key, typename Value, typename Container = std::unordered_map<Key,Value> >
class KeyValue : public KeyValueInterface<Key,Value>
{
    template<typename _Key, typename _Value, typename _Container>
    class KeyValuePrivate
    {
    public:
    public:
        Container container;
    };

public:
    KeyValue() : d_ptr( new KeyValuePrivate<Key,Value,Container>() )
    {}

    KeyValue(const KeyValue& other) : d_ptr(other.d_ptr)
    {}

    KeyValue(KeyValue&& other)
    {
        d_ptr = other.d_ptr;
        other.d_ptr.reset();
    }

    virtual ~KeyValue(){}

    void setValue(const Key& key, const Value& value) override
    {
        detach();
        d_ptr->container[key] = value;
    }

    Value value(const Key& key, const Value& defValue = Value()) const override
    {
        Value val;
        //NOTE: we user count() rather than find() only for simplify code and
        //get access to bigger range of possible containers
        val = d_ptr->container.count(key) > 0 ? d_ptr->container[key] : defValue;

        return val;
    }

    Value& at(const Key& key)
    {
        detach();
        return d_ptr->container.at(key);
    }

    const Value& at(const Key& key)const
    {
        return d_ptr->container.at(key);
    }

    KeyValue& operator=(const KeyValue& other)
    {
        d_ptr = other.d_ptr;
        return this;
    }

    const Value& operator[](const Key& key) const
    {
        return d_ptr->container[key];
    }

    Value& operator[](const Key& key)
    {
        detach();
        return d_ptr->container[key];
    }

    std::vector<Key> keys()const
    {
        std::vector<Key> kv(d_ptr->container.size());
        int ki = 0;
        for(auto i = d_ptr->container.begin(); i != d_ptr->container.end(); i++){
            kv[ki++] = i->first;
        }
        return kv;
    }

    //NOTE: for testing only
    std::vector< std::pair <Key,Value> > keys_values()const
    {
        std::vector< std::pair <Key,Value> > kv(d_ptr->container.size());
        int ki = 0;
        for(auto i : d_ptr->container){
            kv[ki++] = i;
        }
        return kv;
    }

    size_t count() const
    {
        return d_ptr->container.size();
    }

    void clear()
    {
        detach();
        d_ptr->container.clear();
    }

protected:

private:
    void detach()
    {
        if( !d_ptr.unique() ){
            decltype(d_ptr) tmp( new KeyValuePrivate<Key,Value,Container>() );
            tmp->container = d_ptr->container;
            d_ptr = tmp;
        }
    }

    std::shared_ptr< KeyValuePrivate<Key,Value,Container> > d_ptr;
};

//------------------------------------------------------------------
//NOTE: this must be placed in some other place in future
#include <QtCore>
#include <functional>
namespace std{
    template<> struct hash<QString> : public std::__hash_base<size_t, QString>
    {
        size_t operator()(const QString& key)
        {
            return qHash(key);
        }

        size_t operator()(const QString& key)const
        {
            return qHash(key);
        }
    };
}

#endif // KEYVALUE_H
