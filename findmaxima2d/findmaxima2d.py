import numpy as np
from scipy import ndimage
from .cfindmaxima2d import find_maxima as cfind_maxima

def find_local_maxima(img_data,size=3):
	"""
	Function which finds local maxima in neighbourhood for a grayscale image.

	inputs:
	--------------
	img_data  - 2-D image data. 
	size (optional) - Size of neighbourhood to scan, default = 3 (recommended).
	
	outputs:
	--------------
	local_max - 2-D bool image with local maxima.
	"""

	assert(img_data.shape != 2), "Your input image is the wrong dimension, it should 2-D."

	#Filter data with maximum filter to find maximum filter response in each neighbourhood
	max_out = ndimage.filters.maximum_filter(img_data,size=3)
	#Find local maxima.
	local_max = np.zeros((img_data.shape))
	local_max[max_out == img_data] = 1
	local_max[img_data == np.min(img_data)] = 0
	return local_max.astype(bool)

def find_maxima(img_data, local_max, ntol):
	"""
	Function which finds  maxima across a grayscale image, by pruning local maxima using noise tolerance parameter.

	inputs:
	--------------
	img_data  - 2-D image data, should be Grayscale and scaled between 0-255. 
	local_max - 2-D binary image, should indicate local maxima. (see find_local_maxima function).
	
	outputs:
	--------------
	y, x - coordinates of maxima
	regs - 2-D image with regions. Each region represents flood-fill area associated with each maxima.
	
	"""
	assert(img_data.shape != 2), "Your input image is the wrong dimension, it should 2-D."

	if np.max(img_data) >255 or np.min(img_data)<0:
		print ('warning: your image should be scaled between 0 and 255 (8-bit).')
	
	img_data = np.array(img_data).astype(np.float64)
	local_max = local_max.astype(np.uint8)


	return cfind_maxima(img_data, local_max, ntol)