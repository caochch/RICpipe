#!/usr/bin/perl
die "perl $0 intraMolecular.sam gapped_reads_overlapped_with_exon_junction.list pairreads_distance_in_mature_trans.list minimal_fragment_len_for_pair(must be large than num used in creat_gapped_and_Align_pair_bed.pl)\n" if(@ARGV != 4);
my $in_sam=shift;
my $junction_reads=shift;
my $pairreads_distance_in_mature=shift;
my $minimal_fragment_len_for_pair=shift;

my %bad_read_gap_pair;
open(JUNC,$junction_reads) || die;
while(my $line=<JUNC>){
	chomp $line;
	my @sub=split/\s+/,$line;
	$bad_read_gap_pair{$sub[6]}=1;
}

my %close_reads_in_mature;
open(PDM,$pairreads_distance_in_mature) || die;
while(my $line=<PDM>){
	chomp $line;
	my @sub=split/\s+/,$line;
	$close_reads_in_mature{$sub[0]}=$sub[2];
}

open(SM,$in_sam) || die;

my $normal_sam=$in_sam;
my $chimeric_sam=$in_sam;
my $dropped_sam=$in_sam;
$normal_sam=~s/sam$/Singleton.sam/;
$chimeric_sam=~s/sam$/Chimeric.sam/;
$dropped_sam=~s/sam$/dropped.sam/;

open(OUTN,">$normal_sam") || die;
open(OUTC,">$chimeric_sam") || die;
open(OUTD,">$dropped_sam") || die;
open(LOG,">class_of_AlignPair.log") || die;

while(my $frag_a=<SM>){
        if($frag_a=~/^@/){
		print OUTN $frag_a;
		print OUTC $frag_a;
		print OUTD $frag_a;
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
                else{
                        my $chr_a=$sub_a[2];
                        my $loci_a=$sub_a[3];
                        my $cigar_a=$sub_a[5];

                        my $chr_b=$sub_b[2];
                        my $loci_b=$sub_b[3];
                        my $cigar_b=$sub_b[5];

			if($sub_a[0]=~/AlignPair/){ #pair:
                                $cigar_a=~/(\d+)M/;
                                my $match_a=$1;
                                $cigar_b=~/(\d+)M/;
                                my $match_b=$1;
				
				if($strand_a eq $strand_b){
					if($strand_a eq "Plus"){
						my $fragment_len=$loci_a+$match_a-$loci_b;
						if($fragment_len < 0){	#conflict direction
							print OUTC $frag_a,$frag_b;
							print LOG $sub_a[0],"\t3'ReadsAt5'\tChimeric\n";
						}
						elsif($fragment_len <= $minimal_fragment_len_for_pair){	#small than minimal; even in pre-RNA
							print OUTN $frag_a,$frag_b;
							print LOG $sub_a[0],"\tFragmentShorterThan$minimal_fragment_len_for_pair","inPre-RNA\tNormal\n";
						}
						else{
							if(exists $close_reads_in_mature{$sub_a[0]}){
								if($close_reads_in_mature{$sub_a[0]} <= $minimal_fragment_len_for_pair){	#closer than minimal; in mature RNA
									print OUTN $frag_a,$frag_b;
									print LOG $sub_a[0],"\tFragmentLongerThan$minimal_fragment_len_for_pair","inPre-RNAButShorterThan$minimal_fragment_len_for_pair","inMatureRNA\tNormal\n";
								}
								else{										#far than minimal; in mature RNA
									print OUTC $frag_a,$frag_b;
									print LOG $sub_a[0],"\tFragmentLongerThan$minimal_fragment_len_for_pair","inPre-RNAAndLongerThan$minimal_fragment_len_for_pair","inMatureRNA\tChimeric\n";
								}
							}
							else{
								#no transcipts inculde this reads at the same time
								print OUTD ">no_transcripts_available\n";
								print OUTD $frag_a,$frag_b;
								#since we did not require strand for classify interGene and intraGene
								print LOG $sub_a[0],"\tFragmentLongerThan$minimal_fragment_len_for_pair","inPre-RNAButNoAvailableTranscripts\tDropped\n";
							}
						}
					}
					elsif($strand_a eq "Minus"){
						my $fragment_len=$loci_b+$match_b-$loci_a;
						if($fragment_len < 0){	#conflict direction
							print OUTC $frag_a,$frag_b;
							print LOG $sub_a[0],"\t3'ReadsAt5'\tChimeric\n";
						}
						elsif($fragment_len <= $minimal_fragment_len_for_pair){	#small than minimal; even in pre-RNA
							print OUTN $frag_a,$frag_b;
							print LOG $sub_a[0],"\tFragmentShorterThan$minimal_fragment_len_for_pair","inPre-RNA\tNormal\n";
						}
						else{
							if(exists $close_reads_in_mature{$sub_a[0]}){
								if($close_reads_in_mature{$sub_a[0]} <= $minimal_fragment_len_for_pair){	#closer than minimal; in mature RNA
									print OUTN $frag_a,$frag_b;
									print LOG $sub_a[0],"\tFragmentLongerThan$minimal_fragment_len_for_pair","inPre-RNAButShorterThan$minimal_fragment_len_for_pair","inMatureRNA\tNormal\n";
								}
								else{
									print OUTC $frag_a,$frag_b;						#far than minimal in mature RNA
									print LOG $sub_a[0],"\tFragmentLongerThan$minimal_fragment_len_for_pair","inPre-RNAAndLongerThan$minimal_fragment_len_for_pair","inMatureRNA\tChimeric\n";
								}
							}
							else{
								#no transcipts inculde this reads at the same time
								print OUTD ">no_transcripts_available\n";
								print OUTD $frag_a,$frag_b;
								#since we did not require strand for classify interGene and intraGene
								print LOG $sub_a[0],"\tFragmentLongerThan$minimal_fragment_len_for_pair","inPre-RNAButNoAvailableTranscripts\tDropped\n";
							}
						}
					}
				}
				else{	#same fragment but different strand; may be result from intergene interaction
					print OUTD ">maybe_intergene\n";
					print OUTD $frag_a,$frag_b;
					print LOG $sub_a[0],"\tSameFragment_DifferentStrand_MayBeInterGene\tDropped\n";
				}
			}
			elsif($sub_a[0]=~/Chimeric/){       #chimeric reads: classified as RNA structure
				print OUTC $frag_a,$frag_b;
				print LOG $sub_a[0],"\tChimericFragment\tChimeric\n";
			}
			elsif($sub_a[0]=~/Part/){
				if($bad_read_gap_pair{$sub_a[0]}){	#gapped reads overlap with exon junction: classified as Normal RNA-seq
					print OUTN $frag_a,$frag_b;
					print LOG $sub_a[0],"\tPartSegmentOnExonJunction\tNormal\n";
				}
				else{				#gapped reads do not overlap with exon junction: classified as RNA structure
					print OUTC $frag_a,$frag_b;
					print LOG $sub_a[0],"\tPartSegmentAwayFromExonJunction\tChimeric\n";
				}
			}
			else{
				print $frag_a,$frag_b;
				die "wrong read id:\t$sub_a[0]\n";
			}
		}
	}
}

