#!/bin/bash
set -e
ROOT=/Applications/Canopy.app
cd $ROOT/appdata/canopy-1.0.0.1160.macosx-x86_64/Canopy.app/Contents/lib/python2.7/lib-dynload
install_name_tool -change \
    /Library/Frameworks/Python.framework/Versions/111.222.33344/lib/libtcl8.5.dylib \
    /System/Library/Frameworks/Tcl.framework/Versions/8.5/Tcl _tkinter.so
install_name_tool -change \
    /Library/Frameworks/Python.framework/Versions/111.222.33344/lib/libtk8.5.dylib \
    /System/Library/Frameworks/Tk.framework/Versions/8.5/Tk  _tkinter.so