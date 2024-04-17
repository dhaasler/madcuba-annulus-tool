/* 
 * Custom made tool to create an annular RoI in MADCUBA.
 * 
 * First create the outer oval by clicking and dragging, then create the inner oval by clicking and dragging while pressing alt. 
 * This version uses an overlay for the representation of the outer oval while drawing the inner one.
 *
 */

// Changelog
var version = "v4.8.1";
var date = "20240417";
var changelog = "Add sexagesimal coordinates<br>"
              + "Hotfix: fix exception error when closing options and opening again";

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
var centerUnits = "pix";
var r1 = 10;
var r2 = 15;
var radiiUnits = "pix";
var unitsVal = "pix";

var corr = 0;

macro "Annulus Tool - C037 O00ee O3388" {  // C037 O00ee O3388 final annulus icon
    getCursorLoc(x, y, z, flags);
    xFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));
    yFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
    xcenter = xFits; ycenter = yFits;
    if (flags&alt!=0) {     // enter here if pressing alt while click and dragging mouse
        if (selectionType == -1) {  // abort macro if no outer selection is present when trying to create inner radius
            exit("Error: Inner radius cannot be created without an outer radius present. Create one first.");
        }
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
    } else if (flags&ctrl!=0) {     // first calculate the new location using ImageJ coordinates. Then set it using Fits coords
        if (selectionType == -1) {  // abort macro if no outer selection is present when trying to create inner radius
            exit("Error: Cannot move selection. There is no selection present");
        }
        getBoundingRect(x2, y2, w, h);
        getCursorLoc(x0, y0, z0, flags0);   // store information of where I first clicked inside the ROI
        while ((flags&leftButton)!=0) {
            getCursorLoc(x, y, z, flags);
            dx = x - (x0 - x2);     // calculate new the position inside the RoI after moving
            dy = y - (y0 - y2) - 1;     // -1 because after clicking, the selection moves 1 pixel down (may be a problem of coord transformation)
            dxFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", dx));
            dyFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", dy));
            setSelectionLocation(dxFits, dyFits);   // this option moves the center with integers.
            wait(20);
        }
        getBoundingRect(x3, y3, w, h);
        x3Fits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x3));
        y3Fits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y3));
        previousXcenter = x3Fits + w/2;     // If trying to paint it with the Options Menu it will move the annulus slightly
        previousYcenter = y3Fits - h/2 + 1;     // because the menu paints with ovals that accept float values and rounds them later into integers
        // +1 because of problems converting from ImageJ to Fits
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

