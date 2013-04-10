#!/usr/bin/env python

ID = "$Id: dump_header.py 578 2011-06-27 21:44:44Z jmo $"[1:-1]

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


import curses
from curses import A_BOLD,A_UNDERLINE
import os
from file_io import Header, file_type, BiopacData
import sys
from types import *
import yaml
import numpy
from numpy import zeros, allclose
from optparse import OptionParser
from types import TupleType,DictType,StringType
from datetime import datetime
from wbl_util import except_msg

def cvt_time(hdr, key):
    if hdr.has_key(key) and  isinstance(hdr[key], int):
        hdr[key] = datetime.fromtimestamp(float(hdr[key])).strftime('%d%b%Y_%X')


#*******************************************************
def print_matrix(A,title="",print_str=True, fmt='%7.4f'):
#*******************************************************

    if len(title) > 0:
        first_str = "%s |" % title
        bar = "|"
    else:
        first_str = " |"
        bar = "|"
    pad = (len(first_str) - len(bar)-1)*" "
    shp = A.shape
    if shp == (4,4) or shp == (3,3): # Might be a rotation matrix. Set output format.
        if allclose(abs(sum(A[:3,:3],0)),1.):
#           Looks like a rotation matrix with cardinal angles., 
            low_precision = 1
        else:
            low_precision = 0
    else:
        low_precision = 0
    outstr = ""
    if len(shp) == 2:
        ydim,xdim = shp
        for y in range(ydim):
            if y > 0:
                outstr = "%s%s %s" % (outstr,pad,bar)
            else:
                outstr = first_str
            if low_precision:
                str = "%3.0f" % A[y,0]
                str = (3-len(str))*" " + str
            else:
                str = fmt % A[y,0]
                str = (8-len(str))*" " + str
            outstr = outstr + str
            for x in range(xdim-2):
                if low_precision:
                    str = "%3.0f" % A[y,x+1]
                    str = (3-len(str))*" " + str
                else:
                    str = fmt % A[y,x+1]
                    str = (8-len(str))*" " + str
                outstr = outstr + str
            else:
                str = ""
            str = fmt % A[y,xdim-1]
            str = (10-len(str))*" " + str
            outstr = outstr + "%s %s\n" % (str,bar)
    elif len(shp) == 1:
        xdim = shp[0]
        outstr = '%s: ' % title
        for x in range(xdim):
            outstr = outstr + "  " + fmt % A[x]
        outstr = outstr + "\n"
    else:
        outstr = array2string(A)

    if print_str:
        sys.stdout.write(outstr)
    return outstr


COLWIDTH = 40

def convert_integer(value):
    return "%d" % value
def convert_float(value):
    return ("%f" % value).rstrip('0')
def convert_complex(value):
    return ("(%0f+%0fj)" % (value.real,value.imag)).rstrip('0')
def convert_nop(value):
    return value
def convert_string(value):
    return value.strip()[:]
def convert_array(value):
    return print_matrix(value,'',False)
def convert_dict(value):
    return 'Dictionary type not converted'
def convert_seq(value):
    outstr = "["
    for val in value:
        outstr = '%s %s' % (outstr,apply(cvt[type(val)],[val]))
    if len(outstr) > COLWIDTH:
        outstr = outstr[:COLWIDTH-3] + "...]"
    else:
        outstr = outstr[:COLWIDTH] + "]"
    return outstr
def convert_seq2(value):
    return 'tuple'


cvt = {IntType:convert_integer,FloatType:convert_float,NoneType:convert_nop,StringType:convert_string,numpy.ndarray:convert_array,DictType:convert_dict,ListType:convert_seq,TupleType:convert_seq,LongType:convert_integer,numpy.float32:convert_float,numpy.float64:convert_float,numpy.int32:convert_integer,numpy.int16:convert_integer}

keygroups = [ \
        ['ndim','xdim','ydim','zdim','tdim','mdim'], \
        ['xsize','ysize','zsize', 'tsize', 'TR','msize'], \
        ['x0','y0','z0','R'], \
        ['datatype','bitpix','scale_factor','scale_offset'], \
        ['orientation','plane','filetype','imgfile'], \
        ['swap','start_binary','num_voxels','dims','sizes']]

