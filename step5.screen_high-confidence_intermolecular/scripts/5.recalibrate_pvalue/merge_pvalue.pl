#!/usr/bin/perl
die "perl *simulated.thread.xls\n" if(@ARGV < 2);
my @pvalue_files=@ARGV;

my %pairs_info;

foreach my $i (0..$#pvalue_files){
	my $pfile=$pvalue_files[$i];
	if($i < $#pvalue_files){
		open(PF,$pfile) || die;
		while(my $line=<PF>){
			chomp $line;
			my @sub=split/\s+/,$line;
			my $gene_a=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
	        	my $gene_b=$sub[6]."\t".$sub[7]."\t".$sub[8]."\t".$sub[9]."\t".$sub[10]."\t".$sub[11];
	        	my @pair=($gene_a,$gene_b);
	        	@pair=sort @pair;
			$pairs_info{$pair[0]."\t".$pair[1]}{"Observed"}=$sub[12];
			$pairs_info{$pair[0]."\t".$pair[1]}{"Random"}+=$sub[13]*$sub[15];
			$pairs_info{$pair[0]."\t".$pair[1]}{"pvalue"}+=$sub[14]*$sub[15];
			$pairs_info{$pair[0]."\t".$pair[1]}{"SimulatedTimes"}+=$sub[15];
		}
	}
	else{#the last file
                open(PF,$pfile) || die;
                while(my $line=<PF>){
                        chomp $line;
                        my @sub=split/\s+/,$line;
                        my $gene_a=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
                        my $gene_b=$sub[6]."\t".$sub[7]."\t".$sub[8]."\t".$sub[9]."\t".$sub[10]."\t".$sub[11];
                        my @pair=($gene_a,$gene_b);
                        @pair=sort @pair;
                        $pairs_info{$pair[0]."\t".$pair[1]}{"Observed"}=$sub[12];
                        $pairs_info{$pair[0]."\t".$pair[1]}{"Random"}+=$sub[13]*$sub[15];
                        $pairs_info{$pair[0]."\t".$pair[1]}{"pvalue"}+=$sub[14]*$sub[15];
                        $pairs_info{$pair[0]."\t".$pair[1]}{"SimulatedTimes"}+=$sub[15];

			#output
			print $pair[0]."\t".$pair[1],"\t";
			print $pairs_info{$pair[0]."\t".$pair[1]}{"Observed"},"\t";
			my $random_contact=$pairs_info{$pair[0]."\t".$pair[1]}{"Random"}/$pairs_info{$pair[0]."\t".$pair[1]}{"SimulatedTimes"};
			my $pvalue=$pairs_info{$pair[0]."\t".$pair[1]}{"pvalue"}/$pairs_info{$pair[0]."\t".$pair[1]}{"SimulatedTimes"};
			print $random_contact,"\t",$pvalue,"\t",$pairs_info{$pair[0]."\t".$pair[1]}{"SimulatedTimes"},"\n";
		
                }
	}
}
	

