#!/bin/bash
echo   atom dband-center >  results_ed.txt



echo "give atom no."
read atomno
awk '{print $1" "$10" "$11}' DOS${atomno}.lm > dos${atomno}_dxy
awk '{print $1" "$12" "$13}' DOS${atomno}.lm > dos${atomno}_dyz
awk '{print $1" "$14" "$15}' DOS${atomno}.lm > dos${atomno}_dz2
awk '{print $1" "$16" "$17}' DOS${atomno}.lm > dos${atomno}_dxz
awk '{print $1" "$18" "$19}' DOS${atomno}.lm > dos${atomno}_dx2y2

for i in dxy  dyz dz2 dxz dx2y2 ; do


dossplitfile=dos${atomno}_$i   #update file name

Estart=$(awk 'NR==1{print$1}' $dossplitfile)
#echo "First element of Energy column = $Estart"

Eend=$(awk 'END{print $1}' $dossplitfile)
#echo "Last element of Energy column = $Eend"

Np=$(awk 'END{print NR}' $dossplitfile)
#echo "NEDOS= $Np"

#remove all energies above fermi-level, or we can replace E and rho to zero
#awk '$1>0{$1=0;$2=0}1'  $dossplitfile > splitDOSCAR_new
awk '$1<0'  $dossplitfile > d_below_fermi_$i  # energies upto fermi-level

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
rm d_below_fermi_$i  dos${atomno}_$i

done

#awk -v avg=0 'NR>1 {avg+=$2} END{print "Sum of Ed ="avg, ", Number of atoms =" NR-1, ", average Ed up =" avg/(NR-1)}' results_ed.txt >>  results_ed.txt

cat results_ed.txt
