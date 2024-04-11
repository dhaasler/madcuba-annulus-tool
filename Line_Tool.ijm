// This tool draws arrows. Double click on the tool icon
// to set the width and length. Hold the shift key down to
// constrain to mod 45 degree angles. Double click
// on the eye dropper tool to define the color.
// Press "z" to undo.
var arrowWidth = 3;
var arrowLength = -1;
var arrowFirst = 1;
var arrowLast = 1;
macro "Arrow Tool (double click to configure) -C037L1ee1L65e1La9e1L76b6L65b5L97a7L98a8L94c4Db3" {
    leftButton=16; rightButton=4; alt=8; shift=1;
    getCursorLoc(x, y, z, flags); 
    xstart = x; ystart = y; 
    x2=x; y2=y;
    setOption("disablePopupMenu", true); 
    while (flags&leftButton!=0) { 
        getCursorLoc(x, y, z, flags); 
        if (x!=x2 || y!=y2) {
            dx = x - xstart;
            dy = y - ystart;
            a = atan2(dy, dx)*180/PI;
            aa = abs(a);
            ra = sqrt(dx*dx + dy*dy);
            dx /= ra;
            dy /= ra;
            if (flags&shift!=0) {
               s2 = sqrt(2)/2;
               if (aa<=22.5||aa>=157.5)
                  dy=0;
               else if (aa>=67.5&&aa<=112.5)
                  dx=0;
              else if (a>22.5&&a<67.5)
                  {dx=s2;dy=s2;}
              else if (a<-22.5&&a>-67.5)
                  {dx=s2;dy=-s2;}
              else if (a<-112.5&&a>-157.5)
                  {dx=-s2;dy=-s2;}
             else if (a>112.5&&a<157.5)
                  {dx=-s2;dy=s2;}
            }
            if (arrowLength>=0)
               ra = arrowLength;
            x = xstart + dx*ra;
            y = ystart + dy*ra;
            makeLine(xstart, ystart, x, y);
        }
        x2=x; y2=y; 
        wait(10); 
    }
    setOption("disablePopupMenu", false);
     if (x!=xstart || y!=ystart) {
        if (arrowLast>arrowFirst&&arrowFirst<=nSlices&&arrowLast<=nSlices) {
           for (i=arrowFirst; i<=arrowLast; i++) {
              setSlice(i);
              drawArrow(x2, y2, xstart, ystart, arrowWidth);
           }
           arrowFirst=1; arrowLast=1;
        }
        drawArrow(x2, y2, xstart, ystart, arrowWidth);
    }
    run("Select None");   
}

function drawArrow(x1, y1, x2, y2, arrowWidth) {
    setupUndo();
    setLineWidth(arrowWidth);
    size = 12+12* arrowWidth*0.5;
    dx = x2-x1;
    dy = y2-y1;
    ra = sqrt(dx*dx + dy*dy);
    dx /= ra;
    dy /= ra;
    x3 = x2-dx*size;
    y3 = y2-dy*size;
    r = 0.35*size;
    x4 = round(x3+dy*r);
    y4 = round(y3-dx*r);
    x5 = round(x3-dy*r);
    y5 = round(y3+dx*r);
    if (arrowLength==-1 || arrowLength>size)
       drawLine(x1, y1, x2-dx*size, y2-dy*size);
    makePolygon(x4,y4,x2,y2,x5,y5);
    fill;
 }

macro "Arrow Tool (double click to configure) Options" {
    Dialog.create("Arrow Tool");
    Dialog.addString("Width:", arrowWidth);
    len = ""+arrowLength;
    if (arrowLength<0) len = "variable";
    Dialog.addString("Length:", len);
    if (nSlices>1) {
       Dialog.addNumber("First image:", arrowFirst);
       Dialog.addNumber("Last image:", arrowLast);
    }
    Dialog.show();
    arrowWidth = parseInt(Dialog.getString());
    if (isNaN(arrowWidth)) arrowWidth = 3;
    arrowLength = parseInt(Dialog.getString());
    size = 12+12* arrowWidth*0.5;
    if (arrowLength<size) arrowLength=size;
    if (isNaN(arrowLength)) arrowLength=-1;
    if (nSlices>1) {
        arrowFirst = Dialog.getNumber();
        arrowLast= Dialog.getNumber();
        if (arrowFirst<1) arrowFirst = 1;
        if (arrowLast>nSlices) arrowLast = nSlices;
    }
}