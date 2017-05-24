#!usr/bin/perl
# mp.compile.pl
# organize mate pair data into matrix
use strict;
use warnings;
use POSIX;

my $input1 = $ARGV[0];
my $input2 = $ARGV[1];
open REP1, $input1 or die;
open REP2, $input2 or die;
my $out = $ARGV[2];

open OUT1, ">$out.rep.mpx" or die;
open OUT2, ">$out.unique.mpx" or die;

my %rep_HoH;
my $line_counter = 0;
my $seq_ID;
my $seq;
my $seq_line3;
my $quality;
my $rep;
my %unique;
my %repeat;
while (<REP1>) {
	s/[\r\n]+$//;
	$line_counter ++;
	if ($line_counter == 1) {
		$seq_ID = $_ ;
	} elsif ($line_counter == 2) {
		$seq = $_ ;
	} elsif ($line_counter == 3) {
		$seq_line3 = $_ ;
	} elsif ($line_counter == 4) {
		$quality = $_;
	} elsif ($line_counter == 5) {
		$line_counter = 0;
		my @line = split ";", $_;
		my @mp1 = split "=", $line[0];
		my $rep1 = &k_order($mp1[0]);
		my @mp2 = split ":", $line[1];
		if ($mp2[1] eq "na") {
		} else {
			my @mate = split "=", $mp2[1];
			if ($mp2[2]) {
				${$rep_HoH{$rep1}}{$mp2[2]} ++;
				$unique{$mp2[2]} ++;
			}
			else {
				my $rep2 = &k_order($mate[0]);
				${$rep_HoH{$rep1}}{$rep2} ++;
				$repeat{$rep2} ++;
			}
		}	
	}
	
}
close REP1;

while (<REP2>) {
	s/[\r\n]+$//;
	$line_counter ++;
	if ($line_counter == 1) {
		$seq_ID = $_ ;
	} elsif ($line_counter == 2) {
		$seq = $_ ;
	} elsif ($line_counter == 3) {
		$seq_line3 = $_ ;
	} elsif ($line_counter == 4) {
		$quality = $_;
	} elsif ($line_counter == 5) {
		$line_counter = 0;
		my @line = split ";", $_;
		my @mp1 = split "=", $line[0];
		my $rep1 = &k_order($mp1[0]);
		my @mp2 = split ":", $line[1];
		if ($mp2[1] eq "na") {
		} else {
			my @mate = split "=", $mp2[1];
			if ($mp2[2]) {
				${$rep_HoH{$rep1}}{$mp2[2]} ++;
				$unique{$mp2[2]} ++;
			}
		}	
	}
	
}
close REP2;

my @repeat_sort = sort(keys %repeat);
my @unique_sort = sort(keys %unique);

foreach my $col (@repeat_sort) {
	print OUT1 "\t$col";
}
print OUT1 "\n";


foreach my $col (@unique_sort) {
	print OUT2 "\t$col";
}
print OUT2 "\n";

foreach my $row (@repeat_sort) {
	print OUT1 "$row";
	if ($rep_HoH{$row}) {
		foreach my $col (@repeat_sort) {
			if (${$rep_HoH{$row}}{$col}) {
				print OUT1 "\t${$rep_HoH{$row}}{$col}"
			} else {
				print OUT1 "\t0";
			}
		}
	} else {
		print OUT1 "\t0" x scalar(@repeat_sort);
	}		
	print OUT1 "\n";
}

foreach my $row (@repeat_sort) {
	print OUT2 "$row";
	if ($rep_HoH{$row}) {
		foreach my $col (@unique_sort) {
			if (${$rep_HoH{$row}}{$col}) {
				print OUT2 "\t${$rep_HoH{$row}}{$col}"
			} else {
				print OUT2 "\t0";
			}
		}
	} else {
		print OUT2 "\t0" x scalar(@unique_sort);
	}		
	print OUT2 "\n";
}

sub k_order { ## subroutine to pick alphabetically the higest kmer offset
	my $kmer = $_[0];
	my $kmerx2 = "$kmer$kmer";
	my @array = ();
	my $sort_counter = 0;
	my $kmer_length = length($kmer);
	while ($sort_counter < $kmer_length) {
		my $subkmer = (substr $kmerx2, $sort_counter, $kmer_length);
		push @array, $subkmer;
		my $revcomp = reverse($subkmer);
		$revcomp =~ tr/ACGTacgt/TGCAtgca/;
		push @array, $revcomp;
		$sort_counter ++;
	}
	@array = sort(@array); # alphabetizing all possible offsets of the repeat.
	return $array[0];
}