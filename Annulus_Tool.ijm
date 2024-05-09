/** 
 * Custom made tool to create an annular RoI in MADCUBA.
 * 
 * To create an annulus, first create the outer oval by clicking and
 * dragging, then create the inner oval by clicking and dragging while
 * pressing alt.
 * An options menu can be opened by double clicking or right clicking
 * the Tool icon. In this menu the user can input the annulus
 * parameters by hand, transform the coordinates of a previous
 * annulus, or export an annulus as a file, or import an annulus from
 * a file.
 * 
 * Notes: if export, import, coords2pix, paintAnnulus, and transform
 * coordinates are in this order, the preference order is as follows. 
 *  - If import and export are selected, only import is executed.
 *  - If import and Transform coordinates are selected, import is
 *    executed first importing the units of the file. Then the
 *    coordinates get transformed for the next time the options window
 *    is opened. 
 *  - If export and Transform coordinates are selected, export is
 *    executed first exporting the current units. Then the coordinates
 *    get transformed for the next time the options window is opened.
 *
 */

// Changelog
var version = "v5.2";
var date = "20240509";
var changelog = 
    "Re-designed options UI."

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
var newXcenter = 0;
var newYcenter = 0;
var globalXcenter = 0;
var globalYcenter = 0;
var centerUnits = "Pixels";
var coordSystem = "ICRS";
var newr1 = 10;
var newr2 = 15;
var r1 = 10;
var r2 = 15;
var radiiUnits = "Pixels";
var centerKeyword = "pix";
var radiiKeyword = "pix";

var corr = 0;

