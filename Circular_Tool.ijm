// This tool creates a circular selection centered where the mouse 
// is first clicked. It moves the selection if it already exists.
// Revised 2009/03/18 to check only for left mouse button flag

macro "Circular Selection Tool -C00b-B11-O11cc-F6622" {
    getCursorLoc(x, y, z, flags);
    xcenter = x; ycenter = y;
    getBoundingRect(x2, y2, w, h) 
    if (selectionType==1 && x>x2-4 && x<x2+w+4 && y>y2-4 && y<y2+h+4)
        move(w, h);
    else
        radius = create(xcenter, ycenter);
    // xcenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", xcenter);    // getBoundingRect and getCursorLoc use ImageJ coords
    // ycenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", ycenter);
    // setKeyDown("alt");
    // makeOval(xcenter0-radius/2, ycenter0-radius/2, radius, radius);
}

// move existing circular selection until mouse released
function move(width, height) {
    x2=-1; y2=-1;
    while (true) {
        getCursorLoc(x, y, z, flags);
        if (flags&16==0) return;
        if (x!=x2 || y!=y2)
            x0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", x);    // getBoundingRect and getCursorLoc use ImageJ coords
            y0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", y);    // it is easier to just change to fits when drawing
            makeOval(x0-width/2, y0-height/2, width, height);
        x2=x; y2=y;
        wait(10);
    };
}

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

// draw circular selections as overlay until mouse released
function createOverlay(xcenter, ycenter) {
    radius2 = -1;
    while (true) {
        getCursorLoc(x, y, z, flags);
        if (flags&16==0) {
            getBoundingRect(x, y, width, height);
            if (width==0 || height==0)
                run("Select None");
            Overlay.remove;
            makeOval(xcenter0-radius, ycenter0-radius, radius*2, radius*2);
            return(radius2);
        }
        dx = (x - xcenter);
        dy = (y - ycenter);
        radius = sqrt(dx*dx + dy*dy);
        if (radius!=radius2)
            xcenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsX", xcenter);    // getBoundingRect and getCursorLoc use ImageJ coords
            ycenter0 = call("CONVERT_PIXELS_COORDINATES.imageJ2FitsY", ycenter);    // it is easier to just change to fits when drawing
            Overlay.remove;
            Overlay.drawEllipse(xcenter0-radius, ycenter0-radius, radius*2, radius*2);
            Overlay.add;
            Overlay.show;
        radius2 = radius;
        wait(10);
    }
}