#!?usr/bin/perl
die "perl $0 left.arm_overlap_reads.count right.arm_overlap_reads.count\n" if(@ARGV != 2);
my $left_arm_count=shift;
my $right_arm_count=shift;

my %cluster_link;
my %count_for_left_arm;
open(LAC,$left_arm_count) || die;
while(my $line=<LAC>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $arm=$sub[3];
	$count_for_left_arm{$arm}=$sub[-1];
	$cluster_link{$arm}{"left"}=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
}

my %count_for_right_arm;
open(RAC,$right_arm_count) || die;
while(my $line=<RAC>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $arm=$sub[3];
	$count_for_right_arm{$arm}=$sub[-1];
	$cluster_link{$arm}{"right"}=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
}

foreach my $c (keys %count_for_left_arm){
	my @left_arm_loci=split/\s+/,$cluster_link{$c}{"left"};
	my @right_arm_loci=split/\s+/,$cluster_link{$c}{"right"};

	print $left_arm_loci[0],"\t",$left_arm_loci[1],"\t",$left_arm_loci[2],"\t";
	print $right_arm_loci[0],"\t",$right_arm_loci[1],"\t",$right_arm_loci[2],"\t";
	print $right_arm_loci[3],"\t",$right_arm_loci[4],"\t",$right_arm_loci[5],"\t";

	my $left_count=$count_for_left_arm{$c};
	my $right_count=$count_for_right_arm{$c};
	print $left_count,"\t",$right_count,"\t";
	my $score=$right_arm_loci[4]/sqrt($left_count*$right_count);
	print $score,"\n";
}

