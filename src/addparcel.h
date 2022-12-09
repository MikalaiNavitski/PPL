#ifndef ADDPARCEL_H
#define ADDPARCEL_H

#include <QMainWindow>
#include <addressadd.h>
#include <pseudosignupwindows.h>

namespace Ui {
class AddParcel;
}

class AddParcel : public QDialog
{
    Q_OBJECT

public:
    explicit AddParcel(QWidget *parent = nullptr);
    ~AddParcel();
    friend class UserMenu;
    friend class AddressAdd;

private slots:
    void on_backButton_released();

    void on_addYourAdress_released();

    void on_speedBox_currentIndexChanged(int index);

    void on_heightEdit_textChanged(const QString &arg1);

    void on_widthEdit_textChanged(const QString &arg1);

    void on_lengthEdit_textChanged(const QString &arg1);

    void on_weightEdit_textChanged(const QString &arg1);

    void on_receiverEmailOrPhone_editingFinished();

    void on_addReceiver_released();

    void on_addButton_released();

    void on_addReceiverAddress_released();

private:
    int userId;
    int receiverIdM;
    std::vector<int> yourAddresses;
    std::vector<int> receiverAddresses;
    double calculateAndSetPrice();
    void refreshYourAddresses();
    void refreshReceiverAddresses(int);
    AddressAdd *addressAdd;
    PseudoSignUpWindows * pseudoSignUpWindows;
    Ui::AddParcel *ui;
};

#endif // ADDPARCEL_H
