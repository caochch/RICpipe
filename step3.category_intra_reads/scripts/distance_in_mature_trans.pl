#!/usr/bin/perl
die "perl $0 hg19.genecodeV19.gene_element.bed gene_overlap_with_read1.bed gene_overlap_with_read2.bed\n" if(@ARGV != 3);
my $gene_element_bed=shift;
my $gene_read_1=shift;
my $gene_read_2=shift;

my %trans_element_loci;
my %trans_strand;
my %trans_type;
open(GEB,$gene_element_bed) || die;
while(my $line=<GEB>){
	chomp $line;
	my @sub=split/\s+/,$line;
	$trans_strand{$sub[3]}{$sub[-1]}=1;
	push (@{$trans_element_loci{$sub[3]}},[$sub[0],$sub[1],$sub[2],$sub[4]]);
	if($sub[4]=~/^PC/){
		$trans_type{$sub[3]}="ProteinCoding";
	}
	elsif($sub[4]=~/^NC/){
		$trans_type{$sub[3]}="NonCoding";
	}
}

my %element_read_A;
open(INA,$gene_read_1) || die;	#read1
while(my $line=<INA>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $read_info=$sub[6]."\t".$sub[7]."\t".$sub[8]."\t".$sub[9]."\t".$sub[10]."\t".$sub[11];
	push (@{$element_read_A{$sub[3]}},$read_info);
}

my %element_read_B;
open(INB,$gene_read_2) || die;	#read2
while(my $line=<INB>){
	chomp $line;
	my @sub=split/\s+/,$line;
	my $read_info=$sub[6]."\t".$sub[7]."\t".$sub[8]."\t".$sub[9]."\t".$sub[10]."\t".$sub[11];
	push (@{$element_read_B{$sub[3]}},$read_info);
}

my %min_fragment_trans;
my %min_fragment_len;
my %distance_in_preRNA;
foreach my $trans (keys %element_read_A){
	my @links;
	if(exists $element_read_B{$trans}){
		my @reads_A_set=@{$element_read_A{$trans}};
		my @reads_B_set=@{$element_read_B{$trans}};
		my %common_id;
		foreach my $tmp_read_a (@reads_A_set){
			my $tmp_read_id=(split/\s+/,$tmp_read_a)[3];
			$common_id{$tmp_read_id}{1}=$tmp_read_a;
		}
		foreach my $tmp_read_b (@reads_B_set){
			my $tmp_read_id=(split/\s+/,$tmp_read_b)[3];
			$common_id{$tmp_read_id}{2}=$tmp_read_b;
		}
		foreach my $i (keys %common_id){
			if(exists $min_fragment_len{$i} and $min_fragment_len{$i} <= 300){	#no need to further test
				next;
			}
			if(!$common_id{$i}{1} or !$common_id{$i}{2}){
				next;
			}
			my $frag_len;
			my $pre_len;
			my $left_read=$common_id{$i}{2};	#read 2; should locate at 5'
			my $right_read=$common_id{$i}{1};	#read 1; should locate at 3'
			($pre_len,$frag_len)=fragment_len_in_mature($left_read,$right_read,$trans);
			$distance_in_preRNA{$i}=$pre_len;
			#print $trans,"\t",$i,"\t",$frag_len,"\tfrag\n";
			if(exists $min_fragment_len{$i}){
				if($frag_len < $min_fragment_len{$i}){
					$min_fragment_len{$i}=$frag_len;
					$min_fragment_trans{$i}=$trans;
				}
			}
			else{
				$min_fragment_len{$i}=$frag_len;
				$min_fragment_trans{$i}=$trans;
			}
		}
	}
	else{
		next;
	}
}

foreach (keys %min_fragment_len){
	print $_,"\t",$distance_in_preRNA{$_},"\t",$min_fragment_len{$_},"\t",$min_fragment_trans{$_},"\n";
}


