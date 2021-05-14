import cython
cimport cython
import numpy as np
cimport numpy as np
import sys

from is_within import is_within
DTYPE = np.float64
ctypedef np.float64_t DTYPE_f64
DTYPE = np.float32
ctypedef np.float32_t DTYPE_f32
DTYPE = np.int32
ctypedef np.int32_t DTYPE_i
DTYPE = np.int64
ctypedef np.int64_t DTYPE_64
DTYPE = np.uint8
ctypedef np.uint8_t DTYPE_ui
DTYPE = np.int8
ctypedef np.int8_t DTYPE_i8

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)

def find_maxima(img_data_py,local_max_py,ntol_py):
	cdef np.ndarray[DTYPE_ui, ndim=2,cast=True] local_max = local_max_py
	cdef np.ndarray[DTYPE_i8, ndim=2,cast=True] types = local_max_py
	cdef np.ndarray[DTYPE_f64, ndim=2,cast=True] img_data = img_data_py
	cdef int ntol = ntol_py

	#Define the internal variables.
	cdef np.ndarray[DTYPE_64, ndim=1] xpts
	cdef np.ndarray[DTYPE_64, ndim=1] ypts
	cdef np.ndarray[DTYPE_f64, ndim=1] ipts

	cdef unsigned int MAXIMUM = 1
	cdef unsigned int LISTED = 2
	cdef unsigned int PROCESSED = 4
	cdef unsigned int MAX_AREA = 8
	cdef unsigned int EQUAL = 16
	cdef unsigned int MAX_POINT = 32
	cdef unsigned int ELIMINATED = 64

	cdef int maxSortingError = 0
	cdef int width
	cdef int height

	cdef int y0
	cdef int x0
	cdef int d
	cdef double v0

	cdef int sortingError
	
	cdef int y1
	cdef int x1
	cdef int y2
	cdef int x2
	cdef int y3
	cdef int x3
	
	cdef np.ndarray[DTYPE_i, ndim=1] x
	cdef np.ndarray[DTYPE_i, ndim=1] y

	cdef int listlen
	cdef int listI
	cdef np.ndarray[DTYPE_ui, ndim=1,cast=True] dv
	cdef np.ndarray[DTYPE_f64, ndim=1] dist2
	cdef unsigned int div

	cdef float xEqual
	cdef float yEqual
	cdef float nEqual
	cdef unsigned int resetMask

	cdef int maxPossible

	width = img_data.shape[1]
	height = img_data.shape[0]
	cdef float minDist2 = 1e20
	cdef int nearestI = 0


	cdef np.ndarray[DTYPE_64, ndim=1] indx
	ypts, xpts = np.where(local_max == 1)
	
	#Find the corresponding intensities
	ipts = img_data[ypts,xpts]
	
	#Changes order from max to min.
	ind_pts = np.argsort(ipts)[::-1]
	ypts = ypts[ind_pts]
	xpts = xpts[ind_pts]
	ipts = ipts[ind_pts]

	#Create our variables and allocate memory for speed.
	cdef np.ndarray[DTYPE_i, ndim=1] pListx
	cdef np.ndarray[DTYPE_i, ndim=1] pListy

	pListx = np.zeros((width*height)).astype(np.int32)
	pListy = np.zeros((width*height)).astype(np.int32)
	


	

	#This defines the pixel neighbourhood 8-connected neighbourhood [3x3]
	cdef np.ndarray[DTYPE_64, ndim=1] dir_x = np.array([0,  1,  1,  1,  0, -1, -1, -1])
	cdef np.ndarray[DTYPE_64, ndim=1] dir_y = np.array([-1, -1,  0,  1,  1,  1,  0, -1])

	#At each stage we classify our pixels. We use 2n as we can use more than one definition
	#together.
	
	
	for y0, x0, v0 in zip(ypts, xpts, ipts):


		if (types[y0,x0]&PROCESSED) !=0:
			#If processed already then skip this pixel, it won't be maxima.
			continue

		
		sortingError = 1
		while sortingError == 1:

			#Our initial pixel 
			pListx[0] = x0
			pListy[0] = y0
			types[y0,x0] |= (EQUAL|LISTED) #Listed and Equal


			listlen = 1
			listI = 0

			#isEdgeMAxima = (x0==0 or x0 == width-1 or y0 == 0 or y0 == height -1)
			sortingError = 0
			maxPossible = 1
			xEqual = float(x0)
			yEqual = float(y0)
			nEqual = 1.0

			while listI < listlen:
				#We iteratively add points. This loop will keep going until we have
				#exhausted the neighbourhood.

				#Collect the next point to consider
				x1 = pListx[listI]
				y1 = pListy[listI]

				#Is our point legal. //not necessary, but faster than isWithin.
				#With subsequent 'OR' statement the first arguement is evaluated
				#and then only the second if the first is false.
				isInner = (y1 != 0 and y1 != height -1) and (x1!=0 and x1 != width-1)


				for d in range(0,8):
					#Scan the neighbourhood.
					x2 = int(x1+dir_x[d])
					y2 = int(y1+dir_y[d])


					if (isInner or is_within(x1,y1,d,width,height)) and (types[y2,x2]&LISTED) ==0:
						#If the pixel is located legally


						if types[y2,x2]&PROCESSED !=0:
							#If the pixel is processed already. It won't be maxima.
							maxPossible = 0
							break;

						v2 = img_data[y2,x2] #return pixel from neighbourhood.

						if v2 > v0 + maxSortingError:
							#We have reached a higher maximum.
							maxPossible = 0
							break;

						elif v2 >= v0 - ntol:

							#If equal or within we add it on.
							pListx[listlen] = x2
							pListy[listlen] = y2
							listlen = listlen+1
							#We mark it as listed. Because its in our list :-).
							types[y2,x2] |= LISTED


							#We are not excluding edge pixels yet.
							#if (x2==0 or x2 == width-1 or y2==0 or y2==height-1):
							#    isEdgeMaximum = True

								#maxPossible = 0
								#break

							if v2==v0:

								#This point is equal to our maxima.
								types[y2,x2] |= EQUAL
								#We have to merge the coordinates.
								xEqual += x2
								yEqual += y2
								nEqual += 1
				listI +=1
			#if sortingError:
				#If our point x0, y0 was not true maxima and we reach a bigger one, start again.
				#for listI in range(0,Listlen):
			#   types[pListy[0:listlen],pListx[0:listlen]] =0
			#else:
			if maxPossible == 1:
				resetMask = ~(LISTED)
			else:
				resetMask = ~(LISTED|EQUAL)

			#Now we calculate the x and y-coordinates, if there were any equal.
			xEqual /= nEqual
			yEqual /= nEqual
			minDist2 = 1e20
			nearestI = 0

			#This makes sure it has same output as the fiji plugin. Not strictly needed.
			xEqual = round(xEqual)
			yEqual = round(yEqual)
			
			x = pListx[0:listlen].astype(np.int32)
			y = pListy[0:listlen].astype(np.int32)
			
			types[y,x] &= resetMask
			
			types[y,x] |= PROCESSED
			

			

			if maxPossible == 1:
				types[y,x] |= MAX_AREA

				#This is where we assign the actual maxima location.
				
				dv =  (types[y,x]&EQUAL) !=0
				
				dist2 = (xEqual-x[dv])**2+(yEqual-y[dv])**2

				indx = np.arange(0,listlen)
				rd_indx = indx[dv]
				nearestI = rd_indx[np.argmin(dist2)]
				
				x1 = int(pListx[nearestI])
				y1 = int(pListy[nearestI])
				types[y1,x1] |= MAX_POINT






	out = types==61
	ypts,xpts = np.where(out)
	return ypts, xpts,types