macro "Annulus Tool Options" {
    // transform everything to current units
    if (centerUnits == 'pix') {
        newXcenter = previousXcenter;
        newYcenter = previousYcenter;
    }
    if (radiiUnits == 'pix') {
        newr1 = r1;
        newr2 = r2;
    }
    if (centerUnits == "deg") {
        // cant be changed at once because previousXcenter is used in the next statement. We need proxy variables xdeg and ydeg
        xdeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "");
        ydeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "");
        newXcenter = d2s(xdeg,6);
        newYcenter = d2s(ydeg,6);
    }
    if (radiiUnits == "deg") {
        r1deg = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2deg = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        newr1 = d2s(r1deg,6);
        newr2 = d2s(r2deg,6);
    }
    if (centerUnits == "arcmin") {
        xmin = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "")) * 60;
        ymin = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "")) * 60;
        newXcenter = xmin;
        newYcenter = ymin;
    }
    if (radiiUnits == "arcmin") {
        newr1 = r1 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60;
        newr2 = r2 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60;
    }
    if (centerUnits == "arcsec") {
        xsec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "")) * 60 * 60;
        ysec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "")) * 60 * 60;
        newXcenter = xsec;
        newYcenter = ysec;
    }
    if (radiiUnits == "arcsec") {
        newr1 = r1 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60 * 60;
        newr2 = r2 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60 * 60;
    }
    if (centerUnits == "rad") {
        xrad = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "")) * PI/180.0;
        yrad = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "")) * PI/180.0;
        newXcenter = d2s(xrad,8);
        newYcenter = d2s(yrad,8);
    }
    if (radiiUnits == "rad") {
        r1rad = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2")) * PI/180.0;
        r2rad = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2")) * PI/180.0;
        newr1 = d2s(r1rad,8);
        newr2 = d2s(r2rad,8);
    }
    if (centerUnits == "sexagesimal") {
        ra = call("CONVERT_PIXELS_COORDINATES.fits2CoordXString", previousXcenter, previousYcenter,"");
        dec = call("CONVERT_PIXELS_COORDINATES.fits2CoordYString", previousXcenter, previousYcenter,"");
        newXcenter = ra;
        newYcenter = dec;
    }
    // dialog layout
    availableCenterUnits = newArray("deg", "rad", "arcmin", "arcsec", "sexagesimal", "pix");
    availableRadiiUnits = newArray("deg", "rad", "arcmin", "arcsec", "pix");
    Dialog.create("Annulus Tool");
    actionOptions = newArray("Paint Annulus", "Convert Units");
    Dialog.addRadioButtonGroup("Action", actionOptions, 1, 2, "Paint Annulus");
    Dialog.addChoice("Center units:", availableCenterUnits, centerUnits);
    Dialog.addString("Center   X:", newXcenter,15);
    // Dialog.addToSameRow();
    Dialog.addString("Y:", newYcenter,15);
    Dialog.addChoice("Radii units:", availableRadiiUnits, radiiUnits);
    Dialog.addString("Inner radius:", newr1,10);
    Dialog.addString("Outer radius:", newr2,10);
    html = "<html>"
    + "<center><h2>Annulus Tool</h2></center>"
    + "Click and drag mouse to create the outer radius of the annulus.<br>"
    + "Click and drag while pressing 'alt' to create the inner radius.<br>"
    + "Click and drag while pressing 'ctrl' to move the annular selection.<br><br>"
    + "To paint an annulus with given coordinates select the \"Paint<br>"
    + "Annulus\" option, select the units with which to work, and input the<br>"
    + "corresponding values.<br><br>"
    + "To convert the current parameters to another units, select the<br>"
    + "\"Convert units\" option, select the desired units from the dropdown<br>"
    + "menus, and re-open the options window. Note that this option will<br>"
    + "ignore input values and will use the previously selected annulus.<br><br>"
    + "<h4>Changelog</h4>"
    + version + " - " + date + " <br>"
    + changelog;
    Dialog.addHelp(html);
    Dialog.show();
    // read data
    action = Dialog.getRadioButton();
    if (action == "Paint Annulus") {    // read new values, transform them back to pixels and paint
        centerUnits = Dialog.getChoice();
        newXcenter = Dialog.getString();
        newYcenter = Dialog.getString();
        radiiUnits = Dialog.getChoice();
        newr1temp = Dialog.getString();
        newr2 = Dialog.getString();
        // exit macro and print error if input r1 > r2
        if (parseFloat(newr1temp) > parseFloat(newr2)) {
            exit("Error: Inner radius cannot be bigger than the outer radius");
        } else newr1 = newr1temp;
    } else {
        newCenterUnits = Dialog.getChoice();
        dumb1 = Dialog.getString();
        dumb2 = Dialog.getString();
        newRadiiUnits = Dialog.getChoice();
        dumb3 = Dialog.getNumber();
        dumb4 = Dialog.getNumber();
    }
    // transform everything back to pixels
    if (centerUnits == 'pix') {
        previousXcenter = newXcenter;
        previousYcenter = newYcenter;
    }
    if (radiiUnits == 'pix') {
        r1 = newr1;
        r2 = newr2;
    }
    if (centerUnits == "deg") {
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", newXcenter, newYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", newXcenter, newYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
    }
    if (radiiUnits == "deg") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    }
    if (centerUnits == "arcmin") {
        newXcenter = parseFloat(newXcenter) / 60;
        newYcenter = parseFloat(newYcenter) / 60;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", newXcenter, newYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", newXcenter, newYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
    }
    if (radiiUnits == "arcmin") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60;
    }
    if (centerUnits == "arcsec") {
        newXcenter = parseFloat(newXcenter) / 60 / 60;
        newYcenter = parseFloat(newYcenter) / 60 / 60;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", newXcenter, newYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", newXcenter, newYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
    }
    if (radiiUnits == "arcsec") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60 / 60;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60 / 60;
    }
    if (centerUnits == "rad") {
        newXcenter = parseFloat(newXcenter) * 180.0/PI;
        newYcenter = parseFloat(newYcenter) * 180.0/PI;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", newXcenter, newYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", newXcenter, newYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
    }
    if (radiiUnits == "rad") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) * 180.0/PI;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) * 180.0/PI;
    }
    if (centerUnits == "sexagesimal") {
        rapix = call("CONVERT_PIXELS_COORDINATES.coordString2FitsX", newXcenter, newYcenter, "");
        decpix = call("CONVERT_PIXELS_COORDINATES.coordString2FitsY", newXcenter, newYcenter, "");
        previousXcenter = rapix;
        previousYcenter = decpix;
    }
    // paint annulus from options menu
    paintAnnulus();
    // Update values
    if (action == "Convert Units") {
        centerUnits = newCenterUnits;
        radiiUnits = newRadiiUnits;
    }
}

/*
 * ---------------------------------
 * ---------------------------------
 * ------ AUXILIARY FUNCTIONS ------
 * ---------------------------------
 * ---------------------------------
 */

/**
 * Paint an annulus using global variables.
 */
function paintAnnulus() {
    makeOval(previousXcenter-r2, previousYcenter-r2, r2*2, r2*2);
    setKeyDown("alt");
    makeOval(previousXcenter-r1, previousYcenter-r1, r1*2, r1*2);
    setKeyDown("none");
}
