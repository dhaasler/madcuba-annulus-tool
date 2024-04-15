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

macro "Annulus 1 Tool - C037 O00ee O22aa T6b081" {  // C037 O00ee O3388 final annulus icon
    getCursorLoc(x, y, z, flags);
    x = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x));    // getBoundingRect and getCursorLoc use ImageJ coords
    y = parseFloat(call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y));
    paintFromMenu();
}
 
macro "Annulus 1 Tool Options" {
    Dialog.create("Annulus Properties");
    Dialog.addChoice("Units:", newArray("deg", "pix"), unitsVal);
    Dialog.addNumber("X:", x);
    Dialog.addToSameRow() 
    Dialog.addNumber("Y:", y);
    Dialog.addNumber("Inner radius:", r1);
    Dialog.addNumber("Outer radius:", r2);
    Dialog.addCheckbox("Paint Region", paint);
    Dialog.show();
    title = Dialog.getString();
    x = Dialog.getNumber();
    y = Dialog.getNumber();
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
        paintFromMenu();
    }
}

/*
 * ---------------------------------
 * ---------------------------------
 * ------ AUXILIARY FUNCTIONS ------
 * ---------------------------------
 * ---------------------------------
 */

function paintFromMenu () {
    if (unitsVal == "pix") {
        makeOval(x-r2 + corr, y-r2 + corr, r2*2, r2*2);
        setKeyDown("alt");
        makeOval(x-r1 + corr, y-r1 + corr, r1*2, r1*2);
        setKeyDown("none");
    } else if (unitsVal == "deg") {
        test = 0
    }
}
