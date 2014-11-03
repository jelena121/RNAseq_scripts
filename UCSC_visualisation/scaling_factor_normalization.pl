use v5.10.0;
use strict;
use warnings;
use Math::Round;

sub extractQuote {
	my $sentence = $_[0];
	if ($sentence =~ /"(.+)"/) {
		$sentence = $1;
	}
	return $sentence;
}

my %scaling;

#read in DEseq size factors
open FILE, "size_factors.txt";
while (my $line = <FILE>) {
	chomp $line;
	my @tmp = split(/\t/, $line);
	my $sample = &extractQuote($tmp[0]);
	$scaling{$sample} = $tmp[1];
	
}
close FILE;

foreach (keys %scaling) {
	say "$_\t$scaling{$_}";
}

unless (-d "scaling_normalized") {
	system "mkdir scaling_normalized";
}

unless (-d "scaling_normalized_rounded") {
	system "mkdir scaling_normalized_rounded";
}

opendir DIR, "$ARGV[0]";
my $filename;
while ( $filename = readdir(DIR) ) {
	if($filename=~/(.*)\_unique.bedgraph$/i){
		say "Working on $filename";
		my $name = $1;
		say "$name\t$scaling{$name}";
		my $scaling_factor = $scaling{$name};

		
 		my $newfile = $name."_normalized.bedgraph";
 		my $roundedfile = $name."_normalized_rounded.bedgraph";
		open OUT, ">scaling_normalized/$newfile";
		open OUT2, ">scaling_normalized_rounded/$roundedfile";		
		open FILE1, "$ARGV[0]/$filename";
		while (my $line = <FILE1>) {
			chomp $line;
			my @tmp = split(/\t/, $line);
			
			my $chr = $tmp[0];
			my $ntl = $tmp[1];
			my $ntr = $tmp[2];
			my $score = $tmp[3];
			my $norm_score = $score / $scaling_factor;
			
			say OUT "$chr\t$ntl\t$ntr\t$norm_score";
			
			my $rounded_score = round( $norm_score );
			say OUT2 "$chr\t$ntl\t$ntr\t$rounded_score";					
			
		}
		
	} 

}