#!/usr/bin/env python

# Written by John Ollinger
#
# University of Wisconsin, 8/16/09

#Copyright (c) 2006-2007, John Ollinger, University of Wisconsin
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are
#met:
#
#    * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#    * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ** This software was designed to be used only for research purposes. **
# ** Clinical uses are not recommended, and have never been evaluated. **
# ** This software comes with no warranties of any kind whatsoever,    **
# ** and may not be useful for anything.  Use it at your own risk!     **
# ** If these terms are not acceptable, you aren't allowed to use the code.**

"""
ModuleLibrary: file_io

Purpose: Provide simple interface to common neuroimaging image formats such
         as brik, nifti, dicom, and GE proprietary formats.

By: John Ollinger

Date: 2001 - 2008

"""
import os
from os import R_OK, W_OK, F_OK, getcwd
import sys
import struct
import numpy
from numpy import array, dot, zeros, transpose, fromstring, reshape, nonzero, \
        take, float, short, float32, identity, fliplr, flipud, sign, \
        prod, where, ones, byte, int8, uint8, int16, uint16, complex,  \
        integer, diag, argmax, ubyte, float64, complex64, complex128, ubyte, \
        long, ndarray, array2string, dtype, int32, empty, arange
import string
import gzip
import bz2
from types import IntType,FloatType,StringType
import math
from math import sin, cos, acos
from stat import S_IRWXU, S_IRWXG, S_IRWXO
import time
from datetime import datetime
from socket import gethostname, gethostname
import yaml
import cPickle
from subprocess import Popen, PIPE
import signal

#import dicom
from wisc_dicom import Dicom, isdicom, open_gzbz2, DicomTar, dicom_to_rot44
import constants as c
from wbl_util import Timer, GetTmpSpace, except_msg, Translate

#FIGARO_TMP = '/ESE/scratch/tmp'
GE_HEADER_POOL_LEN = 149788

datatype_to_lgth = {'bit':1, 'byte':8, 'short':16, 'integer':32, \
        'float32':32, 'float':32, 'double':64, 'complex':64, 'int16':16, \
        'int32': 32, 'int8':8, 'uint8':8}
datatype_to_lgthbytes = {'bit':0, 'byte':1, 'short':2, 'integer':4, \
        'float32':4, 'float':4, 'double':8, 'complex':8, 'int8':1, 'int16':2, \
        'int32':4, 'uint8':1}
datatype_to_lgthbits = {'bit':1, 'byte':8, 'short':16, 'int16':16, \
        'integer':32, 'float32':32, 'float':32, 'double':64, 'complex':64}

#datatype_to_dtype = {'bit':'?', 'byte':'B', 'short':'h', 'integer':int32, \
#        'float32':'f', 'float':'d', 'double':'d', 'complex':'F'}
datatype_to_dtype = {'bit':'?', 'byte':ubyte, 'short':int16, 'integer':int32, \
        'float32':float32, 'float':float64, 'double':float64, \
        'complex':complex64}

nifti_datacode_to_type = {1:'bit', 2:'byte', 4:'short', 8:'integer', \
        16:'float32', 32:'complex', 64:'double', 128:'rgb'}
nifti_type_to_datacode = {'bit':1, 'byte':2, 'short':4, 'integer':8, \
        'float32':16, 'float':16, 'complex':32, 'double':64, 'int16':16, 'int32':32}
nifti_slice_order_decode = {'0':'zero', '1':'seq+', '2':'seq0', \
        '3':'altplus', '4':'altminus', '5':'alt+2', '6':'alt-2'}
nifti_slice_order_encode = {'unknown':'0', 'seq+':'1', 'seq0':'2', \
        'altplus':'3', 'altminus':'4', 'alt+2':'5', 'alt-2':'6', \
        'alt+z':'3', 'alt-z':'4','zero':'0'}

nifti_intent_decode = {0:'unknown', 2:'correl', 3:'ttest', 4:'ftest', \
        5:'zscore', 6:'chisq', 7:'beta', 8:'binom', 9:'gamma', 10:'poisson', \
        11:'normal', 12:'ftest_nonc', 13:'chisq_nonc', 14:'logistic', \
        15:'laplace', 16:'uniform', 17:'ttest_nonc', 18:'weibull', \
        19:'chi', 20:'invgauss', 21:'extval', 22:'pval', 23:'logpval', \
        24:'log10pval', 2:'ti_first_statcode', 24:'ti_last_statcode', \
        1001:'estimate', 1002:'label', 1003:'neuroname', 1004:'genmatrix', \
        1005:'symmatrix', 1006:'dispvect', 1007:'vector', 1008:'pointset', \
        1009:'triangle', 1010:'quaternion', 1011:'dimless'}
nifti_intent_encode = {'unknown':0, 'correl':2, 'ttest':3, 'ftest':4, \
        'zscore':5, 'chisq':6, 'beta':7, 'binom':8, 'gamma':9, 'poisson':10, \
        'normal':11, 'ftest_nonc':12, 'chisq_nonc':13, 'logistic':14, \
        'laplace':15, 'uniform':16, 'ttest_nonc':17, 'weibull':18, \
        'chi':19, 'invgauss':20, 'extval':21, 'pval':22, 'logpval':23, \
        'log10pval':24, 'nifti_first_statcode':2, \
        'nifti_last_statcode':24, 'estimate':1001, 'label':1002, \
        'neuroname':1003, 'genmatrix':1004, 'symmatrix':1005, \
        'dispvect':1006, 'vector':1007, 'pointset':1008, \
        'triangle':1009, 'quaternion':1010, 'dimless':1011}
nifti_sqform_encode = {'unknown':c.NIFTI_XFORM_UNKNOWN, \
                       'scanner_anat':c.NIFTI_XFORM_SCANNER_ANAT, \
                       'aligned_anat':c.NIFTI_XFORM_ALIGNED_ANAT, \
                       'talairach':c.NIFTI_XFORM_TAILARACH, \
                       'mni_152':c.NIFTI_XFORM_MNI_152, \
                       0:0,1:1,2:2,3:3,4:4}
nifti_sqform_decode = {0:'unknown', 1:'scanner_anat', 2:'aligned_anat', \
        3:'talairach', 4:'mni_152'}
nifti_units_encode = {'':0, 'meter':1, 'mm':2 , 'micron':3, \
        'sec':8, 'msec':16, 'usec':24, 'hz':32 , 'ppm':40, 'rads':48, \
        '0':0,'1':1,'2':2,'3':3,'8':8,'16':16,'24':24,'32':32,'40':40,'48':48}
nifti_units_decode = {'0':'unknown', '1':'meter', '2':'mm', '3':'micron',  \
        '8':'sec', '16':'msec', '24':'usec', '32':'hz', '40':'ppm', '48':'rads'}
nifti_units_scale = {' ':'0', 'meter':'1000', 'mm':'1.' , 'micron':'.001', \
        'sec':'1000', 'msec':'1.', 'usec':'.001', 'hz':'1000' , 'ppm':'1.', \
        'rads':'1.'}
nifti_ecode_decode = {0:'unknown', 2:'DICOM', 4:'AFNI'}
nifti_ecode_encode = {'unknown':0, 'DICOM':2, 'AFNI':4}

analyze_datacode_to_type = {0:'unknown', 1:'bit', 2:'byte', 4:'short', \
        8:'integer', 16:'float32', 32:'complex', 64:'double'}
analyze_type_to_datacode = {'bit':1, 'byte':2, 'short':4, 'integer':8, \
        'float32':16, 'float':16, 'complex':32, 'double':64, 'int32':8}
analyze_orientcode_to_orient = ['???', 'RIP', 'PIR', 'RAI', 'RSP', 'PSR']

afni_sign_code = [0, 1, 1, 0, 0, 1]
time_to_scalefactor = {'0':1., '':1., 'usec':.001, 'msec':1., 'sec':1000.}

plane_type = {0:'Axial', 1:'Sagittal', 2:'Coronal', 4:'oblique', 5:'3-plane'}

image_type = {0:'Real', 1:'Imaginary', 2:'Phase', 3:'Magnitude'}

dicom_datanum_to_code = {8:'byte', 16:'short', 12:'short', 32:'float32', \
        64:'double'}
afni_datanum_to_code = {0:'byte', 1:'short', 2:'integer', 3:'float32', \
            4:'double', 5:'complex'}

hexts = {'.HEAD':'.BRIK', '.hdr':'.img', '.spr':'.sdt', '.tes':'', '.cub':'', \
        '.nii':'', '4dfp.ifh':'4dfp.img', '.7':'','.nii.gz':''}
iexts = {'.BRIK':'.HEAD', '.img':'.hdr', '.sdt':'.spr', '.tes':'.tes', \
        '.cub':'.cub', '.nii':'.n+1', '4dfp.img':'4dfp.ifh', '.7':'.7'}
extlist = {'brik':'.BRIK', 'analyze':'.img', 'dicom':None, 'ge_data':None, \
           'cub':None, 'tes':None, 'ni1':'.img', 'n+1':'.nii', 'nii':'.nii'}
dtype_max = {int8:127.,uint8:255.,int16:32767.,uint16:65535.}

yaml_magic_code = '#!Wimage header\n'

NIFTI_SLICE_UNKNOWN = 0
NIFTI_SLICE_SEQ_INC = 1
NIFTI_SLICE_SEQ_DEC = 2
NIFTI_SLICE_ALT_INC = 3
NIFTI_SLICE_ALT_DEC = 4


none_subhdr = {'AcqTime':-1, \
        'EffEchoSpacing':-1, \
        'FlipAngle':-1, \
        'ImageType':'', \
        'PhaseEncodeDir':'', \
        'InstitutionName':'', \
        'TI':-1, \
        'TE':-1, \
        'TR':-1, \
        'PatientAge':-1, \
        'PatientId':'', \
        'PatientName':'', \
        'PatientSex':'', \
        'PatientWeight':-1, \
        'PlaneType':'', \
        'ProtocolName':'', \
        'PulseSequenceName':'', \
        'CoilName':'', \
        'SeriesDescription':'', \
        'SeriesNumber':-1, \
        'SeriesTime':-1, \
        'StartImage':-1, \
        'StudyDate':'', \
        'StudyDescription':'', \
        'ExamNumber':''}

def convert_integer(value):
    return "%d" % value
def convert_float(value):
    return ("%f" % value).rstrip('0')
def convert_string(value):
    return value.strip()

num_cvt = {IntType:convert_integer, FloatType:convert_float, \
                StringType:convert_string}


# Make translation table for stripping nonprinting characters.
allchar = string.maketrans(string.printable, string.printable)
transtab = 32*" " + allchar[32:128] + 128*" "


def ndarray_representer(dumper, data):
    """Representor to add numpy ndarray objects to a yaml stream."""
    output = '%s:%s:%s' % (data.shape, data.dtype.char, numpy.array2string(data))
    return dumper.represent_scalar(u'!ndarray', output)

def ndarray_constructor(loader, node):
    """Constructor to read  numpy ndarray objects from a yaml stream."""
    value = loader.construct_scalar(node).split(':')
    datatype = dtype(str(value[1])) # Convert from unicode.
    data = value[2].replace('\n','').replace('[','').replace(']','').split()
    dims = map(int, \
            value[0].replace(')','').replace('(','').replace(',','').split())
    return array(data).astype(datatype).reshape(dims)

def add_ndarray_to_yaml():
    yaml.add_representer(numpy.ndarray, ndarray_representer)
    yaml.add_constructor(u'!ndarray', ndarray_constructor)


# See if a last-ditch tmp directory is defined.
system_tmp = os.getenv('SYSTEM_TMP')
if system_tmp is None:
    system_tmp = '.'

#*******************************
def exec_cmd(cmd, verbose=False):
#*******************************
    """
    Execute command.  Deprecated.
    """
    p = Popen(cmd, shell=True, stderr=PIPE, stdout=PIPE)
    output, errors = p.communicate()
    signl = p.wait()
    if verbose:
        print output
        print errors
    return output, errors

#*************************
def get_hdrname(filename):
#*************************

    """ 
    Function: get_hdrname(filename)
    Purpose: Add extension to an analyze, brik, tes or cub filename.
    Returns: A tuple containing  a valid header filename  and its extension.
    """

    if filename.endswith('+orig') or filename.endswith('+tlrc'):
        return ("%s.HEAD"%filename, '.HEAD')
    elif filename.endswith('.HEAD'):
        return (filename, '.HEAD') 
    elif filename.endswith('.BRIK'):
        filename = os.path.splitext(filename)[0] + '.HEAD'
        return (filename, '.HEAD') 

#   Test extensions.
#    stem, extin = os.path.splitext(filename)
    i = filename.find('.')
    if i > 0:
        stem = filename[:i]
        extin = filename[i:]
    else:
        stem = filename
        extin = ''
#    if not extin.startswith('.') and len(extin) > 0:
#        extin = '.' + extin

    if extin in hexts.keys():
        return filename, extin
    elif extin in iexts.keys():
        ext = iexts[extin]
    else:
#       Extensions don't match, might have no extension, so try 
#                        accessng all possibilities.
        for ext in iexts:
            if os.access("%s%s" % (stem, ext), R_OK):
                break
        if len(extin) > 0:
            if extin.startswith('.'):
                ext = extin
            else:
                ext = '.' + extin
        else:
            ext = ''

    return ('%s%s' % (stem, ext), ext[:])

def isImage(fname):
    if file_type(fname) is None:
        return False
    else:
        return True

#*********************************
def file_type(file_in, slot=None):
#*********************************

    """

    Function: file_type(filename)
    Purpose: Determine type of image file.
    Return codes: analyze, nifti, brik, dicom, ge_ifile (I-file), ge_data 
                  (P-file), cub, tes, biopac
    """


    filename, ext = get_hdrname(file_in)

#   Test filenames if that is all there is to go on.
    nametests = {'.HEAD':'brik', '.BRIK':'brik', '.dcm':'dicom', '.nii':'n+1', \
                 '.nii.gz':'n+1', '.sdt':'sdt', '.spr':'sdt'}
    if nametests.has_key(ext):
        return nametests[ext]

    if os.path.isdir(file_in):
#       Directory specified, Look for a dicom or ifile.
        prefix = '%s/%s' % (file_in, os.path.basename(file_in))
        if os.path.exists(prefix + '.pickle'):
            f = open(prefix + '.pickle', 'r')
            hdr = cPickle.load(f)
            f.close()
            return hdr['filetype']
        elif os.path.exists(prefix + '.yaml'):
#           Summary stored in yaml_file.
            f = open(prefix + '.yaml', 'r')
            info = f.read()
            f.close()
            i0 = info.find('filetype:')
            if 'dicom' in info[i0+10:i0+15]:
                return('dicom')
            elif 'ge_ifile' in info[i0+10:i0+15]:
                return('ge_file')
        for fname in os.listdir(file_in):
            if fname.startswith('.'):
                continue
            fname1 = '%s/%s' % (file_in,fname)
            if os.path.isdir(fname1):
                continue
            elif fname1.endswith('.tar'):
                dt = DicomTar(fname1)
                if dt.isTar:
                    return('dicom')
            try:
                if os.path.isdir(fname1):
                    return None
                f = open_gzbz2(fname1, 'rb')
                testdata = f.read(132)
                f.close()
                if testdata.startswith('IMGF'):
                    return('ge_ifile')
                elif testdata.endswith('DICM') or fname.endswith('dcm'):
                    return('dicom')
                elif testdata.endswith('GEMS PET Export'):
                    return('pet')
                else:
                    return None
            except IOError:
                raise IOError("Could not open %s, aborting ..." % fname1)
    else:
        try:
            if not os.path.exists(filename) and not '.' in filename:
                fname = '%s.nii' % filename
                if os.path.exists(fname):
                    filename = fname
                    ext = '.nii'
            f = open_gzbz2(filename, 'rb')
        except IOError:
            raise IOError("\nfile_type: Could not open %s\n" % filename)

#       Read data that will identify file type.
        if not f:
            return None
        try:
            testdata = f.read(132)
            if len(testdata) < 132:
                return None
        except IOError:
            f.close()
            return None
        linetest = {'VB98\nCUB1':'cub', 'VB98\nTES1':'tes', \
                    'INTERFILE':'4dfp.ifh', 'IMGF':'ge_ifile', \
                    'GEMS PET Export':'ge_pet'}
        for key in linetest.keys():
            if testdata.startswith(key):
                filetype = linetest[key]
                if filetype == 'ge_ifile':
                    if 'sunos' in sys.platform:
                        hdr_lgth = fromstring(testdata[:8], int32)[1]
                    else:
                        hdr_lgth = fromstring(testdata[:8], int32).byteswap()[1]
                    if hdr_lgth != 7904:
                        filetype = 'imgf'
                f.close()
                return filetype

        if testdata.endswith('DICM') or filename.endswith('.dcm'):
#           Siemens dicom files from Iowa don't have the DICM code.
            f.close()
            return('dicom')

#       Read embedded magic numbers, first test for nifti
        nifti_tests = ['.hdr', '.nii', 'n+1']
        nifti_types = {'n+1':'n+1', 'ni1':'ni1'}
        if filename.replace('.gz','')[-4:] in nifti_tests:
            f.seek(344)
            nifti_code = f.read(4)
            f.close()
            return nifti_types.get(nifti_code[:3], 'analyze')

        dt = DicomTar(filename)
        if dt.isTar:
            return('dicom')

#       Test for GE data.
        if os.path.basename(filename) == 'HEADER_POOL':
            return 'ge_data'
        f.seek(0)
        test = f.read(44)
        test = test[34:]
        if len(test) < 10:
            f.close()
            return None
        test =  struct.unpack('10s', test)
        if 'GE_MED_NMR' in test or 'INVALIDNMR' in test:
            f.seek(0)
            testdata = f.read(4)
            rev = struct.unpack('f', testdata)[0]
            if abs(rev) < 1. or abs(rev) > 30:
                #rev =  ("%4.1f" % struct.unpack('>f', testdata)[0]).strip()
                rev =  struct.unpack('>f', testdata)[0]
            if abs(rev) > 1. or abs(rev) < 30:
#               This is a valid revision number
                f.close()
                return('ge_data')
                
            return None

        fmt_ctl_windows = '<'
        fmt_ctl_mac = '>'
        fmt_size = 'hi'
        data = struct.unpack(fmt_ctl_windows+fmt_size, testdata[:6])
        if data[1] > 100 or data[1] < 0:
#        Invalid file version. This must be a mac. Don't byteswap.
            data = struct.unpack(fmt_ctl_mac+fmt_size, testdata[:6])
            if data[1] > 0 and data[1] < 100:
                return 'biopac'
#                biopac_version = data[1]
        else:
            if data[1] > 0 and data[1] < 100:
                return 'biopac'
#                biopac_version = data[1]
            else:
                return None
        
        f.close()
    return None

def readheader(filename, scan=False):
    """
    Read header and return as dictionary.
    """

    hd = Header(filename)
    return hd.get_header()


#*****************************************************************************
def writefile(filename, image, hdr, frame=None, last=True, rescale_ints=False):
#*****************************************************************************

    """
    Write image to a file named "filename" in the image format
        specified by hdr['filetype'] with the data-type specified by
        hdr['datatype'], which takes on values of "byte" "short",
        "float"="float32", double, and complex. (complex32 in numpy)
    Returns  0 on successful completion.
    <filename>: output filename with or without extension.
    <image>: numpy ndarray to be written.
    <frame>: Frame to be written. Mulitple frames can be written to the same file by making multiple calls to writefile.
    <last>: Set to True for the only or last frame. The header will only be written if last=true.
    <rescale_ints>: If True, integer images will be rescaled to the maximum and minimum values for their data type. Appropriate scale factors are stored in the header.
    """

    extensions = {'analyze':'.img', 'ni1':'.img', 'n+1':'.nii', \
                  'brik':'.tmp', 'tes':'.tes', 'nii':'.nii'}
    hext = {'analyze':'.hdr', 'ni1':'.hdr', 'n+1':'.nii', 'nii':'.nii', \
            'brik':'+orig.HEAD', 'tes':'.tes'}

#   Synchronize dims and sizes with ?dim and ?size.
    numvox = prod(hdr['dims'][:])
    prod_dim = hdr['xdim']*hdr['ydim']*hdr['zdim']*hdr['tdim']*hdr['mdim']
    ndim = hdr['ndim']
    ndim = where(array(hdr['dims']) > 0, 1, 0).sum()
    if numvox == prod_dim:
        hdr['num_voxels'] = numvox
    else:
