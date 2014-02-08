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
    property int profLevel: mainG.level
    function openDB() {
        Log.db = LocalStorage.openDatabaseSync("db_prof", "1.0", "Profiles", 1000000);

        Log.db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS Profiles(name TEXT, level int)');

                // Add (another) greeting row
//                tx.executeSql('INSERT INTO Profiles VALUES(?, ?)', [ 'hello', 1 ]);
                var rs = tx.executeSql('SELECT COUNT(*) as count FROM Profiles');
                profCount = rs.rows.item(0).count
                // Show all added greetings
//                var rs = tx.executeSql('SELECT * FROM Greeting');

//                var r = ""
//                for(var i = 0; i < rs.rows.length; i++) {
//                    r += rs.rows.item(i).salutation + ", " + rs.rows.item(i).salutee + "\n"
//                }
//                text = r
            }
        )
    }

    Component.onCompleted: openDB()
    Rectangle{
        id:profWindow
        anchors.fill: parent
        color: "black"
        visible: true
        Flickable{
            anchors.fill:parent
            contentWidth: width; contentHeight: (playingF.lay/2)*(main.profCount+1)
            Repeater{
                id: profList
                model: main.profCount
                Rectangle{
                    width: profWindow.width/2
                    height:playingF.lay/2
                    color: "white"
                    border.width: 1
                    border.color: "black"
                    x: (profWindow.width-width)/2
                    y: height*index
                    Text{
                        id: prName
                        color: "Black"
                        anchors.centerIn: parent
                        font.pixelSize: parent.height/1.5
                        function getProf(db) {
                            db.transaction(
                                function(tx) {
                                    var rs = tx.executeSql('SELECT * FROM Profiles');
                                    text = rs.rows.item(index).name
                                }
                            )
                        }
                        Component.onCompleted: getProf(Log.db)
                    }
                    MouseArea{
                        anchors.fill: parent
                        function getProfLevel(name) {
                            Log.db.transaction(
                                function(tx) {

                                    var rs = tx.executeSql('SELECT * FROM Profiles WHERE name = ?', [name.text]);
                                    mainG.level = rs.rows.item(0).level
                                    main.profName = rs.rows.item(0).name
                                }
                            )
                        }
                        onPressed: parent.color = "lightgrey"
                        onReleased: {
                            parent.color = "white"
                            getProfLevel(prName)
                            profWindow.visible = false;
                            mainMenu.visible = true;
                        }
                    }
                    Rectangle{
                        width: parent.height/1.5
                        height: width
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        color: "red"
                        MouseArea{
                            anchors.fill: parent
                            function delProf(name) {
                                Log.db.transaction(
                                    function(tx) {
                                        var rs = tx.executeSql('SELECT COUNT(*) AS count FROM Profiles WHERE name = ?', [name.text]);
                                        var count = rs.rows.item(0).count;

                                        rs = tx.executeSql('DELETE FROM Profiles WHERE name = ?', [name.text]);
                                        profCount -= count;
                                    }
                                )
                            }
                            onPressed: parent.color = "lightgrey"
                            onReleased: {
                                parent.color = "red"
                                delProf(prName)
                            }
                        }
                    }
                }
            }

            Rectangle{
                id: newBtProf
                width: profWindow.width/2
                height: playingF.lay/2
                color: "lightblue"
                border.width: 1
                border.color: "black"
                x: (profWindow.width-width)/2
                y: height*main.profCount
                Text{
                    id: newTxtProf
                    color: "Black"
                    anchors.centerIn: parent
                    font.pixelSize: parent.height/1.5
                    text: "New profile"
                }
                MouseArea{
                    anchors.fill: parent
                    onPressed: parent.color = "lightgrey"
                    onReleased: {
                        parent.color = "white"
    //                    profWindow.visible = false;
                        createNewProf.visible = true;
                    }
                }
            }
        }
        Rectangle{
            id: createNewProf
            anchors.fill: parent
            color: "white"
            visible: false

            Text{
                anchors.bottom: inputProfName.top
                anchors.horizontalCenter: parent.horizontalCenter
                width:inputProfName.width
                color: "Black"
                font.pixelSize: playingF.lay/3
                text: "Please, input you name:"
            }
            TextField{
                id: inputProfName
                anchors.centerIn: parent
                width: parent.width/1.5
                height: playingF.lay/2
                font.pixelSize: playingF.lay/3
            }
            Rectangle{
                id: crBt
                anchors.bottom: parent.bottom
                width: parent.width
                height: playingF.lay/2
                color: "black"
                Text{
                    id: crTxt
                    color: "white"
                    anchors.centerIn: parent
                    font.pixelSize: parent.height/1.5
                    text: "Create"
                }
                MouseArea{
                    function createProf (name, level) {
                        Log.db.transaction(
                            function(tx) {
                                tx.executeSql('INSERT INTO Profiles VALUES(?, ?)', [ name, level ]);
                                mainG.level = level
                                main.profName = inputProfName.text
                            }
                        )
                    }
                    anchors.fill: parent
                    onPressed: parent.color = "lightgrey"
                    onReleased: {
                        parent.color = "black"
                        createProf(inputProfName.text, 1);
                        createNewProf.visible = false
                        profWindow.visible = false;
                        mainMenu.visible = true;
                    }
                }
            }
        }

    }
    Rectangle{
        id: mainMenu
        anchors.fill: parent
        color: "black"
        visible: false
        Column{
            anchors.centerIn: parent
            spacing: parent.height/50
            Button{
                id: newGame
                text: qsTr("New Game")
                onClicked: {
                    mainG.isGameOver = false;
                    mainG.collectStar = 0;
                    mainG.level = Log.startLevel(1,mainG.stage,player, playingF.lay);
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
                id: changeProfiles
                text: qsTr("Change profile")
                onClicked: {
                    profWindow.visible= true

//                    mainG.visible = true;
                    mainMenu.visible = false;
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
        property bool isGameOver: false




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
                    mainG.level = Log.startLevel(mainG.level, mainG.stage, player, playingF.lay);
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
                id: starC
                width: height
                height: playingF.lay/2
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: "<b>"+mainG.collectStar+":</b>"
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
                mainG.isGameOver = false;
                mainG.collectStar = 0;
                mainG.level = Log.startLevel(mainG.level, mainG.stage, player, playingF.lay);
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
                                             mainG.isGameOver = Log.isCrash(player, block, timer, dialog);
                                         if(player.y < playingF.lay)
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
                         interval: 50; running: true; repeat: true
                         onTriggered:{
                             if((player.y >= finish.y-playingF.lay)&&(mainG.collectStar === mainG.starCount)){
                                 mainG.collectStar = 0;
                                 mainG.level = Log.startLevel(mainG.level+1, mainG.stage, player, playingF.lay);
                                 saveLevel(main.profName, mainG.level);
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
                           Log.playerMoveX(player, point.sceneX, point.sceneY, playingF.lay)
                           Log.setOldP(point);
                       }
                   }
                   onReleased:{
                       if(!mainG.isGameOver)
                        Log.playerMoveY(player, point.sceneX, point.sceneY, playingF.lay)
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
                                 if(Log.findStar(player, star, playingF.lay)){
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
                         onTriggered: Log.saveStars(star,timerS, index)
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
