#include "signupwindows.h"
#include "defines.h"
#include "ui_signupwindows.h"
#include "pplapp.h"
#include <iostream>
#include <pqxx/pqxx>

SignUpWindows::SignUpWindows(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::SignUpWindows)
{
    ui->setupUi(this);
    this->setFixedSize(QSize(245, 295));
    ui->warLabel->setStyleSheet("{color: #FF0000}");
}

void SignUpWindows::setLoginAndPass(QString login, QString password) {
    ui->loginEdit->setText(login);
    ui->passEdit->setText(password);

}

SignUpWindows::~SignUpWindows()
{
    ((pplApp*) parent())->mSetEnabled(true);
    delete ui;
}

void SignUpWindows::on_pushButton_released()
{
    QString firstname, lastname, login, password, passwordRe, email, phone;
    firstname = ui->firstnameEdit->text();
    lastname = ui->lastnameEdit->text();
    login = ui->loginEdit->text();
    password = ui->passEdit->text();
    passwordRe = ui->passRepeatEdit->text();
    email = ui->emailEdit->text();
    phone = ui->phoneEdit->text();

    bool emptyCheck =  !firstname.isEmpty() && !lastname.isEmpty() && !login.isEmpty()
                    && !password.isEmpty() && !passwordRe.isEmpty() && !email.isEmpty() && !phone.isEmpty();


    bool passCheck = password == passwordRe;

    bool phoneCheck = phone.length() == 9;
    for (auto c : phone) {
        if (!c.isDigit()) {
            phoneCheck = false;
            break;
        }
    }

    if (!emptyCheck) {
        ui->warLabel->setText("Some field is empty!");
    } else if (!phoneCheck) {
        ui->warLabel->setText("Phone has incorrect format");
    } else if (!passCheck) {
        ui->warLabel->setText("Repeated password is incorrect");
    } else {
        ui->warLabel->setText("");
        int hash = qHash(password);
        QString hashStr = QString::number(hash);
        try
            {
                pqxx::connection connection(defines::connStr);
                pqxx::nontransaction N(connection);

                QString str = ("select ppl.register(\'" + firstname + "\'::varchar, \'"+ lastname + "\'::varchar, \'" + login + "\'::varchar, " + hashStr + ", " + phone + ", \'"+ email +"\'::varchar);");
                N.exec(str.toStdString());
                this->close();
            } catch (const pqxx::integrity_constraint_violation& e) {
                ui->warLabel->setText("Wrong email format");
                std::cerr << e.what() << std::endl;
            } catch (const pqxx::plpgsql_raise& e) {
                QString message;
                for (int i = 8; i < 43; i++) {
                    message.append(e.what()[i]);
                }
                ui->warLabel->setText(message);
            } catch (const std::exception& e)
            {
                std::cerr << e.what() << std::endl;
            }
    }

}