macro "Annulus Tool - C037 O00ee O3388" {
    getCursorLoc(x, y, z, flags);
    xFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));
    yFits = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
    xcenter = xFits; ycenter = yFits;
    // create second oval and then the annulus
    if (flags&alt!=0) {
        if (selectionType == -1) {  /* abort macro if outer oval is not set */
            exit("Error: Inner radius cannot be created with no outer radius "
            + "present. Create one first.");
        }
        Overlay.addSelection; // paint outer oval while selecting inner oval
        while ((flags&leftButton)!=0) {
            getCursorLoc(x, y, z, flags);
            xFits = 
                parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));
            yFits = 
                parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
            dx = (xFits - globalXcenter);
            dy = (yFits - globalYcenter);
            r1 = sqrt(dx*dx + dy*dy);
            makeOval(globalXcenter-r1, globalYcenter-r1, r1*2, r1*2);
            wait(20);
        }
        wait(10);
        Overlay.remove; // delete outer oval overlay to create annulus
        paintAnnulus();
        exit;
    /* Move selection. First calculate the new location using ImageJ 
    coordinates. Then set it using Fits coords */
    } else if (flags&ctrl!=0) {
        if (selectionType == -1) {
            exit("Error: Cannot move selection. There is no selection present");
        }
        getBoundingRect(x2, y2, w, h);
        getCursorLoc(x0, y0, z0, flags0); /* store information of where I first 
                                             clicked inside the ROI */
        while ((flags&leftButton)!=0) {
            getCursorLoc(x, y, z, flags);
            // calculate new the position inside the RoI after moving
            dx = x - (x0 - x2);
            dy = y - (y0 - y2) - 1; /* -1 because after clicking, the selection
                                       moves 1 pixel down (may be a problem of
                                       coords transformation) */
            dxFits = 
                parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", dx));
            dyFits = 
                parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", dy));
            setSelectionLocation(dxFits, dyFits); /* this option moves the
                                                     center with integers */
            wait(20);
        }
        wait(10);
        getBoundingRect(x3, y3, w, h);
        x3Fits = 
            parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x3));
        y3Fits = 
            parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y3));
        globalXcenter = x3Fits + w/2;
        /* if trying to paint it with the Options Menu it will move 
        the annulus slightly because the menu paints with ovals that
        accept float values and rounds them later into integers */
        globalYcenter = y3Fits - h/2 + 1; /* +1 because of problems converting 
                                             from ImageJ to Fits */
        exit;
    }
    // create outer oval
    while ((flags&leftButton)!=0) {
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
    pix2coords();

    // dialog layout
    availableCoordSystems = newArray("ICRS", "J2000", "B1950", 
                                     "Gal", "E2000", "H2000");
    availableCenterUnits = newArray("Pixels", "Degrees", "Radians", 
                                    "Arcmin", "Arcsec", "Sexagesimal");
    availableRadiiUnits = newArray("Pixels", "Degrees", "Radians", 
                                   "Arcmin", "Arcsec");
    Dialog.create("Annulus Tool");
    actionOptions = newArray("Paint Annulus", "Transform Coordinates");
    Dialog.addMessage("Press the \"Help\" button below to read instructions\n"
                     + "on how to use this tool to avoid unexpected behaviour.")
    Dialog.setInsets(5, 0, 5);
    Dialog.addRadioButtonGroup("", actionOptions, 1, 2, "Paint Annulus");
    Dialog.setInsets(12, 0, 0);
    Dialog.addChoice("Center units:", availableCenterUnits, centerUnits);
    Dialog.addToSameRow();
    Dialog.addChoice("", availableCoordSystems, coordSystem);
    Dialog.addString("X:", newXcenter, 13);
    Dialog.addString("Y:", newYcenter, 13);
    Dialog.addChoice("Radii units:", availableRadiiUnits, radiiUnits);
    Dialog.addString("Inner radius:", newr1, 10);
    Dialog.addString("Outer radius:", newr2, 10);
    Dialog.setInsets(15, 80, 5);
    Dialog.addCheckbox("Import ROI", false);
    Dialog.setInsets(0, 80, 5);
    Dialog.addCheckbox("Export ROI as", false);
    Dialog.addToSameRow();
    Dialog.addString("", "annulus.mcroi", 15);
    html = "<html>"
    + "<center><h2>Annulus Tool</h2></center>"
    + "<h3>GUI Tool</h3>"
    + "Click and drag mouse to create the outer radius of the annulus.<br>"
    + "Click and drag while pressing 'alt' to create the inner radius.<br>"
    + "Click and drag while pressing 'ctrl' to move the annulus.<br>"
    + "<h3>Options Menu</h3>"
    + "To paint an annulus with given coordinates select the \"Paint<br>"
    + "Annulus\" option, select the desired units and coordinates system,<br>"
    + "and input the corresponding values.<br><br>"
    + "To convert the current parameters to other units or coordinate<br>"
    + "systems, select the \"Transform Coordinates\" option, select the<br>"
    + "desired units and coordinates system from the dropdown menus,<br>"
    + "and re-open the options window. Note that this option will ignore<br>"
    + "input values and will use the previously selected annulus.<br>"
    + "<h4>Import or export an annulus</h4>"
    + "To import an annulus from a text file, check the \"Import ROI\"<br>"
    + "checkbox. A window will appear asking the user to select the<br>"
    + "annulus file.<br>"
    + "To export the annulus as a text file, check the \"Export ROI\"<br>"
    + "checkbox and input the desired file name. A window will appear<br>"
    + "asking the user to select the Folder in which to save the file.<br><br>"
    + "<h2>Changelog</h2>"
    + version + " - " + date + " <br>"
    + changelog;
    Dialog.addHelp(html);
    Dialog.show();
    
    // read data
    action = Dialog.getRadioButton();
    if (action == "Paint Annulus") {
        centerUnits = Dialog.getChoice();
        coordSystem = Dialog.getChoice();
        newXcenter = Dialog.getString();
        newYcenter = Dialog.getString();
        radiiUnits = Dialog.getChoice();
        newr1temp = Dialog.getString();
        newr2 = Dialog.getString();
        import = Dialog.getCheckbox();
        export = Dialog.getCheckbox();
        saveFile = Dialog.getString();
        // exit macro and print error if input r1 > r2
        if (parseFloat(newr1temp) > parseFloat(newr2)) {
            exit("Error: Inner radius cannot be bigger than the outer radius");
        } else newr1 = newr1temp;
        if (centerUnits == "Sexagesimal"
            && (coordSystem == "Gal" || coordSystem == "E2000"
                || coordSystem == "H2000")) {
            exit("Warning: coordinates system " + coordSystem
                 + " does not accept sexagesimal units");
        }
    } else { // transform parameters
        transformCenterUnits = Dialog.getChoice();
        transformCoordSystem = Dialog.getChoice();
        dumb1 = Dialog.getString();
        dumb2 = Dialog.getString();
        newRadiiUnits = Dialog.getChoice();
        dumb3 = Dialog.getString();
        dumb4 = Dialog.getString();
        import = Dialog.getCheckbox();
        export = Dialog.getCheckbox();
        saveFile = Dialog.getString();
        if (transformCenterUnits == "Sexagesimal"
            && (transformCoordSystem == "Gal" || transformCoordSystem == "E2000"
                || transformCoordSystem == "H2000")) {
            exit("Warning: coordinates system " + transformCoordSystem 
                 + " does not accept sexagesimal units");
        }
    }

    // import roi has preference over import annulus
    if (import) {
        importAnnulus();
    } else if (export) {
        exportAnnulus(saveFile);
    }
    // transform everything back to pixels
    coords2pix();

    // paint annulus from options menu
    paintAnnulus();

    // update units for coordinates transformation
    if (action == "Transform Coordinates") {
        centerUnits = transformCenterUnits;
        radiiUnits = newRadiiUnits;
        coordSystem = transformCoordSystem;
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
    /* if GET SPECTRUM is launched too closely after the previous code sometimes
    it prompts an error message: CANNOT GENERATE SPECTRUM. With a little wait
    time it does not fail. I have no idea why. */
    wait(50);
    run("GET SPECTRUM", "roi");
}

/**
 * Export the annulus as a text file storing its center coordinates
 * and radii lengths
 */
function exportAnnulus(saveFile) {
    /* there is no save file command, only open file */
    path = getDirectory("Choose a Directory");
    annulusInfo = "# MADCUBA ROI file format. "
                + "makeAnnulus(X_center, Y_center, R1, R2)\n";
    annulusCommand = "makeAnnulus(" + newXcenter + centerKeyword + ", "
                                    + newYcenter + centerKeyword + ", "
                                    + newr1 + radiiKeyword + ", "
                                    + newr2 + radiiKeyword + ", "
                                    + coordSystem + ");";
    File.saveString(annulusInfo+annulusCommand, path + saveFile);
}

/**
 * Import an annulus from a .dat file
 */
function importAnnulus() {
    path = File.openDialog("Select a ROI File");
    annulusFile = File.openAsString(path);
    rows = split(annulusFile,"\n\r");
    data = split(rows[1], "(),"); // read only the data row
    coordKeywords = newArray ("pix", "deg", "rad", "hdms", "arcmin", "arcsec");
    coordUnits = newArray("Pixels", "Degrees", "Radians",
                          "Sexagesimal", "Arcmin", "Arcsec");
    units= 10;
    parsedData = newArray(4);
    parsedKeywords = newArray(4);
    for (k=1; k<5; k++) {
        for (j=0; j<coordKeywords.length; j++) // read units
            if (indexOf(data[k], coordKeywords[j]) != -1) units=j;
        if (units == 10) {
            exit("Warning: Coordinates units not found");
        }
        parsedData[k-1] =
            substring(data[k], 0, indexOf(data[k], coordKeywords[units]));
        parsedKeywords[k-1] = coordKeywords[units];
    }
    newXcenter = parsedData[0];
    newYcenter = parsedData[1];
    newr1 = parsedData[2];
    newr2 = parsedData[3];
    centerKeyword = parsedKeywords[0];
    for (j=0; j<coordKeywords.length; j++) // read units
        if (indexOf(centerKeyword, coordKeywords[j]) == 0) coordIndex=j;
    centerUnits = coordUnits[coordIndex];
    newRadiiUnits = parsedKeywords[2];
    coordSystem = substring(data[5], 1, lengthOf(data[5]));
}

/**
 * Transform pixels into celestial coordinates
 */
function pix2coords() {
    // transform center units to selected coordinates
    if (centerUnits == "Pixels") {
        centerKeyword = "pix";
        newXcenter = globalXcenter;
        newYcenter = globalYcenter;
    } else if (centerUnits == "Degrees") {
        centerKeyword = "deg";
        /* cannot be changed at once because globalXcenter is used in the next 
        statement. We need temp variables xdeg and ydeg */
        xdeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordX", 
                    globalXcenter, globalYcenter, coordSystem);
        ydeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordY", 
                    globalXcenter, globalYcenter, coordSystem);
        newXcenter = d2s(xdeg,6);
        newYcenter = d2s(ydeg,6);
    } else if (centerUnits == "Arcmin") {
        centerKeyword = "arcmin";
        xmin = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", 
                               globalXcenter, globalYcenter, coordSystem)) * 60;
        ymin = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", 
                               globalXcenter, globalYcenter, coordSystem)) * 60;
        newXcenter = xmin;
        newYcenter = ymin;
    } else if (centerUnits == "Arcsec") {
        centerKeyword = "arcsec";
        xsec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX", 
                               globalXcenter, globalYcenter, coordSystem))
                               * 60 * 60;
        ysec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY", 
                               globalXcenter, globalYcenter, coordSystem))
                               * 60 * 60;
        newXcenter = xsec;
        newYcenter = ysec;
    } else if (centerUnits == "Arcsec") {
        centerKeyword = "arcsec";
        xsec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX",
                               globalXcenter, globalYcenter, coordSystem))
                               * 60 * 60;
        ysec = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY",
                               globalXcenter, globalYcenter, coordSystem))
                               * 60 * 60;
        newXcenter = xsec;
        newYcenter = ysec;
    } else if (centerUnits == "Radians") {
        centerKeyword = "rad";
        xrad = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordX",
                               globalXcenter, globalYcenter, coordSystem))
                               * PI/180.0;
        yrad = parseFloat(call("CONVERT_PIXELS_COORDINATES.fits2CoordY",
                               globalXcenter, globalYcenter, coordSystem))
                               * PI/180.0;
        newXcenter = d2s(xrad,8);
        newYcenter = d2s(yrad,8);
    } else if (centerUnits == "Sexagesimal") {
        centerKeyword = "hdms";
        ra = call("CONVERT_PIXELS_COORDINATES.fits2CoordXString",
                  globalXcenter, globalYcenter, coordSystem);
        dec = call("CONVERT_PIXELS_COORDINATES.fits2CoordYString",
                   globalXcenter, globalYcenter, coordSystem);
        newXcenter = ra;
        newYcenter = dec;
    } else exit("Error: Center coordinates units not found.");
    // transform radii units to selected coordinates
    if (radiiUnits == "Pixels") {
        radiiKeyword = "pix";
        newr1 = r1;
        newr2 = r2;
    } else if (radiiUnits == "Degrees") {
        radiiKeyword = "deg";
        r1deg = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2deg = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        newr1 = d2s(r1deg,6);
        newr2 = d2s(r2deg,6);
    } else if (radiiUnits == "Arcmin") {
        radiiKeyword = "arcmin";
        newr1 = 
            r1 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60;
        newr2 = 
            r2 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2"))) * 60;
    } else if (radiiUnits == "Arcsec") {
        radiiKeyword = "arcsec";
        newr1 = r1 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2")))
                * 60 * 60;
        newr2 = r2 * parseFloat(parseFloat(call("FITS_CARD.getDbl","CDELT2")))
                * 60 * 60;
    } else if (radiiUnits == "Radians") {
        radiiKeyword = "rad";
        r1rad = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2")) * PI/180.0;
        r2rad = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2")) * PI/180.0;
        newr1 = d2s(r1rad,8);
        newr2 = d2s(r2rad,8);
    } else exit("Error: Radii coordinates units not found.");
}

