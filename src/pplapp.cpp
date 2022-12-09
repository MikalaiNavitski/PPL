#include "defines.h"
#include "parcellmenu.h"
#include "pplapp.h"
#include "ui_pplapp.h"
#include <pqxx/pqxx>
#include <iostream>
#include <signupwindows.h>
#include <usermenu.h>

using namespace std;

pplApp::pplApp(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::pplApp)
{
    ui->setupUi(this);
    //this->setFixedSize(QSize(511, 355));


    this->close();
}

void pplApp::mSetEnabled(bool change)
{
    ui->loginLabel->setEnabled(change);
    ui->passwordEdit->setEnabled(change);
    ui->logInButton->setEnabled(change);
    ui->passwordEdit->setEnabled(change);
}



pplApp::~pplApp()
{
    delete ui;
}



void pplApp::on_logInButton_released()
{
    QString login = ui->loginEdit->text();
    QString password = ui->passwordEdit->text();
    QString hash = QString::number(qHash(password));

    try {
        pqxx::connection connection(defines::connStr);
        pqxx::nontransaction N(connection);

        QString comm = "select ppl.check_login(\'" + login + "\', " + hash + ");";
        QString idStr = QString(N.exec(comm.toStdString()).front().front().c_str());
        int id = idStr.toInt();

        ui->warLabel->setText("Success");

        UserMenu *userMenu = new UserMenu(id);
        userMenu->show();

        this->close();
    } catch (const pqxx::failure& f) {
        ui->warLabel->setText("Wrong login or password!");
    } catch (const std::exception& e)
    {
        std::cerr << e.what() << std::endl;
    }
}


void pplApp::on_signUpButton_released()
{
    ui->warLabel->setText("");
    QString login = ui->loginEdit->text();
    QString password = ui->passwordEdit->text();
//    setEnabled(false);

    SignUpWindows* SignUpWindow = new SignUpWindows();
    SignUpWindow->show();
    SignUpWindow->setLoginAndPass(login, password);
}

