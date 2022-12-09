#include "settings.h"
#include "defines.h"
#include "ui_settings.h"

#include <usermenu.h>
#include <pqxx/pqxx>
#include <iostream>

Settings::Settings(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Settings)
{
    ui->setupUi(this);
    userId = (dynamic_cast<UserMenu*>(parent)->getUserId());
}

void Settings::clearWarLabel()
{
    ui->warLabel->setText("");
}

Settings::~Settings()
{
    delete ui;
}

void Settings::on_backButton_released()
{
    parentWidget()->show();
    this->hide();
}


void Settings::on_applyButton_released()
{
    QString oldPassword = ui->oldPassEdit->text();
    QString hash = QString::number(qHash(oldPassword));

    try {
        pqxx::connection con(defines::connStr);
        pqxx::nontransaction N(con);

        QString command = "select ppl.check_pass_id(" + QString::number(userId) + ", " + hash + ");";
        N.exec(command.toStdString());

        con.close();
    } catch (pqxx::plpgsql_raise const& e) {
        ui->warLabel->setText("Wrong old password!");
        return;
    } catch (std::exception const& e) {
        std::cerr << e.what() << std::endl;
        return;
    }

    QString newPass = ui->newPassEdit->text();
    QString newRePass = ui->reNewPassEdit->text();
    if (newPass != newRePass) {
        ui->warLabel->setText("Repeated password is incorrect");
        return;
    }
    hash = QString::number(qHash(newPass));

    QString email = ui->emailEdit->text();
    QString phone = ui->phoneEdit->text();
    QString firstname = ui->firstnameEdit->text();
    QString lastname = ui->lastnameEdit->text();
    QString login = ui->loginEdit->text();

    bool phoneCheck = phone.length() == 9;
    for (auto c : phone) {
        if (!c.isDigit()) {
            phoneCheck = false;
            break;
        }
    }

    if (phone.size() != 0 && !phoneCheck) {
        ui->warLabel->setText("Phone number is invalid");
        return;
    }


    try {
        pqxx::connection con(defines::connStr);
        pqxx::transaction t(con);

        QString commandTemplate = "update ppl.users set %1 = %2 where id = " + QString::number(userId) + ";";

        if (newPass.size() != 0)
            t.exec(commandTemplate.arg("password_hash", hash).toStdString());
        if (phone.size() != 0)
            t.exec(commandTemplate.arg("phone_number", phone).toStdString());

        if (login.size() != 0)
            t.exec((commandTemplate.arg("login", "'" + login + "'")).toStdString());

        if (firstname.size() != 0)
            t.exec((commandTemplate.arg("firstname", "'" + firstname + "'")).toStdString());
        if (lastname.size() != 0)
            t.exec((commandTemplate.arg("lastname", "'" + lastname + "'")).toStdString());

        if (email.size() != 0)
            t.exec((commandTemplate.arg("email", "'" + email + "'")).toStdString());

        t.commit();
        ui->warLabel->setText("Success");

        con.close();
    } catch (pqxx::unique_violation const& e) {
        ui->warLabel->setText("This login already exists");
        return;
    } /*catch (pqxx::plpgsql_raise const& e) {

    }*/ catch (std::exception const& e) {
        std::cerr << e.what() << std::endl;
        return;
    }
}

