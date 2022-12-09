#include "pseudosignupwindows.h"
#include "ui_pseudosignupwindows.h"
#include <pqxx/pqxx>
#include <defines.h>
#include <iostream>

PseudoSignUpWindows::PseudoSignUpWindows(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::PseudoSignUpWindows)
{
    ui->setupUi(this);
}

void PseudoSignUpWindows::setEdits(QString phone, QString email) {
    ui->emailEdit->setText(email);
    ui->phoneEdit->setText(phone);
}

PseudoSignUpWindows::~PseudoSignUpWindows()
{
    delete ui;
}

void PseudoSignUpWindows::on_pushButton_released()
{
    QString firstname, lastname, login, password, passwordRe, email, phone;
    firstname = ui->firstnameEdit->text();
    lastname = ui->lastnameEdit->text();
    login = "null";
    password = "null";
    passwordRe = "null";
    email = ui->emailEdit->text();
    phone = ui->phoneEdit->text();

    bool emptyCheck =  !firstname.isEmpty() && !lastname.isEmpty()
                        && !email.isEmpty() && !phone.isEmpty();

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
    } else {
        ui->warLabel->setText("");
        try
            {
                pqxx::connection connection(defines::connStr);
                pqxx::nontransaction N(connection);

                QString str = ("select ppl.register_pseudo(\'" + firstname + "\'::varchar, \'"+ lastname + "\'::varchar, " + phone + ", \'"+ email +"\'::varchar);");
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

