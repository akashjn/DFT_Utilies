import numpy as np
import os, sys
from ase.io import write
from ase import Atoms
from ase.data import chemical_symbols

"""
Python script to fetch coordinates of a molecule (from the last step in the optimization) from the gaussian log file
Usage: python gaussian_log2xyz.py <filename.out or filename.log>
"""
class GaussianOut: # 

    def __init__(self,outfile):
        f=open(outfile,'r')
        self.lines=f.readlines()  
        self.name = os.path.splitext(os.path.basename(f.name))[0] 
        # self.file_exetension = os.path.splitext(os.path.basename(f.name))[1] 
        self.name_final=os.path.splitext(self.name)[0]

    def get_name(self):
        return (self.name_final)

    def is_clean(self):
        temp=False
        for i,row in enumerate(self.lines):
            if "Normal termination" in row:
                temp=True
                return temp
            else:
                pass
        return temp

    def is_freq(self):
        temp=False
        for i,row in enumerate(self.lines):
            if "Freq" in row or "freq" in row:
                temp=True
                return temp
            else:
                pass
        return temp

    def get_geometry(self):
#        """ get geometry as an ASE object """

        str=["Standard orientation:"]
        result=[]
        for i in range(len(self.lines)): 
            for item in str: 
                if item in self.lines[i]:
                    start = i
                    for m in range(start + 5, len(self.lines)):
                        if "---" in self.lines[m]:
                            end = m
                            break  
                    Natoms = end - (start + 5)
                    sym = []
                    pos = np.zeros((Natoms, 3))
                    count = 0
                    for line in self.lines[start+5 : end]:
                        entries = line.split()
                        sym.append(chemical_symbols[int(entries[1])])
                        pos[count][0] = float(entries[3])
                        pos[count][1] = float(entries[4])
                        pos[count][2] = float(entries[5])
                        count +=1
                    geometry = Atoms(sym, positions = pos, cell = [0.0, 0.0, 0.0], pbc = [False, False, False])
                    result.append(geometry)
        return result



inpfile=sys.argv[1] # ask for user input
name, ext =inpfile.split('.')[0], inpfile.split('.')[1]

if ext=='out' or ext=='log':
    file1=GaussianOut(inpfile)
    name=file1.get_name()
    complex_atoms=file1.get_geometry()
    
    print("Normal Termination: ",file1.is_clean())
    print("Freq calculation: ",file1.is_freq())
    write("%s-final.xyz" % name, complex_atoms[-1])
else:
    print("Pick a .out or .log file to analyze") 
