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

say "Sample\tTotal reads\tMapped reads\tPerc mapped\tNon unique\tPerc non unique";

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
		if ($line =~ /Input.+?(\d+)/g) {
			$input = $1;	
		}	
		if ($line =~ /Mapped.+?(\d+).+?(\d*\.\d\%)/g) {
			$mapped = $1;	
			$perc_mapped = $2;
		}
		if ($line =~ /of these.+?(\d+).+?(\d*\.\d\%)/g) {
			$non_unique = $1;	
			$perc_non_unique = $2;
		}
	}
	close FILE;
	say "$name\t$input\t$mapped\t$perc_mapped\t$non_unique\t$perc_non_unique";

}