#!/usr/bin/perl

############################################################
#Takes 1) a simulation output file and 
#2) a simulation output file based on a random dataset and
#identifies statistically significant interactions
############################################################

use strict;
use warnings;
use Getopt::Long;
use Math::CDF;    #For normal distribution 
use POSIX;

use Data::Dumper;

 #my @array = qw(0.3 0.3 0.3 0.3 0.9);
# my @sub = @array[2..3];
# print Dumper \@array;
# print Dumper \@sub;


#@array = benjamini(@array);
#print Dumper \@array;

#exit;


####################################
# Option variables and process input
my $control_file;
my $results_file;
my $window_size;
my $config_result = GetOptions(
			       "control=s" => \$control_file,
			       "results=s" => \$results_file,
				   "window=i" => \$window_size
			      );

die "Could not parse options" unless ($config_result);

if(!defined $control_file or !defined $results_file){
	die "Specify --control and --results Monte Carlo Simulation output files\n";
}

if(defined $window_size){
	if($window_size == 0){
		die "Local distribution window size may not be set to zero.";
	} else{
		$window_size = abs($window_size);
		print "Local distribution window size set by user to $window_size\n";
	}
} else {
	$window_size = 500;
	print "Window size defaulting to $window_size\n";
}

print "Performing multiple testing correction\n";



#Datastructures to create:
#Ordered arrays as R script based on control

	


##################################################
# Read in control dataset to create ordered arrays
print "Reading in data from control file '$control_file' and results file '$results_file'\n";

my ($ordered_control_averages_ref, $diff_ordered_by_averages_ref) = get_ordered_averages($control_file);
my @ordered_control_averages = @{ $ordered_control_averages_ref };
my @diff_ordered_by_averages = @{ $diff_ordered_by_averages_ref };

#print Dumper \@ordered_control_averages;
#Read in observed results

my ($ordered_results_averages_ref) = get_ordered_averages($results_file);
my @ordered_results_averages = @{ $ordered_results_averages_ref };


my %res_cont_lookup;    # Create hash of %{obs_val} = position it would occupy control ordered list
#print Dumper \@ordered_results_averages;


#Create relationship between observed and simulated points
my $i = 0;
my $previous_results_average = -1;
foreach my $results_average (@ordered_results_averages){    
	next if($results_average eq $previous_results_average);    #Don't process again
	
	my $previous_control_average = -1;
	my $current_repeats_length = 0;
	while($i < scalar(@ordered_control_averages) ){
		my $control_average = $ordered_control_averages[$i];		
		my $index = $i - 1;
		$index = $index - ceil($current_repeats_length / 2);
		$index = 0 if($index < 0);
	
		$res_cont_lookup{$results_average} = $index;

		last if($control_average > $results_average);
		
		if($control_average == $previous_control_average){
			$current_repeats_length++;
		} else {
			$current_repeats_length = 0;
		}
		$i++;
		$previous_control_average = $control_average;	
	}	
	$previous_results_average = $results_average;
}


foreach my $results_average (@ordered_results_averages){    #Assign those unallocated at the end
	unless(exists $res_cont_lookup{$results_average} ){
		$res_cont_lookup{$results_average} = $i - 1;	
	}
}

#print Dumper \%res_cont_lookup;



#############################################################
# Determine P_values from distribution
print "Re-reading results file '$results_file' to get P-values\n";

if($results_file =~ /\.gz$/){
	open (RESULTS, "zcat $results_file |") or die "Could not read file '$results_file' : $!";
} else {
	open(RESULTS, '<', $results_file) or die "Could not open '$results_file' : $!";
}

scalar <RESULTS>;    #Ignore header

my @p_values;
while(<RESULTS>){
	my $line = $_;
	chomp $line;

	my(undef, undef, $obs, $sim) = split(/\t/, $line);
	my $average = ($obs + $sim) / 2;
	my $diff = $sim - $obs;
	
	my $p_val = get_pval_from_control_normal_dist($average, $diff);
	
	push(@p_values, $p_val);
}
close RESULTS or die "Could not close filehandle on '$results_file' : $!";
my @q_values = benjamini(@p_values);
my @passed_threshold = benjamini_passed_threshold(@p_values);


