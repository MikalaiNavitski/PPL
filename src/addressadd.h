#ifndef ADDRESSADD_H
#define ADDRESSADD_H

#include <QDialog>

namespace Ui {
class AddressAdd;
}

class AddressAdd : public QDialog
{
    Q_OBJECT

public:
    explicit AddressAdd(int userId = -1, QWidget *parent = nullptr);
    void setUserId(int);
    ~AddressAdd();

private slots:
    void on_pushButton_released();

private:
    int userId;
    Ui::AddressAdd *ui;
};

#endif // ADDRESSADD_H
