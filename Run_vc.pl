#!/usr/bin/perl
### do not change below except #38-44 and #62
use strict;
use warnings;
use Getopt::Std;
use vars qw($opt_i $opt_s $opt_e);
getopts("i:s:e:");

#print usage message and quit
sub Usage {
print  <<EOF;
Usage: $0 -i ID-File -s Start -e End
    -i ID-File: the File contain Sample ID
    -s Start: From which lines (sample).
    -e End: To which lines (sample).
EOF
exit;
}

if(!$opt_i || !$opt_s || !$opt_e){
  &Usage();
}

# Read FILE
open FH, "<", "$opt_i" or die "$!";
my @idlist;
while(my $line = <FH>){
    chomp $line;
    push (@idlist, $line);
}
close FH;

# Run Jobs
for (my $i = $opt_s-1; $i < $opt_e; $i++ ){
    my $running_job = &countJob();
    #my $running_job = 0 ;
    
    if ($running_job < 15){ #change here to set the maximum amount of job run in the same time if normal version, you need to multiple this number with your thread count
        printf (STDOUT "Sample %s: %s\n", $i+1, $idlist[$i]);
        # change the command below to run variant calling in your systme(same as you type in your terminal)
        ## pbs version:
        #execute("qsub -N run_TBB_VC$idlist[$i] -o <pbs_log name> variant_calling.sh -v SampleName=$idlist[$i]");
        ## normal version:
        execute("./variant_calling.sh $idlist[$i]");

    } else {
        printf (STDOUT "There are already %d running jobs.\nWait 300 seconds until next check.\nWaiting sample: %s\n", $running_job, $idlist[$i]);
        sleep 300;
        redo;
    }
}


sub execute {
    my $cmd = shift;
    print "$cmd\n";
    system($cmd);
}

## 
sub countJob {
    ## normal version:
    my $check_num_cmd = "ps aux | grep variant| wc -l";
    ##PBS version:
    #my $check_num_cmd = "qstat -a | grep run_TBB_VC| wc -l";
    my $jobnum = qx[$check_num_cmd];
    return $jobnum;
}
