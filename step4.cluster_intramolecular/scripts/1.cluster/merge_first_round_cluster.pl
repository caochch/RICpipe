#!/usr/bin/perl
die "perl $0 in.raw.formatted.cluster.bed supercluster_of_cluster.bed cluster_in_supercluster.list\n" if(@ARGV != 3);
my $raw_cluster_bed=shift;
my $supercluster_of_cluster=shift;
my $cluster_in_supercluster=shift;

my %cluster_merged;
open(CIS,$cluster_in_supercluster) || die;
while(my $line=<CIS>){
	chomp $line;
	$cluster_merged{$line}=1;
}

my $final_cluster_id=0;
open(RCB,$raw_cluster_bed) || die;
while(my $line=<RCB>){
	chomp $line;
	my @sub=split/\s+/,$line;
	if($cluster_merged{$sub[6]}){
		next;
	}
	else{
		$final_cluster_id++;
		$sub[6]="FianlCluster_$final_cluster_id";
		my $info=join"\t",($sub[0],$sub[1],$sub[2],$sub[3],$sub[4],$sub[5],$sub[6]);
		print $info,"\t255\t+\t+\n";
	}
}

open(SOC,$supercluster_of_cluster) || die;
while(my $line=<SOC>){
	chomp $line;
	my @sub=split/\s+/,$line;
	$final_cluster_id++;
	$sub[6]="FianlCluster_$final_cluster_id";
	my $info=join"\t",($sub[0],$sub[1],$sub[2],$sub[3],$sub[4],$sub[5],$sub[6]);
	print $info,"\t255\t+\t+\n";
}
	

