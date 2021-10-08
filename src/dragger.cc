#include <QApplication>
#include <QCommandLineParser>
#include <QDebug>
#include <QDrag>
#include <QFile>
#include <QFileInfo>
#include <QList>
#include <QMimeData>
#include <QUrl>

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);
    QApplication::setApplicationName("dragger");
    QApplication::setApplicationVersion("0.1.0");

    QCommandLineParser parser;
    parser.setApplicationDescription("A CLI drag-and-drop tool");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument(
        "files",
        QCoreApplication::translate("files", "files to drag-and-drop"),
        "[FILES...]");

    parser.process(app);

    QList<QUrl> urls;
    for (auto const& path : parser.positionalArguments()) {
        QFileInfo file{QFile{path}};
        if (file.exists()) {
            urls << QUrl("file:" + file.absoluteFilePath());
        } else {
            qInfo() << file.filePath() << "does not exist";
        }
    }

    if (urls.empty()) {
        return 0;
    }

    QMimeData* mimeData = new QMimeData();
    mimeData->setUrls(urls);

    QDrag drag(&app);
    drag.setMimeData(mimeData);
    drag.exec();
}
