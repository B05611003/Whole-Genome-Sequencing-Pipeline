#!/bin/bash
#PBS -q ngs384G
#PBS -P MST109178
#PBS -W group_list=MST109178
#PBS -N joint_calling
#PBS -l select=1:ncpus=40
#PBS -M hsnu134828@gmail.com
#PBS -m b
#PBS -m e
#PBS -j oe

set -euo pipefail

printf "#############################################################################\n"
printf "###                  Work started:   $(date +%Y-%m-%d:%H:%M:%S)           ###\n"
printf "#############################################################################\n"

# *******************************************
# Script to perform cohort joing calling
# using a single sample gvcf files
# *******************************************

# Update with the location of the Sentieon software package and license file
export SENTIEON_LICENSE=#your sentieon license
release_dir=/project/GP1/alex134828/sentieon/bins/sentieon-genomics-201808 #sentieon package directory

# ******************************************
# 0. Setup
# ******************************************

output_name="TBB_1496_with_GIAB_joing_calling.vcf.gz"         # Your file name
ref_dir="/project/GP1/alex134828/sentieon/Reference/ref_hg19" # Directory of FASTA reference file
fasta="${ref_dir}/ucsc.hg19.fasta"
gvcf_id_list="/project/GP1/alex134828/WGS_DATA/ID_list/list.txt" # Sample ID list that includes all gvcf sample
gvcf_dir="/project/GP1/alex134828/WGS_DATA/GVCF"                 # Directory that includes all gvcf sample

nt=40                                                   # Number of threads to use in computation
workdir="/project/GP1/alex134828/WGS_DATA/JointCalling" # Determine where the output files will be stored
GIAB_include="no"

mkdir -p $workdir
logfile=$workdir/run.log
set -x
exec 3<&1 4<&2
exec >$logfile 2>&1

cd $workdir
# ******************************************
# 1. Reading gvcf file
# ******************************************

# gvcf
all_gvcf=""

while read line; do
	all_gvcf="${all_gvcf} ${gvcf_dir}/${line}.output-hc.g.vcf.gz"
done <$gvcf_id_list
echo "insert gvcf done"

#batch_GIAB
if [ ${GIAB_include} = "yes" ]; then
	list_ID="/project/GP1/alex134828/sentieon/Jobs/ID_list/list_GIAB.txt"
	while read line; do
		all_gvcf="$all_gvcf ${line}"
	done <$list_ID
	echo "insert GIAB done"
fi

# ******************************************
# 2. Joing calling start
# ******************************************

${release_dir}/bin/sentieon driver \
	-r ${fasta} \
	-t ${nt} \
	--algo GVCFtyper ${output_name} ${all_gvcf}
# --emit_mode confident

set +x
exec >&3 2>&4
exec 3<&- 4<&-

printf "#############################################################################\n"
printf "###                  Work completed: $(date +%Y-%m-%d:%H:%M:%S)           ###\n"
printf "#############################################################################\n"
