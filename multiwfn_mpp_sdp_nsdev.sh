#!/bin/bash
echo "filename","MPP_heavy(Ang)","SDP_heavy(Ang)","ndev1(Ang)","ndev2(Ang2)" > results_multifn.csv
for filename in `ls *.xyz`;do
echo calculating $filename ...

#MPP_a=`echo -e "MPP\na\nn\nq" | Multiwfn $filename | grep "Molecular planarity parameter (MPP)"|awk '{print $6}'` # all atoms
#SDP_a=`echo -e "MPP\na\nn\nq" | Multiwfn $filename | grep "Span of deviation from plane (SDP)"|awk '{print $8}'` # all atoms

MPP_h=`echo -e "MPP\nh\nn\nq" | Multiwfn $filename | grep "Molecular planarity parameter (MPP)"|awk '{print $6}'` # only heavy atoms
SDP_h=`echo -e "MPP\nh\nn\nq" | Multiwfn $filename | grep "Span of deviation from plane (SDP)"|awk '{print $8}'` # all atoms

nsdev_file=`echo $filename|sed s/.xyz//g`

#ndev: deviation of only N atoms from the plane
ndev=`echo -e "MPP\nh\nn\nq" | Multiwfn $filename | grep "(N ) to the plane"|awk '{print $9}'`

#ndev1: sum of the absolute value of the deviation of N atoms and divided by number of N atoms in the molecule
ndev1=`echo $ndev| awk 'NR==0{print $0,0;next;} {s=0; for (i=1;i<=NF;i++) s+=sqrt($i*$i); print $0,s/NF;}'|awk '{print $NF}'`

#ndev2: sum of the absolute value of the square of the deviation of N atoms and divided by number of N atoms in the molecule;squaring deviation will give more weight to large deviations
ndev2=`echo $ndev| awk 'NR==0{print $0,0;next;} {s=0; for (i=1;i<=NF;i++) s+=$i*$i; print $0,s/NF;}'|awk '{print $NF}'`
#echo  $ndev1, $ndev2
echo $filename,$MPP_h,$SDP_h,$ndev1,$ndev2 >> results_multifn.csv
done
echo "generated results_multifn.csv  file"
echo "------------------------------------"
cat results_multifn.csv
echo "------------------------------------"
