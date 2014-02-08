import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.1
import QtQuick.LocalStorage 2.0
import "gameLogic.js" as Log

ApplicationWindow {
    title: qsTr("Move you body")
    id: main
    contentOrientation: "PortraitOrientation"
    width: 540
    height: 700
    property int profCount: 0
    property string profName: ""

    Profiles{
        id: profWindow
        anchors.fill: parent
    }

    MenuGame{
        id: mainMenu
        anchors.fill: parent
    }
    Game{
        id: mainG
        anchors.fill: parent

        focus: true  //======================================================================================???
        Keys.onReleased: {
                if (event.key === Qt.Key_Back) {
                     if(Log.visGame){
                         Log.visMenu = true;
                         Log.visGame = false;
                     }
                     else
                         main.close();
                     event.accepted = true
                }
        }
    }

}
