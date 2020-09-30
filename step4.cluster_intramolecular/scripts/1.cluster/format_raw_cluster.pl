#!/usr/bin/perl
die "perl $0 cluster.bed\n" if(@ARGV != 1);
my $RNAseq_background_cluster_bed=shift;

my $pair_id;
open(RBCB,$RNAseq_background_cluster_bed) || die;
while(my $line=<RBCB>){
	chomp $line;
	my @sub=split/\s+/,$line;
	$pair_id++;
	print $sub[0],"\t",$sub[1],"\t",$sub[2],"\t",$sub[3],"\t",$sub[4],"\t",$sub[5],"\t";
	print "Cluster_$pair_id\t";
	print $sub[6],"\t+\t+\n";
}
	