#       The dims array has priority.
        hdr['xdim'] = hdr['dims'][0]
        hdr['ydim'] = hdr['dims'][1]
        hdr['zdim'] = hdr['dims'][2]
        hdr['tdim'] = hdr['dims'][3]
        hdr['mdim'] = hdr['dims'][4]
        hdr['xsize'] = hdr['sizes'][0]
        hdr['ysize'] = hdr['sizes'][1]
        hdr['zsize'] = hdr['sizes'][2]
        hdr['tsize'] = hdr['sizes'][3]
        hdr['msize'] = hdr['sizes'][4]
        hdr['num_voxels'] = numvox

    nvox_in = prod(image.shape)
    if frame is None:
        nvox_hdr = prod(hdr['dims'])
    else:
        nvox_hdr = prod(hdr['dims'][:3])
    if nvox_in != nvox_hdr:
        raise RuntimeError(\
        'Dimensions of input image do not match those in the header: %s.', filename)

    filebase = strip_suffix(filename)

    outdir = os.path.dirname(filebase)
    if len(outdir) == 0:
        outdir = "."
    outdir = os.path.realpath(outdir)
    hdrname = "%s%s" % (filebase, hext[hdr['filetype']])

    filetype = hdr['filetype']

#   Get output filename.
    imgfile = "%s%s" % (filebase, extensions[filetype])

    if filetype == 'tes':
#       Handle tes files separately due to unique format.
        status = write_tes(filename, image, hdr)
        return status


    if frame is not None and image.ndim > 3:
        img = image[frame, :, :, :]
    else:
        img = image

#   Rescale image to fit in output data type.
    if hdr['filetype'] != 'brik':
#       Not a brik, so it's nifti, tes or analyze.
        if hdr['datatype'] in ['byte', 'short'] and \
           hdr['filetype'] != 'brik' and rescale_ints:
            img, scale_factor, scale_offset, image_min, image_max = \
                                            rescale(img, hdr['datatype'])
        else:
            img = image
            scale_factor, scale_offset = (1., 0.)
            image_min = img.min()
            image_max = img.max()
        hdr['scale_factor'] = scale_factor
        hdr['scale_offset'] = scale_offset

        if hdr['filetype'] == 'analyze':
            if hdr['start_binary'] % 16:
#               Data must start on 16-byte boundary for SPM compatibility.
                hdr['start_binary'] = 16*(hdr['start_binary']/16 + 1)

        if img.dtype == 'float':
            img = img.astype(float32)
        hdr['imgfile'] = filebase
        if last:
#           Write the header with the last frame for two-file formats.
            if filetype == 'analyze':
                hdr['native_header']['glmin'] = image_min
                hdr['native_header']['glmax'] = image_max
                write_analyze_header(hdrname, hdr)
            elif filetype in ['ni1', 'n+1','nii']:
                hdr['native_header']['glmin'] = image_min
                hdr['native_header']['glmax'] = image_max
                if frame == None or frame == 0:
                    newfile = True
                else:
                    newfile = False
                write_nifti_header(hdrname, hdr, newfile=newfile)

#       Write the image.
        if hdr['filetype'] == 'ni1':
            hdr['start_binary'] = 0
        elif hdr['filetype'] == 'nii' or  hdr['filetype'] == 'n+1':
            hdr['start_binary'] = 352
        if hdr['filetype'] == 'n+1' or hdr['filetype'] == 'nii':
            if frame == 0:
#               Assume that first frame is written first so existing file
#               can be erased. Otherwise older file will be retained if it 
#               is longer than the new one.
                f = open(imgfile, "wb")
            else:
                f = open(imgfile, "rb+")
            f.seek(0, 2)
        else:
            f = open(imgfile, "wb")
        if frame is not None:
            offset = hdr['start_binary']+frame*hdr['xdim']*hdr['ydim']* \
                        hdr['zdim']*datatype_to_lgthbytes[hdr['datatype']]
        else:
            offset = hdr['start_binary']
        f.seek(offset,0)
        if hdr['swap']:
            f.write(img.byteswap().tostring())
        else:
            f.write(img.tostring())
        f.close()
    else:
#       Use to3d to convert tmp file into BRIK.
        wb = WriteBrik(filename, hdr, img)()

    return 0


class WriteBrik():
    """
    Creates and output buffer to store sub-bricks as they are added, then
    call to3d to write it as a brik file.
    """
    def __init__(self, prefix, hdr=None, image=None, frame=None, force=True):
        self.prefix = strip_suffix(prefix)
        self.outdir = os.path.dirname(prefix)
        self.force = force

#       Get tmp space
        max_required = (2*hdr['xdim']*hdr['ydim']*hdr['zdim']*\
                        hdr['tdim']*hdr['mdim']*8)/1e6 + 400
        self.tmp = GetTmpSpace(max_required, system_tmp)
        self.tmpdir = self.tmp()
        self.tmpfile = '%s/%s.tmp' % (self.tmpdir,os.path.basename(self.prefix))
        self.f = open(self.tmpfile, 'a+')

        self.hdr = self.ProcessHeader(hdr)
        self.nframe = 0

        if image is not None:
#           Add the first image
            self.AddImage(image, frame)

    def ProcessHeader(self, hdr):
        """
        Workaround bugs in third-party packages that create files with
        incomplete or incorrect nifti headers.
        """
        if hdr is None:
            return None
#       Workaround for Freesurfer bug.
        hdr['dims'] = where(hdr['dims'] <= 0, 1, hdr['dims'])
        hdr['xdim'],  hdr['ydim'], hdr['zdim'], hdr['tdim'], hdr['mdim'] = \
                                                hdr['dims'][:5].tolist()
        hdr['xsize'],  hdr['ysize'], hdr['zsize'], hdr['tsize'], hdr['msize'] =\
                                                hdr['sizes'][:5].tolist()
        hdr['num_voxels'] = prod(hdr['dims'])
        hdr['imgfile'] = self.prefix
        hdr['scale_offset'] = 0.
        hdr['scale_factor'] = 1.
        self.xyzdim = prod(hdr['dims'][:3])
        self.voxel_bytes = datatype_to_lgthbytes[hdr['datatype']]
        return hdr

    def AddImage(self, image, frame=None, last=False, history_note=None):
        """
        Add a frame of data to the output buffer.
        """
        if image.dtype == float64:
#           Afni briks don't support 64-bit floats.
            img = image.astype(float32)
        else:
            img = image
        self.datum_type = img.dtype.char
        if frame is not None:
            self.nframe = max(frame, self.nframe-1) + 1
            self.f.seek(frame*self.xyzdim*self.voxel_bytes)
        self.f.write(img.tostring())

        if last is True:
            self.Finish(history_note=history_note)

    def __call__(self):
        self.Finish()

    def Finish(self, history_note=None):
        """
        Use to3d to convert the buffer file a brik file.
        """
        self.f.close()
        to3d_cmd, refit_cmd = make_to3d_cmd(self.tmpfile, self.prefix, \
                                        self.outdir, self.hdr, self.datum_type)
        if self.force:
            if os.path.exists(self.prefix+"+orig.BRIK"):
                exec_cmd('/bin/rm %s+orig.BRIK' % self.prefix)
            if os.path.exists(self.prefix+"+orig.HEAD"):
                exec_cmd('/bin/rm %s+orig.HEAD' % self.prefix)
        out, errs = exec_cmd(to3d_cmd, verbose=False)
        if refit_cmd is not None:
            exec_cmd(refit_cmd, verbose=False)
        modify_HEAD(self.hdr)
        if history_note is not None:
            fname = '%s.HEAD' % self.hdr['imgfile'].replace('.BRIK','')
            old_note = self.hdr['native_header'].get('history_note', '')
            append_history_note(self.prefix + '+orig', \
                                            legacy_history_note=history_note)
        self.tmp.Clean()

def strip_suffix(fname):
    """
    Remove the .nii, .img, .hdr, BRIK etc suffixes from <fname>
    """
    filebase = fname.strip().replace('.nii','')
    filebase = filebase.replace('.img','')
    filebase = filebase.replace('.hdr','')
    filebase = filebase.replace('.BRIK','')
    filebase = filebase.replace('.HEAD','')
    filebase = filebase.replace('+orig','')
    return filebase

#*****************************
def modify_nifti_auxfile(hdr):
#*****************************

    """
    Encode echo-spacing, phase encode axis, and phase encode direction in
    the "aux_file" field for later use.
    Arguments: hdr: Any header.
    Returns: Always True
    """

    subhdr = hdr['subhdr']
    nhdr = hdr['native_header']
    newdescrip = "__"
    if hdr['native_header'].has_key('PEPolar'):
        pepolar =  int(hdr['native_header']['PEPolar'])
    elif hdr['native_header'].has_key('SeriesDescription'):
#       This assumes tech entered "pepolar=1" in the series description.
        test = hdr['native_header']['SeriesDescription'].replace(' ','').lower()
        if 'pepolar=1' in test:
            pepolar = 1
        else:
            pepolar = -1
    else:
        pepolar = -1
    if pepolar > 0:
        newdescrip = "%sPP=%0d_" % (newdescrip, pepolar)
    phase_enc_dir =  hdr['native_header'].get('PhaseEncDir','')
    if phase_enc_dir is None:
        phase_enc_dir = ''
        
    if hdr['native_header'].has_key('EffEchoSpacing'):
        if  hdr['native_header']['EffEchoSpacing'] > 0:
            newdescrip = "%sES=%0d_" % (newdescrip, \
                                int(hdr['native_header']['EffEchoSpacing']))
    if hdr['native_header'].has_key('PhaseEncDir'):
        newdescrip = "%sPD=%s" % (newdescrip, phase_enc_dir.strip())
    if len(newdescrip) > 1:
        newdescrip = "%s__" % newdescrip
    if len(nhdr.get('aux_file','')) == 0:
        nhdr['aux_file'] = newdescrip
    return True


def append_history_note(filename, text=None, legacy_history_note=''):
    """
    Appends "text" to the end of the HISTORY_NOTE field of an AFNI .HEAD file.
    """
    if filename.endswith('.HEAD'):
        hdrfile = filename
    elif filename.endswith('+orig') or filename.endswith('+tlrc'):
        hdrfile = '%s.HEAD' % filename
    else:
        raise RuntimeError('Did not recognize filetype: %s' % filename)
    if not os.path.exists(hdrfile):
#       Probably an operation on just the brik file.
        return
    f = open(hdrfile, 'r')
    lines = f.readlines()
    f.close()
    if len(lines) == 0:
        return
    old_note = ''
    for i in xrange(len(lines)):
        wds = lines[i].split()
        if len(wds) > 2:
            if wds[0] == 'name' and wds[2] == 'HISTORY_NOTE':
                old_note += lines[i+2].strip()[1:-1]
                break
    old_note += legacy_history_note
    host = gethostname()
    username = os.getenv('LOGNAME')
    tod = datetime.today().strftime('%a %b %d %X')
    if text is None:
        text =  ''.join(sys.argv)
    new_note = "'%s\\n[%s@%s %s] %s~\n" % \
                            (old_note, username, host, tod, ' '.join(sys.argv))
    f = open(hdrfile, 'w')
    for i in xrange(len(lines)):
        wds = lines[i].split()
        if len(wds) > 2 and wds[0] == 'name' and wds[2] == 'HISTORY_NOTE':
                f.write(lines[i])
                f.write('count = %d\n' % (len(new_note) - 2))
                f.write(new_note)
                break
        else:
            f.write(lines[i])
    f.writelines(lines[i+3:])
    f.close()

#********************
def modify_HEAD(hdr):
#********************

    """
    Purpose: Encode echo-spacing, phase encode axis, and phase encode 
        in a string and insert it in the HISTORY field of the .HEAD file.
    Argument: hdr: Any valid hdr. The imgfile entry will be used to 
        the name of the file to be modified.
    """

    subhdr = hdr['subhdr']
    nhdr = hdr['native_header']
    newline = "__"
    if hdr['native_header'].has_key('PEPolar'):
        pepolar =  int(hdr['native_header']['PEPolar'])
    elif hdr['native_header'].has_key('SeriesDescription'):
#       This assumes tech entered "pepolar=1" in the series description.
        test = hdr['native_header']['SeriesDescription'].replace(' ','').lower()
        if 'pepolar=1' in test:
            pepolar = 1
        else:
            pepolar = -1
    else:
        pepolar = -1
    if pepolar > 0:
        newline = "%sPEPolar=%0d__" % (newline,pepolar)
    if hdr['native_header'].has_key('EffEchoSpacing'):
        if  hdr['native_header']['EffEchoSpacing'] > 0:
            newline = "%sEffEchoSpacing=%0d__" % (newline, \
                                int(hdr['native_header']['EffEchoSpacing']))
    if hdr['native_header'].has_key('PhaseEncDir'):
        newline = "%sPhaseEncDir=%s__" % (newline, hdr['native_header']\
                                ['PhaseEncDir'].strip())
    if len(newline) > 1:
        if len(newline) == 2:
            newline = ''
        try:
            fname = '%s.HEAD' % hdr['imgfile'].replace('.BRIK','')
            f = open(fname, 'rb+')
            x = f.read()
            i1 = x.find("name = HISTORY_NOTE\ncount =")
            i2 = i1 + x[i1:].find("'")
            i3 = i2 + x[i2:].find('~')
            y = "%sname = HISTORY_NOTE\ncount = %0d\n%s%s%s" % \
                         (x[:i1], i3-i2+1+len(newline), x[i2:i3], newline, x[i3:])
            f.seek(0)
            f.write(y)
            f.close()
        except IOError:
            sys.stderr.write( \
            'modify_HEAD: Error while adding tags to header: %s\n'%fname)

#******************************************
def rescale(image, datatype, compute_only=0):
#******************************************

    """
    
    Function: img = rescale(image, datatype)
    Purpose: Convert a floating point image to a scaled integer image.
    Arguments:
        image: A numpy array object.
        datatype: Type of integer, 'short' for signed int, 
        'byte' for unsigned char

    Returns:
        Tuple containg image, scale-factor, and offset (offset =0 for short)
        i.e, returns (image, scale_factor, offset)

    """

    amin = float(image.min())
    amax = float(image.max())
    scale_factor = 1.
    if datatype == 'short':
        scale_factor = 16383/max(amax, -amin)
        offset = 0
    elif datatype == 'byte':
        scale_factor = 254/(amax-amin)
        offset = amin

    if compute_only:
        return (image.astype(datatype), 1./scale_factor, offset, amin, amax)
    else:
        return ((scale_factor*(image-offset)).astype(datatype), \
                1./scale_factor, offset, amin, amax)

#*********************************
def read_analyze_header(filename):
#*********************************

    """
    Inputs: Name of header file.
    Outputs: Dictionary containing header.
    """
    datacode_to_lgth = {1:1, 2:1, 4:2, 8:4, 15:4, 32:8, 64:8}
    
    try:
        f = open_gzbz2(filename, 'rb')
    except IOError:
        sys.stderr.write(\
        "\nfile_io:read_analyze_header: *** Could not open %s\n" % filename)
        return None
    try:
        data = f.read(348)
    except IOError:
        sys.stderr.write(\
        "\nread_analyze_header: Could not read from %s\n" % filename)
        return None
    f.close()
    if len(data) < 348:
        sys.stderr.write(\
        "\nread_analyze_header: Could not read from %s\n" % filename)
        return None

    format = "i 10s 18s i h c c 8h 4s 8s h h h h 8f f f f f f f i i 2i 80s  \
                24s c 3h 4s 10s 10s 10s 10s 10s 3s i i i i 2i 2i"

    fmt = "<" + format
    vhdr = struct.unpack(fmt, data)
    f.close()

    length = vhdr[0]
    if length == 348:
        swap = 0
    else:
        swap = 1
        fmt = ">" + format
        vhdr = struct.unpack(fmt, data)


    xdim, ydim, xsize, ysize, zsize = \
                        (vhdr[8], vhdr[9], vhdr[22], vhdr[23], vhdr[24])
    if vhdr[10] > 1 and vhdr[11] > 0 and vhdr[12] > 0:
        ndim = 5
        mdim = vhdr[12]
        tdim = vhdr[11]
        zdim = vhdr[10]
    elif vhdr[10] > 1 and vhdr[11] > 0:
        ndim = 4
        mdim = 1
        tdim = vhdr[11]
        zdim = vhdr[10]
    elif vhdr[10] > 1:
        ndim = 3
        mdim = 1
        tdim = 1
        zdim = vhdr[10]
    else:
        ndim = 2
        mdim = 1
        tdim = 1
        zdim = 1

#   Create rotation matrix.
    if vhdr[41].isdigit():
        orient_code = int(vhdr[41])
    else:
        orient_code = 0

#    R = orientecode_to_R(int(orient_code), vhdr[42], vhdr[43], vhdr[44])
#    orientation = analyze_orientcode_to_orient[orient_code]
#   Set R to zero since it is almost always wrong for analyze data.
    R = zeros([4,4],float)
    orientation = 0

    datatype = vhdr[18]
#    Using cal_max as scale factor rather than funused1
    if vhdr[41].isalnum():
        sorient_code = vhdr[41]
    else:
        sorient_code = '0'
    whdr = { 'start_binary':0, 'filetype':'analyze', \
        'orientation':orientation, 'ndim':vhdr[7], 'xdim':vhdr[8], \
        'ydim':vhdr[9], 'zdim':zdim, 'tdim':tdim, \
        'mdim':mdim, 'ndim':ndim, 'msize':vhdr[26], \
        'num_voxels':vhdr[8]*vhdr[9]*zdim*tdim*mdim, \
        'bitpix':vhdr[19], 'xsize':vhdr[22], 'ysize':vhdr[23], \
        'zsize':vhdr[24], 'TR':vhdr[25], 'scale_factor':vhdr[30], \
        'orient_code':sorient_code, 'x0':vhdr[42], 'y0':vhdr[43], \
        'z0':vhdr[44], 'datatype':analyze_datacode_to_type[datatype], \
        'R':R, 'top_left_corner':analyze_orientcode_to_orient[orient_code], \
        'orientation':analyze_orientcode_to_orient[orient_code], 'swap':swap}

    if whdr['scale_factor'] == 0.:
        whdr['scale_factor'] = 1.

    return(whdr)

#******************************************
def orientecode_to_R(orient_code, x0, y0, z0):
#******************************************

    """
    Returns: 4x4 Transformation matrix.
    Arguments:
        orient_code: Valid orient code for Analyze format, 0 <= orient_code <= 6
        x0, y0, z0: origin in RAI coordinates.
    """

    Rpos = {0:(0,4,8), 1:(0,5,7), 2:(2,3,7), 3:(0,4,8), 4:(0,5,7), 5:(2,3,7), \
            6:(0,4,8)}

    Rval = {0:(0., 0.,0.), 1:(1.,1.,-1.), 2:(-1.,1.,1.), 3:(1.,1.,1.), \
            4:(1.,-1.,-1.), 5:(-1.,-1.,1.),6:(-1.,-1.,1.)}

    Rrot = zeros((9), float)
    Rrot.put(array(Rpos[orient_code]), array(Rval[orient_code]))
    R = zeros((4, 4), float)
    R[:3, :3] = Rrot.reshape([3, 3])
    R[:, 3] = array([x0, y0, z0, 1.])

    return(R)

#********************************************
def orientestring_to_R(orient_code, x0, y0, z0):
#********************************************

    """
    Returns: 4x4 Transformation matrix.
    Arguments:
        orient_code: 3-character orientation code, e.g. RAI, LPI etc
        x0, y0, z0: origin in RAI coordinates.
    """

    Rpos = {'RPI':(0,4,8),'RIP':(0,5,7),'PIR':(2,3,7),'RAI':(0,4,8),\
            'RSP':(0,5,7),'PSR':(2,3,7),'LPI':(0,4,8),'ASR':(2,3,7),\
            'RSA':(0,5,7),'ASL':(2,3,7),'OBL':(0,4,8),'LAI':(0,4,8),\
            '???*':(0,4,8)}

    Rval = {'RPI':(1.,-1.,1.),'RIP':(1.,1.,-1.),'PIR':(-1.,1.,1.),\
            'RAI':(1.,1.,1.),'RSP':(1.,-1.,-1.),'PSR':(-1.,-1.,1.),\
            'LPI':(-1.,-1.,1.),'ASR':(1.,-1.,1.),'RSA':(1.,-1.,1.),\
            'ASL':(1.,-1.,-1.),'OBL':(1.,1.,1.),'LAI':(-1.,1.,1.),\
            '???*':(0.,0.,0.)}

    cvt_ambiguous = {'AS?':'ASL', 'RA?':'RAI', 'RS?':'RSA'}
    code = cvt_ambiguous.get(orient_code, orient_code)

    Rrot = zeros((9), float)
    Rrot.put(array(Rpos[orient_code]), array(Rval[orient_code]))
    R = zeros((4, 4), float)
    R[:3, :3] = Rrot.reshape([3, 3])
    R[:, 3] = array([x0, y0, z0, 1.])

    return(R)

