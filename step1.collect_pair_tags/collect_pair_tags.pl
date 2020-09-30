#!/usr/bin/perl
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dirs, $file) = File::Spec->splitpath($path_curf);
$dirs=~s/\/$//;

die "Collect pair tags from mapping results for read1 and read2\n\nUsage: six parameters are required\nperl $file read1.align.sam read2.align.sam read1.chimeric.sam read2.chimeric.sam number_of_cpu outprefix\n" if(@ARGV != 6);
my $read1_align_sam=shift;
my $read2_align_sam=shift;
my $read1_chimeric_sam=shift;
my $read2_chimeric_sam=shift;
my $num_of_cpu=shift;
my $outprefix=shift;

my $prefix_read1_align=$read1_align_sam;
my $prefix_read2_align=$read2_align_sam;
$prefix_read1_align=~s/.sam$//;
$prefix_read2_align=~s/.sam$//;

print "samtools view -@ $num_of_cpu -b -S -o $prefix_read1_align.bam $read1_align_sam\n";
print "samtools view -@ $num_of_cpu -b -S -o $prefix_read2_align.bam $read2_align_sam\n";
print "samtools sort -@ $num_of_cpu $prefix_read1_align.bam $prefix_read1_align.sort\n";
print "samtools sort -@ $num_of_cpu $prefix_read2_align.bam $prefix_read2_align.sort\n";
print "samtools view -@ $num_of_cpu -h -q 30 -F 256 -o $prefix_read1_align.sort.uniq.sam $prefix_read1_align.sort.bam\n";
print "samtools view -@ $num_of_cpu -h -q 30 -F 256 -o $prefix_read2_align.sort.uniq.sam $prefix_read2_align.sort.bam\n";
print "perl $dirs/scripts/obtain_pairs_from_pair.pl $prefix_read1_align.sort.uniq.sam $prefix_read2_align.sort.uniq.sam\n";
print "samtools view -@ 10 -b -S -o interaction_from_pair_mapped_reads_1.bam interaction_from_pair_mapped_reads_1.sam\n";
print "samtools view -@ 10 -b -S -o interaction_from_pair_mapped_reads_2.bam interaction_from_pair_mapped_reads_2.sam\n";
print "samtools sort -n -@ 10 interaction_from_pair_mapped_reads_1.bam interaction_from_pair_mapped_reads_1.sort\n";
print "samtools sort -n -@ 10 interaction_from_pair_mapped_reads_2.bam interaction_from_pair_mapped_reads_2.sort\n";
print "samtools view -h -o interaction_from_pair_mapped_reads_1.sort.sam interaction_from_pair_mapped_reads_1.sort.bam\n";
print "samtools view -h -o interaction_from_pair_mapped_reads_2.sort.sam interaction_from_pair_mapped_reads_2.sort.bam\n";

my $prefix_read1_chimeric=$read1_chimeric_sam;
my $prefix_read2_chimeric=$read2_chimeric_sam;
$prefix_read1_chimeric=~s/.sam$//;
$prefix_read2_chimeric=~s/.sam$//;

print "perl $dirs/scripts/process_Chimeric_sam.pl $read1_chimeric_sam > $prefix_read1_chimeric.processed.sam\n";
print "perl $dirs/scripts/process_Chimeric_sam.pl $read2_chimeric_sam > $prefix_read2_chimeric.processed.sam\n";

print "perl $dirs/scripts/obtain_pairs_from_gapped_reads.pl $prefix_read1_align.sort.uniq.sam $prefix_read2_align.sort.uniq.sam $prefix_read1_chimeric.processed.sam $prefix_read2_chimeric.processed.sam interaction_from_gapped_reads.sam \n";
print "perl $dirs/scripts/merge_interaction.pl num_of_interactions_from_part.list interaction_from_pair_mapped_reads_1.sort.sam interaction_from_pair_mapped_reads_2.sort.sam interaction_from_gapped_reads.sam $prefix_read1_chimeric.processed.sam $prefix_read2_chimeric.processed.sam $outprefix.interaction.sam\n";
print "perl $dirs/scripts/count_link_for_each_kind.pl interaction_from_pair_mapped_reads_1.sort.sam interaction_from_pair_mapped_reads_2.sort.sam interaction_from_gapped_reads.sam $prefix_read1_chimeric.processed.sam $prefix_read2_chimeric.processed.sam > num_of_interactions.list\n";

