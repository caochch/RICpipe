#!/usr/bin/perl
use List::Util qw(shuffle); 
die "perl $0 observed.gene-gene.network" if(@ARGV != 1);
my $net=shift;

my %gene_total_read;
my %network;
open(NT,$net) || die;
while(my $line=<NT>){
	chomp $line;
	my @sub=split/\s+/,$line;
        my $gene_a=$sub[0]."\t".$sub[1]."\t".$sub[2]."\t".$sub[3]."\t".$sub[4]."\t".$sub[5];
        my $gene_b=$sub[6]."\t".$sub[7]."\t".$sub[8]."\t".$sub[9]."\t".$sub[10]."\t".$sub[11];
        my $num=$sub[12];
        my @pair=($gene_a,$gene_b);
        @pair=sort @pair;
	$network{$pair[0]."\t".$pair[1]}=$num;
	$gene_total_read{$gene_a}+=$num;
	$gene_total_read{$gene_b}+=$num;
}

#check
my $total_links;
foreach (keys %network){
        $total_links+=$network{$_};
}

my @sorted_genes=sort {$gene_total_read{$b} <=> $gene_total_read{$a}} keys %gene_total_read;
my @artifical_in;
my @artifical_out;
foreach (1..$total_links){
	push (@artifical_in,$_);
	push (@artifical_out,$_);
}

my $round;
while(1){
	$round++;

	my @random_artifical_in=shuffle(@artifical_in);
	my @random_artifical_out=shuffle(@artifical_out);
	my $in_is_less;
	my %in_link_gene;
	my %out_link_gene;
	foreach my $g (@sorted_genes){
		my $total_degree=$gene_total_read{$g};
		#print $g,"\t",$total_degree,"\n";
		
		my $in_degree=int($total_degree/2);
		if($in_is_less < 0){
			$in_degree++;
		}	
		my $out_degree=$total_degree-$in_degree;
		$in_is_less+=$in_degree-$out_degree;

		my %in_link_currently;
		foreach (1..$in_degree){
			my $index_of_in=shift @random_artifical_in;
			$in_link_currently{$index_of_in}=1;
			$in_link_gene{$index_of_in}=$g;
			#print $index_of_in,"\t$g\tin\n";
		}

		my @effective_out;
		my $number_need=$out_degree;
		foreach (1..5){
			my @pushed_back;
			#print "@random_artifical_out\t\n";
			foreach (1..$number_need){
				my $index_of_out=shift @random_artifical_out;
				if(!exists $in_link_currently{$index_of_out}){
					push (@effective_out,$index_of_out);
				}
				else{
					push (@pushed_back,$index_of_out)
				}
			}
			if(@pushed_back){
				push (@random_artifical_out,@pushed_back);
				$number_need=$#pushed_back+1;
				#print "@random_artifical_out\t\n";
			}
			else{
				last;
			}
		}
		foreach (@effective_out){
			$out_link_gene{$_}=$g;
			#print $_,"\t$g\tout\n";
		}
	}

	my $effective_links;
	foreach (1..$total_links){
		if(exists $in_link_gene{$_} and exists $out_link_gene{$_}){
			$effective_links++;
		}
	}

	if($effective_links > 0.95*$total_links){
		my %random_network;
		foreach (1..$total_links){
			if(exists $in_link_gene{$_} and exists $out_link_gene{$_}){
				my @pair=($in_link_gene{$_},$out_link_gene{$_});
				@pair=sort @pair;
				$random_network{$pair[0]."\t".$pair[1]}++;
				#print $pair[0]."\t".$pair[1],"\tbbb\n";
			}
		}
		foreach (keys %random_network){
			print $_,"\t",$random_network{$_},"\n";
		}
		last;
	}
	else{
	}
}






