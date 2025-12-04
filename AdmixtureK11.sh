#!/bin/sh
# module load conda
# conda activate vanessa
inPATH=$1
inFile=$3
AdmPath=$4



file=${inPATH}Input/${inFile}
samples=${inPATH}Input/temp/SamplesPlink${2}.txt
Refs=${inPATH}Input/RefsPlink_K11.txt
outQ=${inPATH}Output/Q_values${2}.txt
outCI=${inPATH}Output/CI${2}.txt
pop=${inPATH}Input/Ref.pop
outNames=${inPATH}Output/Names${2}.txt
a=0

while read -r LINE
do
	A= wc -l $pop
	echo "$A"
	a=$(( $a + 1 ))
	subset=${inPATH}Analysis/samplesAnalyse${2}.txt
	newpop=${inPATH}Analysis/samplesAnalyse${2}.pop
    printf '%s\n' "$LINE"
    S=$(echo "$LINE" | cut -f1)
    echo "$S"
    cat $Refs > $subset
    echo "$LINE" >> $subset
	plink --bfile ${inPATH}Analysis/samplesAnalyse${2} --recode --allow-extra-chr --out ${inPATH}Analysis/samplesAnalyse${2}
	plink --bfile $file --keep $subset --make-bed --out ${inPATH}Analysis/samplesAnalyse${2}
	N=$(grep "$S" -n ${inPATH}Analysis/samplesAnalyse${2}.fam | cut -f1 -d:) 
	cat $pop > $newpop
	sed -i "$N"'s/^/-\n/' $newpop

	
	echo 'line' 
	echo "$S"
	echo "$N"
	# echo $N
	${AdmPath} ${inPATH}Analysis/samplesAnalyse${2}.bed 11 -B100
	sed -n "$N""p" ${inPATH}samplesAnalyse${2}.11.Q >> $outQ
	echo "$S" ' ' "$N" ' ' "$a" >> $outNames
	#sed -i "$Ns/^/$S\/" $outQ
	sed -n "$N""p" ${inPATH}samplesAnalyse${2}.11.Q_se >> $outCI
done < "$samples"