#shdr_grps = [ \
#        ['ProtocolName','StudyDescription','SeriesDescription', \
#         'StudyDate','ExamNumber'], \
#        ['SeriesDateTime', 'PatientId','PatientName','PatientSex', \
#         'PatientWeight', 'PatientAge', 'PatientBirthDate'], \
#        ['AcqTime','SeriesNumber','SeriesTime','EchoTime','RepetitionTime'], \
#        ['InversionTime','FlipAngle','PulseSequenceName'], \
#        ['EffEchoSpacing'],['ImageType', 'InstitutionName', 'PlaneType', \
#         'CoilName'], \
#        ['StatType', 'DegFreedom']]
#n_shdr_grps = len(shdr_grps)

class ScreenCtl:

    def __init__(self,hdr, stdscr):
        self.hdr = hdr

        self.stdscr = stdscr
#       Determine maximum line length.
        keys = self.hdr.keys()
        self.max_linelen = 0
        for key in keys:
            lines = (self.getvalue(key, self.hdr[key]))
            for line in lines:
                lgth = len(key) + len(line) + 3
                if lgth > self.max_linelen:
                    self.max_linelen = lgth
        if self.max_linelen > 60:
            self.max_linelen = 60
        if curses.has_colors():
            curses.init_pair(3,curses.COLOR_YELLOW,curses.COLOR_BLACK)
            curses.init_pair(4,curses.COLOR_BLACK,curses.COLOR_BLACK)
            self.yellow = curses.color_pair(3)
            self.black = curses.color_pair(4)
        else:
            self.yellow = curses.A_UNDERLINE
            self.black = curses.A_NORMAL
        if os.isatty(1):
            self.screen_ctl = True
        else:
            self.screen_ctl = False
        if self.screen_ctl:
            self.xmax,self.ymax = self.stdscr.getmaxyx()
        else:
            self.xmax = 80
            self.ymax = 30
        self.re_init()

    def re_init(self):

        self.xmax,self.ymax = self.stdscr.getmaxyx()
        if self.screen_ctl:
            if curses.has_colors():
                curses.init_pair(3,curses.COLOR_YELLOW,curses.COLOR_BLACK)
                curses.init_pair(4,curses.COLOR_BLACK,curses.COLOR_BLACK)
                self.yellow = curses.color_pair(3)
                self.black = curses.color_pair(4)
            else:
                self.yellow = curses.A_UNDERLINE
                self.black = curses.A_NORMAL
        else:
            self.yellow = 0
            self.black = 0
#       Must re-initialize if screen has been reshaped.
        if self.screen_ctl:
            self.ymax,self.xmax = self.stdscr.getmaxyx()
        else:
#           Output redirected, create sequence of blank strings to write on.
            self.xmax = 80
            self.ymax = 30
            self.vscreen = []
            for i in range(self.ymax):
                self.vscreen.append(self.xmax*" ")

        self.ncol = self.xmax/self.max_linelen
        if  self.ncol < 1:
            self.ncol = 1
        self.colwidth = self.xmax/self.ncol
        self.rowidx = zeros(self.ncol+1,numpy.integer)
        self.offset = zeros(self.ncol+1,numpy.integer)
        for y in range(self.ymax):
#            Reinitialize background.
            x = (self.xmax-1)*' '
            self.addstring(y,0,x,self.black)

    def getvalue(self, key, value):
#       Retrieve value of key, convert it and break into lines.
        if value is False:
            valstr = 'False'
        elif value is True:
            valstr = 'True'
        else:
            valstr = apply(cvt[type(value)],[value])
        if valstr is None:
            valstr = 'None'
        if len(valstr.strip()) == 0:
            valstr = ''

#       Split values that are more than one line long into a list of lines.
        tmp = valstr.strip().split('\n')
        lines = []
        for line in tmp:
            if len(line.strip()) > 0:
                lines.append(line.strip())
        if len(lines) == 0:
            lines = ['']
        return lines

    def write(self,key,value,col,row):

        lines = self.getvalue(key, value)
        if len(lines) > 1:
            off = 1
        else:
            off = 0

        tag = key.strip()
        for line in lines:
#           Process each line in this key.
            words = line.split()
            if  len(line)+len(key) > self.colwidth:
#               Handle overly long lines
                line = line[:(self.colwidth - len(tag) - 6)] + "..."
                
            if row+self.offset[col] > self.ymax-2:
                return 1 # Sceen full, flag caller to pause
            nextcol = (col + 1) % self.ncol
            for skip in self.skiplist:
