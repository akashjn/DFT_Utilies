#!/bin/sh

echo "filename, total_dipole(Debye)">dipoles.csv
for jj in `ls *log`;do 
Total_dipole=`grep "Dipole moment (field-independent basis, Debye):" $jj  -1|tail -1|awk '{print $8}'`;
echo $jj,$Total_dipole >> dipoles.csv;
done
