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
# Script to perform Variant Quality Score
# Recalibration using a single sample
# vcf file.
# *******************************************

# ******************************************
# 0. Setup
# ******************************************
#define where your vcf input
vcf="<vcf input file name>"
SampleName="<output sample name>" # sample name = ${vcf} without subfile name (.vcf.gz)

# Update with the location of the reference data files
ref_dir="<fullpath of reference data foler>"
### do not change below
fasta="${ref_dir}/ucsc.hg19.fasta"

# Update with the location of the resource files for VQSR
vqsr_Mill="${ref_dir}/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf"
vqsr_1000G_omni="${ref_dir}/1000G_omni2.5.hg19.sites.vcf"
vqsr_hapmap="${ref_dir}/hapmap_3.3.hg19.sites.vcf"
vqsr_1000G_phase1="${ref_dir}/1000G_phase1.snps.high_confidence.hg19.sites.vcf"
vqsr_1000G_phase1_indel="${ref_dir}/1000G_phase1.indels.hg19.sites.vcf"
vqsr_dbsnp="${ref_dir}/dbsnp_138.hg19.vcf"
###

# Update with the location of the Sentieon software package and license file (bcftools is optional for vcf normalization)
export SENTIEON_LICENSE="<your sentieon license IP>"
release_dir="<full path of your sentieon package>"

# Other settings
nt="<thread count>"                           #number of threads to use in computation
workdir="<fullpath of your output directory>" #Determine where the output files will be stored
logfile="${workdir}/<logfile name>"
sensitivity="<int>" # numbers of VQSR sensitivity you wish to run

## setting done, generally you don't need to change anything below

mkdir -p $workdir

set -x
exec 3<&1 4<&2
exec >$logfile 2>&1

cd $workdir
# ******************************************
# 1. VQSR for SNP
# ******************************************
#create the resource argument
resource_text="--resource $vqsr_1000G_phase1 --resource_param 1000G,known=false,training=true,truth=false,prior=10.0 "
resource_text="$resource_text --resource $vqsr_1000G_omni --resource_param omni,known=false,training=true,truth=true,prior=12.0 "
resource_text="$resource_text --resource $vqsr_dbsnp --resource_param dbsnp,known=true,training=false,truth=false,prior=2.0 "
resource_text="$resource_text --resource $vqsr_hapmap --resource_param hapmap,known=false,training=true,truth=true,prior=15.0"

#create the annotation argument
annotation_array="QD MQ MQRankSum ReadPosRankSum FS"

#Initial annotate_text variable
annotate_text=""
for annotation in $annotation_array; do
	annotate_text="$annotate_text --annotation $annotation"
done

#Run the VQSR
tranches="--tranche 100.0 --tranche 99.9 --tranche 99.8 --tranche 99.7 --tranche 99.6 --tranche 99.5 --tranche 99.4 --tranche 99.3 --tranche 99.2 --tranche 99.1 --tranche 99.0 --tranche 98.0 --tranche 97.0 --tranche 96.0 --tranche 95.0 --tranche 94.0 --tranche 93.0 --tranche 92.0 --tranche 91.0 --tranche 90.0"
$release_dir/bin/sentieon driver \
-r $fasta \
-t $nt \
--algo VarCal \
-v ${vcf} $resource_text $annotate_text \
--var_type SNP \
--plot_file ${SampleName}.SNP.plot_file.txt \
--max_gaussians 8 \
--srand 47382911 \
--tranches_file ${SampleName}.SNP.tranches ${SampleName}.SNP.recal $tranches

#apply the VQSR
$release_dir/bin/sentieon driver \
-r $fasta \
-t $nt \
--algo ApplyVarCal \
-v ${vcf} \
--var_type SNP \
--recal ${SampleName}.SNP.recal \
--tranches_file ${SampleName}.SNP.tranches \
--sensitivity ${sensitivity} ${SampleName}.SNP.recaled.vcf.gz

#plot the report
$release_dir/bin/sentieon plot vqsr \
-o ${SampleName}.TBB_train_vqsr_SNP.VQSR.pdf ${SampleName}.SNP.plot_file.txt

# ******************************************
# 1. VQSR for indels after SNPs
# ******************************************
#create the resource argument
resource_text="--resource $vqsr_1000G_phase1_indel --resource_param 1000G,known=false,training=true,truth=false,prior=10.0 "
resource_text="$resource_text --resource $vqsr_Mill --resource_param Mills,known=false,training=true,truth=true,prior=12.0 "
resource_text="$resource_text --resource $vqsr_dbsnp --resource_param dbsnp,known=true,training=false,truth=false,prior=2.0 "

#create the annotation argument
annotation_array="QD ReadPosRankSum FS"
annotate_text=""
for annotation in $annotation_array; do
	annotate_text="$annotate_text --annotation $annotation"
done

#Run the VQSR
tranches="--tranche 100.0 --tranche 99.9 --tranche 99.8 --tranche 99.7 --tranche 99.6 --tranche 99.5 --tranche 99.4 --tranche 99.3 --tranche 99.2 --tranche 99.1 --tranche 99.0 --tranche 98.0 --tranche 97.0 --tranche 96.0 --tranche 95.0 --tranche 94.0 --tranche 93.0 --tranche 92.0 --tranche 91.0 --tranche 90.0"
$release_dir/bin/sentieon driver \
-r $fasta \
-t $nt \
--algo VarCal \
-v ${SampleName}.SNP.recaled.vcf.gz $resource_text $annotate_text \
--var_type INDEL \
--plot_file ${SampleName}.SNP_INDEL.plot_file.txt \
--max_gaussians 4 \
--srand 47382911 \
--tranches_file ${SampleName}.SNP_INDEL.tranches ${SampleName}.SNP_INDEL.recal $tranches

#apply the VQSR
$release_dir/bin/sentieon driver \
-r $fasta \
-t $nt \
--algo ApplyVarCal \
-v ${SampleName}.SNP.recaled.vcf.gz \
--var_type INDEL \
--recal ${SampleName}.SNP_INDEL.recal \
--tranches_file ${SampleName}.SNP_INDEL.tranches \
--sensitivity ${sensitivity} ${SampleName}.SNP_INDEL.recaled.vcf.gz

#plot the report
$release_dir/bin/sentieon plot vqsr \
-o ${SampleName}.TBB_train_vqsr_SNP_INDEL.VQSR.pdf ${SampleName}.SNP_INDEL.plot_file.txt

set +x
exec >&3 2>&4
exec 3<&- 4<&-

printf "#############################################################################\n"
printf "###                  Work completed: $(date +%Y-%m-%d:%H:%M:%S)           ###\n"
printf "#############################################################################\n"
