var component;
var sprite;
var cellSize = 40;

function createField() {
    component = Qt.createComponent("cell.qml");


    if (component.status == Component.Ready) {
        for (var y = 0; y < cellSize * 25; y += cellSize) {
            for (var x = 0; x < cellSize * 40; x += cellSize) {
                sprite = component.createObject(field, {"x": x, "y": y});
            }
        }
    }
}

var allCells = [];
