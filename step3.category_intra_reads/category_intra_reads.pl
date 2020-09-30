#!/usr/bin/perl
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dirs, $file) = File::Spec->splitpath($path_curf);
$dirs=~s/\/$//;

die "remove spliced reads from intramolecular paired reads\n\nUsage: four parameters are required\nperl $file interaction.sam minimum_fragment_len gene_element.bed exon_junction.bedpe\n" if(@ARGV != 4);
my $intraMolecular_interaction_sam=shift;
my $minimum_fragment_length=shift;
my $gene_elements_bed=shift;
my $exon_junction_bedpe=shift;

print "perl $dirs/scripts/creat_gapped_and_Align_pair_bed.pl $intraMolecular_interaction_sam $minimum_fragment_length\n";

my $prefix=$intraMolecular_interaction_sam;
$prefix=~s/.sam//;

print "bedtools intersect -s -wa -wb -a $gene_elements_bed -b $prefix.Alignpair_read1.bed > element_overlap_with_read1.bed\n";
print "bedtools intersect -s -wa -wb -a $gene_elements_bed -b $prefix.Alignpair_read2.bed > element_overlap_with_read2.bed\n";
print "bedtools pairtopair -a $prefix.gapped.bed -b $exon_junction_bedpe -is > gapped_reads_overlapped_with_exon_junction.list\n";
print "perl $dirs/scripts/distance_in_mature_trans.pl $gene_elements_bed element_overlap_with_read1.bed element_overlap_with_read2.bed > pairreads_distance_in_mature_trans.list\n";
print "perl $dirs/scripts/split_intra_to_Normal_Chimeric.pl $intraMolecular_interaction_sam gapped_reads_overlapped_with_exon_junction.list pairreads_distance_in_mature_trans.list $minimum_fragment_length\n"

