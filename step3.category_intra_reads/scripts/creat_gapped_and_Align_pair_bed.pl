die "perl $0 interaction.sam minimum_fragment_len\n" if(@ARGV != 2);
my $sam=shift;
my $minimum_fragment_len=shift;

my $output_alignpair_A=$sam;
my $output_alignpair_B=$sam;
my $output_part=$sam;

$output_alignpair_A=~s/sam$/Alignpair_read1.bed/;
$output_alignpair_B=~s/sam$/Alignpair_read2.bed/;
$output_part=~s/sam$/gapped.bed/;

open(APA,">$output_alignpair_A") || die;
open(APB,">$output_alignpair_B") || die;
open(PT,">$output_part") || die;
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
                if($id_a_info[1] ne $id_a_info[1]){     #same pair
                        print $frag_a,$frag_b;
                        die "did not belong to the same pair\n";
                }
                else{#same read name
                        my @sub_a=split/\s+/,$frag_a;
                        my @sub_b=split/\s+/,$frag_b;

                        my $chr_a=$sub_a[2];
                        my $loci_a=$sub_a[3];
			my $cigar_a=$sub_a[5];
			

                        my $chr_b=$sub_b[2];
                        my $loci_b=$sub_b[3];
			my $cigar_b=$sub_b[5];

			if($sub_a[0] =~ /^AlignPair/){
                                $cigar_a=~/(\d+)M/;
                                my $match_a=$1;
                                $cigar_b=~/(\d+)M/;
                                my $match_b=$1;

                                if($strand_a eq $strand_b){
                                        if($strand_a eq "Plus"){
                                                my $fragment_len=$loci_a+$match_a-$loci_b;
                                                if($fragment_len <= $minimum_fragment_len){	#may be normal
                                                }
                                                else{
							print APA $chr_a,"\t",$loci_a-1,"\t",$loci_a+$match_a-1,"\t",$sub_a[0],"\t255\t+\n";	#read 1
							print APB $chr_b,"\t",$loci_b-1,"\t",$loci_b+$match_b-1,"\t",$sub_b[0],"\t255\t+\n";	#read 2
                                                }
                                        }
                                        elsif($strand_a eq "Minus"){
                                                my $fragment_len=$loci_b+$match_b-$loci_a;
                                                if($fragment_len <= $minimum_fragment_len){
                                                }
                                                else{
							print APA $chr_a,"\t",$loci_a-1,"\t",$loci_a+$match_a-1,"\t",$sub_a[0],"\t255\t-\n";	#read 1
							print APB $chr_b,"\t",$loci_b-1,"\t",$loci_b+$match_b-1,"\t",$sub_b[0],"\t255\t-\n";	#read 2
                                                }
                                        }
                                }
			}
			elsif($sub_a[0] =~ /^Part/){	#overlap junction site are classified as normal;
				$cigar_a=~/(\d+)M/;
				my $match_a=$1;
				$cigar_b=~/(\d+)M/;
				my $match_b=$1;
	                        print PT $chr_a,"\t",$loci_a+$match_a-5,"\t",$match_a+$loci_a+5,"\t";
	                        print PT $chr_b,"\t",$loci_b-5,"\t",$loci_b+5,"\t";
	                        print PT $sub_a[0],"\t60\t+\t+\n";
			}
			else{	#chimeric reads; all classified as chimeric
			}
		}
	}
}