#******************************
def read_afni_header(filename):
#******************************

    """
    Returns a dictionary containing entire AFNI header.
    """

    afni_keys = ['type', 'name', 'count']

    class AFNIItem:
        def __init__(self, filename):
            self.idx = -1
            try:
                f = open_gzbz2(filename, 'rb')
                if f is None:
                    raise IOError
            except IOError:
                sys.stderr.write('\nError opening %s\n\n'%filename)
                self.lines = []
                return None
            self.lines = f.readlines()
            f.close()
            self.converters = {'string-attribute':self._string_attribute, \
                            'integer-attribute':self._integer_attribute, \
                            'float-attribute':self._float_attribute, \
                            'None':self._None_attribute}
        def __iter__(self):
            return self
        def next(self):
            item = {'count':0, 'type':'None', 'name':''}
            while True:
                self.idx = self.idx + 1
                if self.idx > len(self.lines)-1:
                    raise StopIteration
                line = self.lines[self.idx].strip()
                words = line.split(" =")
                key = words[0].strip()
                if key in afni_keys:
                    item[key] = words[1].strip().lower()
                    continue
                elif len(key) == 0:
                    continue
                if item['name'] != "history_note":
                    conc_line = line.split()
                    while len(line.strip()) > 0 and  \
                             line.split()[0].strip() not in afni_keys:
                        self.idx = self.idx + 1
                        if self.idx > len(self.lines)-1:
                            break
                        line = self.lines[self.idx].strip()
                        conc_line = conc_line + line.split()
                    value = apply(self.converters[item['type']], \
                                     (conc_line, int(item['count'])))
                else:
                    value = line[1:-1]
                    self.idx = self.idx + 1
                    if self.idx > len(self.lines)-1:
                        break
                if len(value) == 1:
                    value = value[0]
                return(item['name'], value)
        def _string_attribute(self, line, count):
            return(line[0][1:-1])
        def _integer_attribute(self, line, count):
            return(map(int, line))
        def _float_attribute(self, line, count):
            return(map(float, line))
        def _None_attribute(self, line, count):
            return('')

    whdr = {}
    for item in AFNIItem(filename):
        if isinstance(item, tuple):
            whdr[item[0]] = item[1]
        else:
            sys.stderr.write(\
            "\nread_afni_header: Invalid item in %s\n" % filename)
            return None
    if len(whdr) == 0:
        return None

    try:
        if whdr['dataset_rank'][1] > 1 and whdr.has_key('taxis_nums'):
            if whdr['taxis_nums'][2] == 77001:
                whdr['TR'] = float(whdr['taxis_floats'][1])
            elif whdr['taxis_nums'][2] == 77002:
                whdr['TR'] = whdr['taxis_floats'][1]*1000.
            elif whdr['taxis_nums'][2] == 77003:
                whdr['TR'] = whdr['taxis_floats'][1]/1000.
            else:
                sys.stderr.write(\
                "\nread_afni_header: Could not find TR scaling.\n")
                return None
        else:
            whdr['TR'] = 0.

        if whdr.has_key('history_note'):
#           Decode info in HISTORY_NOTE.
            info = whdr['history_note']
            words = info.split('__')
            for tag in words[1:-1]:
                if len(tag) > 0:
                    wds = tag.split('=')
                    if len(wds) > 1:
                        whdr[wds[0]] = apply(num_cvt[type(wds[1])], [wds[1]])
            if whdr.get('PEPolar', 1) < 0:
                del whdr['PEPolar']
    except KeyError:
        sys.stderr.write('read_afni_header: Could not parse %s' % filename)
        return None

#   Get slice ordering.
    if whdr.has_key('taxis_offsets'):
        TR = whdr['TR']/1000.
        if abs(whdr['taxis_offsets'][0]) < .001 and \
           abs(whdr['taxis_offsets'][1] - TR/2) < .001:
            whdr['SliceOrder'] = 'altplus'
        elif abs(whdr['taxis_offsets'][-1]) < .001 and \
           abs(whdr['taxis_offsets'][-2] - TR/2) < .001:
            whdr['SliceOrder'] = 'altminus'
        else:
            raise RuntimeError('Could not determine slice ordering for %s' % \
                                                                    filename)
    else:
        whdr['SliceOrder'] = 'zero'
            
    return whdr


#**********************************
def read_voxbo_header(filename):
#**********************************
    """
    Purpose: Return native tes header as a dictionary.
    """

    whdr = {}
    lines = []
    f = open_gzbz2(filename, 'rb')
    line = f.readline()
    while line != '\f\n':
#       Read in header.
        lines.append(line.strip())
        line = f.readline()
    whdr['start_binary'] = f.tell()
    f.seek(0, 2)
    whdr['datalength'] = f.tell() -  whdr['start_binary']
    f.close()
    
#   First two lines identify the  file type.
    for line in lines[2:]:
        words = line.split()
        if len(words) < 1:
            continue
        key = words[0].strip()
        data = words[1:]
        if len(data) == 0:
            continue
        if data[0].strip().isdigit() or data[0].startswith('-'):
#           This is an integer.
            value = map(int, data)
        elif data[0].strip().replace('.', '0').isdigit():
#           This is a float
            value = map(float, data)
        else:
#           It's a string
            value = " ".join(data)
        whdr[key] = value
    if whdr['DataType:'] == 'integer':
        whdr['DataType:'] = 'short'
        whdr['datalength'] = whdr['datalength']/2

    if whdr.has_key('Orientation:'):
        sizes = whdr['Origin(XYZ):']
        whdr['R'] = orientestring_to_R(\
                        whdr['Orientation:'], sizes[0], sizes[1], sizes[2])
    else:
        whdr['R'] = identity(4).astype(float)


    return(whdr)

#******************************
def read_nifti_header(hdrname):
#******************************

    """ 
    Read native nifti header into a dictionary.
    """

    try:
        f = open_gzbz2(hdrname, 'rb')
        if f is None:
            raise IOError
    except IOError:
        sys.stderr.write('Error while opening %s\n' % hdrname)
        return None
    whdr = {}

#   Check for byteswapping.
    fmt = 'i10s18sihcB8hfffhhhh8ffffhcbffffii80s24shhffffff4f4f4f16s4s'
    slgth = f.read(4)
    lgth = struct.unpack('<i', slgth)[0]
    if lgth == 348:
        fmt = "<" + fmt
        whdr['swap'] = 0
    else:
        whdr['swap'] = 1
        fmt = ">" + fmt
        lgth = struct.unpack('>i', slgth)[0]
    if lgth != 348:
        raise IOError('\nFile is not in nifti format: %s\n'%hdrname)

#   Now read the data.
    f.seek(0)
    if '.nii' in hdrname[-8:]:
#       One file format, read a bit more to include potential extension header.
        hdrdata = f.read(lgth + 4)
    else:
#       Two file format. Read the whole thing.
        hdrdata = f.read()
    lgth = struct.calcsize(fmt)
    vhdr = struct.unpack(fmt, hdrdata[:lgth])

#   Read extension header if there is one.
    if len(hdrdata) > lgth:
        whdr['extcodes'] = fromstring(hdrdata[-4:],ubyte).tolist()
        if whdr['extcodes'][0] == 1:
#           Extension is present.
            esize, ecode = struct.unpack('<ii', f.read(8))
            whdr['esize'] = esize
            whdr['ecode'] = nifti_ecode_decode[ecode]
            whdr['ecode'] = ecode
            whdr['edata'] = f.read(esize-8)
        else:
            whdr['esize'] = 0
        f.close()
    else:
        whdr['esize'] = 0
    
    whdr['start_binary'] = vhdr[0] + whdr['esize']
    whdr['sizeof_hdr'] = vhdr[0] # MUST be 348 int sizeof_hdr;     
# ++UNUSED++ char data_type[10]; 
    whdr['data_type'] = string.translate(vhdr[1][:10], transtab) 
# ++UNUSED++ char db_name[18];   
    whdr['db_name'] = string.translate(vhdr[2][:18], transtab) 
    whdr['extents'] = vhdr[3] # ++UNUSED++ int extents;        
    whdr['session_error'] = vhdr[4] # ++UNUSED++ short session_error;
    whdr['regular'] = vhdr[5] # ++UNUSED++ char regular;       
    whdr['dim_info'] = vhdr[6] # MRI slice ordering. char hkey_un0;      
#    if not whdr['dim_info'].isdigit():
#        whdr['dim_info'] = '0'

    dim = zeros([8], int)
    for i in range(8):
        dim[i] = vhdr[7+i]
    whdr['dim'] = dim # Data array dimensions.   short dim[8];       
    whdr['intent_p1'] = vhdr[15] # 1st intent parameter. short unused8;      
    whdr['intent_p2'] = vhdr[16] # 2nd intent parameter. short unused10;     
    whdr['intent_p3'] = vhdr[17] # 3rd intent parameter. short unused12;     
    whdr['intent_code'] = vhdr[18] # NIFTI_INTENT_* code.  short unused14;     
    whdr['datacode'] = vhdr[19] # Defines data type! short datatype;     
    whdr['bitpix'] = int(vhdr[20]) # Number bits/voxel. short bitpix;       
    whdr['slice_start'] = vhdr[21] # First slice index. short dim_un0;      
    pixdim = zeros([8], float32)
    for i in range(8):
        pixdim[i] = vhdr[22+i]
    whdr['pixdim'] = pixdim # Grid spacings. float pixdim[8];    
    whdr['vox_offset'] = vhdr[30] # Offset into .nii file float vox_offset;   
    whdr['scl_slope'] = vhdr[31] # Data scaling: slope. float funused1;     
    if whdr['scl_slope'] == 0.:
        whdr['scl_slope'] = 1.
    whdr['scl_inter'] = vhdr[32] # Data scaling: offset. float funused2;     
    whdr['slice_end'] = vhdr[33] # Last slice index. float funused3;     
    whdr['slice_code'] = vhdr[34] # Slice timing order.  
    if not whdr['slice_code'].isdigit():
        whdr['slice_code'] = '0'
    whdr['xyzt_units'] = vhdr[35] # Units of pixdim[1..4]
    if not whdr['xyzt_units']:
        whdr['xyzt_units'] = 0
    whdr['cal_max'] = vhdr[36] # Max display intensity float cal_max;      
    whdr['cal_min'] = vhdr[37] # Min display intensity float cal_min;      
    whdr['slice_duration'] = vhdr[38] # Time for 1 slice. float compressed;   
    whdr['toffset'] = vhdr[39] # Time axis shift. float verified;     
    whdr['glmax'] = vhdr[40] # ++UNUSED++ int glmax;          
    whdr['glmin'] = vhdr[41] # ++UNUSED++ int glmin;          
#   any text you like. char descrip[80];   
    whdr['descrip'] = string.translate(vhdr[42][:80], transtab) 
#   auxiliary filename. char aux_file[24];  
    whdr['aux_file'] = string.translate(vhdr[43][:24], transtab) 
    whdr['qform_code'] = vhdr[44] # NIFTI_XFORM_* code. -- all ANALYZE 7.5 --
    whdr['sform_code'] = vhdr[45] # NIFTI_XFORM_* code. fields below here 
    whdr['quatern_b'] = vhdr[46] # Quaternion b param.  
    whdr['quatern_c'] = vhdr[47] # Quaternion c param.  
    whdr['quatern_d'] = vhdr[48] # Quaternion d param.  
    whdr['qoffset_x'] = vhdr[49] # Quaternion x shift.  
    whdr['qoffset_y'] = vhdr[50] # Quaternion y shift.  
    whdr['qoffset_z'] = vhdr[51] # Quaternion z shift.  

    srow_x = zeros([4], float)
    for i in range(4):
        srow_x[i] = vhdr[52+i]
    whdr['srow_x'] = srow_x # 1st row affine transform.  
    srow_y = zeros([4], float)
    for i in range(4):
        srow_y[i] = vhdr[56+i]
    whdr['srow_y'] = srow_y # 2nd row affine transform.  
    srow_z = zeros([4], float)
    for i in range(4):
        srow_z[i] = vhdr[60+i]
    whdr['srow_z'] = srow_z # 3rd row affine transform.  
#   'name' or meaning of data. 
    whdr['intent_name'] = string.translate(vhdr[64][:16], transtab) 
    whdr['magic'] = vhdr[65][:3] # MUST be "ni1\0" or "n+1\0".
#   Decode nifti entries.
    whdr['num_voxels'] = int(whdr['dim'][1]*whdr['dim'][2]*whdr['dim'][3]*\
                        whdr['dim'][4]*whdr['dim'][5])
    dim_info = int(whdr['dim_info'])
    whdr['freq_dim'] = dim_info & 3
    whdr['phase_dim'] = (dim_info >> 2) & 3
    whdr['slice_dim'] = (dim_info >> 4) & 3
    whdr['SliceOrder'] = nifti_slice_order_decode.get(whdr['slice_code'], \
                nifti_slice_order_decode['0'])
    whdr['intent_class'] = nifti_intent_decode.get(whdr['intent_code'], \
                nifti_intent_decode[0])
    whdr['qform'] = nifti_sqform_decode.get(whdr['qform_code'], '0')
    whdr['sform'] = nifti_sqform_decode.get(whdr['sform_code'], '0')
    whdr['datatype'] = nifti_datacode_to_type[whdr['datacode']]
    whdr['qfac'] = whdr['pixdim'][0]
    xyzt_units = int(whdr['xyzt_units'])
    if xyzt_units:
        whdr['space_units'] = nifti_units_decode.get(xyzt_units & 0x3, '0')
        if xyzt_units & 0x20:
            whdr['misc_units'] = nifti_units_decode.get(xyzt_units & 0x38, '0')
        else:
            whdr['time_units'] = nifti_units_decode.get(xyzt_units & 0x18, '0')
    else:
        whdr['space_units'] = ''
        whdr['time_units'] = ''
        whdr['misc_units'] = ''

    aux_file_code = {'PD':'PhaseEncDir','PP':'PEPolar','ES':'EffEchoSpacing'}
    code = whdr['aux_file'].strip()
    if code.startswith('__') and code.endswith('__'):
#       Contains encoded data.
        for word in whdr['aux_file'][2:-2].split('_'):
            subword = word.split('=')
            name = aux_file_code.get(subword[0],None)
            if name is not None:
                if subword[1].isdigit():
                    value = int(subword[1])
                else:
                    value = subword[1]
                whdr[name] = value
        if whdr.get('PEPolar', 1) < 0:
            del whdr['PEPolar']

    return(whdr)


#*******************************
def read_ge_Ifile(filename, hdr):
#*******************************

    """
    Purpose: Read ifiles in a given directory and return as an ndarray object.
    Arguments:
        filename: filename of image to be read.
        hdr: Header file.
    """

    file = os.path.realpath(filename)
    if os.path.isdir(file):
        dir = file
    else:
        dir = os.path.dirname(file)
        if len(dir) == 0:
            dir = os.path.cwd()

    xdim, ydim, zdim, tdim, mdim  = hdr['dims'][:5]
    nhdr = hdr['native_header']

#   Find I-files in the specified directory.
    img_files = []
    for file in os.listdir(dir):
        fullpath = "%s/%s" % (dir, file)
        if isIfile(fullpath):
            img_files.append(fullpath)
    img_files.sort()

    if nhdr['PulseSequenceName'].strip().lower() == '2dfast' and \
                                                    hdr['ndim'] == 5:
#       Field map data. reorder them. Acquired in order M-P-R-I
        idx = range(0, 8*zdim, 4) + range(1, 8*zdim, 4) + \
              range(2, 8*zdim, 4) + range(3, 8*zdim, 4)
        mdim = 4; tdim = 2
        hdr['mdim'] = 4; hdr['tdim'] = 2; hdr['dims'][3:5] = array([2,4])
    else:
        idx = range(zdim*tdim*mdim)

#   Read the files.
    image = zeros((mdim*tdim*zdim, ydim, xdim)).astype(float)
    length = int(xdim*ydim*hdr['bitpix']/8)
    for z in range(zdim*tdim*mdim):
#        sys.stdout.write('.')
#        sys.stdout.flush()
        zin = idx[z]
        f_img = open_gzbz2(img_files[zin], "rb")
        f_img.seek(hdr['start_binary'])
        img = fromstring(f_img.read(length), hdr['datatype']).byteswap()
        if len(img) != xdim*ydim:
            raise RuntimeError("\n**** file_io::read_file: Read from %s failed.\n%d words read; %d words requested.\n" % (img_files[z], len(img), xdim*ydim))

        image[z, :, :] =  reshape(img, (ydim, xdim))
        f_img.close()


    return reshape(image, [hdr['mdim'], tdim, zdim, ydim, xdim])

#***********************************
def read_GE_ipfile(filename, slot=0):
#***********************************

    """
    Read header from GE I or P-file.
    Returns a dictionary containing the header.
    """
    try:
        import geio
    except ImportError, errmsg:
        sys.stderr.write(\
                "\n%s\nP-files can only be read under Linux systems " % errmsg + \
                "with gcc and with GE-proprietary header files.\n\n")
        return None

    freqdir_lookup = {2:"ROW", 1:"COL", "":"N/A"}

    if os.path.isdir(filename):
        fnames = os.listdir(filename)
        nfiles = 0
        for fname in fnames:
            if isIfile('%s/%s' % (filename, fname)):
                nfiles += 1
        if "I.001" in fnames:
            fname = "%s/I.001" % filename
        elif "I.001.gz" in fnames:
            fname = "%s/I.001.gz" % filename
        elif "I.001.bz2" in fnames:
            fname = "%s/I.001.bz2" % filename
        else:
            sys.stderr.write(\
            '\nread_GE_ipfile: Could not find "I.001" in %s\n' % filename)
            return None
    else:
        nfiles = 1
        if os.path.exists(filename):
            fname = filename
        elif os.path.exists('%s.gz' % filename):
            fname = '%s.gz' % filename
        elif os.path.exists('%s.bz2' % filename):
            fname = '%s.bz2' % filename
        else:
            sys.stderr.write("\nread_GE_ipfile: Could not find %s\n", fname)

    try:
        hdrlist = geio.get_ge_header(fname, slot)
    except IOError, StandardError:
        sys.stderr.write(\
        "\nread_GE_ipfile: Could not read header from %s\n" % fname)
        return None

    if hdrlist is None:
        return None

    nhdr = {}
#    i = 0
    for entry in hdrlist:
        entry = string.translate(entry, transtab)
        words = entry.split()
        value = " ".join(words[1:]).strip()
        if "." in value:
            if value.replace(".", "0").isdigit():
#               Floating point.
                value = float(value)
        else:
            if value.isdigit():
#               Integer
                value = int(value)
        nhdr[words[0].strip()] = value

#    nhdr['ndim'] = 2 + (1 if nhdr['NumberSlices'] > 1 else 0) \
#             + (1 if nhdr['NumberExcitations'] > 1 else 0) \
#             + (1 if nhdr['NumberOfEchoes'] > 1 else 0)
    nhdr['ndim'] = 2 + (nhdr['NumberSlices'] > 1 and 1 or 0) \
         + ((nhdr['NumberExcitations']>1 or (nhdr['NFrames']>1)) and 1 or 0) \
         + (nhdr['NumberOfEchoes'] > 1 and 1 or 0)
    nhdr['PhaseEncDir'] = freqdir_lookup.get(nhdr['FrequencyDirection'], 'N/A')
    nhdr['Nfiles'] = nfiles
    nhdr['SliceOrder'] = 'altplus'

    return(nhdr)

#*************************************************
def write_nifti_header(hdrname, hdr, newfile=True):
#*************************************************

    """ 
    filename is the name of the nifti header file.
    hdr is a header dictionary.  Contents of the native header
    will be used if it is a nifti header.
    Returns: 0 if no error, otherwise 1.
    """


    if hdr.has_key('native_header'):
        whdr = hdr['native_header']
        if whdr.has_key('filetype'):
            ftype = whdr['filetype']
        else:
            ftype = 'unknown'
    else:
        ftype = 'unknown'
    Rout = hdr['R']

#   Fix broken headers.
    if hdr['mdim'] == 0:
        hdr['mdim'] = 1
    if hdr['tdim'] == 0:
        hdr['tdim'] = 1
    if hdr['zdim'] == 0:
        hdr['zdim'] = 1

#   Insert info for fieldmap correction if available.
    modify_nifti_auxfile(hdr)

#   Convert to quaternions.
    if abs(Rout[:3,:3]).sum() > 0 and Rout[3,3] == 1.:
#       This looks like a valid R matrix.
        x = rot44_to_quatern(Rout)
    else:
        x = None
    if isinstance(x, tuple):
        qa, qb, qc, qd, qfac, qoffx, qoffy, qoffz = x
        qform_code = whdr.get('qform_code',c.NIFTI_XFORM_SCANNER_ANAT)
        qform_code = c.NIFTI_XFORM_SCANNER_ANAT
    else:
