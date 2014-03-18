
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
                Image{
                    width:playingF.lay
                    height: width
                    source: "image/minus.png"
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
                Image{
                    width:playingF.lay
                    height: width
                    source: "image/plus.png"
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
                    Log.startLevel(mainG.level,mainG.stage,player, playingF.lay, mainG.level);
                    mainG.starCount = Log.starC[mainG.level-1];
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
            text: "Version - 0.24"
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
        property int stage: 4+((level-1)/10)
        property int starCount: Log.starC[level-1]
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
                    Log.startLevel(mainG.level, mainG.stage, player, playingF.lay, mainG.level);
                    mainG.starCount = Log.starC[mainG.level-1];
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
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "<b>"+(mainG.starCount-mainG.collectStar)+":</b>"
                font.pixelSize: playingF.lay/3
            }
            Image{
                source: "image/star-black.png"
                height: playingF.lay/2
                width: height
                anchors.verticalCenter: starC.verticalCenter
                anchors.left: starC.right
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
            title: "Game Over"
            text: "Sorry, but you lose. Level will be restarted."
            onAccepted: {
                mainG.isGameOver = false;
                mainG.collectStar = 0;
                Log.startLevel(mainG.level, mainG.stage, player, playingF.lay, mainG.level);
                mainG.starCount = Log.starC[mainG.level-1];
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
                    height: playingF.lay
                    x: -1
                    y: (index+1)*playingF.lay
                    color: main.bgnColorFirst
                    border.color: main.fontColorFirst
                    property int starStg: index
                    Block{
                        id: block
                        x: Log.getRandomInt(0, parent.width-width)
                        y: 5
                        width: parent.width/3*(1/((index)+1))
                        speed: Math.log((index+1)*mainG.level*8)
                        color: main.blockColor
                        fickle: Log.getRandomBool()

                        Behavior on x {
                                NumberAnimation { duration: block.width*30/mainG.level }
                            }


                        /********************************************
                            Таймер блоков:
                                Прверяет на столкновений блоки и игрока
                                Управляет движением блоков
                         ********************************************/
                        Timer {
                                id:timer
                                 interval: 10; running: true; repeat: true
                                 onTriggered: {
                                     if(mainG.isGameOver){
                                         stop()
                                         block.x = block.x;
                                     }
                                     else{
                                         if(block.x<=0)
                                         {
                                             block.direction = true;
                                             block.x = playingF.width-block.width+1;
                                         }
                                         else
                                             if(block.x>=playingF.width-block.width)
                                             {
                                                 block.direction = false;
                                                 block.x = -1;
                                             }

                                     if(Math.abs(player.y-block.parent.y)<10)
                                         mainG.isGameOver = Log.isCrash(player, block, timer, dialog);

                                     if(player.y < playingF.lay)
                                     {
                                         if(block.direction)
                                         {
                                             block.x = playingF.width+1-block.width;
                                         }
                                         else{
                                             block.x = -1;
                                         }
                                     }
                                     else
                                         block.x = block.x;
                                     }
                                 }
                             }
                        Component.onCompleted: {
                            block.x = -1;
                            Log.saveBlocks(block, timer, index)
                        }
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
                            if(l === 0 )
                                l=10;
                            Log.setStarPos()
                            var c = Log.starCnt[stageCount][l-1][stg];
                            return c;

                        }

                        model: strC(blockF.starStg, mainG.level%10, mainG.stage)

                        Star{
                            id: star
                            width: playingF.lay/2
                            height: width
                            y: (playingF.lay-height)/2
                            function strX(stg, l, stageCount, index, w, sW){
                                if(l === 0 )
                                    l=10;

                                var c = Log.starCnt[stageCount][l-1][stg];
                                var i = index;
                                var ls = ((w/c)*(index));
                                var rs = ((w/c)*(index+1));

                                if(index === 0)
                                    return Log.getRandomInt(0, rs-sW)
                                else
                                    if(index+1 === c)
                                           return Log.getRandomInt(ls, w-sW)
                                    else
                                        return Log.getRandomInt(ls, rs-sW)

                            }
                            x: strX(blockF.starStg, mainG.level%10, mainG.stage, index, blockF.width, width)

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
                                         if(Math.abs(player.y-blockF.y) < playingF.lay/2)  //проверка на положение по Y игрока и звезды
                                           if(Log.findStar(player, star, playingF.lay)){
                                                 mainG.collectStar++;
                                                 stop();
                                             }
                                 }
                            }

                            Component.onCompleted: {
                                Log.saveStars(star,timerS, index, blockF.starStg)
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
                                 mainG.level++;
                                 Log.level = mainG.level;
                                 Log.startLevel(mainG.level, mainG.stage, player, playingF.lay, mainG.level);
                                 mainG.starCount = Log.starC[mainG.level-1];
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
                    if (event.key === Qt.Key_VolumeUp) {
                        mainG.collectStar = 0;
                        mainG.level++;
                        Log.level = mainG.level;
                        Log.startLevel(mainG.level, mainG.stage, player, playingF.lay, mainG.level);
                        mainG.starCount = Log.starC[mainG.level-1];
                        if(mainG.level > main.profLevel)
                        {
                           main.profLevel = mainG.level;
//                           saveLevel(main.profName, mainG.level);
                        }
                    }
            }
//            Component.onCompleted: Log.initial(playingF.width, playingF.height, mainG.level)
        }

}

