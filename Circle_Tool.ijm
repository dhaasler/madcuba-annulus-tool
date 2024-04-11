// This macro tool creates a circular selection, moves
// it as long as the mouse button is down, and then 
// adds it to an overlay. Click on a circle and drag to
// move it. Alt click to remove it. Double click on 
// the tool icon to set the size of the circle.
// Double click on rectangle tool icon (left-most on toolbar)
// to set the default color and define the group names.
// There is more information about macro tools at
//   http://imagej.nih.gov/ij/developer/macro/macros.html#tools

var size = 20;
var leftButton = 16;
var alt = 8;
var strokeWidth = 2;
var group;
var measure;

macro "Circle Tool - C037 O00ee" {
    moving = false;
    getCursorLoc(x, y, z, flags);
    index = Overlay.indexAt(x,y);
    if (index>=0 && flags&alt!=0) {  // delete?
        Overlay.removeSelection(index);
        exit;
    }
    if (index>=0) {  // move
        Overlay.activateSelection(index);
        moving = true;
    }
    while (flags&leftButton!=0) {
        if (moving)
            Overlay.moveSelection(index, x-size/2, y-size/2);
        else {
            makeOval(x-size/2, y-size/2, size, size);
            Roi.setStrokeWidth(strokeWidth);
        }
        wait(25);
        getCursorLoc(x, y, z, flags);
    }
    if (!moving && Roi.size>0) {
        Roi.setGroup(group);
        Overlay.addSelection;
    }
    Roi.remove;
}

macro "Circle Tool Options" {
    Dialog.create("Circle Tool Options");
    Dialog.addNumber("Diameter", size);
    Dialog.addNumber("Stroke width", strokeWidth);
    Dialog.addNumber("Group", group);
    Dialog.addCheckbox("Measure:", measure);
    Dialog.show();
    size = Dialog.getNumber();
    strokeWidth = Dialog.getNumber();
    group = Dialog.getNumber();
    measure = Dialog.getCheckbox;
    if (measure)
        Overlay.measure;
    Roi.remove;
}
