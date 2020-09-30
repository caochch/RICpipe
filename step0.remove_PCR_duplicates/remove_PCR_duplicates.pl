#!/usr/bin/perl
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dirs, $file) = File::Spec->splitpath($path_curf);
$dirs=~s/\/$//;

die "Remove PCR duplicates by collapsing reads with identical sequences\n\nUsage: five parameters are required\nperl $file read1_clean_pair_fq read2_clean_pair_fq read1_clean_unpair_fq read2_clean_unpair_fq output_dir\n" if(@ARGV != 5);

my $read1_clean_pair_fq=shift;
my $read2_clean_pair_fq=shift;
my $read1_clean_unpair_fq=shift;
my $read2_clean_unpair_fq=shift;
my $outdir=shift;

my $rmDup_read1_pair_fq=$read1_clean_pair_fq;
my $rmDup_read2_pair_fq=$read2_clean_pair_fq;
my $rmDup_read1_unpair_fq=$read1_clean_unpair_fq;
my $rmDup_read2_unpair_fq=$read2_clean_unpair_fq;

$rmDup_read1_pair_fq=~s/fq$/rmDup.fq/;
$rmDup_read2_pair_fq=~s/fq$/rmDup.fq/;
$rmDup_read1_unpair_fq=~s/fq$/rmDup.fq/;
$rmDup_read2_unpair_fq=~s/fq$/rmDup.fq/;

print "perl $dirs/scripts/remove_duplicated_reads_PE.pl $read1_clean_pair_fq $read2_clean_pair_fq $rmDup_read1_pair_fq $rmDup_read2_pair_fq\n";
print "perl $dirs/scripts/remove_duplicated_reads_SE.pl $read1_clean_unpair_fq $rmDup_read1_unpair_fq\n";
print "perl $dirs/scripts/remove_duplicated_reads_SE.pl $read2_clean_unpair_fq $rmDup_read2_unpair_fq\n";
print "cat $rmDup_read1_pair_fq $rmDup_read1_unpair_fq > $outdir/read1.clean.rmDup.fq\n";
print "cat $rmDup_read2_pair_fq $rmDup_read2_unpair_fq > $outdir/read2.clean.rmDup.fq\n";
print "rm -rf $rmDup_read1_pair_fq $rmDup_read2_pair_fq $rmDup_read1_unpair_fq $rmDup_read2_unpair_fq\n";
