#takes in a list of transcript IDs
#prints out gene names+ biotypes

use v5.10.0;
use strict;
use warnings;

sub extractQuote {
	my $sentence = $_[0];
	if ($sentence =~ /"(.+)"/) {
		$sentence = $1;
	}
	return $sentence;
}

#loads genome annotations into memory
open FILE, "/Users/jelena/Bigdata/genome/Homo_sapiens.GRCh38.76.withchr.gtf";

my %transcriptInfo;
while (my $line = <FILE>) {
 	chomp $line;
 	my @tmp = split(/\t/, $line);
 	my $featureType = $tmp[1];
 	my $strand = $tmp[6];
 	my $info = $tmp[8];
 	
 	my @geneinfo = split(/; /, $info); 

 	my $trans = &extractQuote($geneinfo[1]);
 	my $geneID = &extractQuote($geneinfo[0]);
 	my $geneName = &extractQuote($geneinfo[3]);

 	$transcriptInfo{$trans} = $geneName."\t".$featureType."\t".$geneID;
}
close FILE;

unless (-d "annotated") {
	system "mkdir annotated";
}

opendir DIR, "$ARGV[0]";
my $filename;
while ( $filename = readdir(DIR) ) {
	if($filename=~/(.*).res$/){
		my $name = $1;
		my $counter = 0; 
		my $newfile = $name."_annotated.txt";
		open OUT, ">annotated/$newfile";
		
		open FILE1, "$ARGV[0]/$filename";
		while (my $line = <FILE1>) {
			$counter++;
			chomp $line;
			my @tmp = split(/\t/, $line);
			if ($counter == 1) {
				print OUT "$tmp[0]\tGene name\tBiotype";
				foreach (1..$#tmp) {
					print OUT "\t$tmp[$_]";
				}
				print OUT "\n";
			} else {
				my $trans = &extractQuote($tmp[0]);
				if (exists($transcriptInfo{$trans})) {
					print OUT "$trans\t$transcriptInfo{$trans}";
					foreach (1..$#tmp) {
						print OUT "\t$tmp[$_]";
					}
					print OUT "\n";
				}
			}
		}
		close FILE1;
		close OUT;
	}
}