#               Last column extends into this one, use next column.
                if skip[0] == row+self.offset[col] and skip[1] == col:
                    col = nextcol
                    if nextcol == 0:
                        self.offset[0] = self.offset[0] + 1
            if col >= self.ncol:
                col = self.ncol - 1
            if (len(line) + len(key) + 2) > self.colwidth :
#               Line extends into the next column, flag it to be skipped.
                self.skiplist.append((row+self.offset[col],nextcol))
                line = line.strip() + (2*self.colwidth-len(line.strip())-len(key)-2)*" "
            else:
#               Pad line to erase previous contents.
                line = line.strip() + (self.colwidth-len(line.strip())-len(key)-2)*" "
#           Write line to screen
            self.writeval(tag,line,col,row+self.offset[col])
            self.offset[col] = self.offset[col] + off
            tag = (len(key)+2)*" "
        return 0

    def writeval(self,key,valstr,col,row):
#       Write tag and value strings to the crt or file.
        x0 = col*self.colwidth
        if len(key.strip()) > 0:
            tag = "%s: " % key
        else:
            tag = key
        self.addstring(row,x0,tag,self.yellow)
        valstr = valstr.strip()
        if len(tag)+len(valstr) > self.colwidth-1:
            valstr = valstr[:(self.colwidth-len(tag)-1)]
        self.addstring(row,x0+len(tag),valstr,self.yellow)
#        self.addstring(row,x0+len(tag),'%s'%valstr,self.yellow)

    def wait(self,label):
#       Wait for next character from keyboard.
        if not self.screen_ctl:
            for line in self.vscreen:
                print line
                line = self.xmax*" "
            return " "
        y0 = int(self.ymax -1)
        self.addstring(y0,0,label,curses.A_STANDOUT)
        try:
            c = self.getkey()
        except IOError:
            c = ""
        return c

    def heading(self,label,y0):
#       Write a title for a subsection.
        self.addstring(y0,0,label,A_BOLD|A_UNDERLINE)

    def addstring(self,y,x,valstr,color):
#       Handle writes to screen separately for redirected output.
        valstr = valstr.strip().lstrip()
        valstr.replace('+','#')
        if len(valstr) == 0:
            return 0
        if self.screen_ctl:
#            if len(valstr) < 2 and not valstr.isalnum():
#                valstr = "x"
            y = int(y)
            try:
                self.stdscr.addstr(int(y),int(x),valstr, color)
            except:
                pass
#                f = open('tmp1.txt','a+')
#                f.write("%s %s %s %s\n"%(type(y),type(x),type(valstr),type(color)))
#                f.write("%d %d __%s__ %d\n"%(y,x,valstr,len(valstr)))
#                f.flush()
#                f.close()
        else:
            self.vscreen[row] = self.vscreen[row][:col] + valstr + \
                self.vscreen[row][col+len(valstr):]
        return 0

    def getkey(self):
#       Handle  reads from screen separately for redirected output.
        if self.screen_ctl:
            try:
                c = self.stdscr.getkey()
            except:
                c = " "
            return c
        else:
            return " "
    

class NextKey(ScreenCtl):
    """
    NextKey: Iterator that returns next key and its column and row.

    """
    def __init__(self, hdr, stdscr):
        ScreenCtl.__init__(self, hdr, stdscr)
        self.stdscr = stdscr
        if os.isatty(1):
            self.screen_ctl = True
            self.xmax = 80
            self.ymax = 30
        else:
            self.screen_ctl = False
        self.re_init()
        self.hdr = hdr
        self.shdr = hdr.get('subhdr', None)
        shdr_grps = self.shdr.keys()
        shdr_grps.sort()
        self.shdr_grps = [shdr_grps]
        self.n_shdr_grps = 1
        self.nhdr = hdr['native_header']
        self.nkeys = hdr['native_header'].keys()
        self.nkeys.sort()
        self.idx = 0
        self.group = 0
        self.ngroups = len(keygroups)
        self.col = 0
        self.row = 0
        self.nhdrs = 3
        self.hdrnum = 0
        self.skiplist = []
#        self.shdr_grps = shdr_grps
#        self.shdr_grps = []
#        for group in shdr_grps:
#            newgroup = []
#            for key in group:
#                if self.shdr.has_key(key):
#                    newgroup.append(key)
#            self.shdr_grps.append(newgroup)
        self.heading('Main Header',self.rowidx[0])
        self.rowidx[0] = self.rowidx[0] + 1

    def __iter__(self):
        return self

    def next(self):
        if self.hdrnum == 0 and self.group < self.ngroups:
