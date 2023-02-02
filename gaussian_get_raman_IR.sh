#!/bin/bash


for  filename in `ls *.log`;do

file=`echo ${filename}|sed 's/.log//g'`

echo "Freq,Raman,"> raman_freq_${file}.csv

grep "Raman Activ"  ${filename}|awk '{for(i=4;i<=NF;i++) printf $i",\n"}'|awk '{for(i=1;i<=NF;i++) printf $i"\n"}' > raman_${file}.csv

grep "Frequencies"  ${filename}|awk '{for(i=3;i<=NF;i++) printf $i",\n"}'|awk '{for(i=1;i<=NF;i++) printf $i"\n"}' > freq_${file}.csv

awk 'FNR==NR { a[FNR""] = $0; next } { print a[FNR""], $0 }'  freq_${file}.csv raman_${file}.csv >> raman_freq_${file}.csv


echo "raman intensities written in raman_freq_${file}.csv"


# Find IR

echo "Freq,IR,"> IR_freq_${file}.csv

grep "IR Inten"  ${filename}|awk '{for(i=4;i<=NF;i++) printf $i",\n"}'|awk '{for(i=1;i<=NF;i++) printf $i"\n"}' > ir_${file}.csv


awk 'FNR==NR { a[FNR""] = $0; next } { print a[FNR""], $0 }'  freq_${file}.csv ir_${file}.csv >> IR_freq_${file}.csv

rm raman_${file}.csv freq_${file}.csv  ir_${file}.csv 


echo "IR intensities written in IR_freq_${file}.csv"

done
