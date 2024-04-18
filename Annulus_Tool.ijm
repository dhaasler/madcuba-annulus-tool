/* 
 * Custom made tool to create an annular RoI in MADCUBA.
 * 
 * First create the outer oval by clicking and dragging, then create the inner oval by clicking and dragging while pressing alt. 
 * This version uses an overlay for the representation of the outer oval while drawing the inner one.
 *
 */

// Changelog
var version = "v4.9.0";
var date = "20240418";
var changelog = "Add astronomical coordinate systems";

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
var globalXcenter = 0;
var globalYcenter = 0;
var centerUnits = "Pixels";
var coordSystem = "ICRS";
var r1 = 10;
var r2 = 15;
var radiiUnits = "Pixels";
var unitsVal = "Pixels";

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
            dx = (xFits - globalXcenter);
            dy = (yFits - globalYcenter);
            r1 = sqrt(dx*dx + dy*dy);
            makeOval(globalXcenter-r1, globalYcenter-r1, r1*2, r1*2);
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
        globalXcenter = x3Fits + w/2;     // If trying to paint it with the Options Menu it will move the annulus slightly
        globalYcenter = y3Fits - h/2 + 1;     // because the menu paints with ovals that accept float values and rounds them later into integers
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
    globalXcenter = xcenter;
    globalYcenter = ycenter;
}

