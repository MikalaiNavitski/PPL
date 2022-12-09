#ifndef PPLAPP_H
#define PPLAPP_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class pplApp; }
QT_END_NAMESPACE

class pplApp : public QMainWindow
{
    Q_OBJECT

public:
    pplApp(QWidget *parent = nullptr);
    void mSetEnabled(bool);
    ~pplApp();

private slots:

    void on_logInButton_released();

    void on_signUpButton_released();

private:
    Ui::pplApp *ui;
};
#endif // PPLAPP_H
