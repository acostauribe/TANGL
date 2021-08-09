###AUG2021: Juliana Acosta-Uribe
###All rights reserved
### Copyright: UCSB

#!/bin/bash
# Script to perform a PCA analysis using PLINK 1.9 and smartpca2.perl
# smartpca2.perls is a modification of smartpca.perl that allows flag -c for parallel computing
# Both programs need to be in the PATH, for the script to run

# I previously used KING to detect relatedness between families and removed related individuals

PREFIX=FILE #Give prefix of the plink files
HIGHMAF=0.05 # maximum maf to include snps, if you dont wat a max-maf set value to 1
LOWMAF=0.01 # maf to include snps, if you dont want a lowmaf set value to 0

echo "Performing calculations with MAF" $HIGHMAF "and" $LOWMAF

plink --bfile $PREFIX \
--maf $LOWMAF \
--max-maf $HIGHMAF \
--snps-only \
--make-bed --out $PREFIX.maf$LOWMAF.max-maf$HIGHMAF

echo "Detecting SNPs in pair-wise Linkage disequilibrium" 

plink --bfile $PREFIX.maf$LOWMAF.max-maf$HIGHMAF \
--indep-pairwise 50 5 0.5 \
--out $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.snps

echo "Extracting SNPs in pair-wise Linkage disequilibrium"

plink --bfile $PREFIX.maf$LOWMAF.max-maf$HIGHMAF \
--extract $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.snps.prune.in \
--make-bed --out $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD

awk '{print $1, $2, $3, $4, "Population-name", $6}' \
$PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.fam > $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.pedind


echo "Performing PCA analysis"

smartpca2.perl -i $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.bed \
-a $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.bim \
-b $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.pedind \
-o $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.pca \
-e $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.eval \
-l $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.log \
-p $PREFIX.maf$LOWMAF.max-maf$HIGHMAF.LD.plot \
-c 5 #use 5 threads for parallel computing

echo "done"
