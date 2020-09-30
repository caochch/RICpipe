#!/usr/bin/perl
die "perl $0 <interaction.sam> <pets_in_same_gene.list>\n" if(@ARGV != 2);
my $contact_sam=shift;
my $list=shift;

my $output_intra_sam=$contact_sam;
my $output_inter_sam=$contact_sam;
$output_intra_sam=~s/sam$/intraMolecular.sam/;
$output_inter_sam=~s/sam$/interMolecular.sam/;

my %intra_list;
open(LST,$list) || die;
while(my $line=<LST>){
	chomp $line;
	$intra_list{$line}=1;
}

open(INTRA,">$output_intra_sam") || die;
open(INTER,">$output_inter_sam") || die;
open(SM,$contact_sam) || die;
while(my $frag_a=<SM>){
        if($frag_a=~/^@/){
		print INTRA $frag_a;
		print INTER $frag_a;
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
			if($intra_list{$id_a_info[0]."_".$id_a_info[1]}){
				chomp $frag_a;
				chomp $frag_b;
				$frag_a=~s/\s+$//;
				$frag_b=~s/\s+$//;
				print INTRA $frag_a,"\n",$frag_b,"\n";
			}
			else{
				chomp $frag_a;
				chomp $frag_b;
				$frag_a=~s/\s+$//;
				$frag_b=~s/\s+$//;
				print INTER $frag_a,"\n",$frag_b,"\n";
			}
		}
	}
}

