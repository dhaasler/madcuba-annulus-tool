/* 
 * Custom made macro to create an annular RoI in MADCUBA.
 * First creates the outer oval, then by pressing alt and dragging, it creates the inner radius. 
 * This uses an overlay for the representation of the outer oval while drawing the inner one.
 *
 * In this first iteration the annulus is defined by the center of the circle [x, y], and by are inner and outer radii [r1, r2]:
 *     annulus [[x, y], [r1, r2]]
 */

// Global Variables
// Mouse values and flags
var x = 1;
var y = 1;
var z = 1;
var flags = "None";
var shift=1;
var ctrl=2;
var leftButton=16;
var rightButton=4;
var alt=8;

// Annulus parameters
var previousXcenter = 0;
var previousYcenter = 0;
var r1 = 10;
var r2 = 15;
var unitsVal = "pix";

var paint = false;
var corr = 0;

var updateValues = false;
var valuesUpdated = false;

macro "Annulus 2 Tool - C037 O00ee O22aa T6b082" {  // C037 O00ee O3388 final annulus icon
    getCursorLoc(x, y, z, flags);
    xFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));
    yFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
    xcenter = xFits; ycenter = yFits;
    if (valuesUpdated) {
        valuesUpdated = false;
    }
    if (flags&alt!=0) {     // enter here if pressing alt while click and dragging mouse
        Overlay.addSelection;       // add outer oval overlay while selecting inner oval
        while ((flags&leftButton)!=0) {
            getCursorLoc(x, y, z, flags);
            xFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));
            yFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
            dx = (xFits - previousXcenter);
            dy = (yFits - previousYcenter);
            r1 = sqrt(dx*dx + dy*dy);
            makeOval(previousXcenter-r1, previousYcenter-r1, r1*2, r1*2);
            wait(20);
        }
        Overlay.remove;     // delete outer oval overlay to create annulus
        paintAnnulus();
        exit;
    } else if (flags&ctrl!=0) {
        print("you pressed ctrl");
        getBoundingRect(x2, y2, w, h);
        x2Fits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x2));
        y2Fits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y2));
        getCursorLoc(x0, y0, z0, flags0);   // store information of where I first clicked inside the ROI
        x0Fits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x0));
        y0Fits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y0));
        while ((flags&leftButton)!=0) {
            getCursorLoc(x, y, z, flags);
            xFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));
            yFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
            dx = xFits - (x0Fits - x2Fits);     // calculate new the position inside the RoI after moving
            dy = yFits - (y0Fits - y2Fits) + 1;     // +1 because after clicking the selction moves 1 pixel down (may be a problem of coord transformation)
            setSelectionLocation(dx, dy);
            wait(20);
        }
        getBoundingRect(x3, y3, w, h);  // Currently this option moves the center with integers. 
        previousXcenter = x3 + w/2;     // If trying to paint it with the Options Menu it will move the annulus slightly
        previousYcenter = y3 + h/2;     // because the menu paints with ovals that accept float values and rounds them later into integers
        exit;
    }
    while ((flags&leftButton)!=0) {      // enter here if only clic and dragging mouse
        getCursorLoc(x, y, z, flags);
        xFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));
        yFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
        dx = (xFits - xcenter);
        dy = (yFits - ycenter);
        r2 = sqrt(dx*dx + dy*dy);
        makeOval(xcenter-r2, ycenter-r2, r2*2, r2*2);
        wait(20);
    }
    wait(10);
    previousXcenter = xcenter;
    previousYcenter = ycenter;
}

macro "Annulus 2 Tool Options" {
    // transform everything to current units
    if (unitsVal == "deg") {
        xdeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "");
        ydeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "");
        previousXcenter = xdeg;
        previousYcenter = ydeg;
        r1 = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    }
    // dialog layout
    Dialog.create("Annulus Properties");
    Dialog.addChoice("Units:", newArray("deg", "pix"), unitsVal);
    Dialog.addNumber("X:", previousXcenter);
    Dialog.addToSameRow();
    Dialog.addNumber("Y:", previousYcenter);
    Dialog.addNumber("Inner radius:", r1);
    Dialog.addNumber("Outer radius:", r2);
    Dialog.addCheckbox("Paint Region", paint);
    Dialog.addChoice("Update values", newArray("do not update", "pix", "deg"), "do not update");
    Dialog.show();
    // read data
    previousXcenter = Dialog.getNumber();
    previousYcenter = Dialog.getNumber();
    r1temp = Dialog.getNumber();
    r2 = Dialog.getNumber();
    unitsVal = Dialog.getChoice();
    paint = Dialog.getCheckbox();
    updateValuesTo = Dialog.getChoice();
    // exit macro and print error if input r1 > r2
    if (r1temp > r2) {
        setKeyDown("Esc");
        showMessage("Error", "Error: Inner radius cannot be bigger than the outer radius");
    } else r1 = r1temp;
    // transform everything back to pixels
    if (unitsVal == "deg") {
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", previousXcenter, previousYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", previousXcenter, previousYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
        r1 = r1 / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = r2 / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    }
    // paint annulus from options menu
    if (paint) {
        previousXcenterFits = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", previousXcenter);
        previousYcenterFits = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", previousYcenter);
        paintAnnulus();
    }
    // Update values
    valuesUpdated = false;  // for reruns of options after updating
    if (updateValuesTo != "do not update") {
        valuesUpdated = true;
        if (updateValuesTo == "deg") {
            unitsVal = "deg";
        }
        if (updateValuesTo == "pix") {
            unitsVal = "pix";
        }
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
    makeOval(previousXcenter-r2, previousYcenter-r2, r2*2, r2*2);
    setKeyDown("alt");
    makeOval(previousXcenter-r1, previousYcenter-r1, r1*2, r1*2);
    setKeyDown("none");
    }
