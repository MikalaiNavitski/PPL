#ifndef PARCELLMENU_H
#define PARCELLMENU_H

#include <QDialog>
#include <QListWidgetItem>
#include <vector>

namespace Ui {
class ParcellMenu;
}

class ParcellMenu : public QDialog
{
    Q_OBJECT

public:
    explicit ParcellMenu(QWidget *parent = nullptr);
    void setId(int idn);
    void refresh();
    ~ParcellMenu();

  public slots:
    void refreshParcell(QListWidgetItem* item);

private slots:
    void on_pushButton_released();

    void on_backButton_released();

private:
    int id;
    std::vector<QString> items;
    Ui::ParcellMenu *ui;
};

#endif // PARCELLMENU_H
