**These repository contains a series of scripts developed for the analyses of identity by descent (IBD) in a three-way admixed population from Colombia.** 

We are provinding examples of the scripts we used at every step of the analyses we presented in our paper "A Neurodegenerative Disease Landscape of Rare Mutations in Colombia Due to Founder Effects". If you use our scripts, please cite: 
Acosta-Uribe, et al. A Neurodegenerative Disease Landscape of Rare Mutations in Colombia Due to Founder Effects. [link]

We are providing a shell script for every step, and additional R and Python scripts for nice plots. The scripts need to be modified with the name of the files you are using.

**Pipeline**

1. Identify relatedness between samples using KING
2. Principal Component Analysis (PCA) using PLINK 1.9 [http://www.cog-genomics.org/plink2]() and EIGENSOFT(v7.2.1) [https://github.com/DReichLab/EIG/archive/v7.2.1.tar.gz]
3. Estimation of global ancestry using ADMIXTURE [https://dalexander.github.io/admixture/]()
4. Phasing genomes using SHAPEIT2
5. Local ancestry inference using RFMix
6. Identification of Identitical by Descent (IBD) segments using Hap-IBD

________

Our dataset comprised both *related* and *unrelated* individuals. Having related individuals in the same dataset improves *Phasing* and *IBD* detection.
However, certain analyses such as PCA or ADMIXTURE need to be performed in Unrelated individuals. If you know your dataset contains related individuals, I recommend doing some additional quality control steps using PLINK.

First, edit your <file>.fam to reflect the Paternal and Maternal ID for each sample, and give each known family, the same Family ID (first column of <file>.fam). 
If the father or the mother is in the dataset, their Sample ID needs to match the Father or Mother ID of their offspring.
Once your <file>.fam reflects known relationships, check your file for "mendel errors"

  
Set mendel errors to missing, (this will be useful for the phasing steps as well)
```
plink --bfile <file-prefix> --mendel-duos --set-me-missing  --make-bed --out <file-prefix>.me
  
plink --bfile <file-prefix>.me --mendel-multigen --set-me-missing  --make-bed --out <file-prefix>.me.multigen
``` 
  

**1. Identify relatedness between samples**

We used KING to verify diclosed relationships (e.g. parent-offsping, full-siblings etc)[https://www.kingrelatedness.com/manual.shtml]() 
Ideally, the relatedness coefficient should match the disclosed relationship.  

A subset of unrelated samples was selected by keeping only the proband of each family. Once we extracted a single individual per family, we performed another check for criptic relatedness. Only sample pairs with kinship coefficient less than 0.044 should be retained 
 
```
king -b <file-prefix>.bed --related --degree 3
```


**2. Principal Component Analysis (PCA)**

For PCA, we used the subset of unrelated samples and performed LD-pruning using PLINK to exclude variants with an r2 value of greater than 0.2 with any other SNP within a 50-SNP sliding window, advancing by 10 SNPs each time. Then, we performed a PCA using the smartpca package from EIGENSOFT(v7.2.1) [https://github.com/DReichLab/EIG/archive/v7.2.1.tar.gz]. You can open the script ``PCA_with_MAF_restrictions.sh`` in any text editor and set the minor allele frequency (MAF) thresholds you want for your analyses. 
  ```
  chmod u+x PCA_with_MAF_restrictions.sh
  ```
  ```
  ./PCA_with_MAF_restrictions.sh
  ```

The PCA results colored according to ancestry were plotted using the PCAviz package for R, take a look at the R markdown ``RunningPCAviz.Rmd``
You can also make nice PCA images and a 3D PCA using the R script ``3D_PCA.R``
![ Alt text](3dAnimatedScatterplot.gif) 
**3. Estimation of global ancestry using ADMIXTURE**



We calculated global ancestry using ADMIXTURE (v.1.3.0)[37] independently for the unrelated TANGL individuals (n=566) and for the TANGL.AFR.EUR.NAT-Unrelated cohort. As recommended by ADMIXTURE, PLINK (v.1.9)[31,32] was used to perform pair-phased linkage disequilibrium (LD) pruning; excluding variants with an r2 value of greater than 0.2 with any other SNP within a 50-SNP sliding window, advancing by 10 SNPs each time (--indep-pairwise 50 10 0.2). The LD-pruned dataset contained 203,810 variants. We then performed an unsupervised analysis modeling from one to ten ancestral populations (K = 1 – 10) using the random seed option and replicating each calculation 20 times. We selected the run with the best Loglikehood value for each K and compared the Cross Validation (cv) error values to determine the model with the lowest cv value. Ancestral proportion statistics of mean and standard deviation were calculated using the statistical software R[38]. 


**4. Phasing genomes using SHAPEIT2**

We phased the combined TANGL.AFR.EUR.NAT dataset with SHAPEIT (v.2.r900)[41] using the haplotype reference panel of the 1000GP. We used the parameters –duohmm and a window of 5MB (-W 5), which takes advantage of the inclusion of families, pedigree structure and the large amount of IBD shared by close relatives, leading to increased accuracy


**5. Local ancestry inference using RFMix**

 We used the PopPhased version of RFMix (v1.5.4)[43] to estimate the local ancestry using the following flags: -w 0.2, -e 1, -n 5, --use-reference-panels-in-EM, --forward-backward as recommended by Martin et al[3] for estimating local ancestry in admixed populations.

We implemented protocols similar to those previously developed for ancestry estimation in admixed populations. We recommend the following repository to identify local ancestry 
[https://github.com/armartin/ancestry_pipeline.git]()



**6. Identification of Identitical by Descent (IBD) segments using Hap-IBD**

 
To determine the carrier haplotype and local ancestry of a rare variant of interest, we used PLINK(v.1.9)[31,32]. We identified other single nucleotide variants (SNVs) in linkage disequilibrium with the variant of interest and used them as tags to identify the carrier haplotypes in the phased dataset, and then searched for the local ancestry of the specific locus in the RFMix output.


If any of the disease-conferring or risk-associated variants were shared by two or more unrelated individuals, we used hap-IBD[66] v1.0 to search for identity by descent (IBD) around the locus. Because this software detects IBD of 2cM and higher, we additionally performed an alignment of the haplotypes carrying the variants of interest to search for smaller IBD segments between the TANGL and 1000 Genomes Project (1000GP) carriers. Autozygosity (homozygosity by descent) was determined using the same methods.
