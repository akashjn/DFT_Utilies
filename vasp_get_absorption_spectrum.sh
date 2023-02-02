#!/bin/bash 
## get the absorption spectrum from the VASP phonon  calculations
# Energy, Im(Exx), Im(Eyy),Im(Ezz),Re(Exx),Re(Eyy),Re(Ezz)
awk '{print $2,$3,$4}' < real.dat |paste imag.dat -> combined.dat

awk '{print $1, ($2+$3+$4)/3}'  combined.dat > absorption_spec.dat
rm combined.dat
