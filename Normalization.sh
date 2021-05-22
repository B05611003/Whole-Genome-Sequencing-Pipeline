#!/bin/bash
#PBS -q <QueueName>		### queuename
#PBS -P <groupID>		### group name on your nchc website
#PBS -W group_list=<groupID>	### same as above
#PBS -l select=1:ncpus=40	### cpu thread count (qstat -Qf <queue> and find `resources_default.ncpus` to fill)
#PBS -l walltime=8:00:00	### clock time limit after job started
#PBS -M <email>	### email setting to follow job status
#PBS -m be
#PBS -j oe

set -euo pipefail

printf "#############################################################################\n"
printf "###                  Work started:   $(date +%Y-%m-%d:%H:%M:%S)           ###\n"
printf "#############################################################################\n"

# *******************************************
# Script to perform VCF normalization and
# decompose using a single vcf file as an input.
# *******************************************

# ******************************************
# 0. Setup
# ******************************************

# Update with the location of the reference data files
ref_dir="<fullpath of reference data folder>"
### do not change below
fasta="${ref_dir}/ucsc.hg19.fasta"
###

# Update with the location of the bcftools package
bcftools_dir="<full path of your bcftools >"
# Update the input vcf name 
InputFileName="<Input file name without \".vcf.gz\">"

# Other settings
nt="<thread count>"                           #number of threads to use in computation
workdir="<fullpath of your output directory>" #Determine where the output files will be stored
logfile="${workdir}/<logfile name>"

## setting done, generally you don't need to change anything below

mkdir -p $workdir

set -x
exec 3<&1 4<&2
exec >$logfile 2>&1

cd $workdir

# ******************************************
# 1. Decompose and Normalization start
# ******************************************

${bcftools_dir}/bin/bcftools norm \
--multiallelics -both \
--fasta-ref ${fasta} \
--output-type z \
--output ${InputFileName}.decomposed.normalized.vcf.gz \
--threads ${nt} \
${InputFileName}.vcf.gz

set +x
exec >&3 2>&4
exec 3<&- 4<&-

printf "#############################################################################\n"
printf "###                  Work completed: $(date +%Y-%m-%d:%H:%M:%S)                  ###\n"
printf "#############################################################################\n"
