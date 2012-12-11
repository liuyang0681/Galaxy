#!/usr/bin/perl

#purpose: script which calculates the percent of genome coverage and average coverage of bases
#author: Ziru Zhou
#date: October, 2012


use strict;
use warnings;
use File::Basename;

#globals
#======================================================================
my $bamfile = $ARGV[0];
my $reffile = $ARGV[1];
my $outputfile = $ARGV[2];
my $bamname = $ARGV[3];
my $refname = $ARGV[4];

my $genomesize = 0;
my $pileupwc = 0;
my $pileupc4 = 0;

my $percentofcover = 0;
my $averagebasecoverage = 0;


#function declarations
#======================================================================
#get the pileupwc value
sub Getpileupwc()
{
	#system ("samtools pileup -f ${reffile} ${bamfile} | cut --fields=4 > tmp");
	#$pileupwc = `cat tmp | wc -l`;
	$pileupwc = `samtools pileup -f ${reffile} ${bamfile} | cut --fields=4 | wc -l`;
}

#get the pileupc4 value
sub Getpileupc4()
{
	$pileupc4 = `samtools pileup -f ${reffile} ${bamfile} | cut --fields=4 | awk '{ total += \$1 } END { print total }'`;
}

#get the genomesize value
sub Getgenomesize()
{
	$genomesize = `tail -n 1 "$reffile.fai"| cut --fields=3`;
}

#function to calculate the final 2 values for output
sub Calculate()
{
	$percentofcover = ( int($pileupwc) / int($genomesize) ) * 100;
	$averagebasecoverage = int($pileupc4) / int($pileupwc);
}

#function to write to output file
sub Output()
{
	open FILE, '>'.$outputfile or die "unable to create $outputfile\n";

	print FILE "\n#";
	print FILE "\n# Generated by BAMEdit.  Please send your questions/comments to modENCODE DCC at help\@modencode.org.";
	print FILE "\n#";
	print FILE "\n# coverage: % of bases in genome covered";
	print FILE "\n# avg coverage: average coverage of bases covered in genome ";
	print FILE "\n#\n";
	print FILE "input file\t$bamname\n";
	print FILE "genome file\t$refname\n";
	print FILE "genome length\t$genomesize";
	printf FILE "coverage\t%.2f\n", $percentofcover;
	printf FILE "avg coverage\t%.2f\n", $averagebasecoverage;

	close FILE;
}

#function to clean up, the tmp file and the .fai file 
sub Cleanup()
{
	system ("sudo rm ${reffile}.dat.fai");
}

#function calls
#======================================================================
Getpileupwc();
Getpileupc4();
Getgenomesize();
Calculate();
Output();
Cleanup();