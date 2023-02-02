## List of useful grep, and awk commands with examples

#grep print lines with Match
grep MATCH input

#grep print lines with Matach, and their line number
grep -n "TextToBeMatched" input

#grep print lines which doesn't contain match 
grep -vn "TextToBeMatched" input 

#grep, count number of lines that match the query, no printing
grep -c "TextToBeMatched" input

#grep to ignore case, find match with both lower and upper case
grep -i "TextToBeMatched" input

#Find and replace 
sed -i 's/TextToBeRepalaced/NewTextTobeAdded/g' filename  #g at end replaces all the matches found in line
sed ' s/TextToBeRepalaced/NewTextTobeAdded/' filename #no g  only first match is replaced 

#Find and delete
sed -i '/TextTobeDeleted/d'  filename

#Delete Rows below ROW#
sed 'ROW NUMBER,$ d' ~/temp.txt
# Use sed only in some lines only 
sed -i 'lineN1,lineN2s/replace/newtext/g'  input

#Delete last line 
sed -i '$ d' input

#Append line after match 
sed '/TextToBeMatched/a \TextTobeAdded' input

#Insert line before match 
sed '/TextToBeMatched/i \TextTobeAdded' input

#Add line after 3rd  line
sed '3 a\ TextTobeAdded' input

#Add line before 3rd line 
sed '3 i\ TextTobeAdded' input

#Add line at the end of the file 
sed '$ a\ TextTobeAdded' input

#Add line before the last line of the file
sed '$ i\ TextTobeAdded' input

#Replace a first line of the file
sed '1 c\ NewTextTobeAdded' input

#Replace the last line of the file
sed '$ c\ NewTextTobeAdded' input

#Replace a line which matches the pattern
sed '/PatternTobeMatched/c\ NewTextTobeAddedInTheLine' input

#Remove all patterns found in input file
sed 's/PatternTobeRemoved//g' input

#Multiple patters
sed 's/[P1,P2]//g' input

#Add prefix and suffix
#https://www.shellhacks.com/sed-awk-add-end-beginning-line/

#to add prefix 
sed 's/^/____first____/' input
# OR BY awk 
awk '{$1= "TEXT" FS $1}1' input

#to add suffix
awk '{$(NF+1)= "TEXT"}1' input 
sed 's/$/____last____/' input

#Add both prefix and suffix 
 sed 's/.*/____first____&____last____/' input
#http://www.theunixschool.com/2014/08/sed-examples-remove-delete-chars-from-line-file.html


#Print every line after matched pattern
 sed -ne '/PatternTobeMatched/,$ p' input

#tO ADD pattern after some keyword
#1st get the line number 
grep -n Direct POSCAR
#lets say NR=8, then to add F F F after direct use,
awk 'NR>8 {$(NF+1)=" F  F  F"}1' POSCAR > new.file
#In new file, we see ^M 
#To remove ^M, OPEN FILE IN VIM, PRESS ESC AND THEN TYPE:
:%s/\r//g
or 
sed -i 's/\r//g' *com

#Find a certain file in all the folders
 find . -type f -name 'NAME_OF_FILE'

# If you set "shopt -s autocd" in the bash shell, then you'll be able to change directories by just typing the name of the directory.

#sum time taken by each ionic from OUTCAR
grep LOOP+ OUTCAR | awk 'BEGIN{s=0;}{s+= $7;print $7}END{print "Number of Ionic steps=" NR, "TOTAL TIME TAKEN in hours =" s/3600 }'

#TO GET FULL NAME OF JOBS IN SLRUM QUEUE
sacct --format="JobID,JobName%30"

# fIND homo and lumo in gaussian out file
HOMO=`grep  "Alpha  occ. eigenvalues" <filename>.com.out |tail -1|awk '{print $NF}'`
LUMO=`grep  "Alpha  occ. eigenvalues" <filename>.com.out -1|tail -1|awk '{print $5}'`


#CHECK NEGATIVE FREQ in G16
grep " Frequencies --" <filename>.com.out  |awk 'BEGIN{a=1;b=1;c=1;}{a+= $3 < 0;b+= $4 < 0;c+=$5 < 0 }END{print "If a, b and c are all 1, then no negative vib frequencies; a=" a, "b=" b ,"c=" c}'

#
cat temp |awk 'BEGIN{sum=0;}{sum+=$4+$6/60+$8/3600}END{print sum}'

#USE CMD WINDOW OPENSSH TO OPEN BEBOP
#ssh -i path-to-public-key-in-openSSH-format user@host
ssh -i C:\Users\akashjn\Documents\is_rsa_forwin jaina@bebop.lcrc.anl.gov
# USE DOUBLE QOUTES TO USE VARIABLES in SED
for  j in {0..50};do echo $j; sed -i "s/\%Chk=IsoFlavone-reduced-wB97XD-oio.chk/\%Chk=IsoFlavone-reduced-wB97XD-$j.chk/g" IsoFlavone-neutral-wB97XD-$j.com; done
#print number of lines in files a and b; 
ls *com > b ; grep Station *log > a ;  wc -l b a

#print range of columns with awk 
awk '{for(i=NF;i>=1;i--) printf $i" "; print ""}' homos.csv
awk '{for(i=1;i<=NF-4;i++) printf $i" "; print ""}' homos.csv

#PRINT specifics lines with awk
awk 'NR>=46 && NR<=49' file
#PRINT FILE, total_scf_Steps,total_time(hours)
echo "file,total_scf_steps,total_time(hours)">file_scf_time.csv;for jj in `ls *.log`;do echo $jj; new=`echo $jj|sed 's/.log//g'`; time=`grep "Elapsed time:" $jj|awk '{print $3*24+$5+$7/60+$9/3600}'`; scf=`grep "SCF Done" $jj -c`; echo "${new},${scf},${time}" >> file_scf_time.csv; done
