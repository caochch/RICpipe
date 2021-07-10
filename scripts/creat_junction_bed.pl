#!/usr/bin/perl
die "perl $0 gencode.v19.annotation.bed \n" if(@ARGV != 1);
my $gene_bed=shift;
open(GB,$gene_bed) || die;
while(my $line=<GB>){
        chomp $line;
        my @sub=split/\s+/,$line;
        my $gene=shift @sub;
        my $chr=shift @sub;
	my $start=shift @sub;
	my $end=shift @sub;
	my $strand=shift @sub;
        if(@sub==1){
                next;
        }
        foreach (1..$#sub){
                my $last_exon_end=(split/-/,$sub[$_-1])[1];
                my $this_exon_start=(split/-/,$sub[$_])[0];
		print $chr,"\t",$last_exon_end-5,"\t",$last_exon_end+5,"\t",$chr,"\t",$this_exon_start-5,"\t",$this_exon_start+5,"\t";
		print $gene,"\t60\t$strand\t$strand\n";
        }
}
