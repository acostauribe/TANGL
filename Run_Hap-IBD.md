**Running Hap-IBD to detect shared IBD segments**

Install as recommended. I installed it in acostauribe/bin/hap-ibd.jar 

Data Parameters: 
  gt=<VCF file with GT field>                         (required)
  map=<PLINK map file with cM units>                  (required)
  out=<output file prefix>                            (required)
  excludesamples=<excluded samples file>              (optional)

Algorithm Parameters: 
  min-seed=<min cM length of seed segment>            (default: 2.0)
  max-gap=<max base pairs in non-IBS gap>             (default: 1000)
  min-extend=<min cM length of extension segment>     (default: min(1.0, min-seed))
  min-output=<min cM length of output segment>        (default: 2.0)
  min-markers=<min markers in seed segment>           (default: 100)
  min-mac=<minimum minor allele count filter>         (default: 2)
  nthreads=<number of computational threads>          (default: all CPU cores)

Before running the program you also need to download the map files [http://bochet.gcc.biostat.washington.edu/beagle/genetic_maps/plink.GRCh37.map.zip]()

The **.map** fine and the **vcf** file need to have the same SNP ids. You can change the vcf file SNP IDs using bcftools. 

**Make sure your vcf is gzipped and indexed with tabix**

```
bgzip prefix.mac2.snps-only.chr14.geno.vcf > prefix.mac2.snps-only.chr14.geno.vcf.gz
tabix -p vcf prefix.mac2.snps-only.chr14.geno.vcf.gz
```
Then
```
bcftools annotate --set-id '%CHROM\_%POS' prefix.mac2.snps-only.chr14.geno.vcf.gz > prefix.mac2.snps-only.chr14.geno.new-ID.vcf
```

**Make sure map file uses the same format to label the SNP ids**

This can be done using AWK

```
awk '{print $1, $1"_"$4, $3, $4}' plink.chr14.GRCh37.map > plink.chr14.GRCh37.newID.map
```
**Use default settings for SNP array data**

**Run Hap-IBD on the following settings for Whole genomic sequencing data**

```
java -jar ~/bin/hap-ibd.jar \
gt=prefix.mac2.snps-only.chr14.geno.new-ID.vcf \
map=plink.chr14.GRCh37.newID.map \
min-seed=1.0 \
min-extend=0.2 \
min-output=2.0 \
out=prefix.mac2.snps-only.chr14.geno.new-ID.WGS_hap-ibd 
```
The hap-ibd program produces three output files: a log file, an ibd file, and an hbd file.

The log file (.log) contains a summary of the analysis, which includes the analysis parameters, the number of markers, the number of samples, the number of output HBD and IBD segments, and the mean number of HBD and IBD segments per sample.

The gzip-compressed ibd file (.ibd.gz) contains IBD segments shared between individuals. The gzip-compressed hbd file (.hbd.gz) contains HBD segments within within individuals. Each line of the ibd and hbd output files represents one IBD or HBD segment and contains 8 tab-delimited fields:


**Search for IBD at a specific locus (e.g. PSEN1)**
  
You can use AWK to filter the IBD segments that include your locus of interest.
```
awk -F "\t" '{ if (($6 <= 73603143) && ($7 >= 73690399)) { print } }' prefix.mac2.snps-only.chr14.geno.new-ID.WGS_hap-ibd.ibd > prefix.mac2.snps-only.chr14.geno.new-ID.WGS_hap-ibd.PSEN1-locus
```

