#!/usr/bin/perl
die "perl $0 <interaction.pairwiseTag.sam>\n" if(@ARGV != 1);
my $sam=shift;

open(OUTA,">read_1.bed") || die;
open(OUTB,">read_2.bed") || die;

open(SM,$sam) || die;
while(my $frag_a=<SM>){
	if($frag_a=~/^@/){
                next;
        }
        else{
		my $frag_b=<SM>;

		my @sub_a=split/\s+/,$frag_a;
		my @sub_b=split/\s+/,$frag_b;
		my @id_a_info=split/_/,$sub_a[0];
		my @id_b_info=split/_/,$sub_b[0];
		my $strand_a=$id_a_info[2];
		my $strand_b=$id_b_info[2];

		if($id_a_info[1] ne $id_b_info[1]){	#same pair
			print $frag_a,$frag_b;
			die "did not belong to the same pair\n";
		}

		my $chr_a=$sub_a[2];
		my $loci_a=$sub_a[3];
		my $cigar_a=$sub_a[5];
		$cigar_a=~/(\d+)M/;
		my $match_a=$1;

		my $chr_b=$sub_b[2];
		my $loci_b=$sub_b[3];
		my $cigar_b=$sub_b[5];
		$cigar_b=~/(\d+)M/;
		my $match_b=$1;

		if($strand_a eq "Plus"){
			print OUTA $chr_a,"\t",$loci_a-1,"\t",$loci_a+$match_a-1,"\t",$id_a_info[0],"_",$id_a_info[1],"\t",255,"\t+\n";
		}
		elsif($strand_a eq "Minus"){
			print OUTA $chr_a,"\t",$loci_a-1,"\t",$loci_a+$match_a-1,"\t",$id_a_info[0],"_",$id_a_info[1],"\t",255,"\t-\n";
		}
		else{
			die "wrong format\n";;
		}
		if($strand_b eq "Plus"){
			print OUTB $chr_b,"\t",$loci_b-1,"\t",$loci_b+$match_b-1,"\t",$id_b_info[0],"_",$id_b_info[1],"\t",255,"\t+\n";
		}
		elsif($strand_b eq "Minus"){
			print OUTB $chr_b,"\t",$loci_b-1,"\t",$loci_b+$match_b-1,"\t",$id_b_info[0],"_",$id_b_info[1],"\t",255,"\t-\n";
		}
		else{
			die "wrong format\n";
		}
	}
}
