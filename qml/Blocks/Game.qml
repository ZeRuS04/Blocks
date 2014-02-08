import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.1
import QtQuick.LocalStorage 2.0
import "gameLogic.js" as Log

Rectangle{
    id: mainG
    anchors.fill: parent
    visible: Log.visGame
    /********************************************
        Основные переменные:
     ********************************************/
    property int level: Log.level
//    property int stage: 4
//    property int starCount: level*2
//    property int collectStar: 0
//    property bool isGameOver: false




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
                Log.isGameOver = false;
                Log.collectStar = 0;
                Log.startLevel(Log.level, player);
            }
        }
    }
    Rectangle{
        id: scoreEl
        height: parent.height/(Log.stage+3)
        color: "#c6d1f1"
        border.color: "black"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: refresh.left
        Text{
            id: starC
            width: height
            height: playingF.lay/2
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            text: "<b>"+Log.collectStar+":</b>"
            font.pixelSize: playingF.lay/3
        }

        Text{
            id: lev
            width: height
            height: playingF.lay/2
            anchors.left: parent.left
            anchors.top: parent.top
            font.pixelSize: playingF.lay/3
            text: "<b>Level: "+mainG.level+"</b>"
        }

    }


    /********************************************
        Диалоговое окно:
     ********************************************/
    MessageDialog {
        id: dialog
//            visible: false
        title: "Game Over"
        text: "Sorry, but you lose. Level will be restarted."
        onAccepted: {
            Log.isGameOver = false;
            Log.collectStar = 0;
           Log.startLevel(Log.level, player);
        }
//            Component.onCompleted: visible = true
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
        property int lay: parent.height/(Log.stage+3)
        Component.onCompleted:  Log.initial(playingF.width, playingF.height, 1, playingF.lay)
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
            model: Log.stage
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
                                 if(Log.isGameOver)
                                     stop()
                                 else{
                                     if(Math.abs(player.y-block.parent.y)<10)
                                         Log.isGameOver = Log.isCrash(player, block, timer, dialog);
                                     if(player.y < Log.lay)
                                        Log.move(block, 0)
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
                         onTriggered: Log.saveBlocks(block, timer)
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
                    function saveLevel (name, level) {
                        Log.db.transaction(
                            function(tx) {
                                tx.executeSql('UPDATE Profiles SET level = ? WHERE name = ?', [level, name]);
                            }
                        )
                    }
                     interval: 50; running: false; repeat: true
                     onTriggered:{
                         if((player.y >= finish.y-Log.lay)&&(Log.collectStar === Log.starCount)){
                             Log.collectStar = 0;
                             Log.startLevel(Log.level+1, player);
                             saveLevel(Log.profName, Log.level);
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
                   if(!Log.isGameOver)
                    Log.setStartP(point);
               }
               onTouchUpdated:{
                   if(!Log.isGameOver){
                       Log.playerMoveX(player, point.sceneX, point.sceneY)
                       Log.setOldP(point);
                   }
               }
               onReleased:{
                   if(!Log.isGameOver)
                    Log.playerMoveY(player, point.sceneX, point.sceneY)
               }
           }
    }

//    /********************************************
//        Таймер инициализации:
//            Инициализирует некоторые глоб. перем.
//     ********************************************/
//    Timer{
//             interval: 1; running: true; repeat: false
//             onTriggered: Log.initial(playingF.width, playingF.height, 1, playingF.lay)

//    }

    /********************************************
        Звезды:
            Распределение положения звезд
            Проверка на столкновения
            Анимация
     ********************************************/
    Repeater{
        model: Log.starCount
        Star{
            id: star
            width: Log.lay/2
            height: width
            y: Log.lay*Log.getRandomInt(2, Log.stage+1)+(Log.lay-height)/2
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
                         if((Math.abs(player.y+Log.lay-star.y) < Log.lay/2)&&  //проверка на положение по Y игрока и звезды
                                                               star.y > Log.lay*2)       //проверка на то что звезда уже переместилась на игровое поле
                             if(Log.findStar(player, star, Log.lay)){
                                 Log.collectStar++;
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
                     onTriggered: Log.saveStars(star,timerS, index)
            }

        }

    }



}