############################################################
# Create the output file
my $outfile = "$results_file.window_$window_size.qval.txt.gz";
print "Re-reading results file '$results_file' and writing results to '$outfile'\n";

if($results_file =~ /\.gz$/){
	open (RESULTS2, "zcat $results_file |") or die "Could not read file '$results_file' : $!";
} else {
	open(RESULTS2, '<', $results_file) or die "Could not open '$results_file' : $!";
}

open(OUT, "| gzip -c - > $outfile") or die "Could not write to '$outfile' : $!";

#Name_Feature1	Name_Feature2	Observed_Frequency	Simulation_Average_Frequency	Observed/Simulation	Simulation_Score	P_Value
my $header = scalar <RESULTS2>;
$header =~ s/\n$/\tp(normal)\tq\tPassed_threshold\n/;
print OUT $header;
$i = 0;
while(<RESULTS2>){

	my $line = $_;
	chomp $line;
	
	my $p_val = $p_values[$i];
	my $q_val = $q_values[$i];
	my $passed = $passed_threshold[$i];

	print OUT "$line\t$p_val\t$q_val\t$passed\n";
	
	$i++;
}


close RESULTS2 or die "Could not close filehandle on '$results_file' : $!";
close OUT or die "Could not close filehandle on '$outfile' : $!";


print "Processing complete\n";

exit (0);




#########################################################
#Subroutines
#########################################################


##########################################################
#Takes and average score of observed and simulated resutls and returns
#a p-value by using a local normal distribution on the control dataset as a reference
 sub get_pval_from_control_normal_dist {
	my ($average, $diff) = @_;

	my $average_equivalent_in_control;
	if(exists $res_cont_lookup{$average}){
		$average_equivalent_in_control = $res_cont_lookup{$average};    #Find most approprate equivalent to results average in control distribution
	} else {
		die "Could not find $average in res_cont_lookup hash\n";    #This should not happen
	}

	#Get local distribution
	my $window_start = $average_equivalent_in_control - floor($window_size / 2);
	my $window_end = $average_equivalent_in_control + floor($window_size / 2);
	$window_start = 0 if($window_start < 0);
	$window_end = (scalar(@ordered_control_averages) - 1) if($window_end > (scalar(@ordered_control_averages) - 1) );


	#Get p-value from local normal distribution
	#print &Math::CDF::pnorm(0.25);
	#print "Start: $window_start    End: $window_end\n";
	my @local_differences_distribution = @diff_ordered_by_averages[$window_start..$window_end];    #Keep original array unaltered
	my $std_dev;
	my $total_squares = 0;
	{   #Code bloc

		foreach my $local_difference (@local_differences_distribution){
			$total_squares += ($local_difference * $local_difference);
		}
		$std_dev = ($total_squares / scalar(@local_differences_distribution))**0.5;    #std = square root (average squares)
	}


    
    # Now we work out the p.value for the value we're actually
    # looking at in the context of the control distribution
	my $z_score = ($diff - 0) / $std_dev;    #Assume mean is zero
	my $p_val = Math::CDF::pnorm($z_score);    #Feed Z score into standard normal distribution
	return $p_val;

}





