#include "addparcel.h"
#include "ui_addparcel.h"

#include <usermenu.h>
#include <iostream>
#include <float.h>
#include <pqxx/pqxx>
#include <defines.h>
#include <QMessageBox>
#include <QMainWindow>

AddParcel::AddParcel(QWidget *parent) :
    QDialog(parent),
    receiverIdM(-1),
    userId(dynamic_cast<UserMenu*>(parent)->getUserId()),
    addressAdd(new AddressAdd(userId, this)),
    pseudoSignUpWindows(new PseudoSignUpWindows(this)),
    ui(new Ui::AddParcel)
{
    ui->setupUi(this);
}

AddParcel::~AddParcel()
{
    delete pseudoSignUpWindows;
    delete addressAdd;
    delete ui;
}

void AddParcel::on_backButton_released()
{
    parentWidget()->show();
    this->hide();
}


void AddParcel::on_addYourAdress_released()
{
    addressAdd->setUserId(userId);
    addressAdd->show();
}

double AddParcel::calculateAndSetPrice()
{
    double price = DBL_MAX;
    unsigned int width = ui->widthEdit->text().toUInt();
    unsigned int length = ui->lengthEdit->text().toUInt();
    unsigned int height = ui->heightEdit->text().toUInt();
    unsigned int weight = ui->weightEdit->text().toUInt();

    unsigned int speedInt = ui->speedBox->currentIndex(); //0- normal, 1 - express
    QString speedStr;
    if (speedInt == 0)
        speedStr = "Normal";
    else
        speedStr = "Special";

//    unsigned int sendingTypeInt = ui->sendingTypeBox->currentIndex(); //0 - locker, 1 - place, 2 - courier
//    QString sendingTypeStr;
//    unsigned int receivingType = ui->receivingTypeBox->currentIndex();
//    QString receivingTypeStr;

    if (width * length * height * weight == 0) {
        return price;
    }

    try {
        pqxx::connection connection(defines::connStr);
        pqxx::nontransaction N(connection);

        QString commandTemplate = "select ppl.price_calc(%1, ppl.type_calc(%2), '%3'::ppl.speedType);";
        QString command = commandTemplate.arg(QString::number(width * length * height), QString::number(weight), speedStr);
        auto res = N.exec(command.toStdString());
        QString priceStr = res[0][0].c_str();
        price = priceStr.toDouble();

        connection.close();
    } catch (std::exception const& e) {
        std::cerr << e.what() << std::endl;
        ui->priceLabel->setText("0");
        return price;
    }

    ui->priceLabel->setText(QString::number(price));
    return price;
}

void AddParcel::refreshYourAddresses()
{
    try {
        pqxx::connection connection(defines::connStr);
        pqxx::nontransaction N(connection);

        QString commandTemplate = "select city, street, house_number, flat_number, postal_code, id from ppl.user_addresses where user_id = %1;";
        QString command = commandTemplate.arg(userId);

        auto res = N.exec(command.toStdString());

        yourAddresses.clear();
        ui->yourAddressBox->clear();
        QString addressTemplate = "%1, %2 %3%4, %5";
        for (auto const &row : res) {
            QString oneAddress;
            QString flatNum = "";
            if (!row[3].is_null()) {
                flatNum += "/";
                flatNum += row[3].c_str();
            }
            oneAddress = addressTemplate.arg(row[0].c_str(), row[1].c_str(), row[2].c_str(), flatNum, row[4].c_str());
            ui->yourAddressBox->addItem(oneAddress);
            yourAddresses.push_back(std::stoi(row[5].c_str()));
        }

    } catch(std::exception const& e) {
        ui->yourAddressBox->clear();
        std::cerr<< e.what() << std::endl;
        return;
    }
}

void AddParcel::refreshReceiverAddresses(int receiverId)
{
    try {
        pqxx::connection connection(defines::connStr);
        pqxx::nontransaction N(connection);

        QString commandTemplate = "select city, street, house_number, flat_number, postal_code, id from ppl.user_addresses where user_id = %1;";
        QString command = commandTemplate.arg(receiverId);

        auto res = N.exec(command.toStdString());

        receiverAddresses.clear();
        ui->receiverAddressBox->clear();
        QString addressTemplate = "%1, %2 %3%4, %5";
        for (auto const &row : res) {
            QString oneAddress;
            QString flatNum = "";
            if (!row[3].is_null()) {
                flatNum += "/";
                flatNum += row[3].c_str();
            }
            oneAddress = addressTemplate.arg(row[0].c_str(), row[1].c_str(), row[2].c_str(), flatNum, row[4].c_str());
            ui->receiverAddressBox->addItem(oneAddress);
            receiverAddresses.push_back(std::stoi(row[5].c_str()));
        }

    } catch(std::exception const& e) {
        std::cerr<< e.what() << std::endl;
        return;
    }
}

