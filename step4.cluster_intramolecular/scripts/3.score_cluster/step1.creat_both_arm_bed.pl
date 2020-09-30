#!/usr/bin/perl
die "perl $0 count_fragment.filtered.cluster fragment_num_cutoff outprefix\n" if(@ARGV != 3);
my $in_clsuter_bedpair=shift;
my $fragment_num_cutoff=shift;
my $cell_name=shift;

open(IN,$in_clsuter_bedpair) || die;
open(OUTL,">$cell_name.left.arm.bed") || die;
open(OUTR,">$cell_name.right.arm.bed") || die;
while(my $line=<IN>){
	chomp $line;
	my @sub=split/\s+/,$line;
	if($sub[8] >= $fragment_num_cutoff){
		print OUTL $sub[0],"\t",$sub[1],"\t",$sub[2],"\t",$sub[6],"\t",$sub[7],"\t",$sub[8],"\n";
		print OUTR $sub[3],"\t",$sub[4],"\t",$sub[5],"\t",$sub[6],"\t",$sub[7],"\t",$sub[8],"\n";
	}
}
	
close OUTL;
close OUTR;


