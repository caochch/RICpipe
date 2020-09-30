#!/usr/bin/perl
die "perl $0 arm_overlap_reads.list\n" if(@ARGV != 1);
my $arm_over_tags=shift;

my %count_for_arm;
open(AOT,$arm_over_tags) || die;
while(my $line=<AOT>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $arm=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
	$count_for_arm{$arm}{$sub[9]}=1;

}

foreach (keys %count_for_arm){
	my @tags=keys %{$count_for_arm{$_}};
	print $_,"\t",$#tags+1,"\n";
}
	
