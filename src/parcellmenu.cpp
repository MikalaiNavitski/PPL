#include "parcellmenu.h"
#include "defines.h"
#include "ui_parcellmenu.h"
#include <pqxx/pqxx>
#include <iostream>
#include <usermenu.h>
#include <vector>

ParcellMenu::ParcellMenu(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::ParcellMenu)
{
    ui->setupUi(this);
    connect(ui->listWidget, SIGNAL(itemClicked(QListWidgetItem*)),
               this, SLOT(refreshParcell(QListWidgetItem*)));
    ui->tableWidget->setSelectionMode(QAbstractItemView::NoSelection);
    id = (dynamic_cast<UserMenu*>(parent)->getUserId());

}

void ParcellMenu::refreshParcell(QListWidgetItem* item) {
    try {
        ui->tableWidget->setRowCount(0);
        pqxx::connection con(defines::connStr);
        pqxx::nontransaction N(con);

        auto res = N.exec(("select information, \"time\" from ppl.all_statuses(" + item->text() + ") order by time;").toStdString());

        QTableWidgetItem* item;
        for (auto const& r : res) {
            ui->tableWidget->insertRow(0);
            item = new QTableWidgetItem;

            item->setText(r[1].c_str());
            ui->tableWidget->setItem(0, 0, item);

            item = new QTableWidgetItem;

            item->setText(r[0].c_str());
            ui->tableWidget->setItem(0, 1, item);
        }

    } catch (const std::exception& e) {
        std::cerr << e.what() << std::endl;
    }
}

void ParcellMenu::refresh() {
    try {
        pqxx::connection con(defines::connStr);
        pqxx::nontransaction N(con);

//        ui->tableWidget->insertRow(0);

        auto res = N.exec(("select * from ppl.parcels where sender_id = " + QString::number(id) + " or receiver_id = " + QString::number(id) + ";").toStdString());
        for (auto const &r: res) {
            bool flag = false;
            for(auto& item: items) {
                if (item.toStdString() == r[0].c_str()) {
                    flag = true;
                    break;
                }
            }
            if (!flag) {
                items.push_back(r[0].c_str());
                ui->listWidget->addItem(items.back());

//                connect(ui->listWidget, SIGNAL(itemClicked(QWidget), this, SLOT(refreshParcell(stoi(items.back().text().toStdString()))));
            }
        }

        con.close();
    } catch (const std::exception& e) {
        std::cerr << e.what() << std::endl;
    }
}

ParcellMenu::~ParcellMenu()
{
    delete ui;
}

void ParcellMenu::on_pushButton_released()
{
    refresh();
}


void ParcellMenu::on_backButton_released()
{
    parentWidget()->show();
    this->hide();
}

