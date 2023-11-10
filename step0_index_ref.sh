#!/bin/bash

#SBATCH --nodes=1 # use one node
#SBATCH --time=01:00:00 #10 minutes
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)	
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --ntasks=30 # total processes/threads
#SBATCH --job-name=index
#SBATCH --output=parse_hg38_index_11082023_%J.log
#SBATCH --mem=100G # suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=my.address@email.edu
#SBATCH --mail-type=END
#SBATCHt --error=parse_hg38_index_11082023_%J.err

module load/ anaconda
conda activate spipe

fasta="/path/to/genomes/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
gtf="/path/to/genomes/Homo_sapiens.GRCh38.109.gtf.gz"
genomeName="hg38"
outDir="/path/to/genomes/"
threads=30h

export TMPDIR=/path/to/genomes/

echo "Indexing genome for Parse...."

/usr/bin/time split-pipe --mode mkref --genome_name ${genomeName} --fasta ${fasta} --genes ${gtf} --output_dir ${outDir} --nthreads ${threads}
