# parses lots of bedgraph files into a single matrix score table
# bedgraph coords: zero based start, one based end


use v5.10.0;
use strict;
use warnings;


opendir(DIR, $ARGV[0]) or die "can't open $ARGV[0]";
my @files = grep(/\.bedgraph$/,readdir(DIR));
@files = sort @files;

# step 1 = collect all coords that exist in the two files
# removing "chr" in chromosome for easier sorting
# will put it back again when printing out final file

my %bedcoords;
foreach my $file (@files) {
	say "Working on $file";
	open FILE, "$ARGV[0]/$file";
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

# step 2 - there is a hash of correctly sorted coords
# open a file, save file coords in a separate hash
# populate the coords hash


my $counter =0;

foreach my $file (@files) {
	$counter++;
	my %filecoords;
	say "Extracting coords from $file";
	open FILE, "$ARGV[0]/$file";
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
			my $next = $coord+1;
			my $fullcoord = "$chr\t$coord\t$next";
			
			$filecoords{$fullcoord}=$score;
		}
	}
	close FILE;	

	
	if ($counter == 1) {
		foreach my $chrom (sort {$a <=> $b} keys %bedcoords) {
			foreach my $firstcoord (sort {$a <=> $b} keys %{$bedcoords{$chrom}}) {
				my $nextcoord = $firstcoord +1;
		
				my $fullcoord = "$chrom\t$firstcoord\t$nextcoord";
		
				if (exists($filecoords{$fullcoord})) {
					$bedcoords{$chrom}{$firstcoord} = $filecoords{$fullcoord};
				} else {
					$bedcoords{$chrom}{$firstcoord} = 0;
				}
			}	
		}
	} else {
		foreach my $chrom (sort {$a <=> $b} keys %bedcoords) {
			foreach my $firstcoord (sort {$a <=> $b} keys %{$bedcoords{$chrom}}) {
				my $nextcoord = $firstcoord +1;
		
				my $fullcoord = "$chrom\t$firstcoord\t$nextcoord";
		
				if (exists($filecoords{$fullcoord})) {
					$bedcoords{$chrom}{$firstcoord} = $bedcoords{$chrom}{$firstcoord}."\t".$filecoords{$fullcoord};
				} else {
					$bedcoords{$chrom}{$firstcoord} = $bedcoords{$chrom}{$firstcoord}."\t".0;
				}
			}	
		}
	
	}
}
#

# step 3 - print out results
open OUT, ">bedgraph_data_matrix.txt";


#print header
print OUT "Chr\tNtl\tNtr";
foreach my $name (@files) {
	print OUT "\t$name";
}
print OUT "\n";


#print body
foreach my $chrom (sort {$a <=> $b} keys %bedcoords) {
	foreach my $firstcoord (sort {$a <=> $b} keys %{$bedcoords{$chrom}}) {
		my $nextcoord = $firstcoord +1;
		say OUT "chr$chrom\t$firstcoord\t$nextcoord\t$bedcoords{$chrom}{$firstcoord}";
	}
}