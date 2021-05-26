

# Maxima finding algorithm recreated from implementation in ImageJ/Fiji
The first stage in the maxima finding algorithm is to find the local maxima. This involves processing the image with a 3x3 (default) neighbourhood maximum filter. Once filtered this image is compared back to the original, where the pixels are the same value represents the locations of the local maxima. Typically there are far too many local maxima to be meaningful so the goal is then to merge and prune this maxima using some kind of measure of quality. In the case of algorithm a single parameter is used, the noise tolerance (Prominence). If a maxima is close to another then the maxima will be merged or removed based on the below criteria.

Starting with the brightest maxima and working down the intensities:

Expand out (‘flood fill’) from each maxima location. Neighbouring pixels within a noise tolerance (notl) of the maxima are scanned until the region within tolerance is exhausted.
If the pixels are equal to the maxima, mark this as equal.
If a greater maxima is met, ignore the active maxima.
If the pixels are less than maxima, but greater than maxima minus the noise tolerance, mark as listed.
Mark all ‘listed’ pixels 'processed' if they are included within a valid peak region, otherwise reset them.
From the regions containing a peak, calculate the best pixel to be considered as maxima based on minimum distance calculation with all those maxima considered equal.

In this repository there are two different implementations of the algorithm:  
* legacy_find_maxima.ipynb - pure Python version of the code (slow).  
* find_maxima.ipynb - Python and Cython version of the code (super fast) which requires compilation.  

To build the cython version of the code (recommended). 
To do so please :

Either use pip. E.g python3 -m pip install findmaxima2d.

Or to install from this repository please run:  
    python setup.py build-ext --inplace  This will install the package locally.
    To install into your Python's site-packages directory:
    python setup.py install

This is a re-implementation of the java plugin written by Michael Schmid and Wayne Rasband for ImageJ. This implementation doesn't yet support exclusion of edge maxima or all the varied outputs available for the ImageJ/Fiji Maxima plugin. The original java code source can be found in: https://imagej.nih.gov/ij/developer/source/ij/plugin/filter/MaximumFinder.java.html This code calls a cython compiled version of the code and is much faster than the python only implementation. If compiling the source code is a problem please check the find_maxima.ipynb notebook.

Comparison of Python and Fiji implementation using image 002eggs.png
![alt text](fijiversusPythonFindMaxima.png "Logo Title Text 1")