#       Conversion failed, use defaults.
        qa, qb, qc, qd, qfac, qoffx, qoffy, qoffz = \
                                    (0., 0., 0., 0., 1., 0., 0., 0.)
        qform_code = c.NIFTI_XFORM_UNKNOWN

    fmt = 'i10s18sihsB8hfffhhhh8ffffhcbffffii80s24shh6f4f4f4f16s4s'
    lgth = struct.calcsize(fmt)
    if hdr['swap']:
        fmt = ">" + fmt
    else:
        fmt = "<" + fmt

    if hdr['native_header'].has_key('ScanningSequence'):
        if whdr['ScanningSequence'][0].strip() == 'EP':
            slice_dim = NIFTI_SLICE_ALT_INC
        else:
            slice_dim = 0
        if whdr['PhaseEncDir'] == 'ROW':
#            dim_info = (slice_dim << 4) | (0x1 << 2) | 0x2
            freq_dim = 2
            phase_dim = 1
        else:
#            dim_info = (slice_dim << 4) | (0x2 << 2) | 0x1
            freq_dim = 1
            phase_dim = 2
    else:
        freq_dim = whdr.get('freq_dim', 0)
        phase_dim = whdr.get('phase_dim', 0)
        slice_dim = whdr.get('slice_dim', 0)

    if not whdr.has_key('quatern_b'):
        # Existing header not for a nifti file.  Rewrite defaults.
        whdr = {'sizeof_hdr':348, 'data_type':"", 'db_name':"", \
        'extents':16384, \
        'session_error':0, 'regular':"r", 'dim_info':"0", \
        'dim':[1, 1, 1, 1, 1, 1, 1, 1], \
        'intent_p1':0., 'intent_p2':0., 'intent_p3':0., 'intent_code':0, \
        'bitpix':0, 'slice_start':0, \
        'pixdim':[1., 0., 0., 0., 0., 0., 0., 0.], \
        'vox_offset':0., 'scl_slope':0., 'scl_inter':0., 'slice_code':"",  \
        'xyzt_units':"", 'cal_max':0., 'cal_min':0., 'slice_duration':0., \
        'toffset':0., 'glmax':0, 'glmin':0, 'descrip':"",  \
        'qform_code':qform_code, 'time_units':'msec', 'space_units':'mm', \
        'misc_units':'', 'sform_code':'unknown', 'intent_name':"", \
        'magic':"ni1"}


#   Set orientation information.
    whdr['quatern_b'] = qb
    whdr['quatern_c'] = qc
    whdr['quatern_d'] = qd
    whdr['qoffset_x'] = qoffx
    whdr['qoffset_y'] = qoffy
    whdr['qoffset_z'] = qoffz
    Rlpi = convert_R_to_lpi(hdr['R'], hdr['dims'], hdr['sizes'])
#    Rlpi = hdr['R']
    Rtmp = dot(Rlpi, diag([hdr['xsize'], hdr['ysize'], hdr['zsize'], 1.]))
    whdr['srow_x'] = zeros(4, float)
    whdr['srow_x'][:] = Rtmp[0, :]
    whdr['srow_y'] = zeros(4, float)
    whdr['srow_y'][:] = Rtmp[1, :]
    whdr['srow_z'] = zeros(4, float)
    whdr['srow_z'][:] =  Rtmp[2, :]
#    whdr['srow_x'][:3] *= hdr['xsize']
#    whdr['srow_y'][:3] *= hdr['ysize']
#    whdr['srow_z'][:3] *= hdr['zsize']
    whdr['qfac'] = qfac

#   Set undefined fields to zero. Spm puts garbage here.
    whdr['glmin'] = 0
    whdr['glmax'] = 0

    whdr['sizeof_hdr'] = 348
    whdr['descrip'] = hdr['native_header'].get('descrip','')
    whdr['aux_file'] = hdr['native_header'].get('aux_file','')
    if len(whdr['descrip']) > 79:
        whdr['descrip'] = whdr['descrip'][:79]
    whdr['dim'] = [hdr['ndim'], hdr['xdim'], hdr['ydim'], hdr['zdim'], \
                               hdr['tdim'], hdr['mdim'], 0, 0]
    whdr['slice_end'] = hdr['zdim']-1
    if hdr['sizes'][3] > 0.:
        TR = hdr['sizes'][3]
    else:
        TR = hdr.get('TR',0.)
        if TR == 0.:
            TR = hdr['subhdr'].get('TR',0.)
    whdr['pixdim'] = [hdr['ndim'], hdr['xsize'], hdr['ysize'], hdr['zsize'], \
                    TR, hdr['msize'], 0., 0.]
    whdr['qoffset_x'] = qoffx
    whdr['qoffset_y'] = qoffy
    whdr['qoffset_z'] = qoffz
    whdr['quatern_b'] = qb
    whdr['quatern_c'] = qc
    whdr['quatern_d'] = qd
    whdr['qfac'] = float(qfac)
    whdr['bitpix'] = datatype_to_lgth[hdr['datatype']]
    whdr['datatype'] = nifti_type_to_datacode[hdr['datatype']]

    whdr['dim_info'] = freq_dim | (phase_dim << 2) | (slice_dim << 4)
    whdr['slice_code'] = nifti_slice_order_encode[ \
                        hdr['native_header'].get('SliceOrder', 'unknown')]
    whdr['intent_code'] = nifti_intent_encode[whdr.get('intent_class', \
                                                            'unknown')]
    whdr['qform_code'] = nifti_sqform_encode.get(qform_code, c.NIFTI_XFORM_UNKNOWN)
    whdr['sform_code'] = nifti_sqform_encode[whdr.get('sform_code', 0)]
    whdr['xyzt_units'] = nifti_units_encode[whdr.get('space_units', 'mm')] | \
                        nifti_units_encode[whdr.get('time_units', 'msec')] | \
                        nifti_units_encode[whdr.get('misc_units', '')]
    if hdr['filetype'] == 'nii':
        hdr['filetype'] = 'n+1'
    whdr['magic'] = hdr['filetype']


    if hdr['filetype'] == 'n+1':
        vox_offset = 348
        vox_offset = vox_offset + 4
    else:
        vox_offset = 0
    extcode = whdr.get('extcode', '0000')
    if extcode[0] != '0':
        vox_offset = int(vox_offset) + 6 + len(whdr.get('edata',''))

    whdr['vox_offset'] = vox_offset

    binary_hdr = struct.pack(fmt, whdr['sizeof_hdr'], whdr['data_type'], \
    whdr['db_name'], whdr['extents'], whdr['session_error'], whdr['regular'], \
    whdr['dim_info'], whdr['dim'][0], whdr['dim'][1], whdr['dim'][2], \
    whdr['dim'][3], whdr['dim'][4], whdr['dim'][5], whdr['dim'][6], \
    whdr['dim'][7], whdr['intent_p1'], whdr['intent_p2'], whdr['intent_p3'], \
    whdr['intent_code'], whdr['datatype'], whdr['bitpix'], \
    whdr['slice_start'], whdr['qfac'], whdr['pixdim'][1], whdr['pixdim'][2], \
    whdr['pixdim'][3], whdr['pixdim'][4], whdr['pixdim'][5], \
    whdr['pixdim'][6], whdr['pixdim'][7], whdr['vox_offset'], \
    hdr['scale_factor'], hdr['scale_offset'], whdr['slice_end'], \
    whdr['slice_code'], whdr['xyzt_units'], whdr['cal_max'], whdr['cal_min'], \
    whdr['slice_duration'], whdr['toffset'], whdr['glmax'], whdr['glmin'], \
    whdr['descrip'], whdr['aux_file'], whdr['qform_code'], whdr['sform_code'], \
    whdr['quatern_b'], whdr['quatern_c'], whdr['quatern_d'], \
    whdr['qoffset_x'], whdr['qoffset_y'], whdr['qoffset_z'], \
    whdr['srow_x'][0], whdr['srow_x'][1], whdr['srow_x'][2], whdr['srow_x'][3], \
    whdr['srow_y'][0], whdr['srow_y'][1], whdr['srow_y'][2], whdr['srow_y'][3], \
    whdr['srow_z'][0], whdr['srow_z'][1], whdr['srow_z'][2], whdr['srow_z'][3], \
    whdr['intent_name'], whdr['magic'])

#    try:
    if True:
        if newfile:
            f = open(hdrname, 'w')
        else:
            f = open(hdrname, 'r+')
        f.seek(0)
#    except IOError:
#        raise IOError(\
#        "\nfile_io::write_nifti: Could not open %s\n\n"%hdrname)
    try:
        f.write(binary_hdr)
    except IOError:
        raise IOError(\
        "\nfile_io::write_nifti: Could not write to %s\n\n"%hdrname)

    if hdr['filetype'] == 'n+1':
        ecodes = whdr.get('extcode', zeros(4,byte))
        if isinstance(ecodes, list):
            ecodes = array(ecodes)
        if ecodes[0]:
#           Extension is present.
            exthdr = struct.pack('ccccii', ecodes[0], ecodes[1], \
                    ecodes[2], ecodes[3], whdr['esize'],  \
                    nifti_ecode_encode[whdr['ecode']]) + whdr['edata']
        else:
            exthdr = fromstring(ecodes,byte)
#       Write the extension header.
        f.write(exthdr)

    f.close()

    return 0

#*************************************************************************
def make_to3d_cmd(input_file, output_file, dirname, hdr, input_datum_type):
#*************************************************************************
    """
    Purpose: Build a command-line to run AFNI's to3d program.
    """


    datum_types = {'float':'float', 'short':'short', 'double':'float', \
                'float32':'float', 'int16':'short','byte':'byte'}
    format_codes = {'float':'f', 'float32':'f', 'short':'', 'int16':'', \
                'f':'f', 'h':'','byte':'B'}

#   Get stuff from the header.
    xdim, ydim, zdim, tdim = hdr['dims'][:4]
    xsize, ysize, zsize = hdr['sizes'][:3]

    whdr = hdr['native_header']

#   Get parameters from tranformation matrix.
    params = rot44_to_afni(hdr['R'], xdim, ydim, zdim, xsize, ysize, zsize)
    xorient, yorient, zorient, x0, y0, z0 = params
    dim_mm = array([(xdim-1)*xsize, (ydim-1)*ysize, (zdim-1)*zsize])
    Rr = hdr['R'][:3,:3]
#    x0tox1 = dot(Rr.T, dot(Rr, dim_mm) + hdr['R'][:3,3])
    x0tox1 = dot(abs(Rr).transpose(),dot(Rr,dim_mm) + hdr['R'][:3,3])
    x0, y0, z0 = dot(abs(Rr).transpose(), hdr['R'][:3,3]).tolist()
    x1 = x0tox1[0]
    y1 = x0tox1[1]
    z1 = x0tox1[2]

#   Setup strings for locations of slices.
    ras  = 'RLPAIS'
    ras1 = 'LRAPSI'
    invert_ras = {0:'RL', 1:'LR', 2:'PA', 3:'AP', 4:'IS', 5:'SI'}
    signs = [1, -1, 1, -1, 1, -1]

#   Subtracting 1.e-8 form origin yield correct results when origin is unknown 
#   set to zero. Otherwise it has no practical effect.
    x = array([x0-1.e-8, y0-1.e-8, z0-1.e-8])
    y = array([x1-1.e-8, y1-1.e-8, z1-1.e-8])
    x = x/(abs(x)+where(x==0, 1, 0))
    y = y/(abs(y)+where(y==0, 1, 0))
    xa = ("%7.2f" % abs(x0)).strip()
    xb = ("%7.2f" % abs(x1)).strip()
    ya = ("%7.2f" % abs(y0)).strip()
    yb = ("%7.2f" % abs(y1)).strip()
    za = ("%7.2f" % abs(z0)).strip()
    zb = ("%7.2f" % abs(z1)).strip()

    sgn = abs((x - y)/2).astype(int) # sgn is 1 if sign change else 0
    xstr = "%s%s-%s%s" % (xa, ras[xorient], xb, invert_ras[xorient][sgn[0]])
    ystr = "%s%s-%s%s" % (ya, ras[yorient], yb, invert_ras[yorient][sgn[1]])
    if zdim > 1:
        zstr = "-zSLAB %s%s-%s%s" % \
                        (za, ras[zorient], zb, invert_ras[zorient][sgn[2]])
    else:
        zstr = "-zorigin %s" % (za)
    orient_str = "-orient %s%s%s" % (ras[xorient], ras[yorient], ras[zorient])

    if xdim == 91 and ydim == 109 and zdim == 91:
        view = 'tlrc'
    else:
        view = 'orig'
    fname =  hdr['imgfile'].replace('+orig','')
    hdr['imgfile'] = '%s+%s' % (fname, view)

    stat_types = {'Ttest':'fitt', 'Ztest':'fizt', 'Ftest':'fift'}
    if tdim == 2 and hdr['subhdr'].has_key('StatType'):
#       This must be an fitt, fift
        btype = stat_types[hdr['subhdr']['StatType'][1]]
        to3d_type = 'fbuc'
    elif hdr['native_header'].has_key('btype'):
        btype =  hdr['native_header']['btype']
        statpar = ''
        to3d_type = btype
    else:
        if tdim > 1:
            btype = 'epan'
        else:
            btype = 'anat'
        to3d_type = btype
        statpar = ''

    statpar = ''
    if hdr['subhdr'].has_key('StatType') and \
                                hdr['subhdr']['StatType'] is not None:
        if hdr['tdim'] > 1:
#            refit_cmd = '3drefit -%s' % btype
            refit_cmd = '3drefit'
            for t in xrange(hdr['tdim']):
                if hdr['subhdr']['StatType'][t] == 'Ttest':
                    refit_cmd += ' -substatpar %d fitt %d' % \
                                (t, hdr['subhdr']['DegFreedom'][t])
                elif hdr['subhdr']['StatType'][t] == 'Ftest':
                    refit_cmd += ' -substatpar %d fift %d %d' % \
                                (t, hdr['subhdr']['DegFreedom'][t][0], \
                                    hdr['subhdr']['DegFreedom'][t][1])
                elif hdr['subhdr']['StatType'][t] == 'None':
                    pass
            refit_cmd = '%s %s+%s' % (refit_cmd, output_file, view)
        else:
            if hdr['subhdr']['StatType'] == 'Ttest':
                statpar = '-statpar %d' % hdr['subhdr']['DegFreedom'][0]
            elif hdr['subhdr']['StatType'] == 'Ftest':
                statpar = '-statpar %d %d' % (hdr['subhdr']['DegFreedom'][0], \
                                           hdr['subhdr']['DegFreedom'][1])
            refit_cmd = None
    else:
        statpar = ''
        refit_cmd = None


#   Get session directory and form string.
    outhead, out_file = os.path.split(output_file)
    if len(dirname) > 0:
        str_sess = "-session %s" % dirname
        imgname = "%s/%s+%s.BRIK" % (dirname, out_file, view)
        hdrname = "%s/%s+%s.HEAD" % (dirname, out_file, view)
    elif len(outhead) > 0:
        str_sess = "-session %s" % outhead
        imgname = "%s+%s.BRIK" % (out_file, view)
        hdrname = "%s+%s.HEAD" % (out_file, view)
    else:
        str_sess = "-session ."
    prefix = os.path.basename(output_file)


#   Get TR and lookup AFNI datatype and format code.
    TR = hdr['subhdr'].get('TR', -1)
    data_type = datum_types.get(hdr['datatype'], 'float')
    format_code = format_codes.get(input_datum_type, 'unknown')

    if to3d_type == 'epan' or to3d_type == 'abuc' or to3d_type == 'fbuc':
        slice_order = hdr['subhdr'].get('SliceOrder', 'zero')
        if slice_order == 'unknown':
            slice_order = 'zero'
        timedef = '-time:zt %d %d %5.0f %s' %  (zdim, tdim, TR, slice_order)
    else:
        timedef = ''

    if hdr['scale_factor'] != 1.:
        gsfac = "-gsfac %f" % hdr['scale_factor']
    else:
        gsfac = ""

    gsfac = ""
    to3d_cmd = "to3d -%s %s -xSLAB %s -ySLAB %s  %s %s -datum %s %s \
          -in:1 -skip_outliers -prefix %s %s -view %s %s 3D%s:0:0:%d:%d:%d:%s" \
          % (to3d_type, timedef, xstr, ystr, zstr, orient_str, data_type, gsfac, \
          prefix, str_sess, view, statpar, format_code, xdim, ydim, zdim*tdim, \
          input_file)

    return to3d_cmd, refit_cmd 


#**************************************
def write_analyze_header(hdrname, hdr):
#**************************************

    """
    Purpose: write header in analyze format.
    """

    xdim = hdr['xdim']
    ydim = hdr['ydim']
    zdim = hdr['zdim']
    tdim = hdr['tdim']
    mdim = hdr['mdim']
    TR = hdr['subhdr'].get('TR',0)
    if TR is None:
        TR = 0
    xsize = hdr['xsize']
    ysize = hdr['ysize']
    zsize = hdr['zsize']
    msize = hdr['msize']
    x0 = round(hdr['x0'])
    y0 = round(hdr['y0'])
    z0 = round(hdr['z0'])
    if(hdr.has_key('scale_factor')):
        scale_factor = hdr['scale_factor']
    else:
        scale_factor = 1.
    swap = hdr['swap']

    datatype = hdr['datatype']
    data_type = analyze_type_to_datacode[datatype]
    bitpix = datatype_to_lgthbits[datatype]

    if mdim > 1:
        ndim = 5
    elif tdim > 1:
        ndim = 4
    else:
        ndim = 3

#    if hdr['orientation'] in analyze_orientcode_to_orient:
#        orient_code = '%1d' % analyze_orientcode_to_orient.\
#                        index(hdr['orientation'])
#    else:
#        orient_code = '0'
#   Always set this to zero since most packages use it incorrectly.
    orient_code = '0'

    cd = " "
    sd = " "
    hd = 0
    ld = 0
    fd = 0.

    format = "i 10s 18s i h 1s 1s 8h 4s 8s h h h h 8f f f f f f f i i 2i " + \
             "80s 24s 1s 3h 4s 10s 10s 10s 10s 10s 3s i i i i 2i 2i"

    if swap:
        format = ">" + format
    else:
        format = "<" + format

    bhdr = struct.pack(format, 348, sd, sd, ld, hd, cd, cd, ndim, xdim, \
            ydim, zdim, tdim, mdim, hd, hd, sd, sd, hd, data_type, bitpix, \
            hd, fd, xsize, ysize, zsize, TR, msize, fd, fd, fd, \
            scale_factor, fd, fd, fd, fd, ld, ld, ld, ld, sd, sd, \
            orient_code, x0, y0, z0, sd, sd, sd, sd, sd, sd, sd, ld, ld, \
            ld, ld, ld, ld, ld, ld)

    try:
        f = open(hdrname, 'wb')
    except:
        sys.stderr.write(\
        "\nfile_io::write_analyze_header: Could not open %s\n\n"%hdrname)
        return -1
    vhdr = f.write(bhdr)
    f.close()

    return 0


#*********************************
def write_tes(filename, image, hdr):
#*********************************

    """
    Purpose: Write image in Voxbo's tes format.
    """

# image:    Image to be written.
# filename:    File name to be written to.
# xdim:        X Dimension
# ydim:        Y Dimension
# zdim:        Z Dimension
# tdim:        T Dimension
# xsize:     X voxel size in mm.
# ysize:     Y voxel size in mm.
# zsize:     Z voxel size in mm.
# x0:        X origin
# y0:        Y origin
# z0:        Z origin
# typecode: Python typecode for image number format (d, f, l, i, c)


    xdim, ydim, zdim, datatype = (hdr['xdim'], hdr['ydim'], hdr['zdim'], \
                                    hdr['datatype'])
    try:
        f = open(filename, "wb")
    except IOError:
        sys.stderr.write("file_io::write_file Could not open %s\n"%filename)
        return -1
    f.write("VB98\nTES1\n")

    tdim = hdr['mdim']*hdr['tdim']
    image = reshape(image, [tdim, zdim, ydim, xdim])
    image_typecode = image.dtype.char
    typecode = datatype_to_dtype[hdr['datatype']]
    if datatype == "d":
        f.write("DataType:\tDouble\n")
        if(image_typecode != datatype):
            img = image.astype(float64)
        typecode_out = float
    elif typecode == "f":
        f.write("DataType:\tfloat\n")
        if(image_typecode != typecode):
            img = image.astype(float32)
        typecode_out = float32
    elif typecode == "l":
        f.write("DataType:\tLong\n")
        if(image_typecode != typecode):
            img = image.astype(int32)
        typecode_out = int32
    elif typecode == "h":
        f.write("DataType:\tinteger\n")
        if(image_typecode != typecode):
            scl = 32767./image.max()
            img = (scl*image).astype(short)
        typecode_out = short
    elif typecode == "b":
        f.write("DataType:\tByte\n")
    else:
        print "file_io::read_header: Invalid type code: %s" % typecode
        return -1

    f.write("VoxDims(TXYZ):\t%d\t%d\t%d\t%d\n" % (tdim, xdim, ydim, zdim))
    f.write("VoxSizes(XYZ):\t%f\t%f\t%f\n" % (hdr['xsize'], \
                                            hdr['ysize'], hdr['zsize']))
    f.write("Origin(XYZ):\t%d\t%d\t%d\n" % (int(hdr['x0']), \
                                            int(hdr['y0']), int(hdr['z0'])))
    f.write("ByteOrder:\tmsbfirst\n")
    f.write("Orientation:\t%s\n"%R_to_orientstring(hdr['R']))
    f.write("TR(msecs):\t%d\n" % (hdr['subhdr'].get('TR',-1)))
    nhdr = hdr['native_header']
    f.write("SubjectName:\t%s\n"%nhdr.get('PatientName', 'N/A'))
    f.write("SubjectAge:\t%s\n"%nhdr.get('PatientAge', 'N/A'))
    f.write("Coil Name:\t%s\n"%nhdr.get('CoilName', 'N/A'))
    f.write("PulseSeq:\t%s\n"%nhdr.get('PulseSequenceName', 'N/A'))
    f.write("FieldStrength:\t%s\n"%nhdr.get('FieldStrength', 'N/A'))

