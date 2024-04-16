/* 
 * Custom made macro to create an annular RoI in MADCUBA.
 * First creates the outer oval, then by pressing alt and dragging, it creates the inner radius. 
 * This uses an overlay for the representation of the outer oval while drawing the inner one.
 *
 * In this first iteration the annulus is defined by the center of the circle [x, y], and by are inner and outer radii [r1, r2]:
 *     annulus [[x, y], [r1, r2]]
 */

// Changelog
var version = "v4.6.0";
var date = "20240416";
var changelog = "Add arcmin and arcsec as available units<br>";

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

macro "Annulus 2 Tool - C037 O00ee O22aa T6b082" {  // C037 O00ee O3388 final annulus icon
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

macro "Annulus 2 Tool Options" {
    // transform everything to current units
    if (centerUnits == "deg") {
        // cant be changed at once because previousXcenter is used in the next statement. We need proxy variables xdeg and ydeg
        xdeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "");
        ydeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "");
        previousXcenter = xdeg;
        previousYcenter = ydeg;
    }
    if (radiiUnits == "deg") {
        r1 = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    }
    if (centerUnits == "arcmin") {
        xmin = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "")) * 60;
        ymin = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "")) * 60;
        previousXcenter = xmin;
        previousYcenter = ymin;
    }
    if (radiiUnits == "arcmin") {
        r1 = r1 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60;
        r2 = r2 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60;
    }
    if (centerUnits == "arcsec") {
        xsec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "")) * 60 * 60;
        ysec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "")) * 60 * 60;
        previousXcenter = xsec;
        previousYcenter = ysec;
    }
    if (radiiUnits == "arcsec") {
        r1 = r1 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60 * 60;
        r2 = r2 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60 * 60;
    }
    if (centerUnits == "rad") {
        xrad = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", previousXcenter, previousYcenter, "")) * PI/180.0;
        yrad = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", previousXcenter, previousYcenter, "")) * PI/180.0;
        previousXcenter = xrad;
        previousYcenter = yrad;
    }
    if (radiiUnits == "rad") {
        r1rad = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2")) * PI/180.0;
        r2rad = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2")) * PI/180.0;
        r1 = r1rad;
        r2 = r2rad;
    }
    // dialog layout
    availableUnits = newArray("deg", "rad", "arcmin", "arcsec", "pix");
    Dialog.create("Annulus Tool");
    actionOptions = newArray("Paint Annulus", "Convert Units");
    Dialog.addRadioButtonGroup("Action", actionOptions, 1, 2, "Paint Annulus");
    Dialog.addChoice("Center units:", availableUnits, centerUnits);
    Dialog.addNumber("Center   X:", previousXcenter);
    Dialog.addToSameRow();
    Dialog.addNumber("Y:", previousYcenter);
    Dialog.addChoice("Radii units:", availableUnits, radiiUnits);
    Dialog.addNumber("Inner radius:", r1);
    Dialog.addNumber("Outer radius:", r2);
    html = "<html>"
    + "<center><h2>Annulus Tool</h2></center>"
    + "Click and drag mouse to create the outer radius of the annulus.<br>"
    + "Click and drag while pressing 'alt' to create the inner radius.<br>"
    + "Click and drag while pressing 'ctrl' to move the annular selection.<br><br>"
    + "To paint an annulus with given coordinates select the \"Paint<br>"
    + "Annulus\" option, select the units with which to work, and input<br>"
    + "the corresponding values.<br><br>"
    + "To convert parameters to another units, select the \"Convert<br>"
    + "units\" option, select the desired units from the dropdown<br>"
    + "menus, and re-open the options window. Note that this option<br>"
    + "will ignore input values and will use the previously selected<br>"
    + "annulus.<br><br>"
    + "<h4>Changelog</h4>"
    + version + " - " + date + " <br>"
    + changelog;
    Dialog.addHelp(html);
    Dialog.show();
    // read data
    action = Dialog.getRadioButton();
    if (action == "Paint Annulus") {    // read new values, transform them back to pixels and paint
        centerUnits = Dialog.getChoice();
        previousXcenter = Dialog.getNumber();
        previousYcenter = Dialog.getNumber();
        radiiUnits = Dialog.getChoice();
        r1temp = Dialog.getNumber();
        r2 = Dialog.getNumber();
        // exit macro and print error if input r1 > r2
        if (r1temp > r2) {
            exit("Error: Inner radius cannot be bigger than the outer radius");
        } else r1 = r1temp;
    } else {
        newCenterUnits = Dialog.getChoice();
        dumb1 = Dialog.getNumber();
        dumb2 = Dialog.getNumber();
        newRadiiUnits = Dialog.getChoice();
        dumb3 = Dialog.getNumber();
        dumb4 = Dialog.getNumber();
    }
    // transform everything back to pixels
    if (centerUnits == "deg") {
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", previousXcenter, previousYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", previousXcenter, previousYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
    }
    if (radiiUnits == "deg") {
        r1 = r1 / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = r2 / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    }
    if (centerUnits == "arcmin") {
        previousXcenter = previousXcenter / 60;
        previousYcenter = previousYcenter / 60;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", previousXcenter, previousYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", previousXcenter, previousYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
    }
    if (radiiUnits == "arcmin") {
        r1 = r1 / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60;
        r2 = r2 / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60;
    }
    if (centerUnits == "arcsec") {
        previousXcenter = previousXcenter / 60 / 60;
        previousYcenter = previousYcenter / 60 / 60;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", previousXcenter, previousYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", previousXcenter, previousYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
    }
    if (radiiUnits == "arcsec") {
        r1 = r1 / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60 / 60;
        r2 = r2 / parseFloat(call("FITS_CARD.getDbl","CDELT2")) / 60 / 60;
    }
    if (centerUnits == "rad") {
        previousXcenter = previousXcenter * 180.0/PI;
        previousYcenter = previousYcenter * 180.0/PI;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", previousXcenter, previousYcenter, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", previousXcenter, previousYcenter, "");
        previousXcenter = xpix;
        previousYcenter = ypix;
    }
    if (radiiUnits == "rad") {
        r1 = r1 / parseFloat(call("FITS_CARD.getDbl","CDELT2")) * 180.0/PI;
        r2 = r2 / parseFloat(call("FITS_CARD.getDbl","CDELT2")) * 180.0/PI;
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
