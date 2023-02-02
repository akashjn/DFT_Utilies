#!/bin/bash 

# Energy, Im(Exx), Im(Eyy),Im(Ezz),Re(Exx),Re(Eyy),Re(Ezz)
awk '{print $2,$3,$4}' < real.dat |paste imag.dat -> combined.dat

awk '{print $1, $2/($5^2+$2^2)}'  combined.dat > eels_xx.dat
awk '{print $1, $3/($6^2+$3^2)}'  combined.dat > eels_yy.dat
awk '{print $1, $4/($7^2+$4^2)}'  combined.dat > eels_zz.dat
rm combined.dat
