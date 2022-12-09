#ifndef USERMENU_H
#define USERMENU_H

#include <QMainWindow>
#include <addparcel.h>
#include <parcellmenu.h>
#include <settings.h>

namespace Ui {
class UserMenu;
}

class UserMenu : public QMainWindow
{
    Q_OBJECT

public:
//    explicit UserMenu(QWidget *parent = nullptr);
    explicit UserMenu(int userId = 1, QWidget *parent = nullptr);
    int getUserId();
    ~UserMenu();

private slots:
    void on_logOutButton_released();

    void on_myParcelsButton_released();

    void on_settingsButton_released();

    void on_addParcelButton_released();

private:
    int userId;
    ParcellMenu *parcelMenu;
    AddParcel *addParcel;
    Settings * settings;
    Ui::UserMenu *ui;
};

#endif // USERMENU_H
