#ifndef PSEUDOSIGNUPWINDOWS_H
#define PSEUDOSIGNUPWINDOWS_H

#include <QDialog>

namespace Ui {
class PseudoSignUpWindows;
}

class PseudoSignUpWindows : public QDialog
{
    Q_OBJECT

public:
    explicit PseudoSignUpWindows(QWidget *parent = nullptr);
    void setEdits(QString phone = "", QString email = "");
    ~PseudoSignUpWindows();

private slots:
    void on_pushButton_released();

private:
    Ui::PseudoSignUpWindows *ui;
};

#endif // PSEUDOSIGNUPWINDOWS_H
