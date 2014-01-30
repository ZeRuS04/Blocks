import QtQuick 2.1
import QtQuick.Controls 1.0
import "gameLogic.js" as Log
ApplicationWindow {
    title: qsTr("Move you body")
//    width: 640
//    height: 480
    id: main
    property int level: 2
    property int stage: 6
    property int starCount: level*2
    property bool isGameOver: false
    Image{
        id: refresh
        anchors.top: parent.top
        anchors.right: parent.right
        source: "image/refresh.png"
        height: playingF.lay; width: height
        MouseArea{
            anchors.fill: parent
            onClicked: scrText.text = "Есть касание!"
        }
    }
    Rectangle{
        id: scoreEl
        height: parent.height/(main.stage+3)
        color: "#c6d1f1"
        border.color: "black"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: refresh.left
        Text{
            id: scrText
            anchors.fill: parent
            text: "no touches"
        }

    }



    Item{
        id: playingF

        anchors.top: scoreEl.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        property int lay: parent.height/(main.stage+3)
        Rectangle
        {
            id: start
            anchors.left: playingF.left
            anchors.right: playingF.right
            anchors.top: playingF.top
            height: parent.lay
            color: "#bdf7bc"
            border.color: "black"
        }
        Repeater{
            id: blocks
            model: main.stage
            Rectangle
            {
                opacity: 1
                id:blockF
                anchors.left: playingF.left
                anchors.right: playingF.right
                height: parent.lay
                x: 0
                y: (index+1)*parent.lay
                color: "#ffffff"
                border.color: "black"

                Block{
                    id: block
                    x: 0
                    y: 5
                    z: 1
                    width: parent.width/3*(1/((index)+1))
                    speed: index+1

                }
                Timer {
                        id:timer
                         interval: 5; running: true; repeat: true
                         onTriggered: {
                             if(main.isGameOver)
                                 stop()
                             else{
                                 if(Math.abs(player.y-block.parent.y)<10)
                                     main.isGameOver = Log.isCrash(player, block, timer, scrText);
                                 Log.move(block, main.level, parent.width)
                             }


                         }
                     }
                Timer{
                         interval: 1; running: true; repeat: false
                         onTriggered: Log.saveTimer(timer, scrText)
                }
            }


        }

        Rectangle{
            id: finish
            anchors.left: playingF.left
            anchors.right: playingF.right
            anchors.bottom: playingF.bottom
            height: parent.lay
            color: "#fbc9c9"
            border.color: "black"
        }

        Player{
            id: player
            x: start.width/2 - width/2
            y: 0
            width: playingF.lay
            height: playingF.lay
        }


        MultiPointTouchArea {
               anchors.fill: parent
               touchPoints: [
                           TouchPoint { id: point }
                       ]
               onPressed:   Log.setStartP(point);
               onTouchUpdated:{

                   Log.playerMoveX(player, point.sceneX, point.sceneY, playingF.lay,scrText)
                   Log.setOldP(point);
               }
               onReleased:  Log.playerMoveY(player, point.sceneX, point.sceneY, playingF.lay, scrText)
           }



    }
    Timer{
             interval: ; running: true; repeat: false
             onTriggered: Log.initial(playingF.width, playingF.height, blocks, stage)

    }
    Repeater{
        model: main.starCount
        Star{
            id: star
            width: playingF.lay/2
            height: width
            y: playingF.lay*Log.getRandomInt(2, stage+1)+(playingF.lay-height)/2
            x: Log.getRandomInt(0, playingF.width-width)

            Behavior on width {
                    NumberAnimation { duration: 700 }
                }
            Behavior on x {
                    NumberAnimation { duration: 700 }
                }
            Behavior on y {
                    NumberAnimation { duration: 700 }
                }

            Timer{
                     interval: 5; running: true; repeat: true
                     onTriggered: {
                         if(Math.abs(player.y+playingF.lay-star.y)<playingF.lay/2)
                             if(Log.findStar(player, star, playingF.lay, main.starCount,  scrText))
                                 stop();
                     }
            }

        }
    }

}

