#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use vars qw($opt_i $opt_s $opt_e);
getopts("i:s:e:");

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
    if ($running_job < 15){
        printf (STDOUT "Sample %s: %s\n", $i+1, $idlist[$i]);
        execute("qsub -N run_TBB_VC$idlist[$i] -o /project/GP1/alex134828/sentieon/Jobs/pbs_logs/logs.variant_calling variant_calling.sh -v SampleName=$idlist[$i]");

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

sub countJob {
    my $check_num_cmd = "qstat -a | grep run_TBB_VC| wc -l";
    my $jobnum = qx[$check_num_cmd];
    return $jobnum;
}
