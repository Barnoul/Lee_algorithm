import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQuick.Dialogs 1.2
import "grid.js" as Grid
import "cursor.js" as Cursor


/*
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
}

var allCels = new Array();
*/

Window {
    id: root
    visible: true
    width: 1600
    height: 1000
    title: "Lee algorithm"

    Rectangle {
        Component.onCompleted: Grid.createField()
        id: field
        width: 1600
        height: 1000
        color: "grey"
        property var currentTile
        MouseArea {
            id: mouseArea
            focus: true
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            property bool isStartPlaced: false
            property bool isFinishPlaced: false
            property int startIndex: 0
            property int finishIndex: 0

            onEntered: {
                mouseArea.focus = true
                for (var y = 0; y <= 24; y += 1) {
                    for (var x = 0; x <= 39; x += 1) {
                        var currentTile = field.childAt(x * 40, y * 40);
                        currentTile.num = x + y;
                        Grid.allCells.push(currentTile);
                    }
                }
            }

            onClicked: {
                mouseArea.focus = true;
                var position = mapToItem(field, mouseArea.mouseX, mouseArea.mouseY);
                var clickedTile = field.childAt(position.x, position.y);
                clickedTile.num = Math.floor(position.x / 40) + Math.floor(position.y / 40) * 40;
                console.log("tile num " + clickedTile.num);
                console.log("tile cost " + Grid.allCells[clickedTile.num].cost);
                console.log("start " + startIndex)
                console.log("finish " + finishIndex)

                //Mark as Wall
                if (Qt.LeftButton && Cursor.cursorStatus == 1) {
                    Grid.allCells[clickedTile.num].color = "black"
                    Grid.allCells[clickedTile.num].status = 1
                    Grid.allCells[clickedTile.num].cost = 100000
                }

                //Mark as Start
                else if (isStartPlaced == false && Qt.LeftButton && Cursor.cursorStatus == 2) {
                    Grid.allCells[clickedTile.num].color = "red"
                    Grid.allCells[clickedTile.num].status = 2
                    startIndex = clickedTile.num

                    isStartPlaced = true
                }
                //Mark as Finish
                else if (isFinishPlaced == false && Qt.LeftButton && Cursor.cursorStatus == 3) {
                    Grid.allCells[clickedTile.num].color = "blue"
                    Grid.allCells[clickedTile.num].status = 3
                    finishIndex = clickedTile.num

                    isFinishPlaced = true
                }

                //Mark as blank
                else if (Qt.LeftButton && Cursor.cursorStatus == 0) {
                    Grid.allCells[clickedTile.num].color = "lightgrey"
                    Grid.allCells[clickedTile.num].status = 0
                    Grid.allCells[clickedTile.num].cost = 0
                    if (clickedTile.num == startIndex) {
                        isStartPlaced = false
                    }
                    if (clickedTile.num == finishIndex) {
                        isFinishPlaced = false
                    }
                }

                //Plain cursor
                else if (Qt.LeftButton && Cursor.cursorStatus == 4) {
                    console.log("tile status " + Grid.allCells[clickedTile.num].status);
                }
            }
        }

    }

    function check(parentIndex, newIndex) {
        if (0 <= newIndex && newIndex <= 999 && !Grid.allCells[newIndex].visited &&
                !(newIndex % 40 == 0 && parentIndex % 40 == 39 || newIndex % 40 == 39 && parentIndex % 40 == 0)) {
            if (!Grid.allCells[newIndex].status == 1) {
                if (Grid.allCells[newIndex].cost > 0) {
                    Grid.allCells[newIndex].cost = Math.min(Grid.allCells[newIndex].cost, Grid.allCells[parentIndex].cost + 1);
                }
                else {
                    console.log("tile type " + Grid.allCells[newIndex]);
                    Grid.allCells[newIndex].cost = Grid.allCells[parentIndex].cost + 1;
                }
                Grid.allCells[newIndex].visited = true;
                return true
            }
            else {
                return false
            }
        }
    }

    function check2(newIndex) {
        if (0 <= newIndex && newIndex <= 999 && newIndex != mouseArea.finishIndex) {
            return true;
        }
        return false;
    }

    function lee(start) {
        var q = [];
        var currentIndex = start
        console.log("starttile " + start)
        q.push(currentIndex);

        while (q.length > 0) {
            currentIndex = q[0];
            q.shift();
            console.log("current tile " + currentIndex);
            if (check(currentIndex, currentIndex - 40)) {
                q.push(currentIndex - 40);
            }
            if (check(currentIndex, currentIndex + 40)) {
                q.push(currentIndex + 40);
            }
            if (check(currentIndex, currentIndex - 1)) {
                q.push(currentIndex - 1);
            }
            if (check(currentIndex, currentIndex + 1)) {
                q.push(currentIndex + 1);
            }
        }
    }


    function reset() {
        for (var i = 0; i < 1000; i += 1) {
            Grid.allCells[i].cost = 0;
            Grid.allCells[i].status = 0;
            Grid.allCells[i].color = "lightgrey";
            Grid.allCells[i].visited = false;
        }
        mouseArea.isStartPlaced = false;
        mouseArea.isFinishPlaced = false;
        mouseArea.startIndex = 0;
        mouseArea.finishIndex = 0;
        impossible.visible = false;
    }


    function pathBack(finish) {
        var filter = [];
        var directions = [];
        var nextTile = -1;
        var minCost;
        while (nextTile != mouseArea.startIndex) {
            if (check2(finish - 40)) {
                filter.push(Grid.allCells[finish - 40].cost);
                directions.push(finish - 40);
            }
            if (check2(finish - 1)) {
                filter.push(Grid.allCells[finish - 1].cost);
                directions.push(finish - 1);
            }
            if (check2(finish + 1)) {
                filter.push(Grid.allCells[finish + 1].cost);
                directions.push(finish + 1);
            }
            if (check2(finish + 40)) {
                filter.push(Grid.allCells[finish + 40].cost);
                directions.push(finish + 40);
            }
            minCost = Math.min(...filter);
            console.log("mincost " + minCost);
            nextTile = directions[filter.indexOf(minCost)];
            console.log("nexttile " + nextTile);
            if (minCost > 0) {
                Grid.allCells[nextTile].color = "green";
                Grid.allCells[nextTile].path = true;
            }

            filter = [];
            directions = [];
            finish = nextTile;
            if (minCost == 0) {
                return;
            }
        }

    }
    /*
    Text {
        id: impossible
        font.pointSize: 40
        visible: false
        color: "red"
        text: "IMPOSSIBLE"
    }
    */
    Rectangle {
        id: menu
        height: 440
        width: 120
        opacity: 0.9
        color: "#606060"
        anchors {
            top: parent.top
            left: parent.left
        }

        Button {
            id: buttonStart
            height: 30
            width: 80
            text: "Place Start"
            anchors {
                left: parent.left
                top: parent.top
                margins: 20
            }

            onClicked: {
                Cursor.cursorStatus = 2
                console.log("status = " + Cursor.cursorStatus)
            }
        }

        Button {
            id: buttonWall
            height: 30
            width: 80
            text: "Place Wall"
            anchors {
                left: parent.left
                top: buttonStart.bottom
                margins: 20
            }

            onClicked: {
                Cursor.cursorStatus = 1
                console.log("status = " + Cursor.cursorStatus)
            }
        }

        Button {
            id: buttonFinish
            height: 30
            width: 80
            text: "Place Finish"
            anchors {
                left: parent.left
                top: buttonWall.bottom
                margins: 20
            }

            onClicked: {
                Cursor.cursorStatus = 3
                console.log("status = " + Cursor.cursorStatus)
            }
        }

        Button {
            id: buttonBlank
            height: 30
            width: 80
            text: "Place Blank"
            anchors {
                left: parent.left
                top: buttonFinish.bottom
                margins: 20
            }

            onClicked: {
                Cursor.cursorStatus = 0
                console.log("status = " + Cursor.cursorStatus)
            }
        }

        Button {
            id: plainCursor
            height: 30
            width: 80
            text: "Cursor"
            anchors {
                left: parent.left
                top: buttonBlank.bottom
                margins: 20
            }
            onClicked: {
                Cursor.cursorStatus = 4
                console.log("status = " + Cursor.cursorStatus)
            }
        }


        Button {
            id: buttonReset
            height: 50
            width: 80
            text: "Reset"
            anchors {
                left: parent.left
                bottom: parent.bottom
                margins: 20
            }
            onClicked: reset();
        }


        Button {
            id: buttonGo
            height: 50
            width: 80
            text: "Go"
            anchors {
                left: parent.left
                bottom: buttonReset.top
                margins: 20
            }
            onClicked: {
                lee(mouseArea.startIndex);
                pathBack(mouseArea.finishIndex);
                /*
                var ct = 0;
                for (var i = 0; i < 1000; i += 1) {
                    if (Grid.allCells[i].color == "green") {
                        ct += 1;
                    }
                }
                if (ct ==  0) {
                    impossible.visible = true;
                }
                */
            }
        }
    }
}

