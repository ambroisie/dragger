#include <QApplication>
#include <QDebug>
#include <QDrag>
#include <QFile>
#include <QFileInfo>
#include <QList>
#include <QMimeData>
#include <QUrl>

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);

    QList<QUrl> urls;
    for (int i = 1; i < argc; ++i) {
        QFileInfo file(QFile(argv[i]));
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
