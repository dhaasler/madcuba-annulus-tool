/* 
 * Custom made macro to create an annular RoI in MADCUBA.
 * Creates the annulus directly when clicking the image
 *
 * In this first iteration the annulus is defined by the center of the circle [x, y], and by are inner and outer radii [r1, r2]:
 *     annulus [[x, y], [r1, r2]]
 */

var r1 = 10;
var r2 = 15;
var unitsVal = "deg";
var corr = 1;

macro "Annulus 2 Tool - C037 O00ee O22aa T6b082" {  // C037 O00ee O3388 final annulus icon
    height = call("FITS_CARD.getDbl","NAXIS2");
    getCursorLoc(x, y, z, flags);
    makeOval(x-r2 + corr, height-(y+r2) + corr, r2*2, r2*2);
    setKeyDown("alt");
    makeOval(x-r1 + corr, height-(y+r1) + corr, r1*2, r1*2);
    setKeyDown("none");
}
 
macro "Annulus 2 Tool Options" {
    Dialog.create("Annulus Properties");
    Dialog.addChoice("Units:", newArray("deg", "pix"), unitsVal);
    Dialog.addNumber("Inner radius:", r1);
    Dialog.addNumber("Outer radius:", r2);
    // Dialog.addCheckbox("Ramp", true);
    Dialog.show();
    title = Dialog.getString();
    r1 = Dialog.getNumber();
    r2 = Dialog.getNumber();
    unitsVal = Dialog.getChoice();
    // ramp = Dialog.getCheckbox();
}
