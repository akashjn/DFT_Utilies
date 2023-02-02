#!/bin/bash
# This script will print the d-band center from the polarized DOS of atoms
echo   atom dband-center >  results_ed.txt
#First use split_dos file
echo "Give serial number of the atom from POSCAR"
read atomno
for ((i=$atomno;i<=$atomno;i++)) ; do

#awk '{print $1" "$4}' DOS$i > dband_$i  #D-BAND#

echo "using DOS$i for atom $i"
#read filename
echo "summing spin-polarized s+p+d dos using ~/scripts/sum_dos, writing total dos in the format: E-Ef, s+p+d_up, s+p+d_down"
~/scripts/sum_dos 0 $i $i
awk '{print $1" "$8" "$9}' DOS.SUM.$i.to.$i > total_dos
dossplitfile=total_dos  #update file name
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

dbandcenters=$(awk -v e1=$Eend -v e2=$Estart -v np=$Np 'BEGIN{sum1=0;sum2=0;sum1d=0;sum2d=0;dE=0}
{
dE=(e1-e2)/(np-1)
$4 = dE
$5 = $2*$4 #spin up
$6 = $5*$1 #spin up
#print $0
sum1+=$5
sum2+=$6

$7 = $3*$4 #spin down
$8 = $7*$1 #spin down
#print $0
sum1d+=$7
sum2d+=$8
} 
END{print "spin up=" sum2/sum1,"spin down=" sum2d/sum1d }
'    d_below_fermi_$i )
echo  "DOS$i"  "total_center "$dbandcenters >> results_ed.txt
rm d_below_fermi_$i total_dos  DOS.SUM.$i.to.$i

done

#awk -v avg=0 'NR>1 {avg+=$2} END{print "Sum of Ed ="avg, ", Number of atoms =" NR-1, ", average Ed up =" avg/(NR-1)}' results_ed.txt >>  results_ed.txt

cat results_ed.txt