#           Still writing main header in column order.
            rtn = self.next_key(keygroups)
        elif self.hdrnum== 0 and self.group == self.ngroups:
#           Initialize for the subheader.
            self.hdrnum = 1
            self.group = 0
            self.idx = 0
            self.rowidx[:] = (self.rowidx + self.offset).max() + 1
            self.offset[:] = 0
            self.col = 1
            self.heading('Sub-Header',self.rowidx[0])
            self.rowidx[0] = self.rowidx[0] + 1
            rtn = (self,'',0,self.col,self.rowidx[0])
        elif self.hdrnum == 1 and self.group < self.n_shdr_grps:
#           Write the subheader in column order.
            rtn = self.next_key(self.shdr_grps)
        elif self.hdrnum== 1 and self.group == self.n_shdr_grps:
#           Setup to write the native header.
            self.row = (self.rowidx + self.offset).max() + 1
            self.offset[:] = 0
            self.col = 1
            self.group = 0
            self.hdrnum = 2
            self.idx = 0
            self.heading('Native-Header',self.row)
            rtn = (self,'',0,0,self.row)
        elif self.hdrnum == 2 and  self.idx < len(self.nkeys):
#           Write the native header in row order.
            rtn = self.next_nkey(self.nkeys)
        else:
             raise StopIteration
        return rtn


    def next_key(self,keygrp):
        if self.idx < len(keygrp[self.group]):
            key = keygrp[self.group][self.idx]
            self.row = self.rowidx[self.col]
            self.idx = self.idx + 1
            self.col = (self.col + 1) % self.ncol
            rtn = self,key,self.idx,self.col,self.rowidx[self.col]
            self.rowidx[self.col] = self.rowidx[self.col] + 1
        else:
            self.idx = 0
            self.group += 1
            self.col = (self.col + 1) % self.ncol
            rtn = self,'',self.idx,self.col,self.rowidx[self.col]
        return rtn

    def next_nkey(self,nhdr_keys):
        if self.idx < len(nhdr_keys)-5:
            self.col = self.col + 1
            if self.col > self.ncol-1:
                self.col = 0
                self.row = self.row + 1
            self.idx = self.idx + 1
            return (self,nhdr_keys[self.idx-1],self.idx,self.col,self.row)
        else:
            return (self, None, None, None, None)


#********************************
def curses_func(stdscr, file, h):
#********************************

 #   stdscr = curses.initscr()
 #   if curses.has_colors():
 #       curses.start_color()
    hdr = h.hdr
    if hdr is None:
        sys.stderr.write("\ncurses_func: Could not read header from %s\n\n"%file)
#        sys.exit(1)
        return
    y = NextKey(hdr, stdscr)
#    f = open('tmp.txt','w')
    while True:
        for nxt,key,k,col,row in NextKey(hdr, stdscr):
            if key is None:
                break
            elif len(key) == 0:
                continue
            if hdr.has_key(key):
                value = hdr[key]
            elif hdr['subhdr'].has_key(key):
                value = hdr['subhdr'][key]
            elif hdr['native_header'].has_key(key):
                value = hdr['native_header'][key]
            elif key == 'ExamNumber':
                value = hdr.get('StudyID', 'not found')
            else:
                value = 'not found'
            if value is None:
                value = 'N/A'
                continue
            if isinstance(value, str):
                value = value.strip()
#            f.write("%s %s %d %d %d\n"%(key,value,k,col,row))
#            f.flush()
            if nxt.write(key,value,col,row):
#               Pause and wait for a carriage return.
                c = nxt.wait('Enter "q" to quit, <CR> to continue') 
                if  c == 'q': 
                    curses.endwin()
#                    sys.exit()
                    return
                else:
#                   Draw the next screen.
                    if nxt.screen_ctl:
                        stdscr.erase()
                    nxt.col = 0
                    nxt.row = 0
                    nxt.rowidx[:] = 0
                    nxt.offset[:] = 0
                    nxt.skiplist = []
        c = nxt.wait('Enter "q" to quit, <CR> to start over')
        if  not nxt.screen_ctl:
            curses.endwin()
#            sys.exit()
            return
        elif  c == 'q':
            curses.endwin()
#            f.close()
#            sys.exit()
            return
        else:
            stdscr.erase()
            stdscr.refresh()



# **** MAIN ****

