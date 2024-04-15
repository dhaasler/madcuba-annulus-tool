/* 
 * Custom made macro to create an annular RoI in MADCUBA.
 * First creates the outer oval, then by pressing alt and dragging, it creates the inner radius. 
 * This uses an overlay for the representation of the outer oval while drawing the inner one.
 *
 * In this first iteration the annulus is defined by the center of the circle [x, y], and by are inner and outer radii [r1, r2]:
 *     annulus [[x, y], [r1, r2]]
 */

// Global Variables
var x = 1;
var y = 1;
var z = 1;
var flags = "None";
var shift=1;
var ctrl=2;
var leftButton=16;
var rightButton=4;
var alt=8;

var r1 = 10;
var r2 = 15;
var unitsVal = "pix";

var paint = false;
var corr = 0;

var previousXcenter = 0;
var previousYcenter = 0;

macro "Annulus 2 Tool - C037 O00ee O22aa T6b082" {  // C037 O00ee O3388 final annulus icon
    getCursorLoc(x, y, z, flags);
    xcenter = x; ycenter = y;
    if (flags&alt!=0) {     // enter here if pressing alt while click and dragging mouse
        Overlay.addSelection;       // add outer oval overlay while selecting inner oval
        while ((flags&leftButton)!=0) {
            getCursorLoc(x, y, z, flags);
            dx = (x - previousXcenter);
            dy = (y - previousYcenter);
            r1 = sqrt(dx*dx + dy*dy);
            previousXcenterFits = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", previousXcenter);    // getBoundingRect and getCursorLoc use ImageJ coords
            previousYcenterFits = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", previousYcenter);    // it is easier to just change to fits when drawing
            makeOval(previousXcenterFits-r1, previousYcenterFits-r1, r1*2, r1*2);
            wait(20);
        }
        Overlay.remove;     // delete outer oval overlay to create annulus
        paintAnnulus();
        exit;
    } else if (flags&ctrl!=0) {
        print("you pressed ctrl");
        getBoundingRect(x2, y2, w, h);
        getCursorLoc(x0, y0, z0, flags0);   // store information of where I first clicked inside the ROI
        while ((flags&leftButton)!=0) {
            getCursorLoc(x, y, z, flags);
            dx = x - (x0 - x2);     // calculate new the position inside the RoI after moving
            dy = y - (y0 - y2) - 1;     // -1 because after clicking the selction moves 1 pixel down (may be a problem of coord transformation)
            dxFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", dx));
            dyFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", dy));
            setSelectionLocation(dxFits, dyFits);
            wait(20);
        }
        getBoundingRect(x3, y3, w, h);  // Currently this option moves the center with integers. 
        previousXcenter = x3 + w/2;     // If trying to paint it with the Options Menu it will move the annulus slightly
        previousYcenter = y3 + h/2;     // because the menu paints with ovals that accept float values and rounds them later into integers
        exit;
    }
    while ((flags&leftButton)!=0) {      // enter here if only clic and dragging mouse
        getCursorLoc(x, y, z, flags);
        dx = (x - xcenter);
        dy = (y - ycenter);
        r2 = sqrt(dx*dx + dy*dy);
        xcenterFits = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", xcenter);    // getBoundingRect and getCursorLoc use ImageJ coords
        ycenterFits = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", ycenter);    // it is easier to just change to fits when drawing
        makeOval(xcenterFits-r2, ycenterFits-r2, r2*2, r2*2);
        wait(20);
    }
    wait(10);
    previousXcenter = xcenter;
    previousYcenter = ycenter;
}

macro "Annulus 2 Tool Options" {
    Dialog.create("Annulus Properties");
    Dialog.addChoice("Units:", newArray("deg", "pix"), unitsVal);
    Dialog.addNumber("X:", previousXcenter);
    Dialog.addToSameRow() 
    Dialog.addNumber("Y:", previousYcenter);
    Dialog.addNumber("Inner radius:", r1);
    Dialog.addNumber("Outer radius:", r2);
    Dialog.addCheckbox("Paint Region", paint);
    Dialog.show();

    previousXcenter = Dialog.getNumber();
    previousYcenter = Dialog.getNumber();
    r1temp = Dialog.getNumber();
    r2 = Dialog.getNumber();
    unitsVal = Dialog.getChoice();
    paint = Dialog.getCheckbox();
    if (r1temp > r2) {
        // exit macro and print error if input r1 > r2
        setKeyDown("Esc");
        showMessage("Error", "Error: Inner radius cannot be bigger than the outer radius");
    } else r1 = r1temp;
    if (paint) {
        previousXcenterFits = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", previousXcenter);
        previousYcenterFits = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", previousYcenter);
        paintAnnulus();
    }
}

/*
 * ---------------------------------
 * ---------------------------------
 * ------ AUXILIARY FUNCTIONS ------
 * ---------------------------------
 * ---------------------------------
 */

function paintAnnulus() {
    if (unitsVal == "pix") {
        makeOval(previousXcenterFits-r2, previousYcenterFits-r2, r2*2, r2*2);
        setKeyDown("alt");
        makeOval(previousXcenterFits-r1, previousYcenterFits-r1, r1*2, r1*2);
        setKeyDown("none");
    } else if (unitsVal == "deg") {
        test = 0
    }
}

function moveAnnulus() {

}