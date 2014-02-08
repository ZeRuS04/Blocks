import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.1
import QtQuick.LocalStorage 2.0

import "gameLogic.js" as Log

Rectangle{

    color: "black"
    visible: Log.VisProf

    Flickable{
        id: flick
        anchors.fill: parent
        property int lay: height/(Log.stage+3)
        property int profCount: 0

        function openDB() {
            Log.db = LocalStorage.openDatabaseSync("db_prof", "1.0", "Profiles", 1000000);

            Log.db.transaction(
                function(tx) {
                    // Create the database if it doesn't already exist
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Profiles(name TEXT, level int)');
                    var rs = tx.executeSql('SELECT COUNT(*) as count FROM Profiles');
                    Log.profCount = rs.rows.item(0).count
                    profCount =  Log.profCount;
                }
            )
        }

        Component.onCompleted: openDB()

        contentWidth: width; contentHeight: (lay/2)*(Log.profCount+1)
        Repeater{
            id: profList
            model: flick.profCount
            Rectangle{
                width: flick.width/2
                height: flick.lay/2
                color: "white"
                border.width: 1
                border.color: "black"
                x: (flick.width-width)/2
                y: height*index
                Text{
                    id: prName
                    color: "Black"
                    anchors.centerIn: parent
                    font.pixelSize: parent.height/1.5
                    function getProf() {
                        Log.db.transaction(
                            function(tx) {
                                var rs = tx.executeSql('SELECT * FROM Profiles');
                                var t = rs.rows.item(index).name;
                                text = t;
                            }
                        )
                    }
                    Component.onCompleted: getProf()
                }
                MouseArea{
                    anchors.fill: parent
                    function getProfLevel(name) {
                        Log.db.transaction(
                            function(tx) {

                                var rs = tx.executeSql('SELECT * FROM Profiles WHERE name = ?', [name.text]);
                                Log.level = rs.rows.item(0).level
                                Log.profName = rs.rows.item(0).name
                            }
                        )
                    }
                    onPressed: parent.color = "lightgrey"
                    onReleased: {
                        parent.color = "white"
                        getProfLevel(prName)
                        Log.visProf = false;
                        Log.visMenu = true;
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
                                    Log.profCount -= count;
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
            width: parent.width/2
            height: flick.lay/2
            color: "lightblue"
            border.width: 1
            border.color: "black"
            x: (parent.width-width)/2
            y: height*(Log.profCount+1)
            Text{
                id: newTxtProf
                color: "Black"
                anchors.centerIn: parent
                font.pixelSize: parent.height/3
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
    //    Rectangle{
    //        id: createNewProf
    //        anchors.fill: parent
    //        color: "white"
    //        visible: false

    //        Text{
    //            anchors.bottom: inputProfName.top
    //            anchors.horizontalCenter: parent.horizontalCenter
    //            width:inputProfName.width
    //            color: "Black"
    //            font.pixelSize: Log.lay/3
    //            text: "Please, input you name:"
    //        }
    //        TextField{
    //            id: inputProfName
    //            anchors.centerIn: parent
    //            width: parent.width/1.5
    //            height: Log.lay/2
    //            font.pixelSize: Log.lay/3
    //        }
    //        Rectangle{
    //            id: crBt
    //            anchors.bottom: parent.bottom
    //            width: parent.width
    //            height: Log.lay/2
    //            color: "black"
    //            Text{
    //                id: crTxt
    //                color: "white"
    //                anchors.centerIn: parent
    //                font.pixelSize: parent.height/1.5
    //                text: "Create"
    //            }
    //            MouseArea{
    //                function createProf (name, level) {
    //                    Log.db.transaction(
    //                        function(tx) {
    //                            tx.executeSql('INSERT INTO Profiles VALUES(?, ?)', [ name, level ]);
    //                            Log.level = level
    //                            Log.profName = inputProfName.text
    //                        }
    //                    )
    //                }
    //                anchors.fill: parent
    //                onPressed: parent.color = "lightgrey"
    //                onReleased: {
    //                    parent.color = "black"
    //                    createProf(inputProfName.text, 1);
    //                    createNewProf.visible = false
    //                    Log.VisProf = false;
    //                    Log.visMenu = true;
    //                }
    //            }
    //        }
    //    }

}