def dump_header_main():
    
    u1 =  "Purpose: Dump header to the screen"
    u2 =  "Usage: dump_header [-hs]  filename\n"

    usage = u1 + u2
    optparser = OptionParser(usage)
    optparser.add_option( "", "--write-yaml", action="store", \
            dest="write_yaml", default=None, type=str, \
            help='File where yaml version should be stored. ' + \
                 'Nothing will be written to the screen.')
    optparser.add_option( "-s", "--scan", action="store_true", \
                      dest="scan",default=False, help='Scan all files. This ' + \
                    'is necessary to correctly determine the origin in the ' + \
                    'slice direction for DICOM images.')
    optparser.add_option( "-v", "--verbose", action="store_true",  \
            dest="verbose",default=None, help="Verbose mode.")
    optparser.add_option( "", "--dump-dicom", action="store_true",  \
            dest="dump_dicom",default=None, \
            help="Dump all dicom info to the screen.")
    optparser.add_option( "", "--slot", action="store", type=int,  \
            dest="slot",default=0, \
            help="Slot number (applies to GE's HEADER_POOL file only.")
    optparser.add_option( "-x", "--xml", action="store_true",  \
            dest="dump_xml",default=None, help="Dump header to xml. (dicom only)")
    optparser.add_option( "-y", "--ignore_yaml", action="store_true",  \
            dest="ignore_yaml",default=None, help="Ignore yaml file and re-read original data.")
    opts, args = optparser.parse_args()

    if len(args) != 1:
        optparser.error( "Usage: dump_header filename.")
        sys.exit(1)

    fname  = args[0]

    if opts.dump_xml:
        cmd = "dcm2xml %s" % fname
        os.system(cmd)
        sys.exit()

    elif opts.dump_dicom:
        import dicom
        dataset = dicom.read_file(fname)
        keys = dataset.keys()
        keys.sort()
        for tag in keys:
            item = dataset[tag]
            VR = item.VR
            VM = item.VM
            descr = item.description()
            if descr.startswith('['):
                descr = descr[1:]
            if descr.endswith(']'):
                descr = descr[:-1]
            if VR in ('OW', 'OB'):
                value = 'Binary data'
            else:
                value = item.value
            print tag, VR, VM, '"%s"' % descr, value
        sys.exit()
            


    filetype = file_type(fname)
    if filetype == 'biopac':
#       Biopac data.
        bd = BiopacData(fname)
        bd.DumpSummary()
        sys.exit()

    try:
        h = Header(fname, scan=opts.scan, ignore_yaml=opts.ignore_yaml, slot=opts.slot)
    except (RuntimeError, IOError), err:
        sys.stderr.write('\n%s\n%s\n' % (err, except_msg()))
        sys.exit(1)
    hdr = h.hdr
    if hdr is None:
        print "\n\nCould not read header from %s" % fname
        sys.exit()

    shdr = hdr['subhdr']
    nhdr = hdr['native_header']
    cvt_time(shdr, 'SeriesTime')
    cvt_time(shdr, 'SeriesDateTime')
    cvt_time(shdr, 'AcqTime')
    cvt_time(nhdr, 'ActualSeriesDateTime')
    cvt_time(nhdr, 'ImageActualDate')

    if not os.isatty(1):
#       Output device is not a crt, dump as text.
        keys = hdr.keys()
        keys.sort()
        for key in keys:
            if key is not 'subhdr' and key is not 'native_header':
                sys.stdout.write('%s\t%s\n' % (key, hdr[key]))
        shdr = hdr['subhdr']
        keys = shdr.keys()
        keys.sort()
        for key in keys:
            sys.stdout.write('%s\t%s\n' % (key, shdr[key]))
        nhdr = hdr['native_header']
        keys = nhdr.keys()
        keys.sort()
        for key in keys:
            sys.stdout.write('%s\t%s\n' % (key, nhdr[key]))


    if os.isatty(1) and not opts.write_yaml:
#      Output is a tty, format the display.
        stdscr = curses.initscr()
        if curses.has_colors():
            curses.start_color()

#       Wrap curses functions to ensure that screen is left the way it was found.
#        curses.wrapper(curses_func, fname, h)
        curses_func(stdscr, fname, h)
        sys.exit()
    else:
#       Output is a file, send yaml.
        h.write_hdr_to_yaml('%s' % (opts.write_yaml))

if __name__ == '__main__':
    dump_header_main()
