#!/usr/bin/perl
die "perl $0 <simulated_count_matrix> <Number_of_rows_per_batch> <outputprefix>\n" if(@ARGV != 3);
my $raw_matrix=shift;
my $number_of_rows=shift;
my $outprefix=shift;

my $rows_id;
my $real_rows_id;
my $row_range_start;
my $row_range_end;
my @intermediates_files;

open(RM,$raw_matrix) || die;
while(my $line=<RM>){
	$rows_id++;
	$real_rows_id++;
	chomp $line;
	my @sub=split/\s+/,$line;
	
	open(TMP,">tmp$real_rows_id.$outprefix.simulation") || die;
	foreach (@sub){
		print TMP $_,"\n";
	}
	close TMP;

	if($rows_id >= $number_of_rows){
		$row_range_end=$real_rows_id;
		$row_range_start=$row_range_end-$number_of_rows+1;
		my $output_file=$outprefix.".".$row_range_start."-".$row_range_end.".matrix";
		$rows_id=0;
		push (@intermediates_files,$output_file);

		#merge
		open(TSH,">tmp.$outprefix.merge.sh") || die;
		print TSH "paste ";
		foreach ($row_range_start..$row_range_end){
			print TSH "tmp$_.$outprefix.simulation ";
		}
		print TSH " > $output_file\n";
		
		print TSH "rm -rf ";
		foreach ($row_range_start..$row_range_end){
			print TSH "tmp$_.$outprefix.simulation ";
		}
		print TSH "\n";
		close TSH;
		`nohup sh tmp.$outprefix.merge.sh`;
	}
}

if($rows_id){
	#merge
	$row_range_end=$real_rows_id;
	$row_range_start=$row_range_end-$rows_id+1;
	my $output_file=$outprefix.".".$row_range_start."-".$row_range_end.".matrix";
	push (@intermediates_files,$output_file);

	#merge
	open(TSH,">tmp.$outprefix.merge.sh") || die;
	print TSH "paste ";
	foreach ($row_range_start..$row_range_end){
		print TSH "tmp$_.$outprefix.simulation ";
	}
	print TSH " > $output_file\n";
	print TSH "rm -rf ";
	foreach ($row_range_start..$row_range_end){
		print TSH "tmp$_.$outprefix.simulation ";
	}
	print TSH "\n";
	close TSH;
	`nohup sh tmp.$outprefix.merge.sh`;
}
	
open(TSH,">tmp.$outprefix.final.merge.sh") || die;
my $final=$outprefix.".transposed.matrix";
print TSH "paste ";
foreach (@intermediates_files){
	print TSH $_," ";
}
print TSH " > $final\n";
print TSH "rm -rf ";
foreach (@intermediates_files){
	print TSH $_," ";
}
print TSH "\n";
close TSH;
`nohup sh tmp.$outprefix.final.merge.sh`;
`rm -rf tmp.$outprefix.merge.sh tmp.$outprefix.final.merge.sh`;
