#ifndef LOGHANDLER_H
#define LOGHANDLER_H

#include <QAbstractListModel>
#include <QObject>
#include <QString>
#include <QVector>
#include <QDateTime>
#include <QMutex>

struct LogMessage {
    QDateTime timestamp;
    QtMsgType type;
    QString message;
    QString color;
};

class LogHandler : public QAbstractListModel
{
    Q_OBJECT

public:
    enum LogRoles {
        TimeRole = Qt::UserRole + 1,
        TypeRole,
        MessageRole,
        ColorRole
    };

    explicit LogHandler(QObject *parent = nullptr);
    static LogHandler* instance();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void clear();
    Q_INVOKABLE void saveLog(const QString &filePath);
    Q_INVOKABLE void copyToClipboard();
    Q_INVOKABLE QString getLogs();

    static void messageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg);

private:
    void appendMessage(QtMsgType type, const QString &msg);

    QVector<LogMessage> m_messages;
    static LogHandler* m_instance;
    QMutex m_mutex;
    const int m_maxLines = 2000;
};

#endif // LOGHANDLER_H
