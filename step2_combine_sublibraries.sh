#!/bin/bash

#SBATCH --nodes=1 # use two nodes
#SBATCH --time=03:00:00 #3 hours
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)	
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --ntasks=32 # total processes/threads
#SBATCH --job-name=parse_s2
#SBATCH --output=step2_parse_sublibrary_combine_11122023_%J.log
#SBATCH --mem=120G # suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=tonya.brunetti@cuanschutz.edu
#SBATCH --mail-type=END
#SBATCH --error=step2_parse_sublibrary_combine_11122023_%J.err

module load anaconda
conda activate spipe
module load gnu_parallel/20210322

export TMPDIR=/scratch/alpine/brunetti@xsede.org/parse_gex_data_laurent_11072023/genomes/

outDir="/path/to/outdir/analysis/step2_combined_libraries/"
sublibDir="/path/to/location/of/all/sublib/directories/analysis/"
threads=32

# locate all subdiretories
find ${sublibDir} -type d -name "*fastq.gz_outdir" > ${outDir}"sublibraries_to_combine.txt"

/usr/bin/time split-pipe --mode comb --output_dir ${outDir} --sublib_list ${outDir}"sublibraries_to_combine.txt" --nthreads ${threads} 


