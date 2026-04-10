# Quantification of Introgression

# Panel introgression into native European subspecies

This repository contains two tools that are described in Huml et al 2026 'BEEHYBE v1.0. A new comprehensive toolExtension of current tools  for the accurate measurement of introgression into native European subspecies from all major lineages of A. mellifera’. Please note the scripts and resources provided here are for non-commercial use only and by downloading the corresponding files the user automatically agrees to the licence agreement detailed in license.md provided.

The first tool measures genetic proportions across 6 reference clusters (A-lineage, M-lineage, O-lineage, Y-lineage and A. m. carnica and A. m. ligustica within the C-lineage) using the reference file Refs1261_K6_supervised, this includes 1261 reference individuals, using the run_Admixture_parallel.mpi script.

The second tool is to classify a sample to any of the 11 more subspecies specific clusters (A.m.jemenitica, A.m.intermissa sahariensis, A.m.ruttneri, A.m.lamarckii,	A-lineage_other, A.m.iberiensis, A.m.carnica,	A.m.ligustica, A.m.mellifera,	O-lineage and	A.m.macedonica) using the Refs_K11_unsupervised_classification.vcf.gz reference file and the run_Admixture_parallel_K11_unsupervised.mpi script.

The authors of this paper and GitHub are not affiliated with vcftools, Admixture, Plink or parallel \

Required programs: \
parallel v. 20240822 \
vcftools v. 1.16 \
plink v. 1.9 


## Data Preparation

Data preparation for both tools is the same for both reference panel tools. The difference is in the reference set used and the order of the data.

### Extract Admixture positions from vcf input file

The processes uses vcftools to extract the same positions as the referece panel to be used. Here the `vcf_Input.vcf.gz` is your test samples vcf that you wish to compare to the reference panel, the `PATH_to_Position_File` is the path to the Positions_AIMs.txt file provided. This will output a file so it matches the positions in the reference file.

```
vcftools --gzvcf vcf_Input.vcf.gz --positions PATH_to_Position_File --out vcf_Output_Adm_pos --recode
```

### Reordering the input files

This step reorders the genomic coordinates to match that of the reference set, this is done by sorting and indexing the input file:
```
bgzip vcf_Output_Adm_pos.vcf
vcf-sort vcf_Output_Adm_pos.vcf.gz > vcf_Output_Adm_pos_sort.vcf
bgzip vcf_Output_Adm_pos_sort.vcf
tabix -p vcf vcf_Output_Adm_pos_sort.vcf.gz
```
### Merge with reference set

In the step we will merge your input and reference files using vcftools. Please note that the orde of the Input and Reference fille is important. The pipeline to measure introgression within your samples needs to have the Input data before the Reference Data, like so:
```
vcf-merge vcf_Output_Adm_pos_sort.vcf Path_to_Refs1261_K6_supervised.vcf.gz > vcf_Output_Adm_pos_sort_RefsK6.vcf
```

whilst the pipeline to classify the subpecies of your samples reuires the Reference data set before the Input dataset, like so:

```
vcf-merge Path_to_Refs_K11_unsupervised_classification.vcf.gz vcf_Output_Adm_pos_sort.vcf  > vcf_Output_Adm_pos_sort_RefsK11.vcf
```
### Edit chromosome names

The next step is the change chromosome names to numbers, this is required by Admixture. Tthe file Amel4chrsToNumber.txt can be used in this process:
```
bgzip vcf_Output_Adm_pos_sort_Refs.vcf
tabix -p vcf vcf_Output_Adm_pos_sort_Refs.vcf.gz

bcftools annotate --rename-chrs Path_to_Amel4chrsToNumber.txt  Output_Adm_pos_sort_Refs.vcf.gz -Ov -o Output_Adm_pos_sort_RefsChr.vcf
```
### Convert formats

The data then need to be converted to a format that can be used by Admixture, so we convert to plink format
```
plink --vcf Output_Adm_pos_sort_RefsChr.vcf --make-bed --allow-extra-chr --out Output_Adm_pos_sort_RefsChr --real-ref-alleles
plink --bfile Output_Adm_pos_sort_RefsChr --recode --allow-extra-chr --out Output_Adm_pos_sort_RefsChr
```
place plink files (i.e. .bed,.bim,.fam `Output_Adm_pos_sort_RefsChr` ) in an input folder

## Running the scripts

To run these tools you need your plink formated input files (.bed,.bim,.fam) containing the test samples and the respective reference sample set, and a sample file called SamplesPlink.txt containing the list of test samples inside an input folder.\
The list of test samples (SamplesPlink.txt) needs to provide the ID and the FID (also known as family ID) for each sample in a tab seperated format (tsv), the ID and FID can be the same, for example like this:

```
Sample1  Sample1
Sample2  Sample2
Sample3  Sample3
Sample4  Sample4
Sample5  Sample5
Sample6  Sample6
Sample7  Sample7
```

To run the first tool, which is the 6 reference cluster and 1261 reference individuals, please use the following command, where path `~/Path_to/scripts/` is the path to the folder containing the scripts and the Input folder, the  `number_of_parallel_processes` is the number of cpu processes to use, `input_file_without_extension` is the name of the Input file generated in the data preparation steps outlined abovewithout file extension and `Path_to_admixture` will be the location of your Admixture programe:

```
run_Admixture_parallel.mpi ~/Path_to/scripts/ number_of_parallel_processes input_file_without_extension Path_to_admixture
```
The second tool can be run in a simialr way yet the .mpi script is different and an unsupervised analysis mode is invoked, it is run as follows:
```
run_Admixture_parallel_K11_unsupervised.mpi ~/Path_to/scripts/ number_of_parallel_processes input_file_without_extension Path_to_admixture
```

