#!/bin/bash
# convert xyz to sdf, we need xyz2mol.py
mkdir all_sdfs
echo "file,smiles" > all_smiles.csv
for jj in `ls *.xyz`;do 
echo $jj
new=`echo $jj|sed 's/xyz/sdf/g'`
python ~/scripts/xyz2mol.py $jj -o sdf > all_sdfs/$new
smi=`python ~/scripts/xyz2mol.py $jj` 
echo $new,$smi >> all_smiles.csv 
done
