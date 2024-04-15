/* 
 * Custom made macro to create an annular RoI in MADCUBA.
 * Creates the annulus after dragging for the oputer radius
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

macro "Annulus 2 Tool - C037 O00ee O22aa T6b082" {  // C037 O00ee O3388 final annulus icon
    getCursorLoc(x, y, z, flags);
    xcenter = x; ycenter = y;
    getBoundingRect(x2, y2, w, h) 
    if (selectionType==1 && x>x2-4 && x<x2+w+4 && y>y2-4 && y<y2+h+4)
        move(w, h);
    else
        radius2 = create(xcenter, ycenter);
    xcenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", xcenter);    // getBoundingRect and getCursorLoc use ImageJ coords
    ycenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", ycenter);
    setKeyDown("alt");
    makeOval(xcenter0-radius2/2, ycenter0-radius2/2, radius2, radius2);
}

/*
 * ---------------------------------
 * ---------------------------------
 * ------ AUXILIARY FUNCTIONS ------
 * ---------------------------------
 * ---------------------------------
 */

// draw circular selections until mouse released
function create(xcenter, ycenter) {
   radius2 = -1;
   while (true) {
        getCursorLoc(x, y, z, flags);
        if (flags&16==0) {
            getBoundingRect(x, y, width, height);
            if (width==0 || height==0)
                run("Select None");         
            return(radius2);
        }
        dx = (x - xcenter);
        dy = (y - ycenter);
        radius = sqrt(dx*dx + dy*dy);
        if (radius!=radius2)
            xcenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", xcenter);    // getBoundingRect and getCursorLoc use ImageJ coords
            ycenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", ycenter);    // it is easier to just change to fits when drawing
            makeOval(xcenter0-radius, ycenter0-radius, radius*2, radius*2);
        radius2 = radius;
        wait(10);
    }
}