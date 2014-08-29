# reads in a tab delimited file of old and new names
# renames files accordingly
# no headers

use v5.10.0;
use strict;
use warnings;

my %namingscheme;

open FILE, "naming_scheme.txt" or die "Cannot open the naming scheme file";
while (my $line = <FILE>) {
	chomp $line;
	my @tmp = split(/\t/, $line);
	my $oldname = $tmp[0];
	my $newname = $tmp[1];

	$namingscheme{$oldname} = $newname;
}
close FILE;

foreach my $oldname (sort keys %namingscheme) {
	if (-e "raw_data/$oldname") {
		system "mv raw_data/$oldname raw_data/$namingscheme{$oldname}";
	} else {
		warn "$oldname doesn't exist";
	}
}