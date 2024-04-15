// Star Tool
// Click and drag with this tool to create a star
// selection, to scale and rotate it, and to add it
// to the overlay. Click on a star and drag to move it.
// Alt click to remove it. Double click on the tool
// icon to open a dialog where you can set the star
// size, number of points, open the color picker or
// open a tree to decorate.

// Author: Jerome Mutterer

var button = 16;
var alt = 8;
var minSize = 16;
var nPoints = 5;
var ratio = 0.5;
var lineWidth = 2;
var fillStar = true;

macro "Star Tool - B1eC039T0f40*" {
    getCursorLoc(x, y, z, flags);
    x0=x; y0=y;
    // index = Overlay.indexAt(x,y);   // indexAt is present for 1.53 and above
    // index = "";
    // if (index>=0 && flags&alt!=0) {  // remove
    //     Overlay.removeSelection(index);
    //     exit;
    // }
    // if (index>=0) {  // move
    //    Overlay.activateSelection(index);
    //    Roi.getBounds(x,y,w,h);
    //    Roi.remove;
    //    while ((flags&button)!=0) {
    //       getCursorLoc(x, y, z, flags);
    //       Overlay.moveSelection(index, x-w/2, y-h/2);
    //       wait(20);
    //    }
    //    exit();
    // }
    // or create a new one
    makeLine (x0,y0,x0+1,y0+1);
    while ((flags&button)!=0) {
        getCursorLoc(x, y, z, flags);
        xs=newArray(nPoints*2);
        ys=newArray(nPoints*2);
        r = maxOf(minSize,sqrt((x-x0)*(x-x0)+(y-y0)*(y-y0)));
        a = atan2(x-x0,y-y0);
        for (i=0;i<nPoints;i++) {
            xs[i*2] = x0 + r*sin(a+i*2*PI/nPoints);
            xs[i*2+1] = x0 + ratio*r*sin(a+(i+0.5)*2*PI/nPoints);
            ys[i*2] = y0 + r*cos(a+i*2*PI/nPoints);
            ys[i*2+1] = y0 + ratio*r*cos(a+(i+0.5)*2*PI/nPoints);
        }
        makeSelection("polygon",xs,ys);
        Roi.setStrokeWidth(lineWidth);
        col = toHex(getValue("rgb.foreground")); 
        while (lengthOf(col)<6) col = "0"+col;
        Roi.setStrokeColor(col);
    }
    Overlay.addSelection;
    wait(20);
}

macro "Star Tool Options" {
    Dialog.create("Star Tool Options");
    Dialog.addNumber("Number of points:", nPoints);
    Dialog.addNumber("Minimum size:", minSize);
    Dialog.addNumber("Pointedness:", 1-ratio);
    Dialog.addNumber("Line width:", lineWidth);
    Dialog.addCheckbox("Fill star", fillStar);
    Dialog.addCheckbox("Open color picker", false);
    Dialog.addCheckbox("Open tree to decorate", false);
    Dialog.show();
    nPoints = Dialog.getNumber();
    minSize = Dialog.getNumber();
    ratio = 1 - Dialog.getNumber();
    if (ratio<0) ratio = 0;
    if (ratio>1) ratio = 1;
    lineWidth = Dialog.getNumber();
    fillStar = Dialog.getCheckbox;
    if (Dialog.getCheckbox)
        run("Color Picker...");
    if (Dialog.getCheckbox)
        open("http://wsr.imagej.net/download/Examples/Images/Tree.jpg");
}
