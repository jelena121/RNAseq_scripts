use v5.10.0;
use strict;
use warnings;

my %files;

my $htdir = "RNAseq_P0013";

open FILE, $ARGV[0];
while (my $line = <FILE>) {
	chomp $line;
	my @tmp = split(/\t/, $line);
	$files{$tmp[0]}++;
	
}
close FILE;

if (-e "colour_scheme.txt") {
	my %col;
	open FILE, "colour_scheme.txt";
	while (my $line = <FILE>) {
		chomp $line;
		my @tmp = split(/\t/, $line);
		$col{$tmp[0]} = $tmp[1];
	}
	close FILE;

	foreach my $bwname (sort keys %files) {
	
	
		if ($bwname =~/(.*)\_unique\.bw/) {			
			my $name = $1;
			my $sample = substr($name, 0, -1);
			
			say "track type=bigWig name=\"$name norm\" bigDataUrl=http://jelena.results.cscr.cam.ac.uk/$htdir/$bwname alwaysZero=On windowingFunction=maximum visibility=full  color=$col{$sample}\n"
		}
		if ($bwname =~/(.*)\_norm.+\.bw/) {
			my $name = $1;
			my $sample = substr($name, 0, -1);
			say "track type=bigWig name=\"$name\" bigDataUrl=http://jelena.results.cscr.cam.ac.uk/$htdir/$bwname alwaysZero=On windowingFunction=maximum visibility=full color=$col{$sample}\n"
		}
	}

} else {
	warn "colour scheme missing\n";

}