import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQuick.Dialogs 1.2
import "grid.js" as Grid
import "cursor.js" as Cursor

Window {
    id: root
    visible: true
    width: 1920
    height: 1020
    title: "Lee algorithm"
    /*
    Flickable {
        id: flickArea
        contentHeight: field.height
        contentWidth: field.width
        Component.onCompleted: Grid.createField()
    */
        Rectangle {
            id: field
            width: 3000
            height: 3000
            color: "lightgrey"
            property var currentTile
            Component.onCompleted: Grid.createField()

            MouseArea {
                id: mouseArea
                focus: true
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                /*
                drag.target: field
                drag.axis: Drag.XAndYAxis
                drag.minimumX: root.width - field.width
                drag.maximumX: 0
                drag.minimumY: root.height - field.height
                drag.maximumY: 0
                */
                property bool isStartPlaced: false
                property bool isFinishPlaced: false
                property int startIndex: 0
                property int finishIndex: 0

                onEntered: {
                    mouseArea.focus = true
                    for (var y = 0; y < Grid.colSize; y += 1) {
                        for (var x = 0; x < Grid.rowSize; x += 1) {
                            var currentTile = field.childAt(x * 30, y * 30);
                            currentTile.num = x + y;
                            Grid.allCells.push(currentTile);
                        }
                    }
                }

                onClicked: {
                    mouseArea.focus = true;
                    var position = mapToItem(field, mouseArea.mouseX, mouseArea.mouseY);
                    var clickedTile = field.childAt(position.x, position.y);
                    clickedTile.num = Math.floor(position.x / 30) + Math.floor(position.y / 30) * Grid.rowSize;
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
                        console.log("path? " + Grid.allCells[clickedTile.num].path);
                    }

                    //Mark as sand
                    else if (Qt.LeftButton && Cursor.cursorStatus == 5) {
                        Grid.allCells[clickedTile.num].color = "#FFE400"
                        Grid.allCells[clickedTile.num].status = 5
                    }
                }
            }
        }
    //}

    function increase(index, mark) {
        Grid.allCells[index].cost += mark;
    }

    function check(parentIndex, newIndex) {
        if (0 <= newIndex && newIndex <= Grid.rowSize*Grid.colSize && !Grid.allCells[newIndex].visited &&
                !(newIndex % Grid.rowSize == 0 && parentIndex % Grid.rowSize == (Grid.rowSize-1) || newIndex % Grid.rowSize == (Grid.rowSize-1) && parentIndex % Grid.rowSize == 0)) {
            if (Grid.allCells[newIndex].status == 0 || Grid.allCells[newIndex].status == 3) {
                increase(newIndex, Grid.allCells[parentIndex].cost + 1);
                Grid.allCells[newIndex].visited = true;
                return true;
            }
            if (Grid.allCells[newIndex].status == 5) {
                increase(newIndex, Grid.allCells[parentIndex].cost + 2);
                Grid.allCells[newIndex].visited = true;
                return true;
            }
            else {
                return false;
            }
        }
    }

    function lee(start) {
        var q = [];
        var currentIndex = start
        var row = [-Grid.rowSize, 0, 0, Grid.rowSize];
        var col = [0, -1, 1, 0]
        console.log("starttile " + start)
        q.push(currentIndex);
        while (q.length > 0) {
            currentIndex = q[0];
            q.shift();
            console.log("current tile " + currentIndex);
            for (var k = 0; k < 4; k += 1) {
                if (check(currentIndex, currentIndex + row[k] + col[k])) {
                    q.push(currentIndex + row[k] + col[k]);
                }
            }
        }
    }

    function generate() {
        for (var i = 0; i < Grid.rowSize*Grid.colSize; i += 1) {
            if (Math.random() > 0.55) {
                Grid.allCells[i].status = 1
                Grid.allCells[i].color = "black";
            }
        }

        for (var i = 0; i < Grid.rowSize*Grid.colSize; i += 1) {
            if (Grid.allCells[i].status != 1 && Math.random() > 0.85) {
                Grid.allCells[i].status = 5;
                Grid.allCells[i].color = "#FFE400";
            }
        }
    }

    function resetGrid(x) {
        Grid.allCells[x].cost = 0;
        Grid.allCells[x].status = 0;
        Grid.allCells[x].color = "lightgrey";
        Grid.allCells[x].visited = false;
        Grid.allCells[x].path = false;
        mouseArea.isStartPlaced = false;
        mouseArea.isFinishPlaced = false;
        mouseArea.startIndex = 0;
        mouseArea.finishIndex = 0;
        //impossible.visible = false;
    }

    function resetPath() {
        for (var i = 0; i < Grid.colSize*Grid.rowSize; i += 1) {
            if (Grid.allCells[i].status != 1 && Grid.allCells[i].status != 5) {
                resetGrid(i)
            }
            if (Grid.allCells[i].status == 5) {
                resetGrid(i)
                Grid.allCells[i].status = 5
                Grid.allCells[i].color = "yellow"
            }
        }
    }

    function check2(oldIndex, newIndex) {
        if (0 <= newIndex && newIndex <= Grid.rowSize*Grid.colSize && Grid.allCells[newIndex].status != 1
                && Grid.allCells[newIndex].cost < Grid.allCells[oldIndex].cost && !Grid.allCells[newIndex].path) {
            return true;
        }
        return false;
    }

    function pathBack(finish) {
        var minCost = Grid.allCells[finish].cost;
        var step;
        var next = finish;
        var row = [-Grid.rowSize, 0, 0, Grid.rowSize];
        var col = [0, -1, 1, 0]
        while (next != mouseArea.startIndex) {
            step = false
            for (var k = 0; k < 4; k += 1) {
                if (check2(next, next + row[k] + col[k]) && !step) {
                    next += row[k] + col[k];
                    Grid.allCells[next].path = true;
                    console.log(next);
                    step = true;
                }
            }
            Grid.allCells[next].color = "green";
            Grid.allCells[next].path = true;
            console.log("mincost " + minCost);
            console.log("nexttile " + next);
            if (next == mouseArea.startIndex) {
                Grid.allCells[mouseArea.startIndex].color = "red";
                return;
            }
        }
    }

    /*
    Text {
        id: impossible
        font.pointSize: Grid.rowSize
        visible: false
        color: "red"
        text: "IMPOSSIBLE"
    }
    */

    Rectangle {
        id: menu
        height: 600
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
            }
        }

        Button {
            id: buttonSand
            height: 30
            width: 80
            text: "Place Sand"
            anchors {
                left: parent.left
                top: buttonWall.bottom
                margins: 20
            }
            onClicked: {
                Cursor.cursorStatus = 5
            }
        }

        Button {
            id: buttonFinish
            height: 30
            width: 80
            text: "Place Finish"
            anchors {
                left: parent.left
                top: buttonSand.bottom
                margins: 20
            }

            onClicked: {
                Cursor.cursorStatus = 3
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
            }
        }

        Button {
            id: buttonRandom
            height: 30
            width: 80
            text: "Random"
            anchors {
                left: parent.left
                top: plainCursor.bottom
                margins: 20
            }
            onClicked: {
                generate();
            }
        }

        Button {
            id: buttonResetPath
            height: 50
            width: 80
            text: "Reset Path"
            anchors {
                left: parent.left
                bottom: parent.bottom
                margins: 20
            }
            onClicked: resetPath();
        }

        Button {
            id: buttonResetGrid
            height: 50
            width: 80
            text: "Reset grid"
            anchors {
                left: parent.left
                bottom: buttonResetPath.top
                margins: 20
            }
            onClicked: {
                for (var i = 0; i < Grid.rowSize*Grid.colSize; i += 1) {
                    resetGrid(i);
                }
            }
        }

        Button {
            id: buttonGo
            height: 50
            width: 80
            text: "Go"
            anchors {
                left: parent.left
                bottom: buttonResetGrid.top
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
