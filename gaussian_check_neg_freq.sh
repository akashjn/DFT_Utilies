#!/bin/sh
# the script will check for negative frequencies in gaussian log file
echo "if neg_freq_found = 1, then no neg_freq_found. Otherwise .log or .out has a negative freq."
echo "file","neg_freq_found" > check_neg_freq.csv
for jj in `ls *.log`;do 
new=`grep " Frequencies --" $jj  |awk 'BEGIN{a=1;b=1;c=1;}{a+= $3 < 0;b+= $4 < 0;c+=$5 < 0 }END{print a*b*c}'`

echo $jj,$new >> check_neg_freq.csv
done 
cat check_neg_freq.csv
