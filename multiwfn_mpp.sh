#!/bin/bash
echo "filename","MPP_all(Angstrom)","MPP_heavy(Angstrom)" > results_multifn.csv
for filename in `ls *.xyz`;do
echo calculating $filename ...
MPP_a=`echo -e "MPP\na\nn\nq" | Multiwfn $filename | grep "Molecular planarity parameter (MPP)"|awk '{print $6}'` # all atoms
MPP_h=`echo -e "MPP\nh\nn\nq" | Multiwfn $filename | grep "Molecular planarity parameter (MPP)"|awk '{print $6}'` # only heavy atoms
echo $filename,$MPP_a,$MPP_h  >> results_multifn.csv
done
