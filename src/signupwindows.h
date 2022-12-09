#ifndef SIGNUPWINDOWS_H
#define SIGNUPWINDOWS_H

#include <QDialog>

namespace Ui {
class SignUpWindows;
}

class SignUpWindows : public QDialog
{
    Q_OBJECT

public:
    explicit SignUpWindows(QWidget *parent = nullptr);
    void setLoginAndPass(QString, QString);
    ~SignUpWindows();

private slots:
    void on_pushButton_released();

private:
    Ui::SignUpWindows *ui;
};

#endif // SIGNUPWINDOWS_H
