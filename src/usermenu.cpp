#include "usermenu.h"
#include "addparcel.h"
#include "ui_usermenu.h"

#include <pplapp.h>
#include <parcellmenu.h>
#include <settings.h>

UserMenu::UserMenu(int userId, QWidget *parent) :
    QMainWindow(parent),
    userId(userId),
    ui(new Ui::UserMenu)
{
    parcelMenu = new ParcellMenu(this);
    addParcel = new AddParcel(this);
    settings = new Settings(this);
    ui->setupUi(this);
}

int UserMenu::getUserId()
{
    return userId;
}

UserMenu::~UserMenu()
{
    delete parcelMenu;
    delete addParcel;
    delete settings;
    delete ui;
}

void UserMenu::on_logOutButton_released()
{
    pplApp *loginWin = new pplApp();
    loginWin->show();

    this->close();
}


void UserMenu::on_myParcelsButton_released()
{
    parcelMenu->refresh();
    parcelMenu->show();

    this->hide();
}


void UserMenu::on_settingsButton_released()
{
    settings->show();
    settings->clearWarLabel();
    this->hide();
}


void UserMenu::on_addParcelButton_released()
{
    addParcel->show();
    addParcel->refreshYourAddresses();
    this->hide();
}

