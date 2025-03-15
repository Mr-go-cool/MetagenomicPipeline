# MetagenomicPipeline
A pipeline for processing metagenomic FASTQ sequences to determine microbiome taxonomy and functional pathways using computational tools. This workflow enables efficient taxonomic classification and functional profiling of microbiomes from raw sequencing data.

## Description for GitHub  

1. **Step 1: Download Metagenome Data**  
   - Install SRA Toolkit and download raw sequencing data from SRA (e.g., SRR2175645).  
   - Convert SRA files to FASTQ format.  

2. **Step 2: Preprocessing - Trimming Reads**  
   - Use Trimmomatic to remove low-quality bases and adapter sequences from paired-end reads.  

3. **Step 3: Host Decontamination**  
   - Use Bowtie2 to align reads to the human reference genome (hg38).  
   - Extract non-host reads using Samtools.  

4. **Step 4: Taxonomic Profiling**  
   - Use Kraken2 with the Minikraken2 database to classify microbial reads.  
   - (Optional) Use Bracken to refine species-level abundances.  

5. **Step 5: Functional Profiling**  
   - Use MetaPhlAn to analyze microbial community composition.  

6. **Step 6: Functional Analysis with HUMAnN3**  
   - Run HUMAnN3 to reconstruct microbial metabolic pathways and functional profiles.
