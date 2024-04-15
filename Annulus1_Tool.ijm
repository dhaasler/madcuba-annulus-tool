/* 
 * Custom made macro to create an annular RoI in MADCUBA.
 * Creates the annulus directly when clicking the image
 *
 * In this first iteration the annulus is defined by the center of the circle [x, y], and by are inner and outer radii [r1, r2]:
 *     annulus [[x, y], [r1, r2]]
 */

// Global Variables
var x = 1;
var y = 1;
var z = 1;
var flags = "None";
var r1 = 10;
var r2 = 15;
var unitsVal = "pix";
var paint = false;
var corr = 0;

var updateValues = false;
var valuesUpdated = false;

macro "Annulus 1 Tool - C037 O00ee O22aa T6b081" {  // C037 O00ee O3388 final annulus icon
    getCursorLoc(x, y, z, flags);
    x = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));    // getBoundingRect and getCursorLoc use ImageJ coords
    y = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
    if (valuesUpdated) {
        valuesUpdated = false;
    }
    paintFromMenu();
}
 
macro "Annulus 1 Tool Options" {
    // transform everything to current units
    if (unitsVal == "deg") {
        xdeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordX", x, y, "");
        ydeg = call("CONVERT_PIXELS_COORDINATES.fits2CoordY", x, y, "");
        x = xdeg;
        y = ydeg;
        r1 = r1 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = r2 * parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    }
    Dialog.create("Annulus Properties");
    Dialog.addChoice("Units:", newArray("deg", "pix"), unitsVal);
    Dialog.addNumber("X:", x);
    Dialog.addToSameRow();
    Dialog.addNumber("Y:", y);
    Dialog.addNumber("Inner radius:", r1);
    Dialog.addNumber("Outer radius:", r2);
    Dialog.addCheckbox("Paint Region", paint);
    Dialog.addChoice("Update values", newArray("do not update", "pix", "deg"), "do not update");
    Dialog.show();

    x = Dialog.getNumber();
    y = Dialog.getNumber();
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
        xpix = call("CONVERT_PIXELS_COORDINATES.coord2FitsX", x, y, "");
        ypix = call("CONVERT_PIXELS_COORDINATES.coord2FitsY", x, y, "");
        x = xpix;
        y = ypix;
        r1 = r1 / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
        r2 = r2 / parseFloat(call("FITS_CARD.getDbl","CDELT2"));
    }
    if (paint) {
        paintFromMenu();
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

 /**
 * Paint an annulus.
 *
 * @param valx  RA arc in the sky with units
 * @param valy  DEC arc in the sky with units
 * @return  Converted arc
 */
function paintFromMenu () {
    makeOval(x-r2 + corr, y-r2 + corr, r2*2, r2*2);
    setKeyDown("alt");
    makeOval(x-r1 + corr, y-r1 + corr, r1*2, r1*2);
    setKeyDown("none");
}
