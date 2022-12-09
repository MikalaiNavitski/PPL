QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++20

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    addparcel.cpp \
    addressadd.cpp \
    defines.cpp \
    main.cpp \
    parcellmenu.cpp \
    pplapp.cpp \
    pseudosignupwindows.cpp \
    settings.cpp \
    signupwindows.cpp \
    usermenu.cpp

HEADERS += \
    addparcel.h \
    addressadd.h \
    defines.h \
    parcellmenu.h \
    pplapp.h \
    pseudosignupwindows.h \
    settings.h \
    signupwindows.h \
    usermenu.h

FORMS += \
    addparcel.ui \
    addressadd.ui \
    parcellmenu.ui \
    pplapp.ui \
    pseudosignupwindows.ui \
    settings.ui \
    signupwindows.ui \
    usermenu.ui

LIBS += -lpq -lpqxx

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    resources.qrc
