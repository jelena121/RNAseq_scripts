use v5.10.0;
use strict;
use warnings;
use Math::Round;

unless (-d "results_means") {
	system "mkdir results_means";
}

unless (-d "results_means_rounded") {
	system "mkdir results_means_rounded";
}



# cycle through each file calculating means for it
opendir DIR, "results";
my $filename;
while ( $filename = readdir(DIR) ) {


	if($filename=~/(.*).txt$/i){
		say "Working on $filename";
		my $name = substr($1, 0, -1);
		
 		my $newfile = $name."_means.txt";
 		my $newfileround = $name."_means_rounded.txt";
		open OUT, ">results_means/$newfile";
		open OUT2, ">results_means_rounded/$newfileround";
		say "Writing out $newfile";

		open FILE1, "results/$filename";
		
		my $linecount = 0;
		my $colnumber = 0;
		while (my $line = <FILE1>) {
			$linecount++;
			chomp $line;
			
			
			my @tmp = split(/\t/, $line);
			
			if ($linecount == 1) {
				say OUT "$tmp[0]\t$tmp[1]\t$tmp[2]\t$name"."_means";
				say OUT2 "$tmp[0]\t$tmp[1]\t$tmp[2]\t$name"."_means_rounded";
				foreach (3 .. $#tmp) {
					$colnumber++;
				}
				say "$colnumber replicates";				

			} else {
			
				my $chr = $tmp[0];
				my $ntl = $tmp[1];
				my $ntr = $tmp[2];
				my $score = $tmp[3];
				foreach (4 .. $#tmp) {
					$score = $score + $tmp[$_];
				}
			
				my $norm_score = $score / $colnumber;
			
				say OUT "$chr\t$ntl\t$ntr\t$norm_score";
			
				my $rounded_score = round( $norm_score );
				say OUT2 "$chr\t$ntl\t$ntr\t$rounded_score";					
			}	
		}
		
	} 
	close OUT;
	close OUT2;
	
	

}