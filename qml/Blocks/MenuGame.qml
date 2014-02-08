import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.1
import QtQuick.LocalStorage 2.0
import "gameLogic.js" as Log

Rectangle{

    color: "black"
    visible: Log.visMenu
    Column{
        anchors.centerIn: parent
        spacing: parent.height/50
        Button{
            id: newGame
            text: qsTr("New Game")
            onClicked: {
                Log.isGameOver = false;
                Log.collectStar = 0;
                Log.startLevel(1,player);
                Log.visGame = true;
                Log.visMenu = false;
            }
        }
        Button{
            id: cont
            text: qsTr("Continue")
            onClicked: {
                Log.visGame = true;
                Log.visMenu = false;
            }
        }
        Button{
            id: changeProfiles
            text: qsTr("Change profile")
            onClicked: {
                Log.visProf = true
                Log.visMenu = false;
            }
        }
        Button{
            id: exit
            text: qsTr("Exit")
            onClicked: main.close()
        }
    }
}
