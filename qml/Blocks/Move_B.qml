import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.LocalStorage 2.0
import QtQuick.Dialogs 1.1
import "gameLogic.js" as Log

ApplicationWindow {
    title: qsTr("Move you body")
    id: main
    contentOrientation: "PortraitOrientation"
    //    width: 640
    //    height: 480
    property int profileID: 0
    property string profileName: "No profile"

    property int recordCount: 0

    property string playerName: ""
    property int recordLevel: 0

    /********************************************
        Работа с БД:
     ********************************************/
    MessageDialog {
        id: dbOpenFail
        //            visible: false
        title: "Fail"
        text: "Database was not created or opened."
        onAccepted: {
            main.close()
        }
    }
    function dbOpen() {
        // Открытие базы данных ExampleDB
        Log.db = LocalStorage.openDatabaseSync("db_prof","1.0","Profile data",1000000);
        // Проверка на успешность открытия базы данных ExampleDB
        if(!Log.db){
            dbOpenFail.open()
            return
        }
        Log.db.transaction(
           function(tx) {
              tx.executeSql('CREATE TABLE IF NOT EXISTS Records(name TEXT, level int)');

           }
        )
    }


    function dbRecCount(db){
        db.transaction(
           function(tx) {
//              tx.executeSql('INSERT INTO Profiles VALUES(?, ?, ?)',[1,'NewPlayer', 0]);
              var results = tx.executeSql('SELECT count(*) as count FROM Records');

              var r = results.rows.item(0).count;

//              for(var i = 0; i < results.rows.length; i++) {
//                 r += results.rows.item(i).id + ", " +
//                        results.rows.item(i).name + ", " +
//                       results.rows.item(i).level + "\n"
//              }

              recordCount = r;
           }
        )
    }

    Component.onCompleted: {
        dbOpen()
        dbRecCount(Log.db);

    }


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
                    id: recordTable
                    text: qsTr("Record Table")
                    onClicked: records.visible = true
                }
                Button{
                    id: exit
                    text: qsTr("Exit")
                    onClicked: main.close()
                }
            }
            Text{
                id: profName
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                color: "white"
                text: main.profileName

            }
            Text{
                id: ver
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: parent.width/2
                color: "white"
                horizontalAlignment: Text.AlignRight
                text: "Versoin: 0.18"
            }
        }
        Rectangle{
            id: records
            anchors.fill: parent
            color: "white"
            visible: false
            Repeater
            {
                model: main.recordCount
                Text{
                    id: recs
                    anchors.fill: main
                    function dbViewRecords(db)
                    {
                        db.transaction(
                           function(tx) {
                //              tx.executeSql('INSERT INTO Profiles VALUES(?, ?, ?)',[1,'NewPlayer', 0]);
                              var results = tx.executeSql('SELECT * FROM Records ORDER BY level DESC');

                              var r = "";
                              r += index + ") " + results.rows.item(i).name + ": /t " +
                                    results.rows.item(i).level + " level\n"
                //              for(var i = 0; i < results.rows.length; i++) {
                //                 r += results.rows.item(i).id + ", " +
                //                        results.rows.item(i).name + ", " +
                //                       results.rows.item(i).level + "\n"
                //              }
                               text = r;
                           }
                        )
                    }
                    Component.onCompleted: dbViewRecords(Log.db)
                }
            }
//            focus: true
//            Keys.onReleased: {
//                if (event.key === Qt.Key_Back) {
//                    if(records.visible)
//                        records.visible = false
//                }
//            }

        }

        /********************************************
         Ввод имени игрока для записи в таблицу
                                        рекордов
        ********************************************/
        Rectangle{
            id: inputName
            color: "black"
            anchors.fill: parent
            visible: false
            function dbInsert(db){
                db.transaction(
                   function(tx) {
                      tx.executeSql('INSERT INTO Records VALUES(?, ?)',[pName, mainG.level]);
                   }
                )
            }
            Column{
                spacing:5

                Text{
                    width: 200
                    height: 50
                    color: "white"
                    text: "Please, input you name:"
                }
                Button{
                    text: qsTr("Ok")
                    onClicked: {
                        dbInsert(Log.db);
                        dbRecCount(Log.db);
                        dbViewRecords(Log.db);
                        inputName.visible = false;
                    }
                }
                TextEdit{
                    id: pName
                    width: 200
                    height: 50
                    color: "white"
                    text: "New Player"
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
                        font.pixelSize: parent.height
                        text: "<b>START</b>"
                        horizontalAlignment: Text.AlignHCenter
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

                    Text{
                        anchors.centerIn: parent
                        anchors.fill: parent
                        font.pixelSize: parent.height
                        text: "<b>FINISH</b>"
                        horizontalAlignment: Text.AlignHCenter
                        opacity: 0.1
                    }
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
                                mainG.level = Log.startLevel(mainG.level+1, mainG.stage, player, playingF.lay);
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
                onTriggered: {
//                    Log.profiles(dbOpenFail, profileName);
                    Log.initial(playingF.width, playingF.height, mainG.level)
                }

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
                        inputName.visible = true;
                        mainG.visible = false;
                    }
                    else
                        main.close();
                    event.accepted = true
                }
            }
        }


    }
