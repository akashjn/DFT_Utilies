#!/bin/bash
echo "Extracting G(Har) values from log files"
echo "file,G(har)">file_energy.csv
for jj in `ls *.log`;do 
	new=`echo $jj|sed 's/.log//g'`
	new2=`grep "Sum of electronic and thermal Free Energies=" $jj|awk '{print $NF}'`
	echo "$new,$new2" >> file_energy.csv
done

echo "G(Har) values saved in file_energy.csv"
