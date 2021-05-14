
# Python 2-D Maxima finding algorithm (findmaxima2d) recreated from implementation in ImageJ/Fiji

This is an efficient 2-D maxima finding algorithm (based on previous implementation in ImageJ/Fiji), it requires a local maxima image as input (see below) as well as a grayscale image. When called, the find_maxima algorithm prunes the local maxima based on the ntol (noise tolerance parameter). It processes the local maxima in the following way:
* Scan the neighbourhood of each maxima and determine whether there are any surrounding peaks which are higher. If there are, skip this maxima.
* If there are pixels in the neighbourhood within a noise tolerance (ntol) of the maxima, add them to the list to be scanned, spreading out like a flood fill algorithm, until the neighbourhood is exhausted
    * If the pixels are equal to the maxima, mark this maxima as equal. 
    * If the pixels are less than maxima but greater than maxima minus the noise tolerance, mark as listed.
* Mark all pixels considered as 'processed' as long as they are included within a valid peak region. Reset all others.
* From the regions containing a peak, calculate the best pixel to be considered as maxima based on minimum distance calculation with all those considered equal.


## Installation

```shell
$ python3 -m pip install findmaxima2d

```

## Usage

The module is imported as follows.

```shell
>>> from findmaxima2d import find_maxima
```
The first stage in the maxima finding algorithm is to find the local maxima, this can be achieved in different ways but usually represents the identification of the maximum pixel in each 3x3 neighbourhood (in the default case). Here is some typical code:
```shell
import numpy as np
from scipy import ndimage
def find_local_maxima_np(img_data):
    #This is the numpy/scipy version of the above function (find local maxima).
    #Its a bit faster, and more compact code.
    
    #Filter data with maximum filter to find maximum filter response in each neighbourhood
    max_out = ndimage.filters.maximum_filter(img_data,size=3)
    #Find local maxima.
    local_max = np.zeros((img_data.shape))
    local_max[max_out == img_data] = 1
    local_max[img_data == np.min(img_data)] = 0
    return local_max.astype(np.bool)
 ```

With the find_local_maxima_np function in place it is then possible to find the maxima in an image E.g.:

```shell
img = Image.open('002eggs.png')
ntol = 10 #Noise Tolerance.
img_data = np.array(img).astype(np.float64)

t1 = time.time()


#Should your image be an RGB image.
if img_data.shape.__len__() >2:
    img_data = (np.sum(img_data,2)/3.0)
    
if np.max(img_data) >255 or np.min(img_data)<0:
    print ('warning: your image should be scaled between 0 and 255 (8-bit).')

#Finds the local maxima using maximum filter.
local_max = find_local_maxima_np(img_data)

#Finds the maxima.
y,x,regs = find_maxima(img_data,local_max.astype(np.uint8),ntol)
 ```
The find_maxima function outputs the local maxima coordinates (y,x) and also the pixel regions associated with each maxima (regs).
