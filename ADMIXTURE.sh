###AUG2021: Juliana Acosta-Uribe
###All rights reserved
### Copyright: UCSB

#!/bin/bash
# Script for running ADMIXTURE in Supervised fashion

PREFIX=CLM.EUR.AFR.NAM.QC2 # .bed .fam .bim prefix pf the plink files
ANC="3" # float, number of ancestral populations to use in the Supervised model

# I previously used KING to detect relatedness between families and remove related individuals

# Prune for LD according to ADMIXTURE recommendations
plink --bfile $PREFIX --indep-pairwise 50 10 0.1 

plink --bfile $PREFIX --extract plink.prune.in --make-bed --out $PREFIX.LD

echo "$PREFIX prunned for LD"

#Unsupervised run
echo "starting ADMIXTURE unsupervised analysis"

#The best practice is to run the program to multiple iterations and plot the cv error vs. K to get the K with the lowest cv error
#I usually do 20 iterations (i)

for i in {1..20}; do 

echo "Starting ADMIXTURE unsupervised analysis, iteration" ${i}	

	for k in {1..10}; do 

	./admixture -j4  --cv -s time  $PREFIX.LD.bed ${k} | tee $PREFIX.LD.unsupervised${k}.log 
	#tee reads standard input and writes it to a log file. j4 makes the program run ussing four processors. cv outputs cross validation error

	echo "Unsupervised run K=${k} finalized" ; done

mv *.Q *.iteration${i}.Q 
mv *.P *.iteration${i}.P 
mv *.log *.iteration${i}.log 

echo "Iteration" ${i} "finished" ; done



# Supervised run. remember to add the .pop file in the same location of the plink files
echo "starting supervised analysis"

for i in {1..20}; do \
./admixture -j4 -supervised -s ${i} $PREFIX.LD.bed $ANC | tee supervised${i}.log \
mv $PREFIX.$ANC.Q $PREFIX.$ANC.seed${i}.Q \
mv $PREFIX.$ANC.P $PREFIX.$ANC.seed${i}.P
echo "Supervised run with seed ${i} done" ; done

echo "ADMIXTURE analysis finalized"
