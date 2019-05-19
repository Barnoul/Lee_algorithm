import QtQuick 2.12
import QtQuick.Window 2.12
import "cursor.js" as Cursor

Rectangle {
    id: cell
    width: 40
    height: 40
    color: "lightgrey"
    border.color: "black"
    border.width: 1
    property int cost: 0
    property int status: 0 // 0 - blank, 1 - wall, 2 - start, 3 - finish, 4 - path
    property int num: 0
    property bool visited: false
    property bool path: false
}

