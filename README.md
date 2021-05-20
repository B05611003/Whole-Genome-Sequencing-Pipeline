# Whole Genome Sequencing Pipeline using GATK Best Practice
## Introduction
In this repo, some easy-start up pipeline scripts are given to execute germline Whole Genome Sequencing analysis according to [**GATK Best Practice Workflow**](https://gatk.broadinstitute.org/hc/en-us/sections/360007226651-Best-Practices-Workflows). Here we use an accelerated tool [**Sentieon**](https://www.sentieon.com/products/) to imporve the efficiency.
## Scripts
* Run_vc.pl : 
* Variant_calling.sh :
* VQSR<area>.sh :
* Normailzation<area>.sh :
* Joint_calling.sh :
* Annovar<area>.sh :
## Usage

To run on NCHC server:

```bash
#running single shellscript using queue
qsub -N <jobname> -o <qsub_logfile_name> job.sh
# single sample WGS to run large cohort
perl run_job.pl -i <id_list> -s <start_line> -e\ <end_line>
## -s and -e is the line number of -i file starts with 1
```

To run on Lab server:

```bash
screen -S <your_screen_name>  # create a screen to run job in background
cd <your_pipeline_dir>
bash job.sh
# press ctrl+"a"+"d" to detatch screen
# `screen -ls` to list all screen
# `screen -r <your_screen_name>` to return to the screen
```

## Common part

### PBS header

```bash
#PBS -q ngs192G		### queuename
#PBS -P MST108173		### group name on your nchc website
#PBS -W group_list=MST108173	### same as above
#PBS -l select=1:ncpus=40	### cpu thread count (qstat -Qf <queue> and find `resources_default.ncpus` to fill)
#PBS -l walltime=8:00:00	### clock time limit after job started
#PBS -M hsnu134828@gmail.com	### eamil setting to follow jobs status
#PBS -m be
#PBS -j oe
```

### Logfile

qsub defalut will output the log "after" all job exit, so you need to redirect your logfile to "runtime" runlog.

```bash
#pipe your log output to run.log
logfile=$workdir/run.log
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
