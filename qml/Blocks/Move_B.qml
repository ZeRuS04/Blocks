import QtQuick 2.1
import QtQuick.Controls 1.0
import "gameLogic.js" as Log


ApplicationWindow {
    title: qsTr("Move you body")
    id: main
    contentOrientation: "PortraitOrientation"
//    width: 640
//    height: 480
    Rectangle{
        id: mainMenu
        anchors.fill: parent
        color: "black"
        visible: true
        Column{
            anchors.centerIn: parent
            spacing: parent.height/50
            Button{
                id: newGame
                text: qsTr("New Game")
                onClicked: {
                    mainG.isGameOver = false;
                    mainG.collectStar = 0;
                    mainG.level = Log.startLevel(1,mainG.stage,player, playingF.lay, scrText);
                    mainG.visible = true; mainMenu.visible = false;
                }
            }
            Button{
                id: cont
                text: qsTr("Continue")
                onClicked: {
                    mainG.visible = true; mainMenu.visible = false;
                }
            }
            Button{
                id: exit
                text: qsTr("Exit")
                onClicked: main.close()
            }
        }
    }

    Rectangle{
        id: mainG
        anchors.fill: parent
        visible: false
        /********************************************
            Основные переменные:
         ********************************************/
        property int level: 1
        property int stage: 4
        property int starCount: level*2
        property int collectStar: 0
        property bool isGameOver: true




        /********************************************
            Строка управления и счета:
         ********************************************/
        Image{
            id: refresh
            anchors.top: parent.top
            anchors.right: parent.right
            source: "image/refresh.png"
            height: playingF.lay; width: height
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    mainG.isGameOver = false;
                    mainG.collectStar = 0;
                    mainG.level = Log.startLevel(mainG.level, mainG.stage, player, playingF.lay, scrText);
                }
            }
        }
        Rectangle{
            id: scoreEl
            height: parent.height/(mainG.stage+3)
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
        /********************************************
            Игровое поле:
         ********************************************/
        Item{
            id: playingF

            anchors.top: scoreEl.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            property int lay: parent.height/(mainG.stage+3)

            /********************************************
                Старт:
             ********************************************/
            Rectangle{
                id: start
                anchors.left: playingF.left
                anchors.right: playingF.right
                anchors.top: playingF.top

                height: parent.lay
                color: "#bdf7bc"
                border.color: "black"
                Text{
                    anchors.centerIn: parent
                    anchors.fill: parent
//                    anchors.verticalCenter: parent.verticalCenter
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    width: parent.width
//                    anchors.alignWhenCentered: parent.Center
//                    height: parent.height
                    font.pixelSize: parent.height
                    text: "<b>START</b>"
                    opacity: 0.1
                }
            }

            /********************************************
                Создание игровых строк и блоков:
             ********************************************/
            Repeater{
                id: blocks
                model: mainG.stage
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
                        x: Log.getRandomInt(0, parent.width-width)
                        y: 5
                        width: parent.width/3*(1/((index)+1))
                        speed: index+1
                        fickle: Log.getRandomBool()


                        /********************************************
                            Таймер блоков:
                                Прверяет на столкновений блоки и игрока
                                Управляет движением блоков
                         ********************************************/
                        Timer {
                                id:timer
                                 interval: 5; running: true; repeat: true
                                 onTriggered: {
                                     if(mainG.isGameOver)
                                         stop()
                                     else{
                                         if(Math.abs(player.y-block.parent.y)<10)
                                             mainG.isGameOver = Log.isCrash(player, block, timer, scrText);
                                         if(player.y < playingF.lay)
                                            Log.move(block)
                                     }
                                 }
                             }
                    }

                    /********************************************
                        Таймер сохранения:
                            Сохраняет указатели на блоки
                     ********************************************/
                    Timer{
                             interval: 1; running: true; repeat: false
                             onTriggered: Log.saveBlocks(block, timer, scrText)
                    }
                }


            }

            /********************************************
                Финиш:
             ********************************************/
            Rectangle{
                id: finish
                anchors.left: playingF.left
                anchors.right: playingF.right
                anchors.bottom: playingF.bottom
                height: parent.lay
                color: "#fbc9c9"
                border.color: "black"
            }


            /********************************************
                Игрок:
             ********************************************/
            Player{
                id: player
                x: start.width/2 - width/2
                y: 0
                width: playingF.lay
                height: playingF.lay
                /********************************************
                    Таймер игрока:
                        Проверяет не пришел ли игрок на финиш
                 ********************************************/
                Timer{
                         interval: 50; running: true; repeat: true
                         onTriggered:{
                             if((player.y >= finish.y-playingF.lay)&&(mainG.collectStar === mainG.starCount)){
                                 mainG.collectStar = 0;
                                 mainG.level = Log.startLevel(mainG.level+1, mainG.stage, player, playingF.lay, scrText);
                             }

                         }

                }
            }

            /********************************************
                Мультитач арена:
                    Управление движением игрока
             ********************************************/
            MultiPointTouchArea {
                   anchors.fill: parent
                   touchPoints: [
                               TouchPoint { id: point }
                           ]
                   onPressed:{
                       if(!mainG.isGameOver)
                        Log.setStartP(point);
                   }
                   onTouchUpdated:{
                       if(!mainG.isGameOver){
                           Log.playerMoveX(player, point.sceneX, point.sceneY, playingF.lay,scrText)
                           Log.setOldP(point);
                       }
                   }
                   onReleased:{
                       if(!mainG.isGameOver)
                        Log.playerMoveY(player, point.sceneX, point.sceneY, playingF.lay, scrText)
                   }
               }
        }

        /********************************************
            Таймер инициализации:
                Инициализирует некоторые глоб. перем.
         ********************************************/
        Timer{
                 interval: 1; running: true; repeat: false
                 onTriggered: Log.initial(playingF.width, playingF.height, mainG.level)

        }

        /********************************************
            Звезды:
                Распределение положения звезд
                Проверка на столкновения
                Анимация
         ********************************************/
        Repeater{
            model: mainG.starCount
            Star{
                id: star
                width: playingF.lay/2
                height: width
                y: playingF.lay*Log.getRandomInt(2, mainG.stage+1)+(playingF.lay-height)/2
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

                /********************************************
                    Таймер звезд:
                        Прверяет на столкновений звезды и
                                                       игрока
                 ********************************************/
                Timer{
                         id:timerS
                         interval: 5; running: true; repeat: true
                         onTriggered: {
                             if((Math.abs(player.y+playingF.lay-star.y) < playingF.lay/2)&&  //проверка на положение по Y игрока и звезды
                                                                   star.y > playingF.lay*2)       //проверка на то что звезда уже переместилась на игровое поле
                                 if(Log.findStar(player, star, playingF.lay, mainG.starCount,  scrText)){
                                     mainG.collectStar++;
                                     stop();
                                 }
                     }
                }
                /********************************************
                    Таймер сохранения:
                        Сохраняет указатели на звезды
                 ********************************************/
                Timer{
                         interval: 1; running: true; repeat: false
                         onTriggered: Log.saveStars(star,timerS, index, scrText)
                }

            }

        }
        focus: true
        Keys.onReleased: {
                if (event.key === Qt.Key_Back) {
                     if(mainG.visible){
                         mainMenu.visible = true;
                         mainG.visible = false;
                     }
                     else
                         main.close();
                     event.accepted = true
                }
        }
    }


}
