#!/usr/bin/perl
die "perl $0 <interaction.sam>\n" if(@ARGV != 1);
my $sam=shift;
my $out_bed_pair=$sam;
$out_bed_pair=~s/^.+\///;
$out_bed_pair=~s/sam/pairTag.bed/;

open(OUT,">$out_bed_pair") || die;

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
		my $sample_a=shift @id_a_info;
		my $sample_b=shift @id_b_info;
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

		my $start_a=$loci_a;
		my $end_a=$loci_a+$match_a-1;
		my $start_b=$loci_b;
		my $end_b=$loci_b+$match_b-1;

		my $read_a_info=$chr_a."\t".$start_a."\t".$end_a;
		my $read_b_info=$chr_b."\t".$start_b."\t".$end_b;
	
		my $real_strand_a;
		my $real_strand_b;
		
		if($strand_a eq "Plus"){
			$real_strand_a="+";
		}
		elsif($strand_a eq "Minus"){
			$real_strand_a="-";
		}
		else{
			die "wrong format\n";
		}
		if($strand_b eq "Plus"){
			$real_strand_b="+";
		}
		elsif($strand_b eq "Minus"){
			$real_strand_b="-";
		}
		else{
			die "wrong format\n";
		}
		
		print OUT $read_a_info,"\t",$sample_a,"_",$id_a_info[0],"_",$id_a_info[1],"\n";
		print OUT $read_b_info,"\t",$sample_a,"_",$id_a_info[0],"_",$id_a_info[1],"\n";
	}
}
