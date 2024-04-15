macro "GetCursorLoc Demo Tool - C059o11ee" {
    leftButton=16;
    rightButton=4;
    shift=1;
    ctrl=2; 
    alt=8;
    x2=-1; y2=-1; z2=-1; flags2=-1;
    getCursorLoc(x, y, z, flags);
    while (flags&leftButton!=0) {
        getCursorLoc(x, y, z, flags);
        if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
            s = " ";
            if (flags&leftButton!=0) s = s + "<left>";
            if (flags&rightButton!=0) s = s + "<right>";
            if (flags&shift!=0) s = s + "<shift>";
            if (flags&ctrl!=0) s = s + "<ctrl> ";
            if (flags&alt!=0) s = s + "<alt>";
            print("X="+x+" Y="+y+" Z="+z+" flags="+flags + "" + s);
            logOpened = true;
            startTime = getTime();
        }
        x2=x; y2=y; z2=z; flags2=flags;
        wait(10);
    }
}