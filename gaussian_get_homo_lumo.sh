#!/bin/bash
# print homo and lumo from the gaussian log file
echo "Give file name ex.: <file>.com.out"

read filename

# fIND homo and lumo in gaussian out file
HOMO=`grep  "Alpha  occ. eigenvalues" $filename  |tail -1|awk '{print $NF}'`
LUMO=`grep  "Alpha  occ. eigenvalues" $filename -1|tail -1|awk '{print $5}'`
echo "HOMO=$HOMO, LUMO=$LUMO"
