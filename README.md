# MADCUBA Annulus Tool

[![GitHub Release](https://img.shields.io/github/v/release/dhaasler/madcuba-annulus-tool)](https://github.com/dhaasler/madcuba-annulus-tool/releases/tag/v5.2.0)
[![Static Badge](https://img.shields.io/badge/changelog-brightgreen)](CHANGELOG.md)

MADCUBA tool for creating annular selections. [MADCUBA](https://cab.inta-csic.es/madcuba/) is a software developed in the spanish Center of Astrobiology (CSIC-INTA) to analyze astronomical datacubes, and is built using the ImageJ infrastructure. This tool will not work with any other ImageJ program.

This tool is developed to be used with MADCUBA v10. With this tool the user can select an annular region by clicking and dragging in an image, or by inputting the annulus parameters through an options window.

The annulus is parametrized by its center and its two radii:

- Center coordinates X and Y
- Inner radius (r1)
- Outer radius (r2)

The user can input the parameters in different units:

- Image pixels
- Degrees
- Radians
- Arcminutes
- Arcseconds
- Sexagesimal coordinates.

And using different coordinate systems:

- J Equatorial (J2000)
- B Equatorial (B1950)
- Galactic (Gal)
- ICRS Equatorial (ICRS)
- Ecliptic (E2000)
- HelioEcliptic (H2000)

## Installation

Download the latest version of `Annulus_Tool.ijm` from the releases page and install it in MADCUBA as a plugin (ImageJ window > Plugins > Install...)
The tool will then appear in the ImageJ Toolbar ready to be used.

## How to use

To check the installed version and read the instructions from within MADCUBA, select "Help" in the [options](#options-menu) window of the tool.

### GUI Tool

Click and drag mouse to create the outer radius of the annulus.
Click and drag while pressing <kbd>Alt</kbd> to create the inner radius.
Click and drag while pressing <kbd>Ctrl</kbd> to move the annulus.

### Options Menu

Double click or right-click the Tool icon to open the options menu where:

1. To paint an annulus with given coordinates select the "Paint Annulus" option, select the desired units and coordinate system, and input the corresponding values.
2. To convert the current parameters to other units or coordinate systems, select the \"Transform coordinates" option, select the desired units and coordinate system from the dropdown menus, and re-open the options window.
   Note that this option will ignore input values and will use the previously selected annulus.

#### Import or export an annulus

To import an annulus from a text file, check the "Import ROI" checkbox. A window will appear asking the user to select the annulus file.  
To export the annulus as a text file, check the "Export ROI" checkbox and input the desired file name. A window will appear asking the user to select the Folder in which to save the file.
