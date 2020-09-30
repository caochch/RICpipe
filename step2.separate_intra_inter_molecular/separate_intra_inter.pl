#!/usr/bin/perl
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dirs, $file) = File::Spec->splitpath($path_curf);
$dirs=~s/\/$//;

die "Separate intermolecular and intramolecular paired reads\n\nUsage: two parameters are required\nperl $file interaction.sam whole_gene.bed\n" if(@ARGV != 2);
my $interaction_sam=shift;
my $whole_gene_bed=shift;

print "perl $dirs/scripts/from_sam_to_pair_reads_bed.pl $interaction_sam\n";
print "bedtools intersect -wa -wb -a $whole_gene_bed -b read_1.bed > gene_overlap_with_read1.bed\n";
print "bedtools intersect -wa -wb -a $whole_gene_bed -b read_2.bed > gene_overlap_with_read2.bed\n";
print "perl $dirs/scripts/intra_pets_list.pl gene_overlap_with_read1.bed gene_overlap_with_read2.bed > pets_in_same_gene.list\n";
print "perl $dirs/scripts/separate_intra_inter_pets.pl $interaction_sam pets_in_same_gene.list\n";


my $prefix=$interaction_sam;
$prefix=~s/.sam//;
print "perl $dirs/scripts/from_sam_to_pair_reads_bed.pl $prefix.interMolecular.sam\n";
print "bedtools intersect -wa -wb -a $whole_gene_bed -b read_1.bed > gene_overlap_with_read1.bed\n";
print "bedtools intersect -wa -wb -a $whole_gene_bed -b read_2.bed > gene_overlap_with_read2.bed\n";
print "perl $dirs/scripts/split_chimeric_with_or_without_gene.pl $prefix.interMolecular.sam gene_overlap_with_read1.bed gene_overlap_with_read2.bed\n";
