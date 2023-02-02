#!/bin/sh
# This script will print the maximum and rms force and displacement of the last step in the optimization
# It will use all log files in the folder
echo "Searching in all .log files in the current folder"

for filename in `ls *log`;do
echo $filename
grep Converged $filename -4|tail -5
done
