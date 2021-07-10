#!/usr/bin/perl
die "perl $0 <in.gtf>\n" if(@ARGV != 1);
my $gtf=shift;

my $begin;
my $trans_strand;
my $trans_id;

my @exons;

open(GTF,$gtf) || die;
while(my $line=<GTF>){
	chomp $line;
	my @sub=split/\s+/,$line;
	if($sub[2] =~ /transcript/){
		if($begin){
			if($trans_strand eq "+"){
			}
			else{
				@exons=reverse @exons;
			}
			foreach (@exons){
				print $_,"\t";
			}
			print "\n";
			@exons=();
			$trans_strand=$sub[6];
			$trans_id=$sub[9]."_".$sub[11]."_".$sub[17];
			$trans_id=~s/"//g;
			$trans_id=~s/;//g;
			print $trans_id,"\t",$sub[0],"\t",$sub[3],"\t",$sub[4],"\t",$trans_strand,"\t";
		}
		else{
			$trans_strand=$sub[6];
			$trans_id=$sub[9]."_".$sub[11]."_".$sub[17];
			$trans_id=~s/"//g;
			$trans_id=~s/;//g;
			print $trans_id,"\t",$sub[0],"\t",$sub[3],"\t",$sub[4],"\t",$trans_strand,"\t";
			$begin=1;
		}
	}
	elsif($sub[2] =~ /exon/){
		my $info=$sub[3]."-".$sub[4];
		push (@exons,$info);
	}
	else{
	}
}

if($trans_strand eq "+"){
}
else{
	@exons=reverse @exons;
}
foreach (@exons){
	print $_,"\t";
}
print "\n";
