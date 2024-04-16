/* 
 * Custom made macro to create an annular RoI in MADCUBA.
 * First creates the outer oval, then by pressing alt and dragging, it creates the inner radius. 
 * This uses roi manager for the representation of the outer oval while drawing the inner one.
 *
 * In this first iteration the annulus is defined by the center of the circle [x, y], and by are inner and outer radii [r1, r2]:
 *     annulus [[x, y], [r1, r2]]
 */

// Global Variables
var x = 1;
var y = 1;
var z = 1;
var click = 16;
var alt = 8;
var flags = "None";
var r1 = 10;
var r2 = 15;
var unitsVal = "pix";
var paint = false;
var corr = 0;
var previousx = 0;
var previousy = 0;

macro "Annulus 4 Tool - C037 O00ee O22aa T6b084" {  // C037 O00ee O3388 final annulus icon
    getCursorLoc(x, y, z, flags);
    xcenter = x; ycenter = y;
    if (flags&alt!=0) {
        while ((flags&click)!=0) {
            getCursorLoc(x, y, z, flags);
            dx = (x - xcenter);
            dy = (y - ycenter);
            r1 = sqrt(dx*dx + dy*dy);
            previousx0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", previousx);    // getBoundingRect and getCursorLoc use ImageJ coords
            previousy0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", previousy);    // it is easier to just change to fits when drawing
            makeOval(previousx0-r1, previousy0-r1, r1*2, r1*2);
            wait(10);
        }
        roiManager("reset");
        makeOval(previousx0-r2, previousy0-r2, r2*2, r2*2);
        setKeyDown("alt");
        makeOval(previousx0-r1, previousy0-r1, r1*2, r1*2);
        setKeyDown("none");
        roiManager("add");
        exit;
    }
    while ((flags&click)!=0) {
        getCursorLoc(x, y, z, flags);
        dx = (x - xcenter);
        dy = (y - ycenter);
        r2 = sqrt(dx*dx + dy*dy);
        xcenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", xcenter);    // getBoundingRect and getCursorLoc use ImageJ coords
        ycenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", ycenter);    // it is easier to just change to fits when drawing
        makeOval(xcenter0-r2, ycenter0-r2, r2*2, r2*2);
        wait(10);
    }
    roiManager("add");
    roiManager("show all");
    wait(10);
    previousx = xcenter;
    previousy = ycenter;
}

macro "Annulus 4 Tool Options" {
    Dialog.create("Radio Buttons");
    items = newArray("New York", "London", "Paris", "Tokyo");
    Dialog.addRadioButtonGroup("Cities", items, 2, 2, "Paris");
    items = newArray("One", "Two", "Three");
    Dialog.addRadioButtonGroup("Numbers", items, 1, 3, "One");
    items = newArray("Alfa Romeo ", "Ferrari", "Lamborghini", "Maserati", "Lancia");
    Dialog.addRadioButtonGroup("Italian Cars", items, 5, 1, "Ferrari");
    Dialog.show;
    print("Cities: "+Dialog.getRadioButton);
    print("Numbers: "+Dialog.getRadioButton);
    print("Cars: "+Dialog.getRadioButton);
}

// ESTE PARECE HACERLO BIEN PERO QUIERO NO USAR ROI MANAGER, O AL MENOS METER EL ANILLO FINAL EN ROI MANAGER

/*
 * ---------------------------------
 * ---------------------------------
 * ------ AUXILIARY FUNCTIONS ------
 * ---------------------------------
 * ---------------------------------
 */