#Subroutine get_ordered_averages
#Takes a filename and returns a REFERENCE to an ordered (ascending numerically) array of
#(observed frequency + simulated frequency) / 2 for each feature.  Also returns a REFERENCE to
# an array of differences (obs - sim) sorted in the same order as the 1 first returned array
sub get_ordered_averages {
	my $file = $_[0];
	my @ordered_averages;
	my @differences;

	if($file =~ /\.gz$/){
		open (IN, "zcat $file |") or die "Could not read file '$file' : $!";
	} else {
		open(IN, '<',$file) or die "Could not open '$file' : $!";
	}

	scalar <IN>;    #Ignore header
	while(<IN>){
		my $line = $_;
		chomp $line;
		my(undef, undef, $obs, $sim) = split(/\t/, $line);		
		my $average = ($obs + $sim) / 2;
				
		push(@ordered_averages, $average);
		push(@differences, $obs - $sim);
	}
	close IN or die "Could not close '$file' : $!";

	my @sorted_indexes = sort { $ordered_averages[$a] <=> $ordered_averages[$b] } 0..$#ordered_averages;
	my @ordered_differences;
	foreach my $index (@sorted_indexes){
		push(@ordered_differences, $differences[$index]);
	}

	#print Dumper \@ordered_averages;
	#print Dumper \@sorted_indexes;


	@ordered_averages = sort {$a <=> $b} @ordered_averages;	
	#print Dumper \@ordered_averages;
	#print Dumper \@ordered_differences;

	return (\@ordered_averages, \@ordered_differences)

}


#########################################
#Subroutine: benjamini
#Takes and array of p-values and returns the
#corresponding Q values
#Benjamini-Hochberg critical value, (i/m)Q, where i is the rank, 
#m is the total number of tests, and Q is the false discovery rate you choose
#The adjusted P value for a test is either the raw P value times m/i or the 
#adjusted P value for the next higher raw P value, whichever is smaller 
#(remember that m is the number of tests and i is the rank of each test, with 
#1 the rank of the smallest P value). 
sub benjamini {
	my @p_values = @_;
	
	my @sorted_indexes = sort { $p_values[$a] <=> $p_values[$b] } 0..$#p_values;    #For returning to original order
	@sorted_indexes = sort { $sorted_indexes[$a] <=> $sorted_indexes[$b] } 0..$#sorted_indexes; 
		
	@p_values = sort {$a <=> $b} @p_values;    #Sort p-values ascending
	
	my $i = 1;
	my $m = scalar (@p_values);
	my $previous_p = 2;   #2 is impossible
	my @q_values;

	for($i = 1; $i <= $m; $i++){    #Here we initialise at 1 (not 0 - to make i the same as the BH formula)
		my $p_value = $p_values[$i-1];
		my $q_value = $m / $i * $p_value;	
		push(@q_values, $q_value);  
	}
	
	#Make sure array decreases in size
	my $current_min = $q_values[-1];
	foreach my $q_value (reverse @q_values){
		if($q_value > $current_min){
			$q_value  = $current_min;
		} else {
			$current_min = $q_value;
		}
	}
	
	my @q_values_ordered;
	foreach my $index (@sorted_indexes){   #Convert to original order
		push(@q_values_ordered, $q_values[$index]);
	}
	
	return @q_values_ordered;
}



#########################################
#Subroutine: benjamini
#Takes and array of p-values and returns the
#true or false depending on whether pass the
#Benjamini-Hochberg test
sub benjamini_passed_threshold{
	my @p_values = @_;
	
	my @sorted_indexes = sort { $p_values[$a] <=> $p_values[$b] } 0..$#p_values;    #For returning to original order
	@sorted_indexes = sort { $sorted_indexes[$a] <=> $sorted_indexes[$b] } 0..$#sorted_indexes; 
		
	@p_values = sort {$a <=> $b} @p_values;    #Sort p-values ascending
	
	my $i = 1;    #The i used in the formual (i/m)Q
	my $m = scalar (@p_values);
	my $Q = 0.25;   #Standard Q setting
	my @pass_fail;

	my $pass_flag = 1;    #Default set to pass

	foreach my $p_value (@p_values){
		if($pass_flag){
			if( $p_value < ($i / $m * $Q) ){
				$pass_fail[$i-1] = 'pass';
			} else {
				$pass_fail[$i-1] = 'fail';
				$pass_flag = 0;    #Everything else will now fail
			}

		} else {    #Once one value has failed, everything afterwards fails (sorted p-value array)
			$pass_fail[$i-1] = 'fail';
		}
		$i++;
	}


	#Re-sort to original order
	my @pass_fail_ordered;
	foreach my $index (@sorted_indexes){   #Convert to original order
		push(@pass_fail_ordered, $pass_fail[$index]);
	}
	
	return @pass_fail_ordered;

}


