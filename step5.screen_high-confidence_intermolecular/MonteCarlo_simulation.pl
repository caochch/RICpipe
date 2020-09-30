#!/usr/bin/perl
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dirs, $file) = File::Spec->splitpath($path_curf);
$dirs=~s/\/$//;

die "Screen significant RNA-RNA interaction from intermolecular chimeric reads\n\nUsage: at least six parameters are required\nperl $file gene_region.bed simulation_times P_value_cutoff CpuNumber tmp.prefix rep1.intermolecular.chimeric.sam rep2.intermolecular.chimeric.sam\n" if(@ARGV < 6);
my $whole_gene_region_bed=shift;
my $running_times=shift;
my $pvalue_cutoff=shift;
my $cpuNumber=shift;
my $output_prefix=shift;
my @reps_inter_chimeric_sam=@ARGV;

my @reps_network;
my $reps;
foreach my $sam (@reps_inter_chimeric_sam){
	$reps++;
	print "perl $dirs/scripts/0.prepare/from_sam_to_pair_reads_bed.pl $sam\n";
	print "bedtools intersect -s -wa -wb -a $whole_gene_region_bed -b read_1.bed > gene_overlap_with_read1.bed\n";
	print "bedtools intersect -s -wa -wb -a $whole_gene_region_bed -b read_2.bed > gene_overlap_with_read2.bed\n";
	print "perl $dirs/scripts/0.prepare/count_RRI_multiple_details_addMultiple.pl gene_overlap_with_read1.bed gene_overlap_with_read2.bed > rep$reps.interGene.network\n";
}

print "perl $dirs/scripts/1.build_network/merge_network.pl ";
foreach (1..$reps){
	print "rep$_.interGene.network "
}
print "> $output_prefix.merged.network\n";

if(-e "./1.run_simulation" or -e "./2.pre-process" or -e "./3.calculate_pvalue" or -e "./4.recalibrate_pvalue"){
	warn "Everything in the folder named '1.run_simulation' and '2.pre-process' and '3.calculate_pvalue' and '4.recalibrate_pvalue' will be removed\n";
	warn "This program will sleep 10 seconds before deleting these files\n";
	sleep(10);
	`rm -rf ./1.run_simulation ./2.pre-process ./3.calculate_pvalue ./4.recalibrate_pvalue`;
}

print "rm -rf read_1.bed read_2.bed gene_overlap_with_read1.bed gene_overlap_with_read2.bed\n";
print "echo \"Please run the following shell scripts sequentially\\n\"\n";
print "echo \"./1.run_simulation/1.base_on_observed/run.sh\\n\"\n";
print "echo \"./1.run_simulation/2.base_on_random/run.sh\\n\"\n";
print "echo \"./2.pre-process/1.base_on_observed/run.sh\\n\"\n";
print "echo \"./2.pre-process/2.base_on_random/run.sh\\n\"\n";
print "echo \"./3.calculate_pvalue/1.base_on_observed/run.sh\\n\"\n";
print "echo \"./3.calculate_pvalue/2.base_on_random/run.sh\\n\"\n";
print "echo \"./4.recalibrate_pvalue/run.sh\\n\"\n";

#simulation
`mkdir ./1.run_simulation`;
`mkdir ./1.run_simulation/1.base_on_observed`;
`mkdir ./1.run_simulation/2.base_on_random`;
my $number_for_each_cpu=int($running_times/$cpuNumber);

open(OSH,">./1.run_simulation/1.base_on_observed/run.sh") || die;
print OSH "ln -s ../../$output_prefix.merged.network ./\n";
foreach (1..$cpuNumber){
	print OSH "nohup perl $dirs/scripts/2.run_simulation/1.MonteCarlo_simulation.pl $output_prefix.merged.network $number_for_each_cpu thread$_ > result1.thread$_.simulation.list &\n";
}
close OSH;

open(RSH,">./1.run_simulation/2.base_on_random/run.sh") || die;
print RSH "ln -s ../../$output_prefix.merged.network ./\n";
print RSH "perl $dirs/scripts/2.run_simulation/0.creat_random_interaction.pl $output_prefix.merged.network > result0.random.network\n";
foreach (1..$cpuNumber){
	print RSH "nohup perl $dirs/scripts/2.run_simulation/1.MonteCarlo_simulation.pl result0.random.network $number_for_each_cpu thread$_ > result1.thread$_.simulation_on_random.list &\n";
}
close RSH;

