#!/usr/bin/perl
die "perl $0 rep1.netowkr rep2.network et al\n" if(@ARGV < 1);
my @network_files=@ARGV;
my %all_gene_pair;

foreach my $network (@network_files){
	open(RNA,$network) || die;
	while(my $line=<RNA>){
		chomp $line;
		my @sub=split/\s+/,$line;
		my $gene_a=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
		my $gene_b=$sub[6]."\t".$sub[7]."\t".$sub[8]."\t".$sub[9]."\t".$sub[10]."\t".$sub[11];
		my $num=$sub[12];
		my @pair=($gene_a,$gene_b);
		@pair=sort @pair;
		$all_gene_pair{$pair[0]."\t".$pair[1]}+=$num;
	}
	close RNA;
}

foreach (keys %all_gene_pair){
	print $_,"\t",$all_gene_pair{$_},"\n";
}
