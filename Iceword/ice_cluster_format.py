"""
==============================================================================
Program: ice_cluster_format.py
 Author: Kyle Reese Almryde
         Cj Vance
   Date: today

 Description: The purpose of this program is to demonstrate Python's powerful
              text processing abilities as well as its ability to bootstrap
              the system shell in order to act like

==============================================================================
"""
import os
import glob
from subprocess import check_output


def get_clusterStats(img):
    if img.endswith('.nii.gz'):
        pass
    else:
        img = '.'.join([img, 'nii.gz'])

    cmdSTR = '3dClust -1Dformat -1noneg -orient LPI -dxyz=1 1.01 2'
    cmd = ' '.join([cmdSTR, img]).split()

    output = check_output(cmd)
    keys = output.split('\n')[-4]
    keys = keys.replace('#', '').split()
    clean_keys(keys)  # Strips out the bad elements which will screw us up
    values = output.split('\n')[-2].split()
    clust_stats = dict(zip(keys, values))
    return clust_stats


def clean_keys(keyList):
    """Strips out the elements we dont want

    Params:
        keyList -- List: A list of strings
    """
    for target in ['CM', 'Max', 'MI']:
        while True:
            try:
                i = keyList.index(target)
                keyList.pop(i)
                keyList[i] = '-'.join([target, keyList[i]])
            except ValueError:
                break


def get_name(fname):
    """Get the elements of the file name we need

    Params:
        fname -- String: The file name
                c9_c8_c176_IC12_s4_l_t

    Returns:
        The image's component number, scan number, and hemisphere
        12, 4, L
    """
    if fname.endswith('.nii.gz'):
        fname = fname.replace('.nii.gz', '')

    name_stuff = {}
    tmp = fname.split('_')  # tmp is just a placeholder
    elems = tmp[-4:-1]  # The elements of the file name in a list
    name_stuff['IC'] = elems[0][2:]  # 18
    name_stuff['Scan'] = elems[1][1:]  # 3
    name_stuff['Hemi'] = elems[2].upper()

    return name_stuff


def write_report(contents, fhandle=None):
    """Creates a tab separated text document with the final results
       Params:
           contents -- List: contains the information desired to be written into the
                             report. Order is important
    """
    if fhandle is None:
        fhandle = open('cluster_report.txt', 'a')

    template = "{Img}\t\t\t\t{Scan}\t{IC}\t{Hemi}\t{MI-LR}\t{MI-PA}\t{MI-IS}\t{Volume}\t{Max-Int}\n"

    fhandle.write(template.format(**contents))   # Need to look over syntax again

#=============================== START OF MAIN ===============================


def main():
    header = "Img\t\t\t\tScan\tIC\tSide\tmmX\tmmY\tmmZ\tcluster size\tPeak t\n"
    END = os.getcwd()
    START = '/Exps/Analysis/Ice/GiftAnalysis/AtlasAnalysis/Clusters_manual'
    os.chdir(START)

    handle = open('Cluster_Report1.txt', 'a')

    for i, f in enumerate(glob.iglob('*.nii.gz')):
        if i is 0:
            handle.write(header)
        name_dict = get_name(f)
        stat_dict = get_clusterStats(f)
        stat_dict.update(name_dict)
        stat_dict.update({'Img': f})

        write_report(stat_dict, handle)

    handle.close()
    os.chdir(END)
if __name__ == '__main__':
    main()
