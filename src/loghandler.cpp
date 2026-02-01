#include "../include/loghandler.h"
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QGuiApplication>
#include <QClipboard>
#include <QUrl>

LogHandler* LogHandler::m_instance = nullptr;

LogHandler::LogHandler(QObject *parent)
    : QAbstractListModel(parent)
{
    m_instance = this;
}

LogHandler* LogHandler::instance()
{
    return m_instance;
}

int LogHandler::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_messages.count();
}

QVariant LogHandler::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_messages.count())
        return QVariant();

    const LogMessage &msg = m_messages[index.row()];

    switch (role) {
    case TimeRole:
        return msg.timestamp.toString("yyyy-MM-dd HH:mm:ss");
    case TypeRole:
        switch(msg.type) {
            case QtDebugMsg: return "DEBUG";
            case QtInfoMsg: return "INFO";
            case QtWarningMsg: return "WARNING";
            case QtCriticalMsg: return "CRITICAL";
            case QtFatalMsg: return "FATAL";
            default: return "UNKNOWN";
        }
    case MessageRole:
        return msg.message;
    case ColorRole:
        return msg.color;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> LogHandler::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TimeRole] = "timestamp";
    roles[TypeRole] = "type";
    roles[MessageRole] = "message";
    roles[ColorRole] = "logColor";
    return roles;
}

void LogHandler::clear()
{
    beginResetModel();
    m_messages.clear();
    endResetModel();
}

void LogHandler::saveLog(const QString &filePath)
{
    QString path = QUrl(filePath).toLocalFile();
    if (path.isEmpty()) {
        // Fallback if not a valid URL or just a path
        path = filePath;
        if (path.startsWith("file://")) {
             path = path.mid(7);
        }
    }
    
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        for (const auto &msg : m_messages) {
             out << "[" << msg.timestamp.toString("yyyy-MM-dd HH:mm:ss") << "] "
                 << "[" << (msg.type == QtDebugMsg ? "DEBUG" : msg.type == QtInfoMsg ? "INFO" : msg.type == QtWarningMsg ? "WARNING" : "ERROR") << "] "
                 << msg.message << "\n";
        }
        file.close();
    }
}

void LogHandler::copyToClipboard()
{
    QString text = getLogs();
    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard)
        clipboard->setText(text);
}

QString LogHandler::getLogs()
{
    QString logs;
    for (const auto &msg : m_messages) {
         logs += QString("[%1] [%2] %3\n")
            .arg(msg.timestamp.toString("yyyy-MM-dd HH:mm:ss"))
            .arg(msg.type == QtDebugMsg ? "DEBUG" : msg.type == QtInfoMsg ? "INFO" : msg.type == QtWarningMsg ? "WARNING" : "ERROR")
            .arg(msg.message);
    }
    return logs;
}

void LogHandler::messageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    Q_UNUSED(context);
    if (m_instance) {
        m_instance->appendMessage(type, msg);
    }
    // Also print to original stdout/stderr
    fprintf(type == QtInfoMsg || type == QtDebugMsg ? stdout : stderr, "%s\n", qPrintable(msg));
}

void LogHandler::appendMessage(QtMsgType type, const QString &msg)
{
    QString color;
    switch (type) {
        case QtDebugMsg: color = "#b0b0b0"; break; // Gray
        case QtInfoMsg: color = "#ffffff"; break;  // White
        case QtWarningMsg: color = "#ffcc00"; break; // Yellow
        case QtCriticalMsg: 
        case QtFatalMsg: color = "#ff5252"; break; // Red
        default: color = "#ffffff"; break;
    }

    LogMessage logMsg;
    logMsg.timestamp = QDateTime::currentDateTime();
    logMsg.type = type;
    logMsg.message = msg;
    logMsg.color = color;

    // Use QMetaObject::invokeMethod to ensure thread safety when updating UI from different threads
    QMetaObject::invokeMethod(this, [this, logMsg]() {
        if (m_messages.size() >= m_maxLines) {
            beginRemoveRows(QModelIndex(), 0, 0);
            m_messages.removeFirst();
            endRemoveRows();
        }
        
        beginInsertRows(QModelIndex(), m_messages.size(), m_messages.size());
        m_messages.append(logMsg);
        endInsertRows();
    });
}