macro "Annulus Tool Options" {
    // transform everything to current units
    if (centerUnits == "Pixels") {
        newXcenter = globalXcenter;
        newYcenter = globalYcenter;
    }
    if (radiiUnits == "Pixels") {
        newr1 = r1;
        newr2 = r2;
    }
    if (centerUnits == "Degrees") {
        // cant be changed at once because globalXcenter is used in the next statement. We need proxy variables xdeg and ydeg
        xdeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordX", globalXcenter, globalYcenter, coordSystem);
        ydeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordY", globalXcenter, globalYcenter, coordSystem);
        newXcenter = d2s(xdeg,6);
        newYcenter = d2s(ydeg,6);
    }
    if (radiiUnits == "Degrees") {
        r1deg = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2deg = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        newr1 = d2s(r1deg,6);
        newr2 = d2s(r2deg,6);
    }
    if (centerUnits == "Arcmin") {
        xmin = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", globalXcenter, globalYcenter, coordSystem)) * 60;
        ymin = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", globalXcenter, globalYcenter, coordSystem)) * 60;
        newXcenter = xmin;
        newYcenter = ymin;
    }
    if (radiiUnits == "Arcmin") {
        newr1 = r1 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60;
        newr2 = r2 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60;
    }
    if (centerUnits == "Arcsec") {
        xsec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", globalXcenter, globalYcenter, coordSystem)) * 60 * 60;
        ysec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", globalXcenter, globalYcenter, coordSystem)) * 60 * 60;
        newXcenter = xsec;
        newYcenter = ysec;
    }
    if (radiiUnits == "Arcsec") {
        newr1 = r1 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60 * 60;
        newr2 = r2 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60 * 60;
    }
    if (centerUnits == "Radians") {
        xrad = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", globalXcenter, globalYcenter, coordSystem)) * PI/180.0;
        yrad = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", globalXcenter, globalYcenter, coordSystem)) * PI/180.0;
        newXcenter = d2s(xrad,8);
        newYcenter = d2s(yrad,8);
    }
    if (radiiUnits == "Radians") {
        r1rad = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2")) * PI/180.0;
        r2rad = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2")) * PI/180.0;
        newr1 = d2s(r1rad,8);
        newr2 = d2s(r2rad,8);
    }
    if (centerUnits == "Sexagesimal") {
        ra = call("CONVERT_PIXELS_COORDINATES.fits2CoordXString", globalXcenter, globalYcenter, coordSystem);
        dec = call("CONVERT_PIXELS_COORDINATES.fits2CoordYString", globalXcenter, globalYcenter, coordSystem);
        newXcenter = ra;
        newYcenter = dec;
    }
    // dialog layout
    availablecoordSystems = newArray("ICRS", "J2000", "B1950", "Gal", "E2000", "H2000");
    availableCenterUnits = newArray("Pixels", "Degrees", "Radians", "Arcmin", "Arcsec", "Sexagesimal");
    availableRadiiUnits = newArray("Pixels", "Degrees", "Radians", "Arcmin", "Arcsec");
    Dialog.create("Annulus Tool");
    actionOptions = newArray("Paint Annulus", "Transform Coordinates");
    Dialog.addRadioButtonGroup("Action", actionOptions, 1, 2, "Paint Annulus");
    Dialog.addChoice("Center units:", availableCenterUnits, centerUnits);
    Dialog.addToSameRow();
    Dialog.addChoice("", availablecoordSystems, coordSystem);
    Dialog.addString("X:", newXcenter, 15);
    Dialog.addString("Y:", newYcenter, 15);
    Dialog.addChoice("Radii units:", availableRadiiUnits, radiiUnits);
    Dialog.addString("Inner radius:", newr1, 10);
    Dialog.addString("Outer radius:", newr2, 10);
    html = "<html>"
    + "<center><h2>Annulus Tool</h2></center>"
    + "Click and drag mouse to create the outer radius of the annulus.<br>"
    + "Click and drag while pressing 'alt' to create the inner radius.<br>"
    + "Click and drag while pressing 'ctrl' to move the annular selection.<br><br>"
    + "To paint an annulus with given coordinates select the \"Paint<br>"
    + "Annulus\" option, select the desired units and coordinate system,<br>"
    + "and input the corresponding values.<br><br>"
    + "To convert the current parameters to other units or coordinate<br>"
    + "systems, select the \"Transform Coordinates\" option, select the<br>"
    + "desired units and coordinate system from the dropdown menus,<br>"
    + "and re-open the options window. Note that this option will ignore<br>"
    + "input values and will use the previously selected annulus.<br><br>"
    + "<h4>Changelog</h4>"
    + version + " - " + date + " <br>"
    + changelog;
    Dialog.addHelp(html);
    Dialog.show();
    // read data
    action = Dialog.getRadioButton();
    if (action == "Paint Annulus") {    // read new values, transform them back to pixels and paint
        centerUnits = Dialog.getChoice();
        coordSystem = Dialog.getChoice();
        newXcenter = Dialog.getString();
        newYcenter = Dialog.getString();
        radiiUnits = Dialog.getChoice();
        newr1temp = Dialog.getString();
        newr2 = Dialog.getString();
        // exit macro and print error if input r1 > r2
        if (parseFloat(newr1temp) > parseFloat(newr2)) {
            exit("Error: Inner radius cannot be bigger than the outer radius");
        } else newr1 = newr1temp;
        if (centerUnits == "Sexagesimal" && (coordSystem == "Gal" || coordSystem == "E2000" || coordSystem == "H2000")) {
            exit("Warning: Coordinate system " + coordSystem + " does not accept sexagesimal units");
        }
    } else {
        newCenterUnits = Dialog.getChoice();
        newCoordSystem = Dialog.getChoice();
        dumb1 = Dialog.getString();
        dumb2 = Dialog.getString();
        newRadiiUnits = Dialog.getChoice();
        dumb3 = Dialog.getNumber();
        dumb4 = Dialog.getNumber();
        if (newCenterUnits == "Sexagesimal" && (newCoordSystem == "Gal" || newCoordSystem == "E2000" || newCoordSystem == "H2000")) {
            exit("Warning: Coordinate system " + newCoordSystem + " does not accept sexagesimal units");
        }
    }
    // transform everything back to pixels
    if (centerUnits == "Pixels") {
        globalXcenter = newXcenter;
        globalYcenter = newYcenter;
    }
    if (radiiUnits == "Pixels") {
        r1 = parseFloat(newr1);
        r2 = parseFloat(newr2);
    }
    if (centerUnits == "Degrees") {
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", newXcenter, newYcenter, coordSystem);
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", newXcenter, newYcenter, coordSystem);
        globalXcenter = xpix;
        globalYcenter = ypix;
    }
    if (radiiUnits == "Degrees") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    }
    if (centerUnits == "Arcmin") {
        newXcenter = parseFloat(newXcenter) / 60;
        newYcenter = parseFloat(newYcenter) / 60;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", newXcenter, newYcenter, coordSystem);
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", newXcenter, newYcenter, coordSystem);
        globalXcenter = xpix;
        globalYcenter = ypix;
    }
    if (radiiUnits == "Arcmin") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60;
    }
    if (centerUnits == "Arcsec") {
        newXcenter = parseFloat(newXcenter) / 60 / 60;
        newYcenter = parseFloat(newYcenter) / 60 / 60;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", newXcenter, newYcenter, coordSystem);
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", newXcenter, newYcenter, coordSystem);
        globalXcenter = xpix;
        globalYcenter = ypix;
    }
    if (radiiUnits == "Arcsec") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60 / 60;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60 / 60;
    }
    if (centerUnits == "Radians") {
        newXcenter = parseFloat(newXcenter) * 180.0/PI;
        newYcenter = parseFloat(newYcenter) * 180.0/PI;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", newXcenter, newYcenter, coordSystem);
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", newXcenter, newYcenter, coordSystem);
        globalXcenter = xpix;
        globalYcenter = ypix;
    }
    if (radiiUnits == "Radians") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) * 180.0/PI;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) * 180.0/PI;
    }
    if (centerUnits == "Sexagesimal") {
        rapix = call("CONVERT_PIXELS_COORDINATES.coordString2FitsX", newXcenter, newYcenter, coordSystem);
        decpix = call("CONVERT_PIXELS_COORDINATES.coordString2FitsY", newXcenter, newYcenter, coordSystem);
        globalXcenter = rapix;
        globalYcenter = decpix;
    }
    // paint annulus from options menu
    paintAnnulus();
    // Update values
    if (action == "Transform Coordinates") {
        centerUnits = newCenterUnits;
        radiiUnits = newRadiiUnits;
        coordSystem = newCoordSystem;
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
    makeOval(globalXcenter-r2, globalYcenter-r2, r2*2, r2*2);
    setKeyDown("alt");
    makeOval(globalXcenter-r1, globalYcenter-r1, r1*2, r1*2);
    setKeyDown("none");
}
