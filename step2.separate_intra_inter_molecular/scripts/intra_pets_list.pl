#!/usr/bin/perl

die "perl $0 gene_overlap_with_read1.bed gene_overlap_with_read2.bed > pets_in_same_gene.list\n" if(@ARGV != 2);
my $gene_read_1=shift;
my $gene_read_2=shift;

my %read_A_gene_set;
open(INA,$gene_read_1) || die;
while(my $line=<INA>){
        chomp $line;
        my @sub=split/\s+/,$line;
	my $gene_info=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
        push (@{$read_A_gene_set{$sub[9]}},$gene_info);
}

my %read_B_gene_set;
open(INB,$gene_read_2) || die;
while(my $line=<INB>){
        chomp $line;
        my @sub=split/\s+/,$line;
	my $gene_info=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
        push (@{$read_B_gene_set{$sub[9]}},$gene_info);
}

foreach my $read_id (keys %read_A_gene_set){
	my @set_A=@{$read_A_gene_set{$read_id}};
	my $intra_gene=0;
	if(exists $read_B_gene_set{$read_id}){
		my @set_B=@{$read_B_gene_set{$read_id}};
		foreach my $gene_a (@set_A){
			foreach my $gene_b (@set_B){
				if($gene_a eq $gene_b){
					$intra_gene=1;
					last;
				}
			}
			if($intra_gene){
				last;
			}
		}
		if($intra_gene){
			print $read_id,"\n";
		}
	}
	else{
	}
}
