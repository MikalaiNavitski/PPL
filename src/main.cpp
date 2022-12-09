#include "pplapp.h"
#include <pqxx/pqxx>
#include <iostream>
#include <fstream>
#include <defines.h>

#include <QApplication>

int main(int argc, char *argv[])
{
    std::ifstream confFile("ppl.conf");

    if (confFile && !confFile.eof()) {
        std::string temp;
        std::getline(confFile, temp);
        defines::connStr = temp;
    }
    confFile.close();

    QApplication a(argc, argv);

    pplApp w;
    w.show();
    return a.exec();
}
