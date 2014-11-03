# the size_factors.txt file needs to be in your main project directory

mkdir UCSC_visualisation

mv size_factors.txt UCSC_visualisation

# does this work? I have no clue!
cd UCSC_visualisation

# size factor names need to match whatever is in the bedgraph folder and comes before _unique
perl ~/software/scripts/scaling_factor_normalization.pl ../bedgraph

~/software/scripts/UCSC_normalized_bedgraph2bigwig.sh

scp bigwig/*.bw ja313@tobias.cscr.cam.ac.uk:~/htdocs/Riboseq_P0012

ls bigwig/ > filenames_norm.txt