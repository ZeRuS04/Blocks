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
    property int profLevel: 1

    property color bgnColorFirst: "black"
    property color bgnColorSecond: "white"

    property color blockColor: bgnColorSecond
    property color fontColorFirst: bgnColorSecond
    property color fontColorSecond: bgnColorFirst

    color: bgnColorFirst

    function openDB() {
        Log.db = LocalStorage.openDatabaseSync("db_prof", "1.0", "Profiles", 1000000);

        Log.db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Profiles(name TEXT, level int)');
                var rs = tx.executeSql('SELECT COUNT(*) as count FROM Profiles');
                profCount = rs.rows.item(0).count

            }
        )
    }

    Component.onCompleted: openDB()
    Rectangle{
        id:profWindow
        anchors.fill: parent
        color: main.bgnColorSecond
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
                    color: main.bgnColorFirst
                    border.width: 1
                    border.color: "black"
                    x: (profWindow.width-width)/2
                    y: height*index
                    Text{
                        id: prName
                        color: main.fontColorFirst
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

                                    main.profLevel = rs.rows.item(0).level
                                    mainG.level = main.profLevel
                                    Log.level = mainG.level
                                    main.profName = rs.rows.item(0).name
                                }
                            )
                        }
//                        onPressed: parent.color = "lightgrey"
                        onReleased: {
//                            parent.color = "white"
                            cont.visible = false;
                            getProfLevel(prName)
                            profWindow.visible = false;
                            profWindow.focus = true;
                            mainMenu.visible = true;
                            mainMenu.focus = true;
                            mainG.isGameOver = false;
                            mainG.collectStar = 0;
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
            color: main.bgnColorFirst
            visible: false

            Text{
                anchors.bottom: inputProfName.top
                anchors.horizontalCenter: parent.horizontalCenter
                width:inputProfName.width
                color: main.fontColorFirst
                font.pixelSize: playingF.lay/5
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
                                Log.level = mainG.level
                                main.profName = inputProfName.text
                                var rs = tx.executeSql('SELECT COUNT(*) as count FROM Profiles');
                                profCount = rs.rows.item(0).count


                            }
                        )
                    }
                    anchors.fill: parent
                    onPressed: parent.color = "lightgrey"
                    onReleased: {
                        cont.visible = false;
                        parent.color = "black"
                        createProf(inputProfName.text, 1);
                        createNewProf.visible = false
                        profWindow.visible = false;
                        profWindow.focus = false;
                        mainMenu.focus = true;
                        mainMenu.visible = true;
                    }
                }
            }
        }
        Keys.onReleased: {
                if (event.key === Qt.Key_Back) {
                     if(profWindow.visible){
                         cont.visible = true;
                         mainMenu.visible = true;
                         profWindow.visible = false;
                         mainMenu.focus = true;
                         profWindow.focus = false;
                     }
                     else
                         main.close();
                     event.accepted = true
                }
        }
    }
    Rectangle{
        id: mainMenu
        anchors.fill: parent
        color: main.bgnColorSecond
        visible: false
        Column{
            anchors.centerIn: parent
            spacing: parent.height/50
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.bottom: chLevel
                text: "<b>LEVEL</b>"
                color: main.fontColorSecond
            }
            Row{
//                width: playingF.lay*3
                spacing: 2
                Rectangle{
                    width:playingF.lay
                    height: width
                    color: "skyblue"
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            if(mainG.level > 1)
                            {
                                mainG.level--;
                                Log.level = mainG.level;
                            }
                        }
                    }
                }
                Rectangle{
                    id: chLevel
                    width: playingF.lay
                    height: width
                    color: mainMenu.color
                    Text
                    {
                        anchors.centerIn: parent
                        font.pixelSize: playingF.lay
                        text: mainG.level
                        color: main.fontColorSecond
                   }
                }
                Rectangle{
                    width:playingF.lay
                    height: width
                    color: "red"
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            if(mainG.level < profLevel)
                            {
                                mainG.level++;
                                Log.level = mainG.level;
                            }
                        }
                    }
                }

            }
            Button{
                id: startGame
                width:playingF.lay*3
                height: playingF.lay
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Start")
                onClicked: {
                    mainG.isGameOver = false;
                    mainG.collectStar = 0;
                    Log.startLevel(mainG.level,mainG.stage,player, playingF.lay, mainG.starCount);
                    mainG.visible = true; mainMenu.visible = false;
                    mainG.focus = true;
                }
            }
            Button{
                id: cont
                anchors.horizontalCenter: parent.horizontalCenter
                width:playingF.lay*3
                height: playingF.lay/2
                text: qsTr("Continue")
                visible: false
                onClicked: {
                    mainG.visible = true;
                    mainG.focus = true;
                    mainMenu.focus = false;
                    mainMenu.visible = false;

                }
            }
            Button{
                id: changeProfiles
                anchors.horizontalCenter: parent.horizontalCenter
                width:playingF.lay*3
                height: playingF.lay/2
                text: qsTr("Change profile")
                onClicked: {
                    profWindow.visible = true;
                    profWindow.focus = true;
                    mainMenu.focus = false;
//                    mainG.visible = true;
                    mainMenu.visible = false;
                }
            }
            Button{
                width:playingF.lay*3
                height: playingF.lay/2
                anchors.horizontalCenter: parent.horizontalCenter
                id: exit
                text: qsTr("Exit")
                onClicked: main.close()
            }
        }


        Text{
            id: selProf
            anchors.bottom: parent.bottom
            color: main.fontColorSecond
            text: main.profName
        }
        Text{
            id: ver
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            color: main.fontColorSecond
            text: "Version - 0.05"
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
        property int starCount: 0/*/*Log.level*2level*2*/
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
            height: playingF.lay;
            width: height
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    mainG.isGameOver = false;
                    mainG.collectStar = 0;
                    Log.startLevel(mainG.level, mainG.stage, player, playingF.lay, mainG.starCount);
                }
            }
        }
        Rectangle{
            id: scoreEl
            height: parent.height/(mainG.stage+3)
            color: main.bgnColorSecond
            border.color: main.fontColorSecond
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: refresh.left
            Text{
                id: starC
                width: height
                height: playingF.lay/2
                color: main.fontColorSecond
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: "<b>"+mainG.collectStar+":</b>"
                font.pixelSize: playingF.lay/3
            }

            Text{
                id: lev
                width: height
                height: playingF.lay/2
                color: main.fontColorSecond
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
                Log.startLevel(mainG.level, mainG.stage, player, playingF.lay, mainG.starCount);
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
                color: main.bgnColorFirst
                border.color: main.fontColorFirst
                border.width: 1
                Text{
                    anchors.centerIn: parent
                    color: "#bdf7bc"
                    font.pixelSize: parent.height
                    text: "<b>START</b>"
                    opacity: 0.3
                }
            }

            /********************************************
                Создание игровых строк и блоков:
             ********************************************/
            Repeater{
                id: blocks
                model: mainG.stage
                Rectangle{
                    opacity: 1
                    id:blockF
                    anchors.left: playingF.left
                    anchors.right: playingF.right
                    height: parent.lay
                    x: 0
                    y: (index+1)*parent.lay
                    color: main.bgnColorFirst
                    border.color: main.fontColorFirst
                    property int starStg: index
                    Block{
                        id: block
                        x: Log.getRandomInt(0, parent.width-width)
                        y: 5
                        width: parent.width/3*(1/((index)+1))
                        speed: index+1
                        color: main.blockColor
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

                        Component.onCompleted: Log.saveBlocks(block, timer)
                    }


                    /********************************************
                        Звезды:
                            Распределение положения звезд
                            Проверка на столкновения
                            Анимация
                     ********************************************/
                    Repeater{
                        function strC(stg, l, stageCount)
                        {
                            var mass = [];
                            for(var i = 0; i < stageCount; i++)
                            {

                                if(i+1 === stageCount)
                                {
                                    mass.push(1);
                                    break;
                                }
                                mass.push(0);
                            }
                            for(var k = 1; k < l; k++)
                            {
                                for(var j = 0; j < stageCount; j++)
                                {
                                    if(j+1===stageCount)
                                        mass[j]+=1;
                                    if(mass[j]+1 < mass[j+1])
                                        mass[j]+=1;

                                }
                            }

                            return mass[stg];
                        }

                        model: strC(blockF.starStg, mainG.level%10, mainG.stage)

                        Star{
                            id: star
                            width: playingF.lay/2
                            height: width
                            y: /*playingF.lay*Log.getRandomInt(2, mainG.stage+1)+*/(playingF.lay-height)/2
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

                            Component.onCompleted: {
                                 Log.saveStars(star,timerS, mainG.starCount)
                                 mainG.starCount++;
                            }
                        }
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
                color: main.bgnColorFirst
                border.color: main.fontColorFirst
                Text{
                    anchors.centerIn: parent
                    font.pixelSize: parent.height
                    color: "#fbc9c9"
                    text: "<b>FINISH</b>"
                    opacity: 0.3
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
                                 mainG.level = Log.startLevel(mainG.level+1, mainG.stage, player, playingF.lay, mainG.starCount);
                                 if(mainG.level > main.profLevel)
                                 {
                                    main.profLevel = mainG.level;
                                    saveLevel(main.profName, mainG.level);
                                 }

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

            Keys.onReleased: {
                    if (event.key === Qt.Key_Back) {
                         if(mainG.visible){
                             cont.visible = true;
                             mainMenu.visible = true;
                             mainG.visible = false;
                             mainMenu.focus = true;
                             mainG.focus = false;
                         }
                         else
                             main.close();
                         event.accepted = true
                    }
            }
            Keys.onPressed: {
                    if (event.key === Qt.Key_Right) {
                        mainG.collectStar = 0;
                        mainG.level = Log.startLevel(mainG.level+1, mainG.stage, player, playingF.lay, mainG.starCount);
                        if(mainG.level > main.profLevel)
                        {
                           main.profLevel = mainG.level;
                           saveLevel(main.profName, mainG.level);
                        }
                    }
            }
//            Component.onCompleted: Log.initial(playingF.width, playingF.height, mainG.level)
        }

}

