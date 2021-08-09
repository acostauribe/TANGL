##PHASING GENOMIC DATA#


###I. Prep your files

1.1. Remove singletons and keep only biallelic sites.
Since we are taking benefits of the family structure, many individuals have Mother and Fathre ID, therefore plink categorizes these individuals as "nonfounders". I recommend to use ``--nonfounders`` to include these individulas in the allelic frequency counts.

```
plink --bfile  --bfile <prefix> --mac 2 --snps-only just-acgt --nonfounders --make-bed --out <prefix>.mac2.snps-only
```

You should only phase one chromosome at a time. For our example we will be using chromosome 14, but you could do a "for loop" function to pahse all chromosomes in a sequence.

```
plink --bfile <prefix>.mac2.snps-only --chr 14 --snps-only just-acgt --make-bed --out <prefix>.mac2.snps-only.chr14
```

Make sure your file <prefix>.mac2.snps-only.chr14.bim has the same variant identifiers as your reference panels e.g. **1000GP\_Phase3.hap.legend.sample** and **1000GP\_Phase3_chr14.hap.gz**  files

You can find mutiple reference panels here [https://mathgen.stats.ox.ac.uk/impute/impute_v2.html#reference]()
or get directly the 1000GP phase 3 here [https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.html](). The cM genetic recombination maps are also available in the same site.

###II. PHASE DATA 

####1. Check your file with SHAPEIT2  

```
shapeit \
-check \
--input-ref 1000GP_Phase3_chr14.hap.gz 1000GP_Phase3_chr14.legend.gz 1000GP_Phase3.sample \
--thread 20 \
--input-bed <prefix>.mac2.snps-only.chr14 \
--input-map genetic_map_chr14_combined_b37.txt \
--output-log <prefix>.mac2.snps-only.chr14.shapeit
```

####Output files:

*COL-900.ADM.EUR.AFR.chr14.id.ind.me* : contains the Mendel errors at the individual level (N lines).

The columns are:
id: The individual id
father_id: The father id for this individual
father_mendel: The number of Mendel error when considering only the duo father/child
mother_id: The mother id for this individual
mother_mendel: The number of Mendel error when considering only the duo mother/child
father_mother_mendel: The number of Mendel error when considering the full trio father/mother/child
famID: An unique id internally assigned by SHAPEIT to each distinct family (useful to determine how many unrelated families there are).

	id father_id father_mendel mother_id mother_mendel father_mother_mende  famID
	HG01879 0       0       0       0       0       0
	HG01880 0       0       0       0       0       1
	HG01882 0       0       0       0       0       2
	HG01883 0       0       0       0       0       3
	HG01885 0       0       0       0       0       4
	HG01886 0       0       0       0       0       5
	HG01889 0       0       0       0       0       6
	HG01890 0       0       0       0       0       7
	HG01894 0       0       0       0       0       8

For this file we have 0 mendel errors.

*COL-900.ADM.EUR.AFR.chr14.id.snp.me* : contains the Mendel errors at the SNP level (L lines).
The columns are variant site ID and position, number of mendel errors, total number of duos-trios.
If you divide the 3rd column by the last, you get the Mendel error rate. 

	id     			 				position        mendel  total
	14:19064660:T:G 				19064660        0       105
	rs201332986:19126973:G:T        19126973        0       105
	14:19127510:G:T					19127510        0       105
	14:19130203:A:C 				19130203        0       105
	rs138361741:19130208:A:T        19130208        0       105
	14:19130228:A:G 				19130228        0       105
	rs138032186:19130371:A:G        19130371        0       105
	14:19130399:T:G 				19130399        0       105
	rs190014110:19130435:G:A        19130435        0       105

For this file we have 0 mendel errors.


*COL-900.ADM.EUR.AFR.chr14.id.ind.mm* : contains the individual missing rates (N lines)
The first column gives the individual ID and the second the number of sites with missing data the individual contains.

	id      missing
	HG01879 55
	HG01880 36
	HG01882 61
	HG01883 72
	HG01885 86
	HG01886 67
	HG01889 71
	HG01890 57
	HG01894 72


*COL-900.ADM.EUR.AFR.chr14.id.snp.mm* : contains the SNP missing rates and allele frequencies (L lines)
The columns are:
id: The SNP id (ex: rs id)
position: The SNP physical position in bp
A: The first allele (ref allele in VCF)
B: The second alleles (alt allele in VCF)
missing: The missing genotype count. That is the number of samples with missing data at this site.
count_A_main: The allele A count. The number of haplotypes carrying the A allele.
count_B_main: The allele B count. The number of haplotypes carrying the B allele.
count_A_founder: The allele A count in founder haplotypes only.
count_B_founder: The allele B count in founder haplotypes only.

	id      position        A       B       missing count_A_main    count_B_main    count_A_founder count_B_founder count_A_ref     count_B_ref  count_A_total    count_B_total
	14:19064660:T:G 				19064660        G       T       0       9       4813    9       4603    5       5003    14      9816
	rs201332986:19126973:G:T        19126973        T       G       0       28      4794    24      4588    13      4995    41      9789
	14:19127510:G:T 				19127510        T       G       0       6       4816    6       4606    3       5005    9       9821
	14:19130203:A:C 				19130203        C       A       3       47      4769    46      4560    22      4986    69      9755
	rs138361741:19130208:A:T        19130208        T       A       7       274     4534    258     4340    202     4806    476     9340
	14:19130228:A:G 				19130228        G       A       0       15      4807    14      4598    14      4994    29      9801
	rs138032186:19130371:A:G        19130371        G       A       2       151     4667    142     4466    109     4899    260     9566
	14:19130399:T:G 				19130399        G       T       0       29      4793    28      4584    22      4986    51      9779
	rs190014110:19130435:G:A        19130435        A       G       0       239     4583    223     4389    240     4768    479     9351

To fix the SNPs with high missingness I used the plink --geno command. Use the --nonfounder flag to do this

```
plink --bfile <prefix>.mac2.snps-only.chr14 --geno 0.01  --nonfounders --make-bed --out <prefix>.mac2.snps-only.chr14.geno
```

Missalingment or missingness issues will be reported in *file.strand* and *file.strand.exclude*

You can exclude the file.strand.exclude snps with --exclude-snp file.exclude
Where each line of the file file.exclude corresponds to a physical position that has to be excluded.

Then check again (use the --exclude-snp flag if necessary)

```
shapeit \
-check \
--input-ref 1000GP_Phase3_chr14.hap.gz 1000GP_Phase3_chr14.legend.gz 1000GP_Phase3.sample \
--thread 20 \
--input-bed <prefix>.mac2.snps-only.chr14.geno \
--input-map genetic_map_chr14_combined_b37.txt \
--output-log <prefix>.mac2.snps-only.chr14.geno.shapeit
```

Reading genetic map in [/home/acostauribe/1000G/GeneticMaps/genetic_map_chr14_combined_b37.txt]
	  * 104393 genetic positions found
	  * #set=101046 / #interpolated=609980
	  * Physical map [19.06 Mb -> 107.29 Mb] / Genetic map [0.00 cM -> 117.51 cM]

Checking missingness and MAF...

Checking Mendel errors...
	  * Low level of Mendel error in all trios and duos
	  * 0 SNPs with high Mendel error rate (> 5%)

If everything is good, proceed to phase your data.


####2.  Phase your data with SHAPEIT2

```
shapeit \
-check \
--input-ref 1000GP_Phase3_chr14.hap.gz 1000GP_Phase3_chr14.legend.gz 1000GP_Phase3.sample \
--thread 20 \
--input-bed <prefix>.mac2.snps-only.chr14.geno \
--input-map genetic_map_chr14_combined_b37.txt \
--duohmm \
-W 5 \
--thread 18 \
--output-max <prefix>.mac2.snps-only.chr14.geno.haps.gz \
<prefix>.mac2.snps-only.chr14.geno.haps.gz\
--output-log <prefix>.mac2.snps-only.chr14.geno.shapeit_phased
```

Output files <prefix>.mac2.snps-only.chr14.geno.haps.gz 
<prefix>.mac2.snps-only.chr14.geno.haps.gz


####3. Convert the haps.gz and sample into a VCF

unzip the haps.gz file and run:

```
shapeit -convert \
--input-haps <prefix>.mac2.snps-only.chr14.geno \
--output-vcf <prefix>.mac2.snps-only.chr14.geno.vcf
```
