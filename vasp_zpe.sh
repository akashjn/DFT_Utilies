#!/bin/bash
# bash script to print the zero point energies from the VASP outcar file
echo  "give OUTCAR file path"
read filename
grep meV $filename | awk 'BEGIN{s=0;}{s+= $10;print $10}END{print "Number of Modes=" NR, "zpe energy is in eV =" s/2000 }'

# KbT=25.85  meV at T=300 K
grep meV $filename | awk 'BEGIN{s=0}{s+= (-25.85*(log(1-exp(-$10/25.85))))+($10/(exp($10/25.85)-1))}END{print "sum(TS) in eV =" s/1000 }'

