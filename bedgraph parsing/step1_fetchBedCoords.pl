use v5.10.0;
use strict;
use warnings;

my $count = 0;

my @filepaths;

open FILE, "data/paths.txt";
while (my $line = <FILE>) {
	chomp $line;
	$count++;
	my @tmp = split(/\t/, $line);
	push(@filepaths, $line);
}
close FILE;

# specify which files
my $namematch = $ARGV[0];

unless (-d "results") {
	system "mkdir results";
}
open OUT, ">results/bed_coords_".$namematch.".txt";

#print header
print OUT "Chr\tNtl\tNtr\n";

# cycle through each file extracting coords

my %bedcoords;
foreach my $file (@filepaths) {
	if ($file =~ /$namematch/) {
		say $file;
		
		# working on individual files
		
		open FILE, $file;	
		while (my $line = <FILE>) {
			chomp $line;
			my @tmp = split(/\t/, $line);

			my $chr = $tmp[0]; 
			if ($tmp[0] =~ /chr(.+)/) {
				$chr = $1;
			}
				
			my $ntl = $tmp[1];
			my $ntr = $tmp[2];
			my $score = $tmp[3];
		
			my $end = $ntr - 1;
		
			foreach my $coord ($ntl .. $end) {
				$bedcoords{$chr}{$coord}++;
			}
		
	
		}
		close FILE;		
		
	}
}

#print body
foreach my $chrom (sort keys %bedcoords) {
	foreach my $firstcoord (sort {$a <=> $b} keys %{$bedcoords{$chrom}}) {
		my $nextcoord = $firstcoord +1;
		say OUT "chr$chrom\t$firstcoord\t$nextcoord";
	}
}
close OUT;