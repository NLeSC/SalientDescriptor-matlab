The data used to test this software are the structured scenes of the test data from 

http://www.robots.ox.ac.uk/~vgg/research/affine/

where you can find all data and their full description.

The original files are in PPM format named 'image1..6.ppm' and the homographies between each image and the original one are given.

Here the same data are converted to PNG format and named after the scene sequence, i.e. 'boat1..6.png' for the 'boat' sequence.

Each sequence is used to test a single transformaiton. The mapping sequence <-> transformaiton is:

graffiti <----> viewpoint
bikes    <----> blur
boat     <----> zoom + rotation
leuven   <----> lighting
