# Step 1 (SRR2175645): Download Metagenome Data from SRA
# Install SRA Toolkit
sudo apt update && sudo apt install sra-toolkit

# Verify installation
fastq-dump --version

# Download data from SRA (replace SRR2175645 with actual ID)
prefetch SRR2175645

# Convert SRA file to FASTQ
fastq-dump --split-files SRR2175645

# Step 2 (SRR2175645): Preprocessing - Trimming Reads
# (Assuming Trim Galore is installed for quality trimming)
trimmomatic PE -phred33 SRR2175645_1.fastq SRR2175645_2.fastq SRR2175645_R1_paired.fastq SRR2175645_R1_unpaired.fastq SRR2175645_R2_paired.fastq SRR2175645_R2_unpaired.fastq ILLUMINACLIP:/usr/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# Step 3 (SRR2175645): Host Decontamination
## Install necessary tools
sudo apt install bowtie2
sudo apt install samtools

## Verify installations
bowtie2 --version
samtools --version

## Build Bowtie2 Index for the Human Reference Genome
bowtie2-build /mnt/c/micro/hg38/hg38.fa /mnt/c/micro/hg38/hg38_index

## Align Paired Reads to the Host Genome
bowtie2 -x /mnt/c/micro/hg38/hg38_index -1 /mnt/c/micro/trimming/SRR2175645_R1_paired.fastq -2 /mnt/c/micro/trimming/SRR2175645_R2_paired.fastq -S /mnt/c/micro/host_decontamination/host_mapped.sam

## Extract Non-Host Reads
samtools view -b -f 12 -F 256 /mnt/c/micro/host_decontamination/host_mapped.sam > /mnt/c/micro/host_decontamination/host_unmapped.bam

## Convert BAM to FASTQ
samtools fastq /mnt/c/micro/host_decontamination/host_unmapped.bam -1 /mnt/c/micro/host_decontamination/SRR2175645_non_host_R1.fastq -2 /mnt/c/micro/host_decontamination/SRR2175645_non_host_R2.fastq

# Step 4 (SRR2175645): Taxonomic Profiling using Kraken2
## Download and Extract Minikraken2 Database
wget https://genome-idx.s3.amazonaws.com/kraken/minikraken2_v2_8GB_201904.tgz -O /mnt/d/nama_gokul/minikraken2.tgz
tar -xvzf /mnt/d/nama_gokul/minikraken2.tgz -C /mnt/d/nama_gokul/

## Classify Reads Using Kraken2
kraken2 --db /mnt/d/nama_gokul/minikraken2_v2_8GB --paired /mnt/c/micro/host_decontamination/SRR2175645_non_host_R1.fastq /mnt/c/micro/host_decontamination/SRR2175645_non_host_R2.fastq --report /mnt/d/nama_gokul/kraken2_report.txt --output /mnt/d/nama_gokul/kraken2_output.txt

## (Optional) Refine Species-Level Abundances with Bracken
bracken -d /mnt/d/nama_gokul/minikraken2_v2_8GB -i /mnt/d/nama_gokul/kraken2_report.txt -o /mnt/d/nama_gokul/bracken_report.txt -r 150 -l S

# Step 5 (SRR2175645): Functional Profiling with MetaPhlAn
## Install MetaPhlAn
conda install -c bioconda -c conda-forge metaphlan

## Install MetaPhlAn Database
metaphlan --install --index mpa_vJun23_CHOCOPhlAnSGB_202403 --bowtie2db /mnt/c/micro/metaphlan_db
tar -xvf /mnt/c/micro/metaphlan_db/mpa_vJun23_CHOCOPhlAnSGB_202403_bt2.tar -C /mnt/c/micro/metaphlan_db/

## Verify MetaPhlAn Installation
metaphlan --version

# Step 6 (SRR2175645): Functional Analysis with HUMAnN3
humann --input /mnt/c/micro/host_decontamination/SRR2175645_non_host_R1.fastq \
        --input /mnt/c/micro/host_decontamination/SRR2175645_non_host_R2.fastq \
        --output /mnt/c/micro/humann3_output \
        --threads 4 \
        --nucleotide-database /mnt/c/micro/humann3_db/chocophlan \
        --protein-database /mnt/c/micro/humann3_db/uniref