/**
 * Transform celestial coordinates into pixels.
 */
function coords2pix() {
    // transform center units back to pixels
    if (centerUnits == "Pixels") {
        globalXcenter = newXcenter;
        globalYcenter = newYcenter;
    } else if (centerUnits == "Degrees") {
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX",
                    newXcenter, newYcenter, coordSystem);
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY",
                    newXcenter, newYcenter, coordSystem);
        globalXcenter = xpix;
        globalYcenter = ypix;
    } else if (centerUnits == "Arcmin") {
        newXcenter = parseFloat(newXcenter) / 60;
        newYcenter = parseFloat(newYcenter) / 60;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", 
                    newXcenter, newYcenter, coordSystem);
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", 
                    newXcenter, newYcenter, coordSystem);
        globalXcenter = xpix;
        globalYcenter = ypix;
    } else if (centerUnits == "Arcsec") {
        newXcenter = parseFloat(newXcenter) / 60 / 60;
        newYcenter = parseFloat(newYcenter) / 60 / 60;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX",
                    newXcenter, newYcenter, coordSystem);
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY",
                    newXcenter, newYcenter, coordSystem);
        globalXcenter = xpix;
        globalYcenter = ypix;
    } else if (centerUnits == "Radians") {
        newXcenter = parseFloat(newXcenter) * 180.0/PI;
        newYcenter = parseFloat(newYcenter) * 180.0/PI;
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX",
                    newXcenter, newYcenter, coordSystem);
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY",
                    newXcenter, newYcenter, coordSystem);
        globalXcenter = xpix;
        globalYcenter = ypix;
    } else if (centerUnits == "Sexagesimal") {
        rapix = call("CONVERT_PIXELS_COORDINATES.coordString2FitsX",
                        newXcenter, newYcenter, coordSystem);
        decpix = call("CONVERT_PIXELS_COORDINATES.coordString2FitsY",
                        newXcenter, newYcenter, coordSystem);
        globalXcenter = rapix;
        globalYcenter = decpix;
    } else exit("Error: Center coordinates units not found.");
    // transform radii units back to pixels
    if (radiiUnits == "Pixels") {
        r1 = parseFloat(newr1);
        r2 = parseFloat(newr2);
    } else if (radiiUnits == "Degrees") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    } else if (radiiUnits == "Arcmin") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) 
                / 60;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2"))
                / 60;
    } else if (radiiUnits == "Arcsec") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2")) 
                / 60 / 60;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2"))
                / 60 / 60;
    } else if (radiiUnits == "Radians") {
        r1 = parseFloat(newr1) / parseFloat(call("FITS_CARD.getDbl","CDELT2"))
                * 180.0/PI;
        r2 = parseFloat(newr2) / parseFloat(call("FITS_CARD.getDbl","CDELT2"))
                * 180.0/PI;
    } else exit("Error: Radii coordinates units not found.");
}
