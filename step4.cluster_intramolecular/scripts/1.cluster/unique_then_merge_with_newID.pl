#!/usr/bin/perl
die "perl $0 *bedpair" if(@ARGV < 1);

my %unique;
foreach my $bedpair_file (@ARGV){
	my $prefix=$bedpair_file;
	$prefix=~s/.merged.intraChimeric.bedpair//;
	open(BF,$bedpair_file) || die;
	while(my $line=<BF>){
		chomp $line;
		my @sub=split/\s+/,$line;
		$sub[6]=$prefix."#".$sub[6];
		
		#unique
		my $scale=50;
		my $left_start=int($sub[1]/$scale);		#choose minimal
		my $left_end;
		if($sub[2] % $scale){	#has reminder;
			$left_end=int(($sub[2]/$scale)+1);	#choose maximal
		}
		else{
			$left_end=int($sub[2]/$scale);
		}
		my $right_start=int($sub[4]/$scale);
		my $right_end;
		if($sub[5] % $scale){	#has reminder;
			$right_end=int(($sub[5]/$scale)+1);
		}
		else{
			$right_end=int($sub[5]/$scale);
		}
		my @pair_info=($sub[0]."\t".$left_start."\t".$left_end,$sub[3]."\t".$right_start."\t".$right_end);
		@pair_info=sort @pair_info;
		my $tmp_pair_info=join"\t",@pair_info;
		if($unique{$tmp_pair_info} > 1){	#keep two pair
			next;
		}
		$unique{$tmp_pair_info}++;
		
		#output
		$sub[1]=$scale*$left_start;
		$sub[2]=$scale*$left_end;
		$sub[4]=$scale*$right_start;
		$sub[5]=$scale*$right_end;
		my $new_line=join"\t",@sub;
		print $new_line,"\n";
	}
	close BF;
}
		

