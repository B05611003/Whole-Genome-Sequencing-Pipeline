#!/bin/bash
#PBS -q <QueueName>		### queuename
#PBS -P <groupID>		### group name on your nchc website
#PBS -W group_list=<groupID>	### same as above
#PBS -l select=1:ncpus=40	### cpu thread count (qstat -Qf <queue> and find `resources_default.ncpus` to fill)
#PBS -l walltime=8:00:00	### clock time limit after job started
#PBS -M <email>	### eamil setting to follow jobs status
#PBS -m be
#PBS -j oe

set -euo pipefail

printf "#############################################################################\n"
printf "###                  Work started:   $(date +%Y-%m-%d:%H:%M:%S)                  ###\n"
printf "#############################################################################\n"

ref_dir="/home/alex134828/sentieon/Reference/ref_hg19"
fasta="${ref_dir}/ucsc.hg19.fasta"
bcftools_dir="/home/alex134828/bin/bcftools"

SampleName="TBB_1496_with_GIAB_joing_calling.vcf.gz"
SampleFile="TBB_1496_with_GIAB_joing_calling.vcf.gz.SNP_INDEL.recaled.vcf.gz"

# ******************************************
# 0. Setup
# ******************************************

#DIR setting

WORKDIR="/project/GP1/alex134828/WGS_DATA/JointCalling" #Determine where the output files will be stored
cd ${WORKDIR}
# Other settings
nt=40 #number of threads to use in computation
#WORKDIR=${JOBDIR}/Outputs/1497VCF #Determine where the output files will be stored
#SRCDIR=${JOBDIR}/Outputs/${SampleName}
#cd ${WORKDIR}/log

set -x
exec 3<&1 4<&2
exec > dn_run.log 2>&1

${bcftools_dir}/bin/bcftools norm \
        --multiallelics -both \
        --fasta-ref ${fasta} \
        --output-type z \
        --output ${SampleName}.decomposed.normalized.vcf.gz \
        --threads ${nt} \
		${SampleFile}

#${JOBDIR}/bcftools/bcftools norm -f ${fasta} -t ${nt} -m -both -o ${SampleName}.norm.vcf ${SampleName}.output-hc.vcf

set +x
exec >&3 2>&4
exec 3<&- 4<&-

printf "#############################################################################\n"
printf "###                  Work completed: $(date +%Y-%m-%d:%H:%M:%S)                  ###\n"
printf "#############################################################################\n"
