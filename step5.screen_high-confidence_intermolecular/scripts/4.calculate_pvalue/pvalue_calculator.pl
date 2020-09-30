#!/usr/bin/perl 
die "perl $0 <Input.gene-gene.network> <simulated_count.list> <tmp.outprefix>\n" if(@ARGV != 3);
my $observed_network=shift;
my $simulated_contacts=shift;
my $outprefix=shift;

open(OUT,">comparison.observed_to_simulated.$outprefix.xls") || die;
open(ON,$observed_network) || die;
open(SC,$simulated_contacts) || die;
while(my $line=<ON>){
	my $simu_line=<SC>;
	chomp $line;
	chomp $simu_line;
	print OUT $line,"\t";
	my @sub=split/\s+/,$line;
	my @array=split/\s+/,$simu_line;
	my $avg;
	my $pvalue;
	foreach (@array){
		$avg+=$_;
		if($_ >= $sub[-1]){
			$pvalue++;
		}
	}
	$avg=$avg/@array;
	$pvalue=$pvalue/@array;
	print OUT $avg,"\t",$pvalue,"\t",$#array+1,"\n";
}
	
	
