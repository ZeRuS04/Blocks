import QtQuick 2.0

Rectangle {
    id: block
    color: "green"
    width: parent.width/5
    height: parent.height-10
    radius: 10

    property int speed: 0
    property int leftX: x
    property int rightX: x+width
    property bool direction: true
}