#pre-process
`mkdir ./2.pre-process`;
`mkdir ./2.pre-process/1.base_on_observed`;
`mkdir ./2.pre-process/2.base_on_random`;
open(OSH,">./2.pre-process/1.base_on_observed/run.sh") || die;
foreach (1..$cpuNumber){
	print OSH "nohup perl $dirs/scripts/3.pre_process/split_and_transpose_large_matrix.pl ../../1.run_simulation/1.base_on_observed/result1.thread$_.simulation.list 100 thread$_ &\n";
}
close OSH;

open(RSH,">./2.pre-process/2.base_on_random/run.sh") || die;
foreach (1..$cpuNumber){
	print RSH "nohup perl $dirs/scripts/3.pre_process/split_and_transpose_large_matrix.pl ../../1.run_simulation/2.base_on_random/result1.thread$_.simulation_on_random.list 100 thread$_ &\n";
}
close RSH;

#calculate_pvalue
`mkdir ./3.calculate_pvalue`;
`mkdir ./3.calculate_pvalue/1.base_on_observed`;
`mkdir ./3.calculate_pvalue/2.base_on_random`;
open(OSH,">./3.calculate_pvalue/1.base_on_observed/run.sh") || die;
foreach (1..$cpuNumber){
	print OSH "nohup perl $dirs/scripts/4.calculate_pvalue/pvalue_calculator.pl ../../1.run_simulation/1.base_on_observed/all_pairs.thread$_.list ../../2.pre-process/1.base_on_observed/thread$_.transposed.matrix thread$_ &\n";
}
close OSH;

open(RSH,">./3.calculate_pvalue/2.base_on_random/run.sh") || die;
foreach (1..$cpuNumber){
	print RSH "nohup perl $dirs/scripts/4.calculate_pvalue/pvalue_calculator.pl ../../1.run_simulation/2.base_on_random/all_pairs.thread$_.list ../../2.pre-process/2.base_on_random/thread$_.transposed.matrix thread$_ &\n";
}
close RSH;

#recalibrate pvalue
`mkdir ./4.recalibrate_pvalue`;
open(SH,">./4.recalibrate_pvalue/run.sh") || die;
print SH "perl $dirs/scripts/5.recalibrate_pvalue/merge_pvalue.pl ";
foreach (1..$cpuNumber){
	print SH "../3.calculate_pvalue/1.base_on_observed/comparison.observed_to_simulated.thread$_.xls ";
}
print SH "> comparison.observed_to_simulated.basedOnObserved.finalMerge.xls\n";

print SH "perl $dirs/scripts/5.recalibrate_pvalue/merge_pvalue.pl ";
foreach (1..$cpuNumber){
	print SH "../3.calculate_pvalue/2.base_on_random/comparison.observed_to_simulated.thread$_.xls ";
}
print SH "> comparison.observed_to_simulated.basedOnRandom.finalMerge.xls\n";
print SH "perl $dirs/scripts/5.recalibrate_pvalue/1.convert_format_needed_by_CloseCall.pl comparison.observed_to_simulated.basedOnObserved.finalMerge.xls > result1.results_file.for_Test.list\n";
print SH "perl $dirs/scripts/5.recalibrate_pvalue/1.convert_format_needed_by_CloseCall.pl comparison.observed_to_simulated.basedOnRandom.finalMerge.xls > result1.control_file.for_Test.list\n";
print SH "perl $dirs/scripts/5.recalibrate_pvalue/2.multiple_testing_correction.pl --control result1.control_file.for_Test.list --results result1.results_file.for_Test.list --window 500\n";
print SH "gzip -d result1.results_file.for_Test.list.window_500.qval.txt.gz\n";
print SH "perl $dirs/scripts/5.recalibrate_pvalue/4.replace_rawPvalue_by_LocalCorrectPvalue.pl comparison.observed_to_simulated.basedOnObserved.finalMerge.xls result1.results_file.for_Test.list.window_500.qval.txt > result2.comparison.observed_to_simulated.Add_Local_Corrected_pvalue.list\n";
print SH "perl $dirs/scripts/5.recalibrate_pvalue/5.filter_interaction.pl result2.comparison.observed_to_simulated.Add_Local_Corrected_pvalue.list $pvalue_cutoff > $output_prefix.significant.interMolecular.interaction.list\n";
print SH "cp $output_prefix.significant.interMolecular.interaction.list ../\n";

