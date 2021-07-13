# RICpipe

Softwares required for RIC-seq analysis

Download and install STAR (v.020201) for short reads mapping from:

https://github.com/alexdobin/STAR

Download and install SAMtools (v.0.1.19) from:

https://github.com/samtools/samtools

Download and install BEDtools (v2.28.0) from:

https://github.com/arq5x/bedtools2

Download and install FastQC for quality control of sequencing reads from:

https://www.bioinformatics.babraham.ac.uk/projects/fastqc

Download and install Trimmomatic (v.0.36) for trimming adapter from:

http://www.usadellab.org/cms/?page=trimmomatic

Download and install cutadapt (v.1.15) for cropping low-complexity fragments from:

https://cutadapt.readthedocs.io/en/stable

To extract pairwise splicing site from gtf files:
#step1: perl gtf_to_bed.pl gencode.v19.annotation.gtf > gencode.v19.annotation.bed
#step2: perl creat_junction_bed.pl gencode.v19.annotation.bed > gencode.v19.all_exon_junction.bed
This is an example bash to obtain pairwise splicing sites from genocode.v19 annotation files.  These two perl scripts are also uploaded to the scripts folder.

Important:

Add these programs to the PATH environment variable.


