#!/usr/bin/perl
die "Remove PCR duplicates for single-end sequencing by collapsing reads with identical sequence\n\nUsage: two parameters are required\nperl $0 <Input file name: read1.fq> <Output file name: read1.rmDup.fq>\n" if(@ARGV != 2);
my $read1_fq=shift;
my $read1_rmDup_fq=shift;


my %unique;
open(RA,$read1_fq) || die;
open(OA,">$read1_rmDup_fq") || die;

while(my $id_a=<RA>){
	my $seq_a=<RA>;
	my $symbol_a=<RA>;
	my $qual_a=<RA>;
	
	my $whole_reads=$seq_a;
	if($unique{$whole_reads}){
		next;
	}
	else{
		print OA $id_a,$seq_a,$symbol_a,$qual_a;
		$unique{$whole_reads}=1;
	}
}
close OA;
