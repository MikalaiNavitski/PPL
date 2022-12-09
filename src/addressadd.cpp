#include "addressadd.h"
#include "ui_addressadd.h"

#include <iostream>
#include <usermenu.h>
#include <defines.h>

#include <pqxx/pqxx>

AddressAdd::AddressAdd(int userId, QWidget *parent) :
    QDialog(parent),
    userId(userId),
    ui(new Ui::AddressAdd)
{
    ui->setupUi(this);
}

void AddressAdd::setUserId(int id)
{
    userId = id;
}

AddressAdd::~AddressAdd()
{
    delete ui;
}

void AddressAdd::on_pushButton_released()
{
    QString city, street, houseNumStr, flatNumStr, postalCodeStr;
    city = ui->cityEdit->text();
    street = ui->streetEdit->text();

    bool houseNumConvert = false, flatNumConvert = false, postalCodeConvert = false;
    houseNumStr = ui->houseNumberEdit->text();
    flatNumStr = ui->flatNumberEdit->text();
    postalCodeStr = ui->postalCodeEdit->text();
    houseNumStr.toUInt(&houseNumConvert);
    flatNumStr.toUInt(&flatNumConvert);
    postalCodeStr.toUInt(&postalCodeConvert);


    if (city.size() == 0) {
        ui->warLabel->setText("City cannot be empty!");
        return;
    }
    if (street.size() == 0) {
        ui->warLabel->setText("Street cannot be empty!");
        return;
    }
    if (!houseNumConvert) {
        ui->warLabel->setText("Wrong house number!");
        return;
    }
    if (!flatNumConvert && flatNumStr.size() != 0) {
        ui->warLabel->setText("Wrong flat number!");
        return;
    }
    if (flatNumStr.size() == 0) {
        flatNumStr = "null";
    }
    if (!postalCodeConvert || postalCodeStr.size() != 5) {
        ui->warLabel->setText("Wrong postal code!");
        return;
    }
    ui->warLabel->setText("");

    try {
        pqxx::connection con(defines::connStr);
        pqxx::nontransaction N(con);

        QString commandTemplate = "insert into ppl.user_addresses(user_id, city, street, house_number, flat_number, postal_code) values ('%1', '%2', '%3', %4, %5, %6);";
        QString command = commandTemplate.arg(QString::number(userId), city, street, houseNumStr, flatNumStr, postalCodeStr);
        N.exec(command.toStdString());

        dynamic_cast<AddParcel*>(parentWidget())->refreshYourAddresses();

        con.close();

        this->close();
    } catch (std::exception const& e) {
        std::cerr << e.what() << std::endl;
    }
}

