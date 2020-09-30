#!/usr/bin/perl
die "perl $0 raw.network\n" if(@ARGV != 1);
my $raw_network=shift;

my $total_observed_links;
open(RW,$raw_network) || die;
while(my $line=<RW>){
	chomp $line;
	my @sub=split/\s+/,$line;
	$total_observed_links+=$sub[12];
}
close RW;

my $fix_num=int(log($total_observed_links)/log(10));
$fix_num++;


print "GeneA\tGeneB\tObserved\tSimulated\n";
open(RW,$raw_network) || die;
while(my $line=<RW>){
	chomp $line;
	my @sub=split/\s+/,$line;	
        my $gene_a=$sub[0]."|".$sub[1]."|".$sub[2]."|".$sub[3]."|".$sub[4]."|".$sub[5];
        my $gene_b=$sub[6]."|".$sub[7]."|".$sub[8]."|".$sub[9]."|".$sub[10]."|".$sub[11];
	print $gene_a,"\t";
	print $gene_b,"\t";
	my $observed_freq=$sub[12]/$total_observed_links;
	my $simulated_freq=$sub[13]/$total_observed_links;

	printf("%.10f\t",$observed_freq);
	printf("%.10f\n",$simulated_freq);
}

