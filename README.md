# Whole Genome Sequencing Pipeline using GATK Best Practice
## Introduction
In this repo, some easy-start up pipeline scripts are given to execute germline Whole Genome Sequencing analysis according to [**GATK Best Practice Workflow**](https://gatk.broadinstitute.org/hc/en-us/sections/360007226651-Best-Practices-Workflows). Here we use an accelerated tool [**Sentieon**](https://www.sentieon.com/products/) that imporved the efficiency to replace java -version GATK, and [**bcftools**](http://samtools.github.io/bcftools/bcftools.html) to help vcf normalization. Furthermore, we use [**ANNOVAR**](https://annovar.openbioinformatics.org/en/latest/) as an annotation tool to annotate variants with global database.
## Scripts
* Run_vc.pl : Run a large cohort single sample variant calling (Variant_calling.sh) with one command.
* Variant_calling.sh : Read Fastq raw data and output vcf format file.
* VQSR<area>.sh : Running [**Variant Quality Score Recalibration**](https://gatk.broadinstitute.org/hc/en-us/articles/360035531612-Variant-Quality-Score-Recalibration-VQSR-) of a vcf file.
* Normailzation<area>.sh : Decompose and normalizeation of a vcf file.
* Joint_calling.sh : Running [**Joint calling**](https://gatk.broadinstitute.org/hc/en-us/articles/360035890431-The-logic-of-joint-calling-for-germline-short-variants) using gvcf of a large cohort.
* Annovar<area>.sh : Running variant annotation in single vcf file. 
## Usage

To run on PBS system server:

```bash
#running single shellscript using queue
qsub -N <jobname> -o <qsub_logfile_name> job.sh
# single sample WGS to run large cohort
perl run_job.pl -i <id_list> -s <start_line> -e <end_line>
## -s and -e is the line number of -i file starts with 1
```

To run on normal linux environment:

```bash
screen -S <your_screen_name>  # create a screen to run job in background
cd <your_pipeline_dir>
./<yourjob.sh> # add sample name when running Variant_calling.sh./Variant_calling.sh <SampleName>
# press ctrl+"a"+"d" to detatch screen
# `screen -ls` to list all screen
# `screen -r <your_screen_name>` to return to the screen
```

## Common script explanation

### PBS header
* The header is used for PBS system, if you run the script in normal linux system, you can ignore them~~
```bash
#PBS -q <QueueName>		### queuename
#PBS -P <groupID>		### group name on your nchc website
#PBS -W group_list=<groupID>	### same as above
#PBS -l select=1:ncpus=40	### cpu thread count (qstat -Qf <queue> and find `resources_default.ncpus` to fill)
#PBS -l walltime=8:00:00	### clock time limit after job started
#PBS -M <email>	### email setting to follow job status
#PBS -m be
#PBS -j oe
```

### Logfile

* PBS will output the log "after" all job exit as default, so you need to redirect your logfile to "runtime" runlog.
* Same as normal linux system. You can check your log whenever you want without scrolling your screen in backgroud Screen lol. 

```bash
#pipe your log output to run.log
logfile="${workdir}/<logfile name>"
set -x
exec 3<&1 4<&2
exec >$logfile 2>&1

######################
### your code here ###
######################

#pipe back to queue log
set +x
exec >&3 2>&4
exec 3<&- 4<&-
```
