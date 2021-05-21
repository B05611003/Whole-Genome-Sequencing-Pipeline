#!/bin/bash
#PBS -q <QueueName>		### queuename
#PBS -P <groupID>		### group name on your nchc website
#PBS -W group_list=<groupID>	### same as above
#PBS -l select=1:ncpus=40	### cpu thread count (qstat -Qf <queue> and find `resources_default.ncpus` to fill)
#PBS -l walltime=<hh:mm:ss>	### clock time limit after job started
#PBS -M <email>	### eamil setting to follow jobs status
#PBS -m be
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

output_name="<output file name>" # Your file name
# Update with the location of the reference data files
ref_dir="<fullpath of reference data foler>"
### do not change below
fasta="${ref_dir}/ucsc.hg19.fasta"
###

# Update with the location of the gvcf data files
gvcf_id_list="<fullpath of text file includes all gvcf sample name>"      # Sample ID list that includes all gvcf sample name
gvcf_dir="<fullpath of directory includes all gvcf file>"                 # Directory that includes all gvcf sample
GIAB_id_list="<fullpath of text file includes all GIAB gvcf sample name>" # (optional) Sample ID list that includes all GIAB gvcf sample name
GIAB_dir="<fullpath of directory includes GIAB gvcf file>"                # (optional) Directory that includes all GIAB gvcf sample
# Other settings
nt="<thread count>"                           #number of threads to use in computation
workdir="<fullpath of your output directory>" #Determine where the output files will be stored
logfile="${workdir}/<logfile name>"
GIAB_include="<yes/no>" #yes if you with to combine GIAB gloden standard with your datasets
## setting done, generally you don't need to change anything below except you wish to change which files to kill at #303

mkdir -p $workdir

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
	while read line; do
		all_gvcf="$all_gvcf ${GIAB_dir}/${line}"
	done <${GIAB_id_list}
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
