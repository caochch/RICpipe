#!/usr/bin/perl
use List::Util qw(min max sum);
use List::MoreUtils qw/ uniq/;

die "perl annoFrag.cluster outprefix\n" if(@ARGV != 2);
my $formatted_cluster_overlap_reads=shift;
my $outprefix=shift;

open(OUTC,">$outprefix.count_fragment.cluster") || die;
open(OUTR,">$outprefix.readID.IN.cluster.list") || die;
my $before_cluster;
my %cluster_reads_hash;
my @cluster_reads;
my %cluster_fragment;
open(FC,$formatted_cluster_overlap_reads) || die;
while(my $line=<FC>){
	chomp $line;
	my @sub=split/\s+/,$line;
	if($sub[6] eq $before_cluster){
		$cluster_fragment{$sub[20]}=1;
		#push (@cluster_reads,$sub[10]."\t".$sub[11]."\t".$sub[12]."\t".$sub[13]."\t".$sub[14]."\t".$sub[15]."\t".$sub[16]);
		$cluster_reads_hash{$sub[10]."\t".$sub[11]."\t".$sub[12]."\t".$sub[13]."\t".$sub[14]."\t".$sub[15]."\t".$sub[16]}=1;
	}
	else{
		if($before_cluster){
			my @fragment_list=keys %cluster_fragment;
		        my @cluster_head_chr = ();
		        my @cluster_head_start = ();
		        my @cluster_head_end = ();
		        my @cluster_tail_chr = ();
		        my @cluster_tail_start = ();
		        my @cluster_tail_end = ();
			my @cluster_reads=keys %cluster_reads_hash;
	
			foreach (@cluster_reads){
				($head_chr, $head_start, $head_end, $tail_chr, $tail_start, $tail_end, $pet_id)=split/\s+/,$_;
		                push @cluster_head_chr, $head_chr;
		                push @cluster_head_start, $head_start;
		                push @cluster_head_end, $head_end;
		                push @cluster_tail_chr, $tail_chr;
		                push @cluster_tail_start, $tail_start;
		                push @cluster_tail_end, $tail_end;
				print OUTR $before_cluster,"\t",$_,"\n";
		        }
		        @cluster_head_chr_uniq = uniq(@cluster_head_chr);
		        $cluster_head_start_site = min(@cluster_head_start);
		        $cluster_head_end_site = max(@cluster_head_end);
		        @cluster_tail_chr_uniq = uniq(@cluster_tail_chr);
		        $cluster_tail_start_site = min(@cluster_tail_start);
		        $cluster_tail_end_site = max(@cluster_tail_end);
		        print OUTC "@cluster_head_chr_uniq\t$cluster_head_start_site\t$cluster_head_end_site\t@cluster_tail_chr_uniq\t$cluster_tail_start_site\t$cluster_tail_end_site\t";
		        print OUTC $before_cluster,"\t";
		        print OUTC $#cluster_reads+1,"\t";
		        print OUTC $#fragment_list+1,"\n";
	
			%cluster_fragment=();
			%cluster_reads_hash=();
			@cluster_reads=();	
			$before_cluster=$sub[6];
			$cluster_fragment{$sub[20]}=1;
			#push (@cluster_reads,$sub[10]."\t".$sub[11]."\t".$sub[12]."\t".$sub[13]."\t".$sub[14]."\t".$sub[15]."\t".$sub[16]);
			$cluster_reads_hash{$sub[10]."\t".$sub[11]."\t".$sub[12]."\t".$sub[13]."\t".$sub[14]."\t".$sub[15]."\t".$sub[16]}=1;
		}
		else{
			$before_cluster=$sub[6];
			$cluster_fragment{$sub[20]}=1;
			#push (@cluster_reads,$sub[10]."\t".$sub[11]."\t".$sub[12]."\t".$sub[13]."\t".$sub[14]."\t".$sub[15]."\t".$sub[16]);
			$cluster_reads_hash{$sub[10]."\t".$sub[11]."\t".$sub[12]."\t".$sub[13]."\t".$sub[14]."\t".$sub[15]."\t".$sub[16]}=1;
		}
	}
}

#deal again
my @fragment_list=keys %cluster_fragment;
my @cluster_head_chr = ();
my @cluster_head_start = ();
my @cluster_head_end = ();
my @cluster_tail_chr = ();
my @cluster_tail_start = ();
my @cluster_tail_end = ();
my @cluster_reads=keys %cluster_reads_hash;

foreach (@cluster_reads){
	($head_chr, $head_start, $head_end, $tail_chr, $tail_start, $tail_end, $pet_id)=split/\s+/,$_;
	push @cluster_head_chr, $head_chr;
	push @cluster_head_start, $head_start;
	push @cluster_head_end, $head_end;
	push @cluster_tail_chr, $tail_chr;
	push @cluster_tail_start, $tail_start;
	push @cluster_tail_end, $tail_end;
	print OUTR $before_cluster,"\t",$_,"\n";
}
@cluster_head_chr_uniq = uniq(@cluster_head_chr);
$cluster_head_start_site = min(@cluster_head_start);
$cluster_head_end_site = max(@cluster_head_end);
@cluster_tail_chr_uniq = uniq(@cluster_tail_chr);
$cluster_tail_start_site = min(@cluster_tail_start);
$cluster_tail_end_site = max(@cluster_tail_end);
print OUTC "@cluster_head_chr_uniq\t$cluster_head_start_site\t$cluster_head_end_site\t@cluster_tail_chr_uniq\t$cluster_tail_start_site\t$cluster_tail_end_site\t";
print OUTC $before_cluster,"\t";
print OUTC $#cluster_reads+1,"\t";
print OUTC $#fragment_list+1,"\n";
