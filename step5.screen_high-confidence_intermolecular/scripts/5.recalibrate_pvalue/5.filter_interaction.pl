#!/usr/bin/perl
die "perl $0 <Table_of_Gene-Gene_network> <local-background-corrected_Pvalue_cutoff>\n" if(@ARGV != 2);
my $net=shift;
my $pvalue_cutoff=shift;

my %gene_targetNum;
my $significant_interactions;
my $nonSignificant_interactions;

print "chrA\tStartA\tEndA\tTypeA\tGeneA\tStrandA\tchrB\tStartB\tEndB\tTypeB\tGeneB\tStrandB\t";
print "Observed\tRandom\tRaw_Pvalue\tlocal-background-corrected_Pvalue\tTotalNumberOfSimulations\n";

open(NT,$net) || die;
while(my $line=<NT>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $qvalue=$sub[15];
	my $gene_a=join"\t",@sub[0..5];
	my $gene_b=join"\t",@sub[6..11];

	if($qvalue <= $pvalue_cutoff){
		$significant_interactions++;
		print $line,"\n";
	}
	else{
		$nonSignificant_interactions++;
	}
}

warn "$significant_interactions significant interactions\n";
warn "$nonSignificant_interactions other types interactions\n";

