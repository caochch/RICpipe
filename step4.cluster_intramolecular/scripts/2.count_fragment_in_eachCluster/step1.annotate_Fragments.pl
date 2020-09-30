#!/usr/bin/perl
use List::Util qw(min max sum);
use List::MoreUtils qw/ uniq/;

die "perl $0 intraMolecular.chimeric.sam cluster_overlap_reads.list outprefix\n" if(@ARGV != 3);

my $raw_intergene_sam=shift;
my $formatted_cluster_overlap_reads=shift;
my $outprefix=shift;

my %pet;
my %pet_fragmentID;
open(SM,$raw_intergene_sam) || die;
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
                my $sample_a=shift @id_a_info;
                my $sample_b=shift @id_b_info;
                my $strand_a=$id_a_info[2];
                my $strand_b=$id_b_info[2];
                if($id_a_info[1] ne $id_b_info[1]){     #same pair
                        print $frag_a,$frag_b;
                        die "did not belong to the same pair\n";
                }
                else{
			$pet_fragmentID{$sample_a."_".$id_a_info[0]."_".$id_a_info[1]}=$id_a_info[-1];
                }
        }
}

open(OUTC,">$outprefix.annoFrag.cluster") || die;
open(FC,$formatted_cluster_overlap_reads) || die;
while(my $line=<FC>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $turn=(split/_/,$sub[6])[1];
	print OUTC $line,"\t",$pet_fragmentID{$sub[16]},"\n";
}



