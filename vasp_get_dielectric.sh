#!/bin/bash
awk 'BEGIN{i=1} /imag/,\
                /\/imag/ \
                 {a[i]=$2 ; b[i]=$3 ; c[i]=$4 ; d[i]=$5 ; i=i+1} \
     END{for (j=12;j<i/2-3;j++) print a[j],b[j],c[j],d[j]}' vasprun.xml > imag.dat

awk 'BEGIN{i=1} /real/,\
                /\/real/ \
                 {a[i]=$2 ; b[i]=$3 ;  c[i]=$4 ; d[i]=$5 ; i=i+1} \
     END{for (j=12;j<i/2-3;j++) print a[j],b[j],c[j],d[j]}' vasprun.xml > real.dat
