#!/bin/bash
#PBS -q <QueueName>		### queuename
#PBS -P <groupID>		### group name on your nchc website
#PBS -W group_list=<groupID>	### same as above
#PBS -l select=1:ncpus=40	### cpu thread count (qstat -Qf <queue> and find `resources_default.ncpus` to fill)
#PBS -l walltime=<hh:mm:ss>	### clock time limit after job started
#PBS -M <email>	### email setting to follow job status
#PBS -m be
#PBS -j oe

set -euo pipefail

printf "#############################################################################\n"
printf "###                  Work started:   $(date +%Y-%m-%d:%H:%M:%S)           ###\n"
printf "#############################################################################\n"

# *******************************************
# VCF variant annotation tools using ANNOVAR
# *******************************************

# ******************************************
# 0. Setup
# ******************************************
# Update with your location of the annovar package
annovar_dir="<your annovar package directory>"

# Update with the location of the annovar data base
humandb_dir="<your annovar humandb directory>" #check https://annovar.openbioinformatics.org/en/latest/user-guide/download/# for more detail of humandb

# Update the input output file name
InputFileName="<input vcf name>"
OutputFileName="<output vcf name>"

# Update with your annotation parameter-protocols(databases),operation(databases type)
protocols="<your databases name saperated with ','>" # all the available propocols are listed in https://annovar.openbioinformatics.org/en/latest/user-guide/download/  eg."refGene,knownGene,clinvar_20190305,avsnp150"
operation="<your databases type saperated with ','>" #same order as protocols. You can find type in same link above.

# Other settings
nt="<thread count>"                           #number of threads to use in computation
workdir="<fullpath of your output directory>" #Determine where the output files will be stored
logfile="${workdir}/<logfile name>"

mkdir -p $workdir
set -x
exec 3<&1 4<&2
exec >$logfile 2>&1

cd $workdir

## setting done, generally you don't need to change anything below

# ******************************************
# 1. Annotation starts
# ******************************************
${annovar_dir}/table_annovar.pl ${InputFileName} \
${humandb_dir} \
-vcfinput \
-outfile ${output_name} \
-buildver hg19 \
-remove \
-protocol ${protocols} \
-operation ${operation} \
-otherinfo \
-nastring . \
-thread ${nt}

set +x
exec >&3 2>&4
exec 3<&- 4<&-

printf "#############################################################################\n"
printf "###                  Work completed: $(date +%Y-%m-%d:%H:%M:%S)           ###\n"
printf "#############################################################################\n"