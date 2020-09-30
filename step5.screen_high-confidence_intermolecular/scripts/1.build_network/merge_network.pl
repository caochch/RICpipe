#!/usr/bin/perl
die "perl $0 rep1.netowkr rep2.network\n" if(@ARGV != 2);
my $rep1_network=shift;
my $rep2_network=shift;

my %all_gene_pair;
my %network_rep1;
open(RNA,$rep1_network) || die;
while(my $line=<RNA>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $gene_a=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
	my $gene_b=$sub[6]."\t".$sub[7]."\t".$sub[8]."\t".$sub[9]."\t".$sub[10]."\t".$sub[11];
	my $num=$sub[12];
	my @pair=($gene_a,$gene_b);
	@pair=sort @pair;
	$network_rep1{$pair[0]."\t".$pair[1]}=$num;
	$all_gene_pair{$pair[0]."\t".$pair[1]}=1;
}

my %network_rep2;
open(RNB,$rep2_network) || die;
while(my $line=<RNB>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $gene_a=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
	my $gene_b=$sub[6]."\t".$sub[7]."\t".$sub[8]."\t".$sub[9]."\t".$sub[10]."\t".$sub[11];
	my $num=$sub[12];
	my @pair=($gene_a,$gene_b);
	@pair=sort @pair;
	$network_rep2{$pair[0]."\t".$pair[1]}=$num;
	$all_gene_pair{$pair[0]."\t".$pair[1]}=1;
}

foreach (keys %all_gene_pair){
	print $_,"\t",$network_rep1{$_}+$network_rep2{$_},"\n";
}
