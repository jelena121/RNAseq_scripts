#rename files
#requires the file naming_scheme.txt as input
# 1st column = old name
# 2nd column = desired new name
#perl ~/software/scripts/renamefiles.pl

# initial QC and number of read counts
# PATH=$PATH\:~/software/fastqc ; export PATH
# fastqc raw_data/*
# mkdir raw_data_qc
# mv raw_data/*fastqc* raw_data_qc
# pushd raw_data_qc/
# for file in *.zip; do
# 	unzip file
# done
# perl ~/software/scripts/getReadCountQC.pl > readcount_table_raw_data.txt
# popd 
# mv raw_data_qc/readcount_table_raw_data.txt .

# Tophat alignment
# for file in raw_data/*.fq.gz; do
# 	echo $(date)
# 	echo $file
# 	echo $file > temp
# 	sample=$(cut -d . -f 3 temp)
# 	echo $sample
# 	
# 	tophat -p 12 -o ${sample}_thout -G ~/genomes/Homo_sapiens/Ensembl/GRCh38/Annotation/rel_76/Homo_sapiens.GRCh38.76.withchr.gtf -m 2 /home/ja313/genomes/Homo_sapiens/Ensembl/GRCh38/Sequence/Bowtie2Index/hg38_genome $file
# 	
# done
# rm temp

#perl alignmentInfo.pl > tophat_alignment_summary.txt



# for condition in do8155_Nsun2kd_144h do8155_control_144h do8156_Nsun2kd_72h do8156_control_72h; do
# 	for replicate in a b c d; do
# 		tophat -p 12 -o ${condition}_${replicate}_thout -G 	~/genomes/Homo_sapiens/Ensembl/GRCh37/Annotation/rel_71/Homo_sapiens.GRCh37.71.gtf -m 2 genome raw_data/${condition}_${replicate}_r1.fq.gz,raw_data/${condition}_${replicate}_r2.fq.gz
# 	done
# done
# 
# mkdir sam_files
# mkdir bam_files
# mkdir trans_counts
# mkdir bedgraph
# mkdir bigwig
# 
# 
# for replicate in a b c d; do
# 	for condition in do8155_Nsun2kd_144h do8156_Nsun2kd_72h do8155_control_144h do8156_control_72h; do
# 		# make a sam file and extract unique hits
# 		echo "Creating ${condition}_${replicate} sam file"
# 		samtools view -h ${condition}_${replicate}_thout/accepted_hits.bam > sam_files/do7648_${condition}_${replicate}_accepted.sam
# 		echo "Sam file created"
# 		echo $(date)
# 	
# 		echo "Extracting ${condition}_${replicate} unique hits"
# 		egrep '(NH:i:1)|(^@)' sam_files/do7648_${condition}_${replicate}_accepted.sam > sam_files/do7648_${condition}_${replicate}_unique.sam
# 		echo "Unique hits extracted"
# 		echo $(date)
# 	
# 		echo "Turning ${condition}_${replicate} unique hits to bam file"
# 		samtools view -S -b sam_files/do7648_${condition}_${replicate}_unique.sam > bam_files/do7648_${condition}_${replicate}_unique.bam
# 		echo "Bam file created"
# 		echo $(date)
# 	
# 		# getting a read count per transcript
# 	
# 		echo "Getting ${condition}_${replicate} read count per transcript"
# 		htseq-count -i transcript_id -m intersection-nonempty sam_files/do7648_${condition}_${replicate}_unique.sam ~/genomes/Homo_sapiens/Ensembl/GRCh37/Annotation/rel_71/Homo_sapiens.GRCh37.71.gtf > trans_counts/do7648_${condition}_${replicate}_transcript_counts.txt &
# 		echo "Read count per transcript done"
# 		echo $(date)
# 	
# 		#convert bam to bedgraph
# 		echo "Creating bedgraph for ${condition}_${replicate}"
# 		genomeCoverageBed -bg -split -ibam bam_files/do7648_${condition}_${replicate}_unique.bam -g ~/software/UCSC/hg19_genome_UCSC_nochr.table > bedgraph/do7648_${condition}_${replicate}_unique.bedgraph
# 		echo "Bedgraph done"
# 		echo $(date)
# 
# 		#add chr to the chromosome name
# 		echo "Adding chr for ${condition}_${replicate}"
# 		awk '{print "chr"$0}' bedgraph/do7648_${condition}_${replicate}_unique.bedgraph > bedgraph/do7648_${condition}_${replicate}_unique_chr.bedgraph
# 		echo $(date)
# 	
# 		echo "Replacing MT for ${condition}_${replicate}"
# 		# replace 'MT' chromosome to correct UCSC term 'chrM'
# 		sed -e "s/chrMT/chrM/ig" bedgraph/do7648_${condition}_${replicate}_unique_chr.bedgraph > /tmp/tempfile.tmp
# 		mv /tmp/tempfile.tmp bedgraph/do7648_${condition}_${replicate}_unique_chr.bedgraph
# 		echo "Renaming done"
# 		echo $(date)
# 	
# 		#convert bedgraph to bigwig
# 		echo "Converting bedgraph to bigwig for ${condition}_${replicate}"
# 		~/software/UCSC/bedGraphToBigWig bedgraph/do7648_${condition}_${replicate}_unique_chr.bedgraph ~/software/UCSC/hg19_genome_UCSC.table bigwig/do7648_${condition}_${replicate}_unique_chr.bw
# 		echo "BigWig conversion done"
# 		echo $(date)
# 	done
# done
# 
# echo $(date)