void AddParcel::on_receiverEmailOrPhone_editingFinished()
{
    QRegularExpression numCheck("^[0-9]{9}$");
    QString phoneOrMail = ui->receiverEmailOrPhone->text();
    QString command;
    if (numCheck.match(phoneOrMail).hasMatch()) {
        QString commandTemplate = "select id from ppl.users where phone_number = %1;";
        pseudoSignUpWindows->setEdits(phoneOrMail, "");
        command = commandTemplate.arg(phoneOrMail);
    } else {
        QString commandTemplate = "select id from ppl.users where email = '%1';";
        pseudoSignUpWindows->setEdits("", phoneOrMail);
        command = commandTemplate.arg(phoneOrMail);
    }

    try {
        pqxx::connection connection(defines::connStr);
        pqxx::nontransaction N(connection);

        auto res = N.exec(command.toStdString());

        if (res.size() == 0) {
            ui->receiverAddressBox->clear();
            receiverIdM = -1;
            QMessageBox::critical(this, "", "No such user");
        }

        int receiverId = std::stoi(res[0][0].c_str());
        receiverIdM = receiverId;

        refreshReceiverAddresses(receiverId);

    } catch (std::exception const& e) {
        ui->receiverAddressBox->clear();
        std::cerr<< e.what() << std::endl;
        return;
    }

}

void AddParcel::on_speedBox_currentIndexChanged(int index)
{
    calculateAndSetPrice();
}


void AddParcel::on_heightEdit_textChanged(const QString &arg1)
{
    calculateAndSetPrice();
}


void AddParcel::on_widthEdit_textChanged(const QString &arg1)
{
    calculateAndSetPrice();
}


void AddParcel::on_lengthEdit_textChanged(const QString &arg1)
{
    calculateAndSetPrice();
}



void AddParcel::on_weightEdit_textChanged(const QString &arg1)
{
    calculateAndSetPrice();
}

void AddParcel::on_addReceiver_released()
{
    pseudoSignUpWindows->show();
}


void AddParcel::on_addButton_released()
{
    unsigned int width = ui->widthEdit->text().toUInt();
    unsigned int length = ui->lengthEdit->text().toUInt();
    unsigned int height = ui->heightEdit->text().toUInt();
    unsigned int weight = ui->weightEdit->text().toUInt();
    unsigned int sendingTypeInt = ui->sendingTypeBox->currentIndex(); //0 - locker, 1 - place, 2 - courier
    QString sendingTypeStr;
    if (sendingTypeInt == 0)
        sendingTypeStr = "Parcel_locker";
    else if (sendingTypeInt == 1)
        sendingTypeStr = "Place";
    else
        sendingTypeStr = "Courier";
    unsigned int receivingTypeInt = ui->receivingTypeBox->currentIndex();
    QString receivingTypeStr;
    if (receivingTypeInt == 0)
        receivingTypeStr = "Parcel_locker";
    else if (receivingTypeInt == 1)
        receivingTypeStr = "Place";
    else
        receivingTypeStr = "Courier";

    unsigned int speedInt = ui->speedBox->currentIndex(); //0- normal, 1 - express
    QString speedStr;
    if (speedInt == 0)
        speedStr = "Normal";
    else
        speedStr = "Special";

    if(ui->yourAddressBox->currentText().size() == 0 or ui->receiverAddressBox->currentText() == 0) {
        QMessageBox::critical(this, "", "No address selected");
        return;
    }
    if (weight > 20000 || width > 1000 || height > 1000 || length > 1000) {
        QMessageBox::critical(this, "", "Some size is bigger then 1000, or weight is bigger then 20000");
        return;
    }
    if (weight <=0 || width <= 0 || height <= 0 || length <= 0) {
        QMessageBox::critical(this, "", "Some size/weight is smaller than 0");
        return;
    }

    int yourAddressId = yourAddresses[ui->yourAddressBox->currentIndex()];
    int receiverAddressId = receiverAddresses[ui->receiverAddressBox->currentIndex()];

    try {
        pqxx::connection connection(defines::connStr);
        pqxx::nontransaction N(connection);

        QString commandTemplate = "select ppl.parcel_reg(%1, %2, %3, %4, %5, %6, '%7'::varchar, %8, %9, '%10'::varchar, '%11'::varchar);";
        QString command = commandTemplate.arg(QString::number(weight), QString::number(height), QString::number(length), QString::number(width), QString::number(userId), QString::number(yourAddressId), sendingTypeStr, QString::number(receiverIdM), QString::number(receiverAddressId), receivingTypeStr, speedStr);
        N.exec(command.toStdString());

        QMessageBox::information(this, "Spoko", "Success");
    } catch (std::exception const& e) {
        std::cerr << e.what() << std::endl;
        return;
    }
}


void AddParcel::on_addReceiverAddress_released()
{
    if (receiverIdM == -1) {
        QMessageBox::critical(this, "", "No receiver selected");
        return;
    }
    addressAdd->setUserId(receiverIdM);
    addressAdd->show();
}
