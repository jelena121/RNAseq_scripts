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

#perl ~/software/scripts/alignmentInfo.pl > tophat_alignment_summary.txt
# 
# 
# mkdir sam_files
# mkdir bam_files
# mkdir trans_counts
# mkdir bedgraph
# mkdir bigwig


for file in raw_data/*.fq*; do
	echo $(date)
	echo $file
	echo $file > temp
	sample=$(cut -d . -f 3 temp)
	echo $sample

# make a sam file and extract unique hits
# 	echo "Creating ${sample} sam file"
# 	samtools view -h ${sample}_thout/accepted_hits.bam > sam_files/${sample}_accepted.sam
# 	echo "Sam file created"
# 	echo $(date)
# 
# 	echo "Extracting ${sample} unique hits"
# 	egrep '(NH:i:1)|(^@)' sam_files/${sample}_accepted.sam > sam_files/${sample}_unique.sam
# 	echo "Unique hits extracted"
# 	echo $(date)
# 
# 	echo "Turning ${sample} unique hits to bam file"
# 	samtools view -S -b sam_files/${sample}_unique.sam > bam_files/${sample}_unique.bam
# 	echo "Bam file created"
# 	echo $(date)

#	echo "Making a bam index for viewing"
#	samtools index bam_files/${sample}_unique.bam bam_files/${sample}_unique.bai

	# getting a read count per transcript
# 	echo "Getting ${sample} read count per transcript"
# 	htseq-count -i transcript_id -m intersection-nonempty sam_files/${sample}_unique.sam ~/genomes/Homo_sapiens/Ensembl/GRCh38/Annotation/rel_76/Homo_sapiens.GRCh38.76.withchr.gtf > trans_counts/${sample}_transcript_counts.txt &
# 	echo "Read count per transcript done"
# 	echo $(date)
# 
# 	#convert bam to bedgraph
# 	echo "Creating bedgraph for ${sample}"
# 	genomeCoverageBed -bg -split -ibam bam_files/${sample}_unique.bam -g ~/software/UCSC/hg38_genome_UCSC.table > bedgraph/${sample}_unique.bedgraph
# 	echo "Bedgraph done"
# 	echo $(date)

	echo "Replacing MT for ${sample}"
	# replace 'MT' chromosome to the UCSC term 'chrM' for track upload
	sed -e "s/chrMT/chrM/ig" bedgraph/${sample}_unique.bedgraph > /tmp/tempfile.tmp
	mv /tmp/tempfile.tmp bedgraph/${sample}_unique.bedgraph
	echo "Renaming done"
	echo $(date)

	#convert bedgraph to bigwig
	echo "Converting bedgraph to bigwig for ${sample}"
	~/software/UCSC/bedGraphToBigWig bedgraph/${sample}_unique.bedgraph ~/software/UCSC/hg38_genome_UCSC.table bigwig/${sample}_unique.bw
	echo "BigWig conversion done"
	echo $(date)
done
rm temp