#   Write end-of-header mark.
    f.write("\f\n")

#   Write the mask.
    mask = ones((zdim*ydim*xdim), byte)
    f.write(mask.tostring())

#   Flip images left to right and top to bottom.
#    for t in range(tdim):
#        for z in range(zdim):
#            jmg[:, :] = fliplr(img[t, z, :, :])
#            img[t, z, :, :] = flipud(jmg)

#   Now write the data. 
    img = reshape(img, (tdim, zdim, ydim, xdim))
    for z in range(zdim):
        for y in range(ydim):
            for x in range(xdim):
                f.write(img[:, z, y, x].astype(typecode_out).byteswap(). \
                                                                tostring())

    f.close()
    return 0



#***************************************************************************
def afni_to_rot44(xdim, ydim, zdim, xsize, ysize, zsize, x0, y0, z0, \
                  xorient, yorient, zorient):
#***************************************************************************

    """
    Purpose: Convert afni orientation info to a 4x4 transform matrix.
    xdim, ydim, zdim: Image dimensions.
    xsize, ysize, zsize: Voxel size.
    x0, y0, z0: Origin as defined in the HEAD file.
    xorient, yorient, zorient: AFNI orientation definitions.
    Returns a 4x4 matrix defining transformation from (i,j,k) coordinates in
        image space to (x,y,z) coordinates in RAI space.  
    """


#   The identity matrix corresponds to LPI, while AFNI assumes that 
#   it corresponds to RAI. Flip signs accordingly.
    sgn = 1. - 2*array(afni_sign_code)
    R = zeros([4, 4], float)

#   Compute rotation matrix.
    R[xorient/2, 0] = sgn[xorient]
    R[yorient/2, 1] = sgn[yorient]
    R[zorient/2, 2] = sgn[zorient]

#   Transform the origin from image coordinates to RAI.
    x00 = zeros(3, float)
    x00[0] = x0
    x00[1] = y0
    x00[2] = z0
    x11 = dot(abs(R[:3, :3]), x00)

    R[0, 3] = x11[0]
    R[1, 3] = x11[1]
    R[2, 3] = x11[2]
    R[3, 3] = 1.

#   Flip signs to change RAI standard coordinates to LPI as standard.
#    Rflip = identity(4).astype(float)
#    Rflip[0,0] = -1.
#    Rflip[1,1] = -1.
#    R = dot(Rflip,R)

    return(R)


#*************************************************************************
def quatern_to_rot44( qb, qc, qd, qfac, qx=1., qy=1., qz=1., \
                                        dx=1., dy=1., dz=1.):
#*************************************************************************

    """ 
    Purpose: Convert quaternion representation to 4x4 transform matrix.
    Arguments:
        qb, qc, qd, qfac: Quaternions from nifti header.
        qx, qy, yz: Offsets from nifti header.
        dx, dy, dz: Voxel size.
    Returns:
        4x4 matrix defining transformation from (i,j,k) coordinates in
        image space to (x,y,z) coordinates in RAI space.  

    The code was copied from the nifti clib by Mark Jenkinson.
    """

    R = zeros([4, 4], float)
    b = qb
    c = qc
    d = qd

#   Last row is always [ 0 0 0 1 ]
    R[3, 3] = 1.

#   Compute a parameter from b, c, d
    a = 1.0 - (b*b + c*c + d*d)
    if a < 1.e-7:   # special case
        a = 1.0 /math.sqrt(b*b+c*c+d*d)
        b *= a
        c *= a
        d *= a        # normalize (b, c, d) vector
        a = 0.0       # a = 0 ==> 180 degree rotation
    else:
        a = math.sqrt(a)   # angle = 2*arccos(a)

#   Load rotation matrix, including scaling factors for voxel sizes
    if dx > 0.:
        xd = dx
    else:
        xd = 1.
    if dy > 0.:
        yd = dy
    else:
        yd = 1.
    if dz > 0.:
        zd = dz
    else:
        zd = 1.

    if qfac < 0.:
        zd = -zd      # left handedness

    R[0, 0] =       (a*a+b*b-c*c-d*d) * xd
    R[0, 1] = 2.0 * (b*c-a*d        ) * yd
    R[0, 2] = 2.0 * (b*d+a*c        ) * zd
    R[1, 0] = 2.0 * (b*c+a*d        ) * xd
    R[1, 1] =       (a*a+c*c-b*b-d*d) * yd
    R[1, 2] = 2.0 * (c*d-a*b        ) * zd
    R[2, 0] = 2.0 * (b*d-a*c        ) * xd
    R[2, 1] = 2.0 * (c*d+a*b        ) * yd
    R[2, 2] =       (a*a+d*d-c*c-b*b) * zd

   # load offsets
    R[0, 3] = qx
    R[1, 3] = qy
    R[2, 3] = qz
    R[3, 3] = 1.

#   Convert from LPI to RAI
    Rcvt = array([[-1.,0.,0.,0.],[0.,-1.,0.,0.],[0.,0.,1.,0.],[0.,0.,0.,1.]])
    R = dot(Rcvt, R)

    return(R)

#*****************************
def pfile_nhdr_to_rot44(nhdr):
#*****************************

    """
    Purpose: Compute 4x4 transform matrix from GE raw data file.
    Arguments:
        nhdr: GE native header.
    Returns:
        4x4 matrix defining transformation from (i,j,k) coordinates in
        image space to (x,y,z) coordinates in RAI space.  
    """

#   Find rotation matrix by first finding afni definition.
    signs = {'R':0, 'L':1, 'P':0, 'A':1, 'I':0, 'S':1}
    swap_start = {'R':'L', 'L':'R', 'P':'A', 'A':'P', 'I':'S', 'S':'I'}
    if nhdr['StartRAS'] == 'L'or nhdr['StartRAS'] == 'R':
#        orientation = 'sagittal'
        if float(nhdr['TopLeftCornerA']) < float(nhdr['TopRghtCornerA']):
            xyz = 'P'
            x0 = float(nhdr['TopRghtCornerA'])
        else:
            xyz = 'A'
            x0 = -float(nhdr['TopLeftCornerA'])

#       Adjust origin to center of first sample.
        if x0 < 0:
            x0 += nhdr['FOVx']/nhdr['ImageDimensionX']
        else:
            x0 -= nhdr['FOVx']/nhdr['ImageDimensionX']

        if float(nhdr['TopRghtCornerS']) > float(nhdr['BotRghtCornerS']):
            xyz = xyz + 'S'
            y0 = float(nhdr['TopRghtCornerS'])
        else:
            xyz = xyz + 'I'
            y0 = float(nhdr['TopLeftCornerS'])

        if y0 < 0:
            y0 += nhdr['FOVy']/nhdr['ImageDimensionY']
        else:
            y0 -= nhdr['FOVy']/nhdr['ImageDimensionY']
#        xyz = xyz + nhdr['StartRAS']
#        z0 = float(nhdr['StartLoc'])

    elif nhdr['StartRAS'] == 'I'or nhdr['StartRAS'] == 'S':
#        orientation = 'axial'
#        sys.stderr.write('Potential error in R matrix\n')
        if float(nhdr['TopLeftCornerR']) > float(nhdr['TopRghtCornerR']):
            x0 = float(nhdr['TopRghtCornerR'])
            xyz = 'R'
        else:
            x0 = float(nhdr['TopLeftCornerR'])
            xyz = 'L'

        if float(nhdr['TopRghtCornerA']) > float(nhdr['BotRghtCornerA']):
            xyz = xyz + 'A'
            y0 = float(nhdr['BotRghtCornerA'])
#            yorient = 3  # A-P
        else: 
            xyz = xyz + 'P'
            y0 = float(nhdr['TopRghtCornerA'])
#            yorient = 2  # P-A
#        xyz = xyz + nhdr['StartRAS']
#        z0 = float(nhdr['StartLoc'])
    else:
#        sys.stderr.write('Potential error in R matrix\n')
        if float(nhdr['TopLeftCornerR']) < float(nhdr['TopRghtCornerR']):
            xyz = 'R'
            x0 = float(nhdr['TopRghtCornerR'])
        else:
            xyz = 'L'
            x0 = float(nhdr['TopLeftCornerR'])

        if float(nhdr['TopRghtCornerS']) > float(nhdr['BotRghtCornerS']):
            xyz = xyz + 'S'
            y0 = float(nhdr['TopRghtCornerS'])
        else:
            xyz = xyz + 'I'
            y0 = float(nhdr['BotRghtCornerS'])
#        xyz = xyz + nhdr['StartRAS']
#        z0 = float(nhdr['StartLoc'])

#    signs = {'R':0, 'L':1, 'P':0, 'A':1, 'I':0, 'S':1}
#    swap_start = {'R':'L', 'L':'R', 'P':'A', 'A':'P', 'I':'S', 'S':'I'}
#   Now get the slice axis.
    slice_axis = nhdr['StartRAS']
    if not signs.has_key(slice_axis):
        return(identity(4))
    if signs[slice_axis]:
#        z0 = -float(nhdr['EndLoc'])
        z0 = -float(nhdr['StartLoc'])
    else:
        z0 = float(nhdr['StartLoc'])
    if nhdr['StartRAS'] == nhdr['EndRAS']:
        if float(nhdr['EndLoc']) > float(nhdr['StartLoc']) and nhdr['StartRAS'] in 'LPS':
            slice_axis = swap_start[slice_axis]
    xyz = xyz + slice_axis

    xorient = 'RLPAIS'.index(xyz[0])
    yorient = 'RLPAIS'.index(xyz[1])
    zorient = 'RLPAIS'.index(xyz[2])
    xdim = nhdr['ImageDimensionX']
    ydim = nhdr['ImageDimensionY']
#    ydim = nhdr['ImageDimensionY']
    zdim = nhdr['NumberSlices']
#    xsize = float(nhdr['FOVx'])/float(nhdr['ImageDimensionX'])
#    ysize = float(nhdr['FOVy'])/float(nhdr['ImageDimensionY'])
    xsize = nhdr['DimensionX']
    ysize = nhdr['DimensionY']
    zsize = float(nhdr['SliceThickness']) + float(nhdr['ScanSpacing'])

#    code = '%d %d %d %f %f %f' % (xdim, ydim, zdim, xsize, ysize, zsize)
#    code1 = ' %f %f %f %d %d %d' % (x0, y0, z0, xorient, yorient, zorient)
#    nhdr['Aaatest_code'] = code
#    nhdr['Abatest_code'] = code1

    R = afni_to_rot44(xdim, ydim, zdim, xsize, ysize, zsize, x0, y0, z0, \
                        xorient, yorient, zorient)

    return(R)

#*************************
def rot44_to_quatern(R):
#*************************

    """
    Purpose: Convert a 4x4 transform matrix to quaternions
    Arguments:
        R: A 4x4 transformation matrix to RAI coordinates.
    Returns:
        Quaternion representation used in the nifti header, i.e., quaterna, 
            quaternb, quaternc, qd, qfac, qoffsetx, qoffsety, qoffsetz

    Based on from niftio.c, by Robert W. Cox. at http://nifti.nimh.hih.gov
    """

#   Convert to LPI standard orientation.
    Rcvt = array([[-1.,0.,0.,0.],[0.,-1.,0.,0.],[0.,0.,1.,0.],[0.,0.,0.,1.]])
    Rlpi = dot(Rcvt, R)
#    Rlpi = R

    qoffx = Rlpi[0, 3]
    qoffy = Rlpi[1, 3]
    qoffz = Rlpi[2, 3]
 
# Load 3x3 matrix into local variables
    r11 = Rlpi[0, 0]
    r12 = Rlpi[0, 1]
    r13 = Rlpi[0, 2]
    r21 = Rlpi[1, 0]
    r22 = Rlpi[1, 1]
    r23 = Rlpi[1, 2]
    r31 = Rlpi[2, 0]
    r32 = Rlpi[2, 1]
    r33 = Rlpi[2, 2]

# compute lengths of each column; these determine grid spacings 
    xd = math.sqrt( r11*r11 + r21*r21 + r31*r31 )
    yd = math.sqrt( r12*r12 + r22*r22 + r32*r32 )
    zd = math.sqrt( r13*r13 + r23*r23 + r33*r33 )

# if a column length is zero, patch the trouble
    if xd == 0.0:
        r11 = 1.0
        r21 = 0.0
        r31 = 0.0
        xd = 1.0
    if yd == 0.0:
        r22 = 1.0
        r12 = 0.0
        r32 = 0.0
        yd = 1.0
    if zd == 0.0:
        r33 = 1.0
        r13 = 0.0
        r23 = 0.0
        zd = 1.0

# Assign the output lengths
    dx = xd
    dy = yd
    dz = zd

# Normalize the columns
    r11 = r11/xd
    r21 = r21/xd
    r31 = r31/xd
    r12 = r12/yd
    r22 = r22/yd
    r32 = r32/yd
    r13 = r13/zd
    r23 = r23/zd
    r33 = r33/zd

    from numpy.linalg import det
    tst = det(Rlpi[:3, :3]) # Should be -1 or 1
    if tst > 0:
        qfac = 1.0
    else:                  # improper ==> flip 3rd column
        qfac = -1.0
        r13 = -r13
        r23 = -r23
        r33 = -r33

# Now, compute quaternion parameters
    qa = r11 + r22 + r33 + 1.0

    if qa > 0.5:                # simplest case
        qa = 0.5 * math.sqrt(qa)
        qb = 0.25 * (r32-r23) / qa
        qc = 0.25 * (r13-r31) / qa
        qd = 0.25 * (r21-r12) / qa
    else:                       # trickier case
        xd = 1.0 + r11 - (r22+r33)  # 4*b*b
        yd = 1.0 + r22 - (r11+r33)  # 4*c*c
        zd = 1.0 + r33 - (r11+r22)  # 4*d*d

        if xd > 1.0:
            qb = 0.5 * math.sqrt(xd)
            qc = 0.25* (r12+r21) / qb
            qd = 0.25* (r13+r31) / qb
            qa = 0.25* (r32-r23) / qb
        elif yd > 1.0:
            qc = 0.5 * math.sqrt(yd)
            qb = 0.25 * (r12+r21) / qc
            qd = 0.25 * (r23+r32) / qc
            qa = 0.25 * (r13-r31) / qc
        else:
            qd = 0.5 * math.sqrt(zd)
            qb = 0.25 * (r13+r31) / qd
            qc = 0.25 * (r23+r32) / qd
            qa = 0.25 * (r21-r12) / qd

        if qa < 0.0:
            qb = -qb
            qc = -qc
            qd = -qd
            qa = -qa

    return(qa, qb, qc, qd, qfac, qoffx, qoffy, qoffz)

#*****************************************************
def rot44_to_afni(R, xdim, ydim, zdim, xsize, ysize, zsize):
#*****************************************************

    """
    Purpose: 
    Convert 4x4 rotation matrix into afni xorient, yorient, zorient variables. 
    AFNI defines the origin in data coordinates rather than in RAI coordinates.
    The AFNI conversion defines rotations to the RPI orientation, so the sign
    of the origin (y0) in the AP direction is flipped.
    Returns: 
        Parameters required to write an afni file, i.e., xorient, yorient, 
            zorient, x0_afni, y0_afni, z0_afni
    Arguments:
        R: A 4x4 transform matrix (to RAI)
        xdim, ydim, zdim: Image dimensions.
        xsize, ysize, zsize: Voxel size
    """



    if (abs(R[:3,:3]).sum() - 3.) > .001:
#       Image acquired in an oblique plane.
        orientation = 'OBL'
        Rr = identity(3).astype(float)*sign(R[:3,:3])
    else:
        Rr = zeros([3,3],float)
        Rr[:, :] = R[:3, :3]
    xyz0 = array([R[0, 3], R[1, 3], R[2, 3]])
    dim_mm = array([ (xdim-1.)*xsize, (ydim-1.)*ysize, (zdim-1.)*zsize])
    flip = dot((Rr - abs(Rr))/2., dim_mm)
#    flip = identity(3).astype(float)
##    flip[1, 1] = -1. # Flip AP axis about scanner center.
#    flip = dot(flip, abs(Rr))
#    xyz0_afni = dot(transpose(flip),xyz0)
    xyz0_afni = dot(transpose(abs(Rr)), xyz0 + flip)
#    xyz0_afni = xyz0
    x0_afni = xyz0_afni[0]
    y0_afni = xyz0_afni[1]
    z0_afni = xyz0_afni[2]

    testvec = zeros(3, float)
    ras = (2*abs(dot(transpose(Rr), array([0, 1, 2])))).astype(int)
    dir = ((1 - dot(transpose(Rr), array([1., 1., 1.])))/2).astype(int)
    sgn = array(afni_sign_code)
#afni_sign_code = [0, 1, 1, 0, 0, 1]

    xorient = int(ras[0] + sgn[ras[0]+dir[0]] + .5)
    yorient = int(ras[1] + sgn[ras[1]+dir[1]] + .5)
    zorient = int(ras[2] + sgn[ras[2]+dir[2]] + .5)

    return(xorient, yorient, zorient, x0_afni, y0_afni, z0_afni)

#********************************************************************
def rot44_flip_logical(Rin, flip_LR, flip_AP, flip_IS, xdim, ydim, zdim, \
                         xsize, ysize, zsize):
#********************************************************************

    """
    Purpose:
        Flip rotation matrix along axes defined by the subjects body.
    Arguments:
        Rin: 4x4 transformation matrix (i.e., about A-P axis).
        flip_LR: Flip left-to-right.
        flip_AP: Flip anterior-to-posterior.
        flip_IS : Flip inferior-to-superior.
        xdim, ydim, zdim: Image dimensions.
        xsize, ysize, zsize: voxel sizes.
    """

    R = zeros([4, 4], float)
    R[:, :] = Rin
    offsets = dot(R[:3, :3], array([(xdim-1)*xsize, (ydim-1)*ysize, \
                                    (zdim-1)*zsize]))
    if flip_LR:
        R[0, 3] = R[0, 3] + offsets[0]
        Rcvt = identity(3)
        Rcvt[0, 0] = -1.
        R[:3, :3] = dot(Rcvt, R[:3, :3])
    if flip_AP:
        R[1, 3] = R[1, 3] + offsets[1]
        Rcvt = identity(3)
        Rcvt[1, 1] = -1.
        R[:3, :3] = dot(Rcvt, R[:3, :3])
    if flip_IS:
        R[2, 3] = R[2, 3] + offsets[2]
        Rcvt = identity(3)
        Rcvt[2, 2] = -1.
        R[:3, :3] = dot(Rcvt, R[:3, :3])

    return(R)


#************************
def R_to_orientstring(R):
#************************

    """
    Purpose: Convert transformation matrix to 3-character string 
            defining orientation (e.g., RAI, LPI etc)
    Arguments: 
        R: 4x4 transformation matrix
    Returns:
        orientation: A 3-character string.
    """

#LPI    orient_decode = {-1:'L',1:'R', -2:'P', 2:'A', -4:'S', 4:'I'}
    orient_decode = {0:'?',-1:'L',1:'R', -2:'P', 2:'A', -4:'S', 4:'I'}

    if (abs(R[:3,:3]).sum() - 3.) > .001:
#       Image was not acquired on a cardinal axis.
        orientation = 'OBL'
    else:
        v = (dot(R[:3, :3].transpose(), array([1., 2., 4.]))).round()
        orientation = orient_decode.get(v[0], 'x') + \
                    orient_decode.get(v[1], 'x') + \
                    orient_decode.get(v[2], 'x')

    return(orientation)

