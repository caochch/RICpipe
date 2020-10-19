#!/usr/bin/perl
die "perl $0 <comparison.observed_to_simulated.basedOnObserved.finalMerge.xls> <testResultsFromCloseCall>\n" if(@ARGV != 2);
my $raw_network=shift;
my $test_results=shift;

open(RW,$raw_network) || die;
open(TR,$test_results) || die;
<TR>;
while(my $line=<RW>){
	my $test_line=<TR>;
	chomp $line;
	chomp $test_line;
	my @sub=split/\s+/,$line;	
	my @sub_test=split/\s+/,$test_line;
	
	my $new_line=join"\t",@sub[0..14];
	$new_line.="\t".$sub_test[4]."\t".$sub[15];
	print $new_line,"\n";
}

