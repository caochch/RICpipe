#!/usr/bin/perl

die "perl $0 gene_overlap_with_read1.bed gene_overlap_with_read2.bed > RRI.network\n" if(@ARGV != 2);
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

my %RRI;

foreach my $read_id (keys %read_A_gene_set){
	my @set_A=@{$read_A_gene_set{$read_id}};
	#if(@set_A > 1 ){	#unique to a gene
	#	next;
	#}
	if(exists $read_B_gene_set{$read_id}){
		my @set_B=@{$read_B_gene_set{$read_id}};
		#if(@set_B > 1){	#unique to a gene
		#	next;
		#}
		my $factor=1/(($#set_A+1)*($#set_B+1));
		foreach my $gene_a (@set_A){
			foreach my $gene_b (@set_B){
				my @pair=($gene_a,$gene_b);
				@pair=sort @pair;
				#$RRI{$pair[0]."\t".$pair[1]}+=$factor;
				$RRI{$pair[0]."\t".$pair[1]}+=1;
			}
		}
	}
	else{
		next;
	}
}

foreach (keys %RRI){
	print $_,"\t",$RRI{$_},"\n";
}
