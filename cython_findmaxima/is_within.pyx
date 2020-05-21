import cython
cimport cython
import numpy as np
cimport numpy as np
import sys

DTYPE = np.float64
ctypedef np.float64_t DTYPE_t
DTYPE = np.int32
ctypedef np.int32_t DTYPE_i

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)


def is_within(x_py, y_py, direction_py, width_py, height_py):
	cdef int y = y_py
	cdef int x = x_py
	cdef int direction = direction_py
	cdef int width = width_py
	cdef int height = height_py
	cdef int xmax
	cdef int ymax
	
	#Depending on where we are and where we are heading, return the appropriate inequality.
	xmax = width - 1
	ymax = height -1
	if direction ==0:
		return (y>0);
	elif direction ==1:
			return (x<xmax and y>0);
	elif direction ==2:
			return (x<xmax);
	elif direction ==3:
			return (x<xmax and y<ymax);
	elif direction ==4:
			return (y<ymax);
	elif direction ==5:
			return (x>0 and y<ymax);
	elif direction ==6:
			return (x>0);
	elif direction ==7:
			return (x>0 and y>0);