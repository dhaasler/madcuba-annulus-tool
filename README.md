# MADCUBA Annulus Tool

MADCUBA tool to create annular regions.

With this tool the user can select an annular region by clicking and dragging in an image, or by inputting the annulus parameters through an options window.

The user can input the parameters in a wide set of units: image pixels, degrees, radians, arcminutes, arcseconds, and sexagesimal coordinates.

The annulus is parametrized by its center and its two radii:  
1. Center coordinates X and Y
2. Inner radius (r1)
3. Outer radius (r2) 

## Installation

Install `Annulus_Tool.ijm` in MADCUBA as a plugin (ImageJ window > Plugins > Install...)
The tool will then appear in the ImageJ Toolbar and will be ready to be used.

## Use

Click and drag mouse to create the outer radius of the annulus.  
Click and drag while pressing 'alt' to create the inner radius.  
Click and drag while pressing 'ctrl' to move the annular selection.  

Double click or right-click the Tool icon to open the options menu where:
1. To paint an annulus with given coordinates select the "Paint Annulus" option, select the units with which to work, and input the corresponding values.

2. To convert the current parameters to another units, select the \"Convert units\" option, select the desired units from the dropdown menus, and re-open the options window.
    > Note that this option will ignore input values and will use the previously selected annulus.