#*************************************************
def orientstring_to_plane(orientstring, nhdr=None):
#*************************************************

    """
    Purpose: Convert 3-character code (RPI, LAI etc) into english
            (axial, sagittal, coronal, or oblique)
    Arguments:
        orientstring: 3-character orient string:
    Keywords:
        nhdr: Native header. Required for data at an oblique angle.
    Returns:
        Image plane as a string, i.e., "axial", "sagittal", "coronal" 
        or "oblique"
    """

    if orientstring == 'OBL':
        return 'oblique'
    elif orientstring == '???':
        return 'unknown'

    leftright = ['L', 'R']
    antpost = ['A', 'P']
    infsup = ['I', 'S']

    if orientstring[0] in leftright:
        if orientstring[1] in antpost:
            if not isinstance(nhdr, dict):
                return 'axial'
            Robl, phi, theta =  rot44_oblique(nhdr)
            if abs(phi) > .1 or abs(theta) > .1:
                return 'oblique'
            else:
                return 'axial'
        elif orientstring[1] in infsup:
            return 'coronal'
    elif orientstring[0] in antpost:
        if orientstring[1] in infsup:
            return 'sagittal'
        else:
            return 'Invalid orientation'



#*************************************************************************
def rot44_flip_physical(Rin, flip_LR, flip_TB, flip_FL, xdim, ydim, zdim, \
                        xsize, ysize, zsize):
#***************************************************************************

    """ 
    Purpose 
        Flip xform matrix along axes defined in image coordinates.
    Arguments:
        Rin: 4x4 transform matrix.
        flip_LR: Flip left-to-right.
        flip_TB: Flip top-to-bottom.
        flip_FL: Flip first-to-last.
        xdim, ydim, zdim: Image dimensions. 
        xsize, ysize, zsize: Voxel size.
    Returns:
        A 4x4 transformation matrix.
    """

    R = zeros([4, 4], float)
    R[:, :] = Rin
    if flip_LR: # Flip x axis
        offsets = dot(R[:3, :3], array([(xdim-1)*xsize, 0., 0.]))
        R[:3, 3] = R[:3, 3] + offsets
        Rcvt = identity(3)
        Rcvt[0, 0] = -1.
        R[:3, :3] = dot(R[:3, :3], Rcvt)
    if flip_TB: # Flip top and bottom
        offsets = dot(R[:3, :3], array([0., (ydim-1)*ysize, 0.]))
        R[:3, 3] = R[:3, 3] + offsets
        Rcvt = identity(3)
        Rcvt[1, 1] = -1.
        R[:3, :3] = dot(R[:3, :3], Rcvt)
    if flip_FL: # Flip first and last
        offsets = dot(R[:3, :3], array([0., 0., (zdim-1)*zsize]))
        R[:3, 3] = R[:3, 3] + offsets
        Rcvt = identity(3)
        Rcvt[2, 2] = -1.
        R[:3, :3] = dot(R[:3, :3], Rcvt)

    return(R)


#*********************************
def flip_image(image, xflip, yflip):
#*********************************

    """
    Purpose:
        Flip image without changing transform matrix.
    Arguments:
        image: Input image.
        xflip: True = flip left-right in image coordinates.
        yflip: True = flip top-bottom in image coordinates.
    Returns:
        Flipped image
    """

    shp = image.shape
    tmpdim = prod(shp[:image.ndim-2])
    img = image.reshape([tmpdim, shp[-2], shp[-1]])
    jmg = zeros([shp[-2], shp[-1]], image.dtype.char)
    jmg = zeros([tmpdim, shp[-2], shp[-1]], image.dtype.char)
    tmp = zeros([shp[-2], shp[-1]], image.dtype.char)
    for z in range(tmpdim):
        if xflip*yflip:
            tmp[:, :] = fliplr(img[z, :, :])
            jmg[z, :, :] = flipud(tmp[:, :])
        elif xflip:
            jmg[z, :, :] = fliplr(img[z, :, :])
        elif yflip:
            jmg[z, :, :] = flipud(img[z, :, :])
            
    return(jmg.reshape(shp))
    

  
#******************
def isIfile(prefix):
#******************
    """
    Purpose: 
        Test for GE I.xxx file format
    Arguments:
        fname: Input filename.
    Returns:
        True if filename is a GE I-file (pre ESE rev 10 image file format)
    """

    try:
        if os.path.isdir(prefix):
            fname = '%s/I.001' % prefix
        else:
            fname = prefix
        exts = ('', '.gz', '.bz2')
        for ext in exts:
            if os.path.exists(fname+ext):
                f = open_gzbz2(fname+ext, 'rb')
                break
        else:
            return False
        code = f.read(4)
        f.close()
        if code == "IMGF":
            return(True)
        else:
            return(False)
    except IOError:
        return(False)

#***********************
def rot44_oblique(whdr):
#***********************

    """ 
    Purpose: 
        Compute a transformation matrix from coordinates in the GE header.
    Usage: 
        rot44_oblique(hdr['native_header'])
    Returns: 
        phi: Pitch angle (rotation about the x-axis in scannor coords.)
        theta: Yaw angle (rotation about the y-axis in scannor coords.)

    """

    tlhc_R = float(whdr.get('tlhc_R', -1))
    tlhc_A = float(whdr.get('tlhc_A', -1))
    tlhc_S = float(whdr.get('tlhc_S', -1))
    trhc_R = float(whdr.get('trhc_R', -1))
    trhc_A = float(whdr.get('trhc_A', -1))
    trhc_S = float(whdr.get('trhc_S', -1))
    brhc_R = float(whdr.get('brhc_R', -1))
    brhc_A = float(whdr.get('brhc_A', -1))
    brhc_S = float(whdr.get('brhc_S', -1))

    xtl = array([tlhc_R, tlhc_A, tlhc_S])
    xtr = array([trhc_R, trhc_A, trhc_S])
    xbr = array([brhc_R, brhc_A, brhc_S])

    if xtr[0]-xtl[0] != 0.:
        theta = atan((xtr[2]-xtl[2])/(xtr[0]-xtl[0]))
    elif abs(xtr[2]-xtl[2]) < .1:
        theta = 0.
    else:
        theta = math.pi/2.

    Rtht = identity(3).astype(float)
    ctht = cos(theta)
    stht = sin(theta)
    Rtht[0, 0] =  ctht
    Rtht[0, 2] =  stht
    Rtht[2, 0] = -stht
    Rtht[2, 2] =  ctht

    xtrp = dot(Rtht, xtr+xtl)
    xbrp = dot(Rtht, xbr+xtl)

    if xtr[0]-xtl[0] != 0.:
        phi = atan((xtrp[2]-xbrp[2])/(xtrp[1]-xbrp[1]))
    elif abs(xtrp[2]-xbrp[2]) < .1:
        phi = 0.
    else:
        phi = math.pi/2.

    Rphi = identity(3).astype(float)
    cphi = cos(phi)
    sphi = sin(phi)
    Rphi[1, 1] =  cphi
    Rphi[1, 2] =  sphi
    Rphi[2, 1] = -sphi
    Rphi[2, 2] =  cphi

    Rphi = identity(3).astype(float)
    Rphi[0, 0] =  cphi
    Rphi[0, 1] =  sphi
    Rphi[1, 0] = -sphi
    Rphi[1, 1] =  cphi

    R = dot(Rphi, Rtht)
    return (R, phi, theta)



class NativeHeader():
    """
    Purpose: 
        Create a dictionary containing native header elements.
    """
    def _get_dicom_header(self, scan=False):
        self.dcm = Dicom(self.hdrname, scan=scan)
        if self.dcm.nhdr is None:
            return None
        self.nhdr = self.dcm.nhdr
        return self.nhdr
    def _get_nifti_header(self, scan=False):
        self.nhdr = read_nifti_header(self.hdrname)
        return self.nhdr
    def _get_afni_header(self, scan=False):
        self.nhdr = read_afni_header(self.hdrname)
        return self.nhdr
    def _get_voxbo_header(self, scan=False):
        self.nhdr = read_voxbo_header(self.hdrname)
        return self.nhdr
    def _get_analyze_header(self, scan=False):
        self.nhdr = read_analyze_header(self.hdrname)
        return self.nhdr
    def _get_GE_ipfile_header(self, scan=False):
        self.nhdr = read_GE_ipfile(self.hdrname, self.slot)
        return self.nhdr
    def _get_none_header(self, scan=False):
        self.nhdr = None
        return None

def convert_unix_time(unixtime):
    """
    Convert posix time-stamp ( time since invention of unix in seconds) to
    a meaningful string.
    """
    if unixtime is not None:
        if isinstance(unixtime, int) or isinstance(unixtime, float):
            xtime = '%d' % unixtime
        else:
            xtime = unixtime
        if xtime.isdigit():
            if len(xtime) > 6:
                ctime = datetime.fromtimestamp(float(xtime)).\
                                                strftime('%Y%b%d_%X')
            else:
                ctime = '%s:%s:%s' % (xtime[:2], xtime[2:4], xtime[4:])
        else:
            ctime = 'unknown'
    else:
        ctime = 'unknown'
    return ctime

class SubHeader(NativeHeader):
    """
    Purpose:
        Create a dictionary with keys that are common across file types.
        Provides a uniform interface to often-used parameters.
    """
    def _get_dicom_shdr(self):
        nhdr = self.nhdr
        if not nhdr['ImageData']:
            return None
        
        ctime = convert_unix_time(nhdr.get('SeriesTime',None))
        self.shdr = {\
                'AcqTime':ctime, \
                'InstitutionName':nhdr['InstitutionName'], \
                'TR':nhdr['RepetitionTime'], \
                'PatientAge':nhdr['PatientAge'], \
                'PatientId':nhdr['PatientId'], \
                'PatientName':nhdr['PatientName'], \
                'PatientSex':nhdr['PatientSex'], \
                'PatientWeight':nhdr['PatientWeight'], \
                'ProtocolName':nhdr['ProtocolName'], \
                'SeriesNumber':nhdr.get('SeriesNumber',0), \
                'SeriesTime':nhdr.get('ActualSeriesDateTime',0), \
                'SeriesDescription':nhdr['SeriesDescription'], \
                'SeriesNumber':nhdr['SeriesNumber'], \
#                'StartImage':nhdr['StartImage'], \
                'StudyDate':nhdr['StudyDate'], \
                'StudyDescription':nhdr['StudyDescription'], \
                'SeriesDateTime':nhdr['SeriesDateTime'], \
                'PatientBirthDate':nhdr['PatientBirthDate'], \
                'ExamNumber':nhdr['StudyID']}
        if self.nhdr['Modality'] == 'MR':
            self.shdr['EffEchoSpacing'] = nhdr['EffEchoSpacing']
            self.shdr['FlipAngle'] = nhdr['FlipAngle']
            self.shdr['ImageType'] = nhdr['ImageType']
            self.shdr['PhaseEncodeDir'] = nhdr['PhaseEncDir']
            self.shdr['TI'] = nhdr['InversionTime']
            self.shdr['TE'] = nhdr['EchoTime']
            self.shdr['PulseSequenceName'] = nhdr['PulseSequenceName']
            self.shdr['CoilName'] = nhdr['ReceiveCoilName']
            self.shdr['TR'] = nhdr['RepetitionTime']
        elif self.nhdr['Modality'] == 'PT':
            self.shdr['TR'] = nhdr['ActualFrameDuration']

#       Fix slice order based on sorting procedure.
#        if not nhdr.has_key('SliceOrder'):
        if nhdr.has_key('DicomInfo'):
            if nhdr['DicomInfo'].has_key('ndig'):
                first_slice = nhdr['DicomInfo']['0_0_0'][0]
            else:
                first_slice = int(nhdr['DicomInfo']['0_0_0'][0].split('.')[1])
            if first_slice == 1:
                nhdr['SliceOrder'] = 'altplus'
            else:
                nhdr['SliceOrder'] = 'altminus'
        else:
            nhdr['SliceOrder'] = 'None'
        self.shdr['SliceOrder'] = nhdr['SliceOrder']

        R = nhdr['R']
#       Correct z-axis position if all files have been scanned.
        self.protohdr = { \
            'dims':(nhdr['ndim'], nhdr['Columns'], nhdr['Rows'], \
                    nhdr['LocationsInAcquisition'], nhdr['NumberOfFrames'], \
                    nhdr['TypeDim']), \
            'sizes':(nhdr['PixelSpacing'][0], nhdr['PixelSpacing'][1], \
                    abs(nhdr['SpacingBetweenSlices']), self.shdr['TR'], 1.),\
            'origin':nhdr['ImagePosition'], \
            'vox_info':(nhdr['Columns']*nhdr['Rows']* \
                    nhdr['LocationsInAcquisition']* \
                    nhdr.get('NumberOfFrames', 1)*nhdr['TypeDim'], 
                    nhdr['BitsStored'], \
                    dicom_datanum_to_code.get(nhdr['BitsStored'], 'unknown'), \
#                    1 if nhdr['HighBit'] == 0 else 0, nhdr['StartImage']), \
#                    nhdr['HighBit'] == 0 and 1 or 0, nhdr['StartImage']), \
                    nhdr['HighBit'] == 0 and 1 or 0, -1), \
#                    nhdr['HighBit'] == 0 and 1 or 0, nhdr['StartImage']), \
            'scale':(1., 0.), 'R':R}
        return self.shdr

    def _get_nifti_shdr(self):
        nhdr = self.nhdr
        R = quatern_to_rot44(nhdr['quatern_b'], nhdr['quatern_c'], \
                nhdr['quatern_d'], nhdr['qfac'], nhdr['qoffset_x'], \
                nhdr['qoffset_y'], nhdr['qoffset_z'])
        TR = nhdr['pixdim'][4]*time_to_scalefactor[nhdr['time_units']]
        if TR < 10: # Looks like TR is in seconds 
            TR = TR*1000

            

#       Fix broken headers.
        for i in xrange(8):
            if nhdr['dim'][i] == 0:
                nhdr['dim'][i] = 1

        self.protohdr = {'dims':(nhdr['dim'][0], nhdr['dim'][1], 
            nhdr['dim'][2], nhdr['dim'][3], nhdr['dim'][4], nhdr['dim'][5]), \
            'sizes':(nhdr['pixdim'][1], nhdr['pixdim'][2], nhdr['pixdim'][3], \
            float(TR), nhdr['pixdim'][5]), \
            'origin':(R[0, 3], R[1, 3], R[2, 3]), \
            'vox_info':(nhdr['num_voxels'], nhdr['bitpix'], nhdr['datatype'], \
             nhdr['swap'], nhdr['vox_offset']), \
            'scale':(nhdr['scl_slope'], nhdr['scl_inter']), \
            'R':R}
        self.shdr = none_subhdr.copy()
        self.shdr['TR'] = TR
        self.shdr['SeriesDescription'] = nhdr['descrip']
        self.shdr['EffEchoSpacing'] = nhdr.get('EffEchoSpacing','N/A')

        self.shdr['SliceOrder'] = nhdr['SliceOrder']
        return self.shdr

    def _get_afni_shdr(self):
        nhdr = self.nhdr
        if nhdr['dataset_rank'][1] > 1:
            datanum = nhdr['brick_types'][0]
            brick_float_fac = nhdr['brick_float_facs'][0]
        else:
            datanum = nhdr['brick_types']
            brick_float_fac = nhdr['brick_float_facs']
        datatype = afni_datanum_to_code[datanum]

#        self.protohdr = {'dims':(3 if nhdr['dataset_rank'][1] == 1 else 4, \
        self.protohdr = {'dims':(nhdr['dataset_rank'][1] == 1 and 3 or 4, \
            nhdr['dataset_dimensions'][0], nhdr['dataset_dimensions'][1], \
            nhdr['dataset_dimensions'][2], nhdr['dataset_rank'][1], 1), \
            'sizes':(abs(nhdr['delta'][0]), abs(nhdr['delta'][1]), \
            abs(nhdr['delta'][2]), float(nhdr.get('TR', 0.)), 1.), \
            'origin':(nhdr['origin'][0], nhdr['origin'][1], \
            nhdr['origin'][2]), \
            'vox_info':( nhdr['dataset_dimensions'][0]*\
            nhdr['dataset_dimensions'][1]* \
             nhdr['dataset_dimensions'][2]*nhdr['dataset_rank'][1], \
             datatype_to_lgth[datatype], datatype, \
             nhdr['byteorder_string']=='MSB_FIRST' and 1 or 0, 0), \
             'scale':(brick_float_fac==0. and 1.0 or brick_float_fac, 0.)}
#             1 if nhdr['byteorder_string']=='MSB_FIRST' else 0, 0), \
#            'scale':(1. if brick_float_fac==0. else brick_float_fac, 0.)}

        dims = self.protohdr['dims']
        sizes = self.protohdr['sizes']
        xyz0 = self.protohdr['origin']
        self.protohdr['R'] = afni_to_rot44(dims[0], dims[1], dims[2], \
            abs(sizes[0]), \
            abs(sizes[1]), abs(sizes[2]), xyz0[0], xyz0[1], xyz0[2], \
            nhdr['orient_specific'][0], nhdr['orient_specific'][1], \
            nhdr['orient_specific'][2])
        self.shdr = none_subhdr.copy()
        self.shdr['TR'] = nhdr.get('TR', 0)
        if nhdr.has_key('SliceOrder'):
            self.shdr['SliceOrder'] = nhdr['SliceOrder']
        if nhdr.has_key('brick_statsym'):
            if ';' in nhdr['brick_statsym']:
#               HEAD file not written by fmristat.
                statsym_frms = nhdr['brick_statsym'].split(';')
            else:
                statsym_frms = [nhdr['brick_statsym']]
            stat_type = []
            stat_dof = []
            for statsym in statsym_frms:
                if statsym == 'none':
                    stat_type.append(None)
                    stat_dof.append(0)
                else:
                    wds = statsym.split('(')
                    stat_type.append(wds[0])
                    if wds[0] == 'Ttest':
                        stat_dof.append((int(wds[1][:-1])))
                    elif wds[0] == 'Ftest':
                        svals = wds[1][:-1].split(',')
                        stat_dof.append((int(svals[0]), int(svals[1])))
            self.shdr['StatType'] = stat_type
            self.shdr['DegFreedom'] = stat_dof
        else:
            if self.nhdr.has_key('worsley_df'):
                self.shdr['StatType'] = ['Ttest']
                self.shdr['DegFreedom'] = [float(self.nhdr['worsley_df'])]
        return self.shdr

    def _get_voxbo_shdr(self):
        nhdr = self.nhdr
#        self.protohdr = {'dims':(3 if self.filetype == 'cub' else 4, \
        self.protohdr = {'dims':(self.filetype == 'cub' and 3 or 4, \
                nhdr['VoxDims(TXYZ):'][1], nhdr['VoxDims(TXYZ):'][2], \
                nhdr['VoxDims(TXYZ):'][3], nhdr['VoxDims(TXYZ):'][0], 1), \
            'sizes':(nhdr['VoxSizes(XYZ):'][0], \
                nhdr['VoxSizes(XYZ):'][1], nhdr['VoxSizes(XYZ):'][2], \
            float(nhdr.get('TR(msecs):', [0.])[0]), 1.), \
            'origin':nhdr['Origin(XYZ):'], \
            'vox_info':(nhdr['VoxDims(TXYZ):'][0]*nhdr['VoxDims(TXYZ):'][1]* \
                nhdr['VoxDims(TXYZ):'][2]*nhdr['VoxDims(TXYZ):'][3], \
                datatype_to_lgth[nhdr['DataType:'].lower()], \
                nhdr['DataType:'].lower(), \
#                0 if nhdr.get('ByteOrder:', "")=='msbfirst' else 1, \
                nhdr.get('ByteOrder:', "")=='msbfirst' and 0 or 1, \
                 nhdr['start_binary']), \
            'scale':(nhdr.get('scl_slope:', 1.), 0.), \
            'R':nhdr['R']}
        self.shdr = none_subhdr
        self.shdr['TR'] = nhdr.get('TR(msecs):', None)
        self.shdr['PatientName'] = nhdr.get('SubjectName:', None)
        self.shdr['PatientAge'] = nhdr.get('SubjectAge:', None)
        self.shdr['CoilName'] = nhdr.get('CoilName', None)
        return self.shdr

    def _get_analyze_shdr(self):
        nhdr = self.nhdr
        self.protohdr = {'dims':(nhdr['ndim'], nhdr['xdim'], nhdr['ydim'], \
             nhdr['zdim'], nhdr['tdim'], nhdr['mdim']), \
            'sizes':(nhdr['xsize'], nhdr['ysize'], nhdr['zsize'], \
            float(nhdr.get('TR',0)), nhdr['msize']), 'origin':(nhdr['x0'],  \
            nhdr['y0'], nhdr['z0']), \
            'vox_info':(nhdr['num_voxels'], nhdr['bitpix'], nhdr['datatype'], \
                nhdr['swap'], nhdr['start_binary']), \
            'scale':(nhdr['scale_factor'], 0.), 'R':nhdr['R']}
        self.shdr = none_subhdr
        self.shdr['TR'] = nhdr['TR']
        return self.shdr

    def _get_GE_ipfile_shdr(self):
        nhdr = self.nhdr
