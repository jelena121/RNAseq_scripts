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
my $coordsfile = "results/bed_coords_".$namematch.".txt";


# cycle through each file extracting coords


my $filecount = 0;
foreach my $file (@filepaths) {
	if ($file =~ /$namematch/) {
		my %scores;
		say "Reading in scores from $file";
		$filecount++;
		
		# working on individual file
		
		open FILE, $file;
		while (my $line = <FILE>) {
			chomp $line;
			my @tmp = split(/\t/, $line);
			my $chr = $tmp[0]; 
			my $ntl = $tmp[1];
			my $ntr = $tmp[2];
			my $score = $tmp[3];
	
			my $end = $ntr - 1;
	
			foreach my $current ($ntl .. $end) {
				my $secondcoord = $current+1;
				my $coord = "$chr\t$current\t$secondcoord";
		
				$scores{$coord} = $score;
			}
		}
		close FILE;		
		
		
		#spit out intermediate file with coordinates? 

		if ($filecount == 1) {
			# already defined coordsfile
		} else {
			my $lastfile = $filecount - 1;
			$coordsfile =  "results/bed_coords_".$namematch.$lastfile.".txt";
		}
		
		open COORDS, $coordsfile;
		say "Adding scores to $coordsfile";
		open OUT, ">results/bed_coords_".$namematch.$filecount.".txt";
		my $linecount = 0;
		while (my $line = <COORDS>) {
			chomp $line;
			$linecount++;
			if ($linecount == 1) {
				say OUT "$line\t$file";
			} else {		
				my @tmp = split(/\t/, $line);
				my $chr = $tmp[0]; 
				my $ntl = $tmp[1];
				my $ntr = $tmp[2];
		
				my $currentcoord = "$chr\t$ntl\t$ntr";
		
				if (exists($scores{$currentcoord})) {
					say OUT "$line\t$scores{$currentcoord}";
				} else {
					say OUT "$line\t0";
				}
	
			}
		}
		close COORDS;
		close OUT;
		
		system "rm $coordsfile";
		
	}
}
