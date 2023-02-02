#!/bin/bash
# This script will print the d-band center from the unpolarized DOS of atoms
echo   atom dband-center >  results_ed.txt
#First use split_dos file
echo "Give serial number of the atom from POSCAR"
read atomno
for ((i=$atomno;i<=$atomno;i++)) ; do

awk '{print $1" "$4}' DOS$i > dband_$i  #D-BAND#

dossplitfile=dband_$i  #update file name
#echo file name = $dossplitfile

Estart=$(awk 'NR==1{print$1}' $dossplitfile)
#echo "First element of Energy column = $Estart"

Eend=$(awk 'END{print $1}' $dossplitfile)
#echo "Last element of Energy column = $Eend"

Np=$(awk 'END{print NR}' $dossplitfile)
#echo "NEDOS= $Np"

#remove all energies above fermi-level, or we can replace E and rho to zero
#awk '$1>0{$1=0;$2=0}1'  $dossplitfile > splitDOSCAR_new
awk '$1<0'  $dossplitfile > d_below_fermi_$i  # energies upto fermi-level
#echo energies upto fermilevel in new file = splitDOSCAR_new_$i

dbandcenters=$(awk -v e1=$Eend -v e2=$Estart -v np=$Np 'BEGIN{sum1=0;sum2=0;dE=0}
{
dE=(e1-e2)/(np-1)
$3 = dE
$4 = $2*$3
$5 = $4*$1
#print $0
sum1+=$4
sum2+=$5
} 
END{print sum2/sum1}
'    d_below_fermi_$i )
echo  $i  $dbandcenters >> results_ed.txt
rm d_below_fermi_$i
done

awk -v avg=0 'NR>1 {avg+=$2} END{print "Sum of Ed ="avg, ", Number of atoms =" NR-1, ", average Ed =" avg/(NR-1)}' results_ed.txt >>  results_ed.txt
cat results_ed.txt
