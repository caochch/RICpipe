#!/usr/bin/perl
die "perl $0 count_fragment.cluster readID.IN.cluster.list fragment_number_cutoff outprefix\n" if(@ARGV != 4);
my $raw_cluster=shift;
my $raw_read_in_cluster=shift;
my $fragment_num_cutoff=shift;
my $outprefix=shift;

open(RC,$raw_cluster) || die;
open(RRIC,$raw_read_in_cluster) || die;
open(OUTFC,">$outprefix.count_fragment.filtered.cluster") || die;
open(OUTRIFC,">$outprefix.readID.IN.filtered.cluster") || die;

while(my $line=<RC>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my @read_id;
	foreach (1..$sub[7]){
		my $tmp=<RRIC>;
		push (@read_id,$tmp);
	}
	if($sub[-1] >= $fragment_num_cutoff){
		print OUTFC $line,"\n";
		foreach (@read_id){
			print OUTRIFC $_;
		}
	}
}
