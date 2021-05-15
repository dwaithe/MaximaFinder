from setuptools import setup
import numpy
from distutils.extension import Extension
from Cython.Build import cythonize

setup(name='findmaxima2d',
      version='0.0.25',
      description='Python 2-D Maxima finding algorithm (findmaxima2d) recreated from implementation in ImageJ/Fiji',
      url='https://github.com/dwaithe/MaximaFinder/tree/master/findmaxima2d',
      author='Dominic Waithe',
      author_email='dominic_waithe@hotmail.com',
      license='GNU',
      packages=['findmaxima2d'],
      install_requires=[
          'cython','scipy','numpy'
      ],

      
      
      
      include_dirs=[numpy.get_include()],
      include_package_data=True,
      ext_modules =  cythonize(["findmaxima2d/is_within.pyx","findmaxima2d/cfindmaxima2d.pyx"]),
      zip_safe=False)