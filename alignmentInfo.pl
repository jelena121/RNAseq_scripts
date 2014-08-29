use v5.10.0;
use strict;
use warnings;

# reads directories in the current location
opendir (DIR, ".");
my @files = readdir(DIR);
my @output = grep { -d } @files;
my @dirs;

foreach (@output) {
	if ($_ =~ /thout/) {
		push(@dirs, $_);
	}
}


foreach my $directory (@dirs) {
	open FILE, "$directory/align_summary.txt";
	my $count = 0;
	my $input;
	my $mapped;
	my $non_unique;
	my $perc_mapped;
	my $perc_non_unique;
	$directory =~ /(.+)\_thout/;
	my $name = $1;
		
	while (my $line = <FILE>) {
		chomp $line;
		if ($line =~ /Input.+(\d+)/) {
			$input = $1;	
		}	
	}
	close FILE;
	say "$name\t$input";

}