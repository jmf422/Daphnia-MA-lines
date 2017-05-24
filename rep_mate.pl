#!usr/bin/perl
# rep_mate.pl
# identifies repeats in every read, and counts them, version 2.
use strict;
use warnings;
use POSIX;

my $input1 = shift @ARGV;
my $input2 = $input1;
$input2 =~ s/1.rep/2.rep/;

print "$input1\n$input2\n";

open REP1, $input1 or die;
open REP2, $input2 or die;

my %rep1_hash;
my $line_counter = 0;
my $seq_ID;
my $seq;
my $seq_line3;
my $quality;
my $rep;	
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
		$rep = $_;
		my $index = substr($seq_ID, 17, -23);
		$rep1_hash{$index} = join("\n", $seq_ID, $seq, $seq_line3, $quality, $rep);
	}
	
}

my %rep2_hash;
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
		$rep = $_;
		my $index = substr($seq_ID, 17, -23);
		$rep2_hash{$index} = join("\n", $seq_ID, $seq, $seq_line3, $quality, $rep);
	}
	
}
open OUT1, ">$input1.mp";
foreach my $key (sort(keys %rep1_hash)) {
	my @read1 = split("\n", $rep1_hash{$key});
	if ($rep2_hash{$key}) {
		my @read2 = split("\n", $rep2_hash{$key});
		$read1[4] = $read1[4] . ";" . "MP:" . $read2[4];
	} else {
		$read1[4] = $read1[4] . ";" . "MP:" . "na";
	}
	foreach my $line (@read1) {
		print OUT1 "$line\n";
	}
}
open OUT2, ">$input2.mp";
foreach my $key (sort(keys %rep2_hash)) {
	my @read1 = split("\n", $rep2_hash{$key});
	if ($rep1_hash{$key}) {
		my @read2 = split("\n", $rep1_hash{$key});
		$read1[4] = $read1[4] . ";" . "MP:" . $read2[4];
	} else {
		$read1[4] = $read1[4] . ";" . "MP:" . "na";
	}
	foreach my $line (@read1) {
		print OUT2 "$line\n";
	}
}