#        data_type = 'short' if nhdr['PointSize'] == 2 else 'integer'
        if nhdr['PointSize'] == 1:
            nhdr['PointSize'] = 2
        data_type = nhdr['PointSize'] == 2 and 'short' or 'integer'
        R = pfile_nhdr_to_rot44(nhdr)
        orientstring = R_to_orientstring(R)
        if self.filetype == 'ge_data':
            xdim = nhdr['DAResolutionX']; ydim = nhdr['DAResolutionY']
#            zdim = nhdr['NumberSlices']
            nslices = nhdr['NumberSlices']
            if nhdr.has_key('NumberExcitations'):
                nframes = float(nhdr['NumberExcitations'])
            else:
                nframes = float(nhdr['NumberSlicesTotal'])/nslices
            nframes = int(nframes)
            nchan = int((self.nbytes - nhdr['StartImage'])/ \
                      (2*nhdr['PointSize']*xdim*ydim*nslices*nframes))
            zdim = nslices
            if nchan > 1:
                tdim = nchan
                mdim = nframes
            else:
                tdim = nframes
                mdim = 1
            data_type = 'complex'
        elif 'epi' in nhdr['PulseSequenceFile'].lower():
            xdim = nhdr['ImageDimensionX']; ydim = nhdr['ImageDimensionY']
            zdim = nhdr['NumberSlices']
            tdim = nhdr['NumberExcitations']
            mdim = 1
        elif nhdr['Nfiles'] == \
                nhdr['NFrames']*nhdr['NumberOfEchoes']*nhdr['NumberSlices']:
            xdim = nhdr['ImageDimensionX']; ydim = nhdr['ImageDimensionY']
            zdim = nhdr['NumberSlices']
            tdim = nhdr['NFrames']
            mdim = nhdr['NumberOfEchoes']
        elif self.filetype == 'ge_ifile':
            xdim = nhdr['ImageDimensionX']
            ydim = nhdr['ImageDimensionY']
            zdim = nhdr['NumberSlices']
            tdim = nhdr['NFrames']
            mdim = nhdr['Nfiles']/(zdim*tdim)
        else:
            raise RuntimeError('Unrecognized file type: %s for %s' % \
                                        (self.filetype, self.filename))
                
        self.protohdr = {'dims':(nhdr['ndim'], \
            xdim, ydim, zdim, tdim, mdim), \
            'sizes':(nhdr['PixelSizeX'], nhdr['PixelSizeY'], \
            float(nhdr['SliceThickness'])+float(nhdr['ScanSpacing']), \
            float(nhdr.get('RepetitionTime',0.)), 1.), \
            'origin':(R[0, 3], R[1, 3], R[2, 3]), \
            'vox_info':(nhdr['ImageDimensionX']*nhdr['ImageDimensionY']* \
            nhdr['NumberSlices']*nhdr['NumberExcitations']*\
            nhdr['NumberOfEchoes'],8*nhdr['PointSize'], data_type, \
            nhdr['ByteSwap'], nhdr['StartImage']), 'scale':(1., 0.), 'R':R}
        PlaneType = orientstring_to_plane(orientstring, nhdr)
        ImageType = 'N/A'
        ctime = convert_unix_time(nhdr.get('ImageDate',None))
        self.shdr = {'AcqTime':ctime, \
            'EffEchoSpacing':nhdr.get('EchoSpacing', -1), \
            'FlipAngle':nhdr['FlipAngle'], \
            'ImageType':nhdr['FrequencyDirection'],  \
            'ImageType':ImageType, \
#            'PhaseEncodingDir':nhdr['None'], \
            'InstitutionName':nhdr['HospitalName'], \
            'TI':nhdr['InversionTime'], \
            'TE':nhdr['EchoTime'], \
            'TR':nhdr['RepetitionTime'], \
            'PatientAge':nhdr['PatientAge'], \
            'PatientId':nhdr['PatientId'], \
            'PatientName':nhdr['PatientName'], \
            'PatientSex':nhdr['PatientSex'], \
            'PatientWeight':nhdr['PatientWeight'], \
#            'PlaneType':plane_type.get(nhdr['ObliquePlane'], 'Unknown'), \
            'PlaneType':PlaneType, 
            'ProtocolName':nhdr['Protocol'], \
            'PulseSequenceName':nhdr['PulseSequenceName'], \
            'CoilName':nhdr['CoilName'], \
            'SeriesDescription':nhdr['SeriesDescription'], \
            'SeriesNumber':nhdr['SeriesNumber'], \
            'SeriesTime':nhdr.get('ImageDate',None), \
            'StudyDate':nhdr['ExamDateTime'], \
            'StudyDescription':nhdr['ExamDescription'], \
            'ExamNumber':nhdr['ExamNumber']}
#            'SwapPhaseFreq':nhdr['SwapPhaseFreq']}
        return self.shdr
    def _get_none_shdr(self):
        self.shdr = None
        self.protohdr = None

#protohdr = {'dims':
#            'size':
#            'origin':
#            'vox_info':numvoxels, bitpix, datatype, swap, start_binary
#            'scale':scale_factor, scale_offset
#            'orient':R, orient_str, orientation

class Header(SubHeader, NativeHeader):
    """
    Purpose:
        Read native header, create sub-header, and pack into a single 
        dictionary to comprise the header.
    """
    def __init__(self, path_in=None, scan=False, native_header=None, \
                 ignore_yaml=False, slot=0):
        """
        Check if there is a yaml or pickle file (dicom and GE I-file only). 
        If so, read the header from the yaml or pickle file.  Otherewise,
        read it from the data itself.
        """
        self.hdr = None
        self.shdr = {}
        self.nhdr = None
        self.scan = scan
        self.slot = slot
        self.filetype_to_nhdrmeth = {\
            'dicom':self._get_dicom_header, \
            'brik':self._get_afni_header, \
            'ni1':self._get_nifti_header, \
            'n+1':self._get_nifti_header, \
            'nii':self._get_nifti_header, \
            'analyze':self._get_analyze_header, \
            'tes':self._get_voxbo_header, \
            'ge_data':self._get_GE_ipfile_header, \
            'ge_ifile':self._get_GE_ipfile_header, \
            'none':self._get_none_header}
        self.filetype_to_shdrmeth = {\
            'dicom':self._get_dicom_shdr, \
            'brik':self._get_afni_shdr, \
            'ni1':self._get_nifti_shdr, \
            'n+1':self._get_nifti_shdr, \
            'analyze':self._get_analyze_shdr, \
            'tes':self._get_voxbo_shdr, \
            'ge_data':self._get_GE_ipfile_shdr, \
            'ge_ifile':self._get_GE_ipfile_shdr, \
            'none':self._get_none_shdr}
        if path_in is None:
            path = None
            self.filename = None
        else:
            path = os.path.abspath(path_in)
            self.filename = path

        if native_header:
            self.nhdr = native_header
            yaml_name = None
        elif not ignore_yaml:
            if os.path.isdir(path):
                yaml_name = self.CheckYaml('%s/%s' % \
                                            (path, os.path.basename(path)))
            else:
                yaml_name = self.CheckYaml(path)
        else:
            yaml_name = None
        if yaml_name is not None:
            self.ReadYaml(yaml_name)    
        if self.hdr is None:  
            self.hdr = self.get_header(scan=scan)

    def CheckYaml(self, prefix):
        """
        Check for the existence of a yaml or pickle file.
        """
        if os.path.exists('%s.pickle' % prefix):
            return '%s.pickle' % prefix
        elif os.path.exists('%s.yaml' % prefix):
            return '%s.yaml' % prefix
        elif os.path.exists('%s.yaml.gz' % prefix):
            return '%s.yaml' % prefix
        elif os.path.exists('%s.yaml.bz2' % prefix):
            return '%s.yaml' % prefix
        else:
            return None

    def ReadYaml(self, fname):
        """
        Read header from yaml file. It has apparently already been read
        and then rewritten in this format.
        """
        dirname = os.path.dirname(fname)
        if 'yaml' in fname:
            self.hdr = self.read_hdr_from_yaml(fname)
        elif fname.endswith('.pickle'):
            f = open(fname, 'r')
            self.hdr = cPickle.load(f)
            f.close()
        else:
            raise RuntimeError('Invalid file name: %s' % fname)
        if self.hdr is None:
            return
        if self.hdr.has_key('imgfile'):
            if isinstance(self.hdr['imgfile'], tuple):
                iname = self.hdr['imgfile'][0].\
                            join(self.hdr['imgfile'][1])
            else:
                iname = self.hdr['imgfile']
            self.hdr['imgfile'] = '%s/%s' % \
                (dirname, os.path.basename(iname))
#                (dirname, os.path.basename(self.hdr['imgfile']))
        if self.hdr.has_key('native_header'):
            nhdr = self.hdr['native_header']
            if nhdr.has_key('DicomInfo'):
                nhdr['DicomInfo']['dims']['dirname'] = dirname
            if nhdr.get('FileName', None):
                nhdr['FileName'] = '%s/%s' % \
                    (dirname, os.path.basename(nhdr['FileName']))
            nhdr['dirname'] = dirname
        if self.hdr['filetype'] == 'ge_ifile':
            self.hdr['mdim'] = self.hdr['native_header']['Nfiles']/ \
                                (self.hdr['zdim']*self.hdr['tdim'])
            self.hdr['dims'][4] = self.hdr['mdim']
        elif self.hdr['filetype'] == 'dicom':
            imgfile = '%s/%s' % (os.path.dirname(fname), \
                                os.path.basename(self.hdr['imgfile']))
            if os.path.exists(imgfile):
                dicom_name = imgfile
            elif os.path.exists(imgfile + '.bz2'):
                dicom_name = imgfile + '.bz2'
            elif os.path.exists(imgfile + '.gz'):
                dicom_name = imgfile + '.gz'
            else:
                dirname = os.path.dirname(fname)
                fnames = os.listdir(dirname)
                for fname in fnames:
                    fullname = '%s/%s' % (dirname, fname)
                    if isdicom(fullname):
                        dicom_name = fullname
                        break
                    elif fname.endswith('.tar'):
                        dt = DicomTar(fullname)
                        if dt.isTar:
                            dicom_name = fullname
                            break
                else:
                    self.dcm = None
                    return
            self.dcm = Dicom(dicom_name, nhdr=self.hdr['native_header'])
            if self.hdr is not None:
                self.shdr = self.hdr['subhdr']
                self.dcm.nhdr = self.hdr['native_header']
                self.nhdr = self.dcm.nhdr
                if self.nhdr.has_key('DicomInfo'):
                    self.dcm.dicominfo = self.nhdr['DicomInfo']
                    dims = self.dcm.dicominfo['dims']
                    self.dcm.scan = True
                    self.scan = True
#                   Fix for bug in yaml files uploaded in early 2011.
                    self.nhdr['LocationsInAcquisition'] = dims['zdim']
                    self.nhdr['NumberOfFrames'] = dims['tdim']
                    self.nhdr['EchoTimes'] = dims['EchoTimes']
                    self.dcm.nhdr['LocationsInAcquisition'] = dims['zdim']
                    self.dcm.nhdr['NumberOfFrames'] = dims['tdim']
                    self.hdr['zdim'] = dims['zdim']
                    self.hdr['tdim'] = dims['tdim']
                    self.hdr['mdim'] = dims['TypeDim']
                    if self.hdr['mdim'] > 1:
                        self.hdr['ndim'] = 5
                    elif self.hdr['tdim'] > 1:
                        self.hdr['ndim'] = 4
                    elif self.hdr['zdim'] > 1:
                        self.hdr['ndim'] = 3
                    else:
                        self.hdr['ndim'] = 2
                    self.hdr['dims'][2:5] = [dims['zdim'], dims['tdim'], \
                                                    dims['TypeDim']]

#                   Test if yaml file written after left-right flip bug  that
#                   occurred Spring 2011. If SliceOrder is present, the hdr 
#                   can be trusted. Otherwise recompute R.
                    if not dims.has_key('SliceOrder') and \
                       self.nhdr['FirstScanRas'] is not None and \
                       self.nhdr['FirstScanLocation'] is not None:
                        self.hdr['R'], self.hdr['orientation'] = \
                                                        self.GetDicomOrient()
                    else:
                        self.shdr['SliceOrder'] = self.nhdr.get('SliceOrder', None)
                else:
                    self.dcm.scan = False
                    self.scan = False

    def GetDicomOrient(self):
        """
        Deduce the transformation matrix that would transform the data within
        a DICOM series into the RAI coordinate system.
        """
        dims = self.dcm.dicominfo['dims']
        start_ras = self.nhdr['FirstScanRas'].strip()
        revras = {'R':'L', 'A':'P', 'I':'S', 'L':'R', 'P':'A', 'S':'I'}
        if self.nhdr['DicomInfo'].has_key('0_0_1'):
            if self.nhdr['DicomInfo'].has_key('ndig'):
                test = self.nhdr['DicomInfo']['0_0_1'][0] - \
                       self.nhdr['DicomInfo']['0_0_0'][0]
            else:
                test = int(self.nhdr['DicomInfo']['0_0_1'][0].split('.')[1]) - \
                        int(self.nhdr['DicomInfo']['0_0_0'][0].split('.')[1])
        else:
#           Only one slice.
            test = 1
        if test > 0:
            self.nhdr['SliceOrder'] = 'altplus'
            swap_locs = False
        else:
            self.nhdr['SliceOrder'] = 'altminus'
            start_ras = revras[start_ras]
            swap_locs = True
        start_loc = -float(self.nhdr['FirstScanLocation'])
        if start_loc != dims['StartLoc'] and start_loc != dims['EndLoc']:
#           Account for unique behavior for ASL recon.
            start_loc = -start_loc
        if start_loc == dims['EndLoc']:
#           First find the actual start-loc and end_loc.
            self.nhdr['StartLoc'], self.nhdr['EndLoc'] = \
                            self.Swap(dims['StartLoc'], dims['EndLoc'])
        else:
            self.nhdr['StartLoc'], self.nhdr['EndLoc'] = \
                                (dims['StartLoc'], dims['EndLoc'])
        if swap_locs:
#           Now account for the flip that will take place.
            self.nhdr['StartLoc'], self.nhdr['EndLoc'] = \
                        self.Swap(self.nhdr['StartLoc'], self.nhdr['EndLoc'])
        
        self.shdr['SliceOrder'] = self.nhdr['SliceOrder']
        R = dicom_to_rot44(self.nhdr['ImageOrientation'], \
                  self.nhdr['ImagePosition'], start_ras, self.nhdr['StartLoc'])

        orientation = R_to_orientstring(R)
        if self.nhdr['StartLoc'] == self.nhdr['EndLoc']:
            orientation = orientation[:2] + '?'
        return R, orientation

    def Swap(self, x1, x2):
        """
        Swap two elements in an array or sequence.
        """
        tmp = x1
        return x2, tmp

    def get_header(self, scan=False):
        """
        Read the header. Creates the hdr attribute - a dictionary containing 
        a uniform set of keys for parameters common to all file-types.  
        Format-specific data are stored in dictionaries under  the "subhdr" 
        and "native_header" keys.
        """
        if self.hdr is not None and self.scan == scan:
            return self.hdr
        if self.filename:
            self.hdrname, self.hdrsuffix = get_hdrname(self.filename)
            self.filetype = file_type(self.hdrname)
            if len(self.hdrsuffix) == 0 and self.filetype == 'n+1':
                self.hdrsuffix = '.nii'
                self.filename = '%s.nii' % self.filename
                self.hdrname = self.filename
            if self.filetype == 'ge_data':
                st = os.stat(self.filename)
                self.nbytes = st.st_size
        else:
            self.filetype = self.nhdr['filetype']

        if self.filetype is None or self.filetype is 'biopac':
            return None
#        sys.stdout.write( ' 3c ' + self.timer.ReadTimer())
        self.file_nhdr_meth = self.filetype_to_nhdrmeth[self.filetype]
        self.file_shdr_meth = self.filetype_to_shdrmeth[self.filetype]
        self.shdr = self._get_none_shdr

#       Read native header.
        if self.nhdr is not None:
            if self.nhdr.has_key('dicominfo'):
                self.scan = True
            else:
                self.scan = False
        else:
            self.nhdr = apply(self.file_nhdr_meth, ([scan]))
            self.scan = scan
#        sys.stdout.write( ' 4c ' + self.timer.ReadTimer() )

        if self.nhdr is None:
            self.hdr = None
            return None

#       Read subheader.
        self.shdr = apply(self.file_shdr_meth, ())
        if self.shdr is None:
            self.hdr = {'native_header': self.nhdr, 'subhdr':{}}
            return self.hdr

        orient = R_to_orientstring(self.protohdr['R'])
        plane = orientstring_to_plane(orient)
        if self.filetype == 'dicom':
#           Orientation undefined for single-slice dicoms.
            if self.nhdr['StartLoc'] == self.nhdr['EndLoc']:
                orient = orient[:2] + '?'

        if self.filename:
            if self.filetype == 'dicom':
                imgfile = os.path.splitext(self.filename)[0]
            else:
                imgfile = os.path.splitext(self.filename)[0] + \
                        hexts.get(self.hdrsuffix, self.hdrsuffix)
        else:
            imgfile = ''
        if self.protohdr['dims'][5] > 1:
            ndim = 5
        elif self.protohdr['dims'][4] > 1:
            ndim = 4
        elif self.protohdr['dims'][3] > 1:
            ndim = 3
        else:
            ndim = 2
        dims = ones([6],int)
        sizes = zeros([5],float)
        dims[:ndim] = self.protohdr['dims'][1:ndim+1]
        sizes[:ndim] = self.protohdr['sizes'][:ndim]
        self.hdr = {'xdim':long(self.protohdr['dims'][1]), \
            'ydim':long(self.protohdr['dims'][2]), \
            'zdim':long(self.protohdr['dims'][3]), \
            'tdim':long(self.protohdr['dims'][4]), \
            'mdim':long(self.protohdr['dims'][5]), \
            'dims':dims.astype(long), \
            'ndim':ndim, \
            'xsize':self.protohdr['sizes'][0], \
            'ysize':self.protohdr['sizes'][1], \
            'zsize':self.protohdr['sizes'][2], \
            'tsize':self.protohdr['sizes'][3], \
            'msize':self.protohdr['sizes'][4], \
            'sizes':sizes, \
            'x0':self.protohdr['origin'][0], \
            'y0':self.protohdr['origin'][1], \
            'z0':self.protohdr['origin'][2], \
            'num_voxels':self.protohdr['vox_info'][0], \
            'bitpix':self.protohdr['vox_info'][1], \
            'datatype':self.protohdr['vox_info'][2], \
            'swap':self.protohdr['vox_info'][3], \
            'start_binary':self.protohdr['vox_info'][4], \
            'scale_factor':self.protohdr['scale'][0], \
            'scale_offset':self.protohdr['scale'][1], \
            'R':self.protohdr['R'], \
            'orientation':orient, \
            'plane':plane, \
            'filetype':self.filetype, \
            'imgfile':imgfile, \
            'subhdr':self.shdr, \
            'native_header':self.nhdr}
#        sys.stdout.write( ' 5d ' + self.timer.ReadTimer() + '\n')
        return self.hdr

    def convert_to_yaml(self):
        """
        Serialize the header using the YAML serializer.
        """
        add_ndarray_to_yaml()
        hdr1 = self.hdr.copy()
        hdr1['imgfile'] = os.path.basename(hdr1['imgfile'])
        return yaml.dump(self.hdr)

    def write_hdr_to_yaml(self, filename):
        """
        Write header to a yaml-encoded file.
        """
        if self.scan == False and self.hdr['filetype'] == 'dicom':
            raise RuntimeError(\
            "Cannot write dicom headers to a yaml file unless the scan option is True.\nfile: %s" % filename)
#       Tell yaml how to handle numpy arrays.
        add_ndarray_to_yaml()
        hdr1 = self.hdr.copy()
        hdr1['imgfile'] = os.path.basename(hdr1['imgfile'])
        try:
            f = open(filename, "wb")
            f.write(yaml_magic_code) # Write the magic code.
            f.write(yaml.dump(self.hdr))
            f.close()
        except IOError:
            raise IOError(\
            'file_io:: Could not write to yaml file: %s' % filename)

    def read_hdr_from_yaml(self, filename):
        """
        Read header from a yaml-encoded file.
        """
        try:
            f = open_gzbz2(filename, "rb")
        except IOError:
            raise IOError(\
            'file_io:: Could not read from yaml file: %s' % filename)
        code = f.read(len(yaml_magic_code))
        if code != yaml_magic_code:
            f.close()
            hdr = None
        else:
#           Tell yaml how to handle numpy arrays.
            add_ndarray_to_yaml()
            data = f.read()
            try:
                hdr = yaml.load(data)
            except:
                lines = data.split('\n')
                fixed = []
                i = 0
                while i < len(lines):
                    if lines[i].startswith('  MediaStorageSopClassUid:'):
