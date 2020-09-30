#!/usr/bin/perl
die "perl $0 cluster.withScore.bed connection_score_cutoff\n" if(@ARGV != 2);
my $cluster_with_score=shift;
my $score_cutoff=shift;

my %cluster;
open(CWS,$cluster_with_score) || die;
while(my $line=<CWS>){
	chomp $line;
	my @sub=split/\s+/,$line;
	if($sub[-1] >= $score_cutoff){
		my $cluster_turn=(split/_/,$sub[6])[1];
		$cluster{$cluster_turn}=$line;
	}
}


print "Chr_LeftArm\tLeftArm_start\tLeftArm_end\tChr_RightArm\tRightArm_start\tRightArm_end\n";
print "Cluster_ID\tNumberOfChimericReads\tNumberOfChimericFragments\tReadsInLeftArm\tReadsInRightArm\tConnectionScore\n";

foreach my $i (sort {$a<=>$b} keys %cluster){
	print $cluster{$i},"\n";
}

sleep(10);
`rm -rf $cluster_with_score`;
	

