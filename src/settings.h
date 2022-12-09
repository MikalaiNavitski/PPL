#ifndef SETTINGS_H
#define SETTINGS_H

#include <QDialog>

namespace Ui {
class Settings;
}

class Settings : public QDialog
{
    Q_OBJECT

public:
    explicit Settings(QWidget *parent = nullptr);
    void clearWarLabel();
    ~Settings();

private slots:
    void on_backButton_released();

    void on_applyButton_released();

private:
    int userId;
    Ui::Settings *ui;
};

#endif // SETTINGS_H
