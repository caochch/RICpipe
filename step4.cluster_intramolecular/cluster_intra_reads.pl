#!/usr/bin/perl
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dirs, $file) = File::Spec->splitpath($path_curf);
$dirs=~s/\/$//;

die "cluster intramolecular chimeric reads into high-confidence interactions\n\nUsage: at least three parameters are required\nperl $file fragment_number_cutoff connection_score_cutoff tmp.prefix rep1.intramolecular.chimeric.sam rep2.intramolecular.chimeric.sam\n" if(@ARGV < 4);

my $fragment_number_cutoff=shift;
my $connection_score_cutoff=shift;
my $tmp_prefix=shift;
my @reps_intra_chimeric_sam=@ARGV;

#prepare sam files
print "perl $dirs/scripts/0.prepare/merge_sam_without_head_giveNewID.pl ";
foreach (@reps_intra_chimeric_sam){
	print $_," ";
}
print "> $tmp_prefix.merged.intraChimeric.sam\n";

#cluster chimeric reads
print "perl $dirs/scripts/1.cluster/from_sam_to_bedOfPair.pl $tmp_prefix.merged.intraChimeric.sam\n";
print "perl $dirs/scripts/1.cluster/unique_then_merge_with_newID.pl $tmp_prefix.merged.intraChimeric.bedpair > $tmp_prefix.merged.intraChimeric.uniq.bedpair\n";
print "bedtools pairtopair -a $tmp_prefix.merged.intraChimeric.uniq.bedpair -b $tmp_prefix.merged.intraChimeric.uniq.bedpair -is -rdn > $tmp_prefix.pair_to_pair.overlap\n";
print "perl $dirs/scripts/1.cluster/3.clustering_bridge_SaveMemory_fast.pl $tmp_prefix.pair_to_pair.overlap $tmp_prefix.cluster.bed $tmp_prefix.readsID_in_cluster.list\n";
print "perl $dirs/scripts/1.cluster/format_raw_cluster.pl $tmp_prefix.cluster.bed > $tmp_prefix.cluster.RawFormatted.bed\n";
print "bedtools pairtopair -a $tmp_prefix.cluster.RawFormatted.bed -b $tmp_prefix.cluster.RawFormatted.bed -is -rdn > $tmp_prefix.cluster_to_cluster.overlap\n";
print "perl $dirs/scripts/1.cluster/3.clustering_bridge_SaveMemory_fast.pl $tmp_prefix.cluster_to_cluster.overlap $tmp_prefix.supercluster_of_cluster.bed $tmp_prefix.cluster_in_supercluster.list\n";
print "perl $dirs/scripts/1.cluster/merge_first_round_cluster.pl $tmp_prefix.cluster.RawFormatted.bed $tmp_prefix.supercluster_of_cluster.bed $tmp_prefix.cluster_in_supercluster.list > $tmp_prefix.cluster.Final.bed\n";
print "bedtools pairtopair -a $tmp_prefix.cluster.Final.bed -b $tmp_prefix.merged.intraChimeric.bedpair -is -rdn > $tmp_prefix.cluster_overlap_reads.list\n";

#count number of fragment in each cluster
print "perl $dirs/scripts/2.count_fragment_in_eachCluster/step1.annotate_Fragments.pl $tmp_prefix.merged.intraChimeric.sam $tmp_prefix.cluster_overlap_reads.list $tmp_prefix\n";
print "perl $dirs/scripts/2.count_fragment_in_eachCluster/step2.improve_boundary_and_count_fragment.pl $tmp_prefix.annoFrag.cluster $tmp_prefix\n";
print "perl $dirs/scripts/2.count_fragment_in_eachCluster/step3.filter_cluster.pl $tmp_prefix.count_fragment.cluster $tmp_prefix.readID.IN.cluster.list $fragment_number_cutoff $tmp_prefix\n";


#score each cluster
print "perl $dirs/scripts/3.score_cluster/from_sam_to_bedOfPairtags.pl $tmp_prefix.merged.intraChimeric.sam\n";
print "perl $dirs/scripts/3.score_cluster/step1.creat_both_arm_bed.pl $tmp_prefix.count_fragment.filtered.cluster $fragment_number_cutoff $tmp_prefix\n";
print "bedtools intersect -a $tmp_prefix.left.arm.bed -b $tmp_prefix.merged.intraChimeric.pairTag.bed -wa -wb -F 1 > $tmp_prefix.left.arm_overlap_reads.list\n";
print "bedtools intersect -a $tmp_prefix.right.arm.bed -b $tmp_prefix.merged.intraChimeric.pairTag.bed -wa -wb -F 1 > $tmp_prefix.right.arm_overlap_reads.list\n";
print "perl $dirs/scripts/3.score_cluster/step2.count_tags_for_each_arm.pl $tmp_prefix.left.arm_overlap_reads.list > $tmp_prefix.left.arm_overlap_reads.count\n";
print "perl $dirs/scripts/3.score_cluster/step2.count_tags_for_each_arm.pl $tmp_prefix.right.arm_overlap_reads.list > $tmp_prefix.right.arm_overlap_reads.count\n";
print "perl $dirs/scripts/3.score_cluster/step3.score_each_cluster.pl $tmp_prefix.left.arm_overlap_reads.count $tmp_prefix.right.arm_overlap_reads.count > $tmp_prefix.cluster.withScore.bed\n";
print "perl $dirs/scripts/3.score_cluster/step4.filter_by_specificScore.pl $tmp_prefix.cluster.withScore.bed $connection_score_cutoff > $tmp_prefix.cluster.withScore.highQuality.list\n";


