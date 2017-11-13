# Listeria_spread_movies


This folder contains time-lapse data of Listeria monocytogenes spread from cell to cell.
The bacteria (in red or green) are swimming inside the cytoplasm of gut-like human cells (nuclei in blue).
Note how some bacteria travel much farther than others.

The **WT_WT.mp4** movie shows wild-type bacteria (red) spreading inside wild-type human cells.

The **ActA-del.mp4** movie shows mutant bacteria (green) that have lost the ability to move from cell to cell.

The **shape_analysis.md** file shows the output of **shapeAnalyzer.m**, a MATLAB script that takes in the raw image of a bacterial focus and outputs the contour lines of the focus according to the blurred fluorescence intensity.

Finally, **test.tif** is a raw still image from a time-lapse series. It is the input for **shapeAnalyzer.m**.
