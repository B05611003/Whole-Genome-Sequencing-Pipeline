#!/bin/bash
#PBS -q <QueueName>		### queuename
#PBS -P <groupID>		### group name on your nchc website
#PBS -W group_list=<groupID>	### same as above
#PBS -l select=1:ncpus=40	### cpu thread count (qstat -Qf <queue> and find `resources_default.ncpus` to fill)
#PBS -l walltime=8:00:00	### clock time limit after job started
#PBS -M <email>	### eamil setting to follow jobs status
#PBS -m be
#PBS -j oe

JOBDIR="/project/GP1/alex134828/sentieon/Jobs"

cd $JOBDIR

set -euo pipefail

printf "#############################################################################\n"
printf "###                  Work started:   $(date +%Y-%m-%d:%H:%M:%S)                  ###\n"
printf "#############################################################################\n"


# *******************************************
# Script to perform DNA seq variant calling
# using a single sample with fastq files
# named 1.fastq.gz and 2.fastq.gz
# *******************************************

# ******************************************
# 0. Setup
# ******************************************
# Other settings
nt=40 #number of threads to use in computation
workdir=${JOBDIR}/Outputs/${SampleName} #Determine where the output files will be stored

logfile=$workdir/annovar_run.log
set -x
exec 3<&1 4<&2
exec >$logfile 2>&1

cd $workdir

/project/GP1/alex134828/annovar/table_annovar.pl ${SampleName}.output-hc.vcf \
    /project/GP1/alex134828/annovar/humandb \
    -vcfinput \
    -outfile ${SampleName} \
    -buildver hg19 \
    -remove \
    -protocol refGene,knownGene,clinvar_20190305,avsnp150,esp6500siv2_all,1000g2015aug_all,EAS.sites.2015_08,exac03,cg69,kaviar_20150923,gnomad_genome,dbnsfp33a,dbscsnv11,gwava,tfbsConsSites,wgRna,targetScanS \
    -operation g,g,f,f,f,f,f,f,f,f,f,f,f,f,r,r,r \
    -otherinfo \
    -nastring . \
    -thread ${nt}

set +x
exec >&3 2>&4
exec 3<&- 4<&-

printf "#############################################################################\n"
printf "###                  Work completed: $(date +%Y-%m-%d:%H:%M:%S)                  ###\n"
printf "#############################################################################\n"