#                       Invalid constructor on scanner end. Fix it.
                        uid = lines[i+1].replace('[','').replace(']','').split()[-1]
                        fixed.append('  MediaStorageSopClassUid: %s\n' % uid)
                        i += 3
                    elif lines[i].startswith('  RequestingPhysician:'):
                        i += 11
                    else:
                        fixed.append(lines[i])
                    i += 1
                hdr = yaml.load('\n'.join(fixed))
            f.close()
        return hdr

def write_yaml(fname, hdr, write_pickle=False):

    prefix = strip_suffix(fname)

#   Tell yaml how to handle numpy arrays.
    add_ndarray_to_yaml()

#   Update filename field.
    hdr1 = hdr.copy()
    hdr1['imgfile'] = os.path.basename(hdr1['imgfile'])
    f = open('%s.yaml' % prefix, 'w')
    f.write(yaml_magic_code)
    f.write(yaml.dump(hdr1))
    f.close()

    if write_pickle == True:
#       Now write to a pickle file.
        f = open('%s.pickle' % prefix, 'w')
        pickler = cPickle.Pickler(f)
        pickler.dump(hdr1)
        f.close()
        
#***************************
def rot44_inv(M, dims, sizes):
#***************************

    """ 
    Invert a 4x4 transformation matrix with a unitary rotation matrix.
        dims: 3x1 vector of image dimensions, array((xdim, ydim, zdim))
        sizes: 3x1 vector of voxel sizes, array((xsize, ysize, zsize))
        dims and sizes are both specified in the original coordinate system.
    """

    Minv = zeros([4, 4], float)
    dsizes = diag(sizes)
    R = dot(M[:3, :3], dsizes)
    x0in = M[:3, 3]
    fov = (dims - 1.)*sizes
    direction = dot(R.transpose(), abs(R)) # dir = -1 for reversed traversals
    flips = ((identity(3) - direction)/2).round()
    x0 = dot(R.transpose(), dot(dsizes, x0in)) + dot(flips, fov)
    Minv[:3, :3] = dot(dsizes, R.transpose())

    Minv[:3, 3] = x0 #dot(dsizes, x0)
    return Minv
    

##*******************************
#def get_exam_list(exam):
##*******************************
#
#
##    Get list of study directories.
#    top = '/export/home1/sdc_image_pool/images'
#    topdirs = os.listdir(top)
#    exampaths = []
#    for dir in topdirs:
#        subdir = "%s/%s" % (top, dir)
#        examdirs = os.listdir(subdir)
#        for examdir in examdirs:
#            if examdir[:4] != 'core':
#                exampaths.append("%s/%s" % (subdir, examdir))
#
#    exam_info = []
#    examm1 = ""
#    exams = []
#    for exampath in exampaths:
#        examseries = os.listdir(exampath)
##       Loop over each series in the exam
#        for series in examseries:
#            seriespath = "%s/%s" % (exampath, series)
#            slices = os.listdir(seriespath)
#            if len(slices) > 0:
##               Read the header from the first slice to get the exam number.
#                filename = '%s/%s' % (seriespath, slices[0])
#                hdr = read_ge_dicom_header(filename)
#                examno = hdr['exam']
#                if exam == 0 or examno == exam:
#                    if examno != examm1:
##                       This is a new exam.
#                        exams.append(examno)
#                    exam_info.append((examno, seriespath, slices[0]))
#            examm1 = examno
##        if examno != exam:
##            break
#    return(exams, exam_info)

def ispfile(fname):

    """
    Return true if <fname> is a GE pfile.
    """
    f = open_gzbz2(fname, 'rb')
    f.seek(34)
    test = f.read(10)
    if 'GE_MED_NMR' in struct.unpack('10s', test):
        f.seek(0)
        testdata = f.read(4)
        rev = struct.unpack('f', testdata)[0]
        if abs(rev) < 1. or abs(rev) > 30:
            #rev =  ("%4.1f" % struct.unpack('>f', testdata)[0]).strip()
            rev =  struct.unpack('>f', testdata)[0]
        if abs(rev) > 1. or abs(rev) < 30:
#           This is a valid revision number
            f.close()
            return True
        else:
            f.close()
            return False


class Wimage(Header):
    """
    Image object with the header as an attribute and method to read the image. 
    """
            
    def __init__(self, filename=None, scan=False, force_scan=False, \
                native_header=None, ignore_yaml=False):
        """
       filename: Image file name.
       scan: Only has meaning for the dicom format. If true and no yaml file is
             found, every file in the directory is examined.
       force_scan*: Read raw data even if yaml file is present.
       ignore_yaml*: Don't read ehe yaml file.
       * Only applies to dicom files.
        """
        
        if filename is None and native_header is None:
            self.hdr = None
            return None
#        self.timer = Timer()
        try:
            if force_scan:
                ignore_yaml = True
                scan = True
            Header.__init__(self, filename, scan=scan, \
                        native_header=native_header, ignore_yaml=ignore_yaml)
        except IOError, errstr:
            sys.stderr.write('%s\n%s\n' % (errstr, except_msg()))
            self.hdr = None
            return
#        sys.stdout.write( ' 1b ' + self.timer.ReadTimer() + '\n')
        if self.hdr is None:
            return None
        self.scan = scan
        self.filename = filename
        if filename:
            if filename.endswith('gz'):
                self.gzip = True
            else:
                self.gzip = False
        else:
            self.gzip = False
#        self.hdr = self.get_header(scan=scan)
        self.xdim = self.hdr['xdim']
        self.ydim = self.hdr['ydim']
        self.zdim = self.hdr['zdim']
        self.tdim = self.hdr['tdim']
        self.mdim = self.hdr['mdim']

#    def readheader(self, filename, scan=False):
#        """ 
#        Arguments:
#             scan: True: for dicom each file in directories will be 
#                interrogated to determine all header parameters.
#        Returns:
#            header: dictionary containing header information.
#        """
#        if filename is not None:
#            if not os.access(filename,F_OK):
#                sys.stderr.write( \
#                'Wimage: Could not open %s\n' % filename)
#                self.hdr = None
#                return None
#            self.filename = filename
#            self.hd = Header(self.filename, scan=scan)
#        self.hdr = self.hd.get_header()
#        return(self.hdr)

    def _read_dicom(self, frame=None, mtype=None, filename=None, dtype=float):
#       Read Dicom images.
        self.image = self.dcm.get_series(frame=frame, mtype=mtype, dtype=dtype)

    def _read_ifile(self, frame=None, mtype=None, filename=None, dtype=float):
#           Read separately if GE I-file format. mtype is not used.
            self.image = read_ge_Ifile(self.filename, self.hdr)

    def _read_tes(self,frame):
#       Voxbo stores a mask for nonzero voxels and only stores nonzero voxels.
#       Offset for size of mask.
        self.f.seek(self.hdr['start_binary'])
        nvox =  self.xdim*self.ydim*self.zdim
        mask = fromstring(self.f.read(nvox), 'byte').astype(short)
        self.start = int(self.hdr['start_binary'] + lgth)
        lgth_data = self.hdr['num_voxels']* \
                        datatype_to_lgth[self.hdr['datatype']]/8

#       Voxbo tes files need special processing.
        idx = mask.nonzero()[0]
        xyzdim = self.zdim*self.ydim*self.xdim
        shp = [self.tdim, self.zdim, self.ydim, self.xdim]
        jmg = zeros([self.tdim, xyzdim], short)
        try:
            if self.hdr['swap']:
                img = (fromstring(self.f.read(lgth_data), \
                    datatype_to_dtype[self.hdr['datatype']])).byteswap()
            else:
                img = fromstring(self.f.read(lgth_data), self.hdr['datatype'])
        except IOError:
            sys.stderr.write('%s\n' % errstr)
            sys.stderr.write('\nreadfile: Could not read from %s\n%s\n' % (imgfile, except_msg()))
            return None
        img = reshape(img, [xyzdim, self.tdim])
        for t in range(self.tdim):
            jmg[t, :].put(idx, img[:, t])
        return reshape(jmg, shp)

    def _open_for_read(self):

#       Save compression suffix. 
        if self.filename.endswith('.gz'):
            filename = self.filename[:-3]
            compression = '.gz'
        elif self.filename.endswith('.bz2'):
            filename = self.filename[:-4]
            compression = '.bz2'
        else:
            filename = self.filename
            compression = ''

#       Add correct extension.
        if extlist[self.hdr['filetype']] is None:
            imgfile = filename
        elif self.filename.endswith('.nii.gz'):
            imgfile = filename
        else:
            base = filename.replace('.nii','')
            base = base.replace('.img','')
            base = base.replace('.hdr','')
            base = base.replace('.BRIK','')
            base = base.replace('.HEAD','')
            imgfile = "%s%s" % (base, extlist[self.hdr['filetype']])
        imgfile += compression

#       Find position and length in file.
        self.hdr['imgfile'] = imgfile
        self.f = open_gzbz2(imgfile, 'rb') 

    def _get_frame(self, frame, mtypes, nvox, lgth):
        self.f.seek(self.start)
        datatype =  datatype_to_dtype[self.hdr['datatype']]
        mdim = len(mtypes)
        img = empty((mdim, nvox), datatype)
        for m in xrange(mdim):
            self.f.seek(self.start + m*self.tdim*lgth, 0)
            if datatype == complex64:
                jmg = fromstring(self.f.read(lgth), int32)
                img[m,...] = fromstring(jmg.astype(float).tostring(), complex).\
                             reshape(nvox)
            else:
                img[m,:] = fromstring(self.f.read(lgth), datatype)
        if self.hdr['swap']:
            img = img.byteswap()
        return img

    def _read_image(self, frame=None, mtype=None):

        if self.hdr['filetype'] != 'tes' and frame is None:
            self.start = int(self.hdr['start_binary'])
            read_lgth = self.hdr['num_voxels']*datatype_to_lgthbits[ \
                                        self.hdr['datatype']]/8
            shp = (self.mdim, self.tdim, self.zdim, self.ydim,self.xdim)
            nvox = self.tdim*self.zdim*self.ydim*self.xdim
            mtypes = range(self.mdim)
        else:
#           Reading frame by frame.
#            self.start = long(self.hdr['start_binary'] + frame*self.xdim* \
#              self.ydim*self.zdim*datatype_to_lgthbits[self.hdr['datatype']]/8)
            shp = (self.zdim, self.ydim, self.xdim)
            nvox = self.zdim*self.ydim*self.xdim
            read_lgth = self.xdim*self.ydim*self.zdim* \
                                datatype_to_lgthbits[self.hdr['datatype']]/8
            mtypes = [mtype]
            if mtype is None:
                mdim = self.mdim
                self.start = long(self.hdr['start_binary'] + frame*read_lgth)
            else:
                mdim = 1
                self.start = long(self.hdr['start_binary'] + \
                                        mtype*(self.tdim + frame)*read_lgth)
#       Read Image.
        try:
            img = self._get_frame(frame, mtypes, nvox, read_lgth)
        except IOError:
            sys.stderr.write('\nreadfile: Could not read from %s\n%s\n' % \
                                            (self.filename, except_msg()))
            return None
        self.f.close()
        return img.reshape(shp)

    def _set_image_scale(self,img,dtype):

        self.scl = self.hdr['scale_factor']
        self.offset = self.hdr['scale_offset']
        return

    def _scale_images(self, img, dtype):

#       Use scale factor in header and/or scale factors ot avoid truncation
#       and overflow.
        if dtype == 'short' or dtype == 'byte':
            self.image = img
        elif self.hdr['filetype'] == 'brik':
            brick_float_facs = self.hdr['native_header']['brick_float_facs']
            if self.tdim > 1:
                if img.dtype != dtype:
                    self.image = zeros(img.shape, dtype)
#                            [self.tdim, self.zdim, self.ydim, self.xdim], dtype)
                else:
                    self.image = img
                for t in range(self.tdim):
                    if brick_float_facs[t] > 0.:
                        self.image[t, :, :, :] =  \
                          (brick_float_facs[t]*img[t, :, :, :]).astype(dtype)
                    else:
                        self.image = img.astype(dtype)
            elif brick_float_facs > 0.:
                self.image = brick_float_facs*img
            else:
                self.image = img.astype(dtype)
        elif  self.scl != 1. or self.offset != 0.:
            if img.ndim == 4:
                shp = [self.mdim, self.tdim, self.zdim, self.ydim, self.xdim]
                self.image = zeros(shp, dtype)
                self.image[...] = (self.scl*img.reshape(shp) + \
                                            self.offset).squeeze().astype(dtype)
            else:
                self.image = (self.scl*img + self.offset).astype(dtype)
        elif dtype == img.dtype:
            self.image = img
        else:
            self.image = img.astype(dtype)
 
    def readpfile(self, frame=None, channel=None):
        ptsize = self.hdr['native_header']['PointSize']
        start = self.hdr['start_binary']
        lgth = self.xdim*self.ydim*self.zdim*ptsize*2
        if frame == None:
            frames = range(self.mdim)
        elif isinstance(frame, list):
            frames = frame
        else:
            frames = [frame]

        if channel == None:
            channels = range(self.tdim)
        elif isinstance(channel, list):
            channels = channel
        else:
            channels = [channel]

#       Open input file.
        self._open_for_read()

        shp3d = [self.zdim, self.ydim, self.xdim]
        image = empty([len(frames), len(channels)] + shp3d, complex64) 
        ifrm = 0
        ich = 0
        for frm in frames:
            for ch in channels:
                self.f.seek(start + (frame*self.tdim + ch)*lgth, 0)
                if ptsize == 4:
                    rawimg = fromstring(self.f.read(lgth), int32)
                else:
                    rawimg = fromstring(self.f.read(lgth), int16)
                image[ifrm, ich,...] = fromstring(rawimg.astype(float32).\
                                        tostring(), complex64).reshape(shp3d)
                ich += 1
            ifrm += 1
        return image.squeeze()
        

    def readfile(self, frame=None, mtype=None, filename=None, dtype=None, \
                                                          hdr=None):
        """
        Read one or more frames or types (the fifth image dimension) from disk.
        frame: If specified, only a single frame will be read.
        mtype: If specified only a single image type (i.e., magnitude, phase etc.) will be read.
        dtype: Specifies the data type to be returned. It can be any valid ndarray dtype, i.e., float, float32, short, double etc.  Images will be rescaled to prevent overflows and excessive
           truncation errors.
        hdr: Previously read header.  This will eliminate the overhead incurred by re-reading the header.
        """
        if self.hdr is None:
            return None

        if self.hdr['filetype'] is 'ge_data':
            img = self.readpfile(frame)
            return img

        if dtype is None:
            dtype = datatype_to_dtype[self.hdr['datatype']]

        funcs = {'dicom':self._read_dicom,'ge_ifile':self._read_ifile}
#       dicom and GE image files have standalone functions.
        if funcs.has_key(self.hdr['filetype']):
            apply(funcs[self.hdr['filetype']],(frame,mtype,filename,dtype))
            return self.image

        self._open_for_read()

        if self.hdr['filetype'] == 'tes':
#           Get the tes mask.
            img = self._read_tes(frame)
        else:
#           Read the image.
            img = self._read_image(frame, mtype)
            if img is None:
                return None

#       Fix the shape
#        if self.mdim > 1 and frame < 0:
#            shp = [self.mdim, self.tdim, self.zdim, self.ydim, self.xdim]
#        elif self.tdim > 1 and frame < 0 or self.hdr['filetype'] == 'tes':
#            shp = [self.tdim, self.zdim, self.ydim, self.xdim]
#        else:
#            shp = [self.zdim, self.ydim, self.xdim]
        if self.mdim > 1 and mtype is None:
            shp = [self.mdim]
        else:
            shp = []
        if self.tdim > 1 and frame < 0:
            shp += [self.tdim]
        if self.zdim > 1:
            shp += [self.zdim]
        shp += [self.ydim, self.xdim]


        if dtype == 'integer':
            dtyp = datatype_to_dtype[dtype]
        else:
            dtyp = dtype

#       Scale if truncation error is excessive.
        self._set_image_scale(img,dtyp)

        self._scale_images(img,dtyp)

        self.image = reshape(self.image, shp)

        return self.image

def abspath_to_relpath(tgtpath, srcpath):
    """
    Convert absolute paths to relative paths.
    <tgtpath>: The path to be converted.
    <srcpath>: The origin path.
    Written by Dave Perlman.
    """
    
    # make sure the paths are clean
    tgtpath=os.path.realpath(tgtpath)
    srcpath=os.path.realpath(srcpath)
   
    # get them as lists
    pathlist=[]
    while os.path.split(tgtpath)[1]:
        tgtpath,thetail = os.path.split(tgtpath)
        pathlist.append(thetail)
   
    reflist=[]
    while os.path.split(srcpath)[1]:
        srcpath,thetail = os.path.split(srcpath)
        reflist.append(thetail)
   
    # remove the matching base path
    try:
        while pathlist[-1] == reflist[-1]:
            pathlist.pop()
            reflist.pop()
    except:
        pass
   
    # create the relative path
    pathlist = pathlist + ['..'] * len(reflist)
    pathlist.reverse()
    if len(pathlist) == 0:
        outpath = '.'
    else:
        outpath=os.path.join(*pathlist)
    return outpath

def convert_R_to_lpi(R, dims, sizes):
    """
    Convert R such that transforms to LPI coordinates than to RAI. Might be useful with FSL.
    """
    Rlpi = dot(array(diag([-1., -1., 1., 1.])), R)

 #   dirs = dot(R[:3,:3], ones(3))
 #   lpi = array([-1., -1., 1.])
 #   lpi_mask = array([1., 1., 0.])
 #   flip = lpi_mask*(1. - dirs*lpi)/2.
 #   fov_flip = dot(array(diag(flip)), (dims[:3] - 1.)*sizes[:3])
 #   Rlpi = dot(diag(-2*flip+1), R[:3,:3])
 #   xyz0 = dirs*lpi_mask*dot(abs(R[:3,:3]), fov_flip) + R[:3,3]

 #   Rlpi = zeros([4,4], float)
 #   Rlpi[:3,:3] = Rlpi
 #   Rlpi[:3, 3] = xyz0
 #   Rlpi[ 3, 3] = 1.
#    print 'Rrai:'
#    print R
#    print 'Rlpi:'
#    print Rlpi
    return Rlpi

class BiopacData():
    """
    Object for reading and displayin Biopac header information.
    """

    def __init__(self, fname):
        """
        Read the Biopac data.
        """
        import bioread
        if fname.endswith('.gz'):
            import gzip
            f = gzip.GzipFile(fname, 'r')
            tmp = GetTmpSpace(500)
            tmpfile = '%s/tmp_biopac' % tmp.tmpdir
            fout = open(tmpfile, 'w')
            fout.write(f.read())
            f.close()
            fout.close()
            bd = bioread.read_file(tmpfile)
            tmp.Clean()
        else:
            bd = bioread.read_file(fname)
        self.channels = bd.channels
        self.nchan =    len(bd.channels)

        self.chan_names = []
        self.stepsizes = []
        self.units = []
        self.channel_data = []
        self.sample_rate = []
        self.npts = []
        for ch in xrange(self.nchan):
            self.chan_names.append(self.channels[ch].name)
            self.stepsizes.append(self.channels[ch].sample_size)
            self.units.append(self.channels[ch].units)
            self.channel_data.append(self.channels[ch].data)
            self.npts.append(self.channels[ch].data.shape[0])
            self.sample_rate.append(self.channels[ch].samples_per_second)

        self.mhdr = bd.graph_header
        self.duration = self.mhdr.sample_time

    def DumpSummary(self, fd=sys.stdout):
        """
        Dump a summary to the file object specified by fd.
        """
        print 'Number of channels: %d' % self.nchan

        keys = ['Channel', 'Description', 'Units', 'Rate (Hz)', 'N']
        data = {'Channel':(range(self.nchan), '%d')}
        data['Description'] = (self.chan_names, '%s')
        data['Units'] = (self.units, '%s')
        data['Rate (Hz)'] = (self.sample_rate, '%d')
        data['N'] = (self.npts, '%d')
        N = 4
#        data[4] = self.chan_names
#        data[5] = self.chan_names
        columns = []
        for key in keys:
            columns.append(self.FormatColumn(data[key], key))

        text = ''
        for ch in xrange(self.nchan):
            for col in columns:
                text += col[ch]
            text += '\n'
        print text

        if fd is not None:
            fd.write(text)
        return text

    def FormatColumn(self, data, heading):
        column = [heading]
        for entry in data[0]:
            column.append(data[1] % entry)
        maxwidth = 0
        for row in column:
            if len(row) > maxwidth:
                maxwidth = len(row)
        output = []
        for row in column:
            output.append(row + ' '*(maxwidth+2 - len(row)))

        return output
