#ifndef ERROR_H
#define ERROR_H

#include <QString>

class Error
{
public:
    enum ErrorCodes{OK = 0};

    Error():m_code(OK)
    {}
    Error(int code, const QString& msg = QString(), const QString& file = QString(), int line = -1):m_code(code),m_msg(msg),m_file(file),m_line(line)
    {}
    virtual ~Error(){}

    int code()const
    {
        return m_code;
    }

    QString message() const
    {
        return m_msg;
    }

    QString file()const
    {
        return m_file;
    }

    int line()const
    {
        return m_line;
    }

protected:
    int m_code;
    QString m_msg;
    QString m_file;
    int m_line;
};

#endif // ERROR_H
