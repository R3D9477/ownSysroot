#include <QCoreApplication>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    
    qInfo( "Hello from Qt console!" );
    
    return a.exec();
}
