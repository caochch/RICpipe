#!/usr//bin/perl
die "perl $0 rep1.interaction.sam rep2.interaction.sam rep3.interaction.sam ... > merged.sam\n" if(@ARGV < 1);
my @sam=@ARGV;
my $file_id;
foreach my $s (@sam){
	$file_id++;
	open(IN,$s) || die;
	while(my $line=<IN>){
		if($line=~/^@/){
		}
		else{
			print "Sample$file_id","_",$line;
		}
	}
	close IN;
}
