#!/usr/bin/perl
die "perl $0 <interaction.sam> <gene_overlap_with_read1.bed> <gene_overlap_with_read2.bed>\n" if(@ARGV != 3);
my $interaction_sam=shift;
my $gene_read_1=shift;
my $gene_read_2=shift;

my %read_in_gene;
open(INA,$gene_read_1) || die;
while(my $line=<INA>){
        chomp $line;
        my @sub=split/\s+/,$line;
	$read_in_gene{$sub[9]}=1;
}

open(INB,$gene_read_2) || die;
while(my $line=<INB>){
        chomp $line;
        my @sub=split/\s+/,$line;
	$read_in_gene{$sub[9]}=1;
}

my $with_sam=$interaction_sam;
my $without_sam=$interaction_sam;
$with_sam=~s/sam/withGene.sam/;
$without_sam=~s/sam/withoutGene.sam/;

open(WITHG,">$with_sam") || die;
open(WITHOUTG,">$without_sam") || die;

open(SM,$interaction_sam) || die;
while(my $frag_a=<SM>){
        if($frag_a=~/^@/){
		print WITHG $frag_a;
		print WITHOUTG $frag_a;
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

                if($id_a_info[1] ne $id_b_info[1]){     #same pair
                        print $frag_a,$frag_b;
                        die "did not belong to the same pair\n";
                }
		else{
			if($read_in_gene{$id_a_info[0]."_".$id_a_info[1]}){
				print WITHG $frag_a,$frag_b;
			}
			else{
				print WITHOUTG $frag_a,$frag_b;
			}
		}
	}
}

close WITHG;
close WITHOUTG;
