import enum
import shutil
import struct
import numpy as np
import os, sys
import glob
from subprocess import Popen, STDOUT, PIPE
import subprocess
from ase.io import read, write
from ase import Atom, Atoms
from ase.data import chemical_symbols
from ase.build import molecule
import matplotlib.pyplot as plt
from calculate_rmsd_aj import calculate_rmsd

"""
Visulaize the progress of gaussian optimization job with this script
ase gui will need Xming application
Usage: python gaussian_job_visualization.py <filename.out or filename.log>
To calculate rmsd use calculate_rmsd_aj.py to get calculate_rmsd
if calculate_rmsd_aj.py is not in the current dir then use: sys.path.append(path_of_the_calculate_rmsd_aj.py)
"""
class GaussianOut: # Modified Garvit's script

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

    def get_energies_forces(self): # aj
        steps=0       
        scf_energy=[]
        max_force=[]
        max_rforce=[]
        max_disp=[]
        max_rdisp=[]
        for row in self.lines:
            if "SCF Done" in row:
                scf_energy.append(float(row.split()[4]))
                steps+=1
            if "Maximum Force" in row:
                max_force.append(float(row.split()[2]))
            if "RMS     Force" in row:
                max_rforce.append(float(row.split()[2]))
            if "Maximum Displacement" in row:
                max_disp.append(float(row.split()[2]))
            if "RMS     Displacement" in row:
                max_rdisp.append(float(row.split()[2]))
        return steps,scf_energy, max_force,max_rforce,max_disp,max_rdisp

    def get_thresholds(self): # aj
    
        for row in self.lines:
            if "Maximum Force" in row:
                max_force=float(row.split()[3])
            if "RMS     Force" in row:
                max_rforce=float(row.split()[3])
            if "Maximum Displacement" in row:
                max_disp=float(row.split()[3])
            if "RMS     Displacement" in row:
                max_rdisp=float(row.split()[3])
                return max_force,max_rforce,max_disp,max_rdisp

    def get_xyz_paths(self): # aj
        structs=self.get_geometry()
        path = os.getcwd()
        path = path +'_xyz_files_'+self.name
        files_list=[]
        print("xyz files written in ", path)
        if not os.path.exists(path): os.makedirs(path)
        string=self.name
        outStruct = os.path.join(path, string)
        for idx,struct in enumerate(structs):
            filename=outStruct+"_"+str(idx)+".xyz"
            struct.write(filename)
            files_list.append(filename)
        return files_list

    def get_rmsd(self): # aj
        rmsd_wrt_initial_xyz=[]
        for idx,xyz in enumerate(self.get_xyz_paths()):
            if idx==0:
                initial_xyz=xyz
            
            rmsd_wrt_initial_xyz.append(calculate_rmsd(initial_xyz,xyz))
        return rmsd_wrt_initial_xyz
        

inpfile=sys.argv[1] # ask for user input
name, ext =inpfile.split('.')[0], inpfile.split('.')[1]

if ext=='out' or ext=='log':
    file1=GaussianOut(inpfile)
    name=file1.get_name()
    complex_atoms=file1.get_geometry()
    nsteps,scf_energy,max_force,max_rms_force,max_disp,max_rms_disp=file1.get_energies_forces()
    thres_max_force,thres_max_rms_force,thres_max_disp,thres_max_rms_disp=file1.get_thresholds()
    
    print("Normal Termination: ",file1.is_clean())
    print("Freq calculation: ",file1.is_freq())
    print("5 large displacements during optimization = ",np.sort(max_disp)[-5:])    
    print("Maximum Displacement during optimization = ",np.max(max_disp)," at the step number ", np.argmax(max_disp))
    print("Writing individual xyz files")
    
    rmsds=file1.get_rmsd()
    
    plt.figure(1)
    plt.gcf().set_size_inches((16, 16))
    plt.subplot(2,2,1)
    plt.plot(np.arange(len(scf_energy)),scf_energy,label="SCF Energy",linewidth=2.5,color="orange")
    plt.xlabel("Steps")
    plt.ylabel("Energy (Hartree)")
    plt.legend()

    plt.subplot(2,2,2)
    plt.plot(np.arange(len(max_force)),max_force,label="Max. Force",linewidth=2.5,color="blue")
    plt.plot([0,nsteps],[thres_max_force,thres_max_force],"--",label="Threshold",color="blue",linewidth=1.5)
    plt.plot(np.arange(len(max_rms_force)),max_rms_force,label="Max. RMS Force",linewidth=2.5,color="red")
    plt.plot([0,nsteps],[thres_max_rms_force,thres_max_rms_force],"--",label="Threshold",color="red",linewidth=1.5)
    plt.xlabel("Steps")
    plt.ylabel("Forces (Hartrees/Bohr)")
    plt.legend()
    
    plt.subplot(2,2,3)
    plt.plot(np.arange(len(max_disp)),max_disp,label="Max. Displacement",linewidth=2.5,color="blue")
    plt.plot([0,nsteps],[thres_max_disp,thres_max_disp],"--",label="Threshold",color="blue",linewidth=1.5)
    plt.plot(np.arange(len(max_rms_disp)),max_rms_disp,label="Max. RMS Displacement",linewidth=2.5,color="red")
    plt.plot([0,nsteps],[thres_max_rms_disp,thres_max_rms_disp],"--",label="Threshold",color="red",linewidth=1.5)
    plt.xlabel("Steps")
    plt.ylabel("Displacement (Bohr)")
    plt.legend()

    plt.subplot(2,2,4)
    plt.plot(np.arange(len(rmsds)),rmsds,label="RMSD wrt the initial structure",linewidth=2.5,color="magenta")
    plt.xlabel("Steps")
    plt.ylabel("RMSD")
    plt.legend()
    write("%s-movie.xyz" % name, complex_atoms)
    #write("%s-final.xyz" % name, complex_atoms[-1])
    os.system('ase gui '+name+'-movie.xyz &')
    plt.show()
    print("removed xyz files")
    path = os.getcwd() +'_xyz_files_'+name
    shutil.rmtree(path)
    os.remove(name+'-movie.xyz')

else:
    print("Pick a .out or .log file to analyze") 
