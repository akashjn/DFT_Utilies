#!/bin/bash
echo "Extracting H(Har) values from log files"
echo "file,H(har)">file_Enthalpies.csv
for jj in `ls *.log`;do 
	new=`echo $jj|sed 's/.log//g'`
	new2=`grep "Sum of electronic and thermal Enthalpies=" $jj|awk '{print $NF}'`
	echo "$new,$new2" >> file_Enthalpies.csv
done

echo "G(Har) values saved in file_Enthalpies.csv"
