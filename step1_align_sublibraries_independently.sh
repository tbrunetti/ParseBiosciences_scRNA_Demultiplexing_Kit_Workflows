#!/bin/bash

#SBATCH --nodes=2 # use two nodes
#SBATCH --time=10:00:00 #10 hours
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)	
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --ntasks=64 # total processes/threads
#SBATCH --job-name=parse_s1
#SBATCH --output=step1_parse_sublibrary_demux_11112023_%J.log
#SBATCH --mem=240G # suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=tonya.brunetti@cuanschutz.edu
#SBATCH --mail-type=END
#SBATCH --error=step1_parse_sublibrary_demux_11112023_%J.err

module load anaconda
conda activate spipe
module load gnu_parallel/20210322

export TMPDIR=/scratch/alpine/brunetti@xsede.org/parse_gex_data_laurent_11072023/genomes/

genomeIndexDir="/path/to/indexed/genomes/"
chemVersion="V2"
outDir="/path/to/analysis/output/"
threads=64
parseSampleSheet="/path/to/expdata/20231017_Parse_Biosciences_Evercode_WT_Mini_Sample_Loading_Table_V1.2.0.xlsm"
fastqDir="/path/to/expdata/fastq/files/"


# generate arguments file to pass to gnuparallel!  Since reading from file use :::: (4 colons) instead of ::: (3 colons to pass an array)
cd ${fastqDir}
ls -1 *R1*.fastq.gz > sublibraries_to_process.txt


# parallelize commands across nodes by first getting list of all available nodes
scontrol show hostname > $SLURM_SUBMIT_DIR/nodelist.txt

# --env PATH exports $PATH to each node -- useful for conda; --sshloginfile reads in the list of nodes
gnuparallel="parallel --joblog step1_parse_sublibrary_demux.log -j 2 --env PATH --sshloginfile ${SLURM_SUBMIT_DIR}/nodelist.txt --wd ${SLURM_SUBMIT_DIR} --delay 0.2"

# must make a new output directory for each subdirectory
cd ${outDir}
while read createDirName;
do
	mkdir ${createDirName}"_outdir";
done < ${fastqDir}/sublibraries_to_process.txt


# NOTE! DO NOT SPECIFY FQ2, because it is already inferred from FQ1 by having the same name but different suffix, so make sure pairs are located in the same directory

${gnuparallel} "split-pipe --mode all --chemistry ${chemVersion} --nthreads ${threads} --fq1 ${fastqDir}{} --output_dir ${outDir}{}"_outdir" --samp_sltab ${parseSampleSheet} --genome_dir ${genomeIndexDir}" :::: ${fastqDir}/sublibraries_to_process.txt
