use v5.10.0;
use strict;
use warnings;

opendir (DIR, ".");
my @files = readdir(DIR);
my @output = grep { -d } @files;
my @dirs;

foreach (@output) {
	if ($_ =~ /fastqc/) {
		push(@dirs, $_);
	}
}

#print @dirs;

foreach my $directory (@dirs) {
	open FILE, "$directory/fastqc_data.txt";
	while (my $line = <FILE>) {
		chomp $line;
		if ($line =~ /Total Sequences\s(\d+)/) {
			my $readcount = $1;
			$directory =~ /(.+)\_fastqc/;
			
			my $million = $readcount / 1000000;
			
			my $roundedmillion = sprintf "%.1f", $million;
			
			#filename
			my $name = $1;		
			say "$name\t$roundedmillion";
		}
	
	}
	close FILE;

}