sub fragment_len_in_mature{
	my $left_read=shift;
	my $right_read=shift;
	my $trans=shift;

	#print $left_read,"\n--vs--\n",$right_read,"\n-------------------------------\n";

	my @left_read_info=split/\s+/,$left_read;
	my @right_read_info=split/\s+/,$right_read;

	my $left_bin;
	my $right_bin;
	my $left_element;
	my $right_element;

	my $trans_len=0;
	my $left_read_to_tss=0;
	my $right_read_to_tss=0;
	my $left_to_right;

	my @raw_trans_element=@{$trans_element_loci{$trans}};

	if($trans_strand{$trans}{"+"} and !$trans_strand{$trans}{"-"}){
		my $left_read_start=int(($left_read_info[1]+$left_read_info[2])/2);	#use middle of 5'read; to eliminate the mini shift at splicing site
		my $right_read_start=$right_read_info[2];
		$left_to_right=$right_read_start-$left_read_start;
                my @trans_element=sort {$a->[1] <=> $b->[1]} @raw_trans_element;   #sort by region start; from min to max
                foreach (0..$#trans_element){
                        #print $trans_element[$_][0],"\t",$trans_element[$_][1],"\t",$trans_element[$_][2],"\t",$trans_element[$_][3],"\tcccc\n";
                        if($trans_element[$_][3] =~ /Intron/){
                                next;
                        }
                        $trans_len+=$trans_element[$_][2]-$trans_element[$_][1];
                }
		my $left_element_index;
                foreach (0..$#trans_element){
                        if($trans_element[$_][2] < $left_read_start){
                                if($trans_element[$_][3] =~ /Intron/){  #intron are not taken into account;
                                        next;
                                }
                                $left_read_to_tss+=$trans_element[$_][2]-$trans_element[$_][1];
                        }
                        elsif($trans_element[$_][1] <= $left_read_start and $trans_element[$_][2] >= $left_read_start){
                                $left_read_to_tss+=$left_read_start-$trans_element[$_][1];
                                $left_element=$trans_element[$_][3];
				$left_element_index=$_;
                                last;
                        }
                        else{
                                last;
                        }
                }
                foreach (0..$#trans_element){
                        if($trans_element[$_][2] < $right_read_start){
                                if($trans_element[$_][3] =~ /Intron/){  #intron are not taken into account;
					if($left_element =~ /Intron/ and $_ >= $left_element_index){
						$right_read_to_tss+=$trans_element[$_][2]-$trans_element[$_][1];
					}
					else{
						next;
					}
                                }
                                else{
					$right_read_to_tss+=$trans_element[$_][2]-$trans_element[$_][1];
				}
                        }
                        elsif($trans_element[$_][1] <= $right_read_start and $trans_element[$_][2] >= $right_read_start){
                                $right_read_to_tss+=$right_read_start-$trans_element[$_][1];
                                $right_element=$trans_element[$_][3];
                                last;
                        }
                        else{
                                last;
                        }
                }
	}
	elsif(!$trans_strand{$trans}{"+"} and $trans_strand{$trans}{"-"}){
		my $left_read_start=int(($left_read_info[1]+$left_read_info[2])/2); #use middle of 5'read; to eliminate the mini shift at splicing site
		my $right_read_start=$right_read_info[1];
		$left_to_right=$left_read_start-$right_read_start;
		my @trans_element=sort {$b->[1] <=> $a->[1]} @raw_trans_element;   #sort by region start; from max to min
		foreach (0..$#trans_element){
			#print $trans_element[$_][0],"\t",$trans_element[$_][1],"\t",$trans_element[$_][2],"\t",$trans_element[$_][3],"\tcccc\n";
			if($trans_element[$_][3] =~ /Intron/){
				next;
			}
			$trans_len+=$trans_element[$_][2]-$trans_element[$_][1];
		}

		my $left_element_index;
                foreach (0..$#trans_element){
                        if($trans_element[$_][1] > $left_read_start){
				if($trans_element[$_][3] =~ /Intron/){	#intron are not taken into account;
					next;
				}
                                $left_read_to_tss+=$trans_element[$_][2]-$trans_element[$_][1];
                        }
                        elsif($trans_element[$_][1] <= $left_read_start and $trans_element[$_][2] >= $left_read_start){
                                $left_read_to_tss+=$trans_element[$_][2]-$left_read_start;
                                $left_element=$trans_element[$_][3];
				$left_element_index=$_;
				last;
                        }
                        else{
				last;
                        }
		}
		foreach (0..$#trans_element){
                        if($trans_element[$_][1] > $right_read_start){
				if($trans_element[$_][3] =~ /Intron/){	#intron are not taken into account;
					if($left_element =~ /Intron/ and $_ >= $left_element_index){
						$right_read_to_tss+=$trans_element[$_][2]-$trans_element[$_][1];
					}
					else{
						next;
					}
				}
                                else{
					$right_read_to_tss+=$trans_element[$_][2]-$trans_element[$_][1];
				}
                        }
                        elsif($trans_element[$_][1] <= $right_read_start and $trans_element[$_][2] >= $right_read_start){
                                $right_read_to_tss+=$trans_element[$_][2]-$right_read_start;
                                $right_element=$trans_element[$_][3];
				last;
                        }
                        else{
				last;
                        }
                }
	}
	else{
		die $trans,"\taaa\n";
		die "wrong trans strand\n";
	}

	#print $left_read_to_tss,"\t",$right_read_to_tss,"\n";

	my $fragment_len=$right_read_to_tss-$left_read_to_tss;
	return ($left_to_right,$fragment_len);
}

