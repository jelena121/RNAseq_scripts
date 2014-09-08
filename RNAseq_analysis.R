##
#
#
#
## Calling differentially expressed genes with DEseq


library("DESeq")

# function assumes an object called cds is already loaded into the workspace
# takes in the names of the sample, control and gene annotations
getDEresults <- function(sample, control, annot) {
  
	# calculates and writes table of unfiltered results
	res <- nbinomTest( cds, control, sample )
	write.table(res, file=paste(control, "_vs_", sample, ".res", sep=""), sep="\t")

	# diagnostic MA plot
	pdf(file=paste(control, "_vs_", sample, "_MAplot.pdf", sep=""));
	plotMA(res)
	dev.off();

	# diagnostic p-value histogram plot
	pdf(file=paste("results/", control, "_vs_", sample, "_pvalplot.pdf", sep=""));
	hist(res$pval, breaks=100, col="skyblue", border="slateblue", main="");
	dev.off();

	# filtering for significant results
	# currrent thresholds are set at: 
	# adj pval < 0.01, average >10 normalized reads for both samples, 
	# abs(log2 fold change) > 0.5
	# also filters NA fields, and Inf caused by 0 read coverage

	resSig = res[ res$padj < 0.01, ];
	resFiltered = resSig[complete.cases(resSig) & resSig[3] != 0 & resSig[4] != 0 & 
						resSig$log2FoldChange!="-Inf" 
					   & resSig$log2FoldChange!="Inf" & resSig$baseMeanA > 10 &
						resSig$baseMeanA > 10 &
					   abs(resSig$log2FoldChange) > 0.5,]; 

	# renames columns with more specific sample names
	colnames(resFiltered)[3] <- paste("Basemean ",control, sep="")
	colnames(resFiltered)[4] <- paste("Basemean ",sample, sep="")
	colnames(resFiltered)[5] <- paste("foldChange (",sample,"/", control, ")", sep="")
	colnames(resFiltered)[6] <- paste("log2foldChange (",sample,"/", control, ")", sep="")

	# adds gene annotations
	resFiltered <- cbind(annot[match(resFiltered$id, rownames(annot)),],
	 resFiltered[,c(2:ncol(resFiltered))])  
	
	# writes out final filtered results
	write.table(resFiltered, file=paste("results/", control, 
	"_vs_", sample, "_FDR5_filtered.res", sep=""), sep="\t", 
	row.names=TRUE, col.names=NA)
	
	# returns filtered results to workspace
	return(resFiltered)
}


# reading in data - counts table including gene annotations
data <- read.table("RNAseq_trans_counts_table_annotated.txt", header=T, 
					row.names=1, sep="\t")
counts <- data[,c(6,8:12,5,7,4,15:19,13,14)] # reordering columns
annot <- annot[,1:3]

# create results folder
mainDir <- "~"
subDir <- "results"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)

# experimental conditions
conds <- c(rep("WT", 4), rep("mother", 4), rep("AF1", 4), rep("AF2", 4))

#converts missing data into zeros
for (i in 1:ncol(counts)) {
  counts[is.na(counts[,i]),i] <- 0
}

# experiment metadata table
ribosomalDesign = data.frame (
  rownames =colnames(counts),
  condition = conds,
  libType = c(rep("single-end", 16)) )

# creates a DEseq count dataset object
# then calculates size factors and prints normalized data

cds <- newCountDataSet( counts, conds )
cds <- estimateSizeFactors( cds )

factors <- sizeFactors( cds )
write.table(factors, file="results/size_factors.txt", sep="\t")

nCounts <- counts(cds, normalized=TRUE)
write.table(nCounts, file="results/normalized_counts.txt", sep="\t")

# estimates dispersions and makes diagnostic plot
cds <- estimateDispersions( cds )
str(fitInfo(cds))

pdf(file="results/Dispersion.pdf");
plotDispEsts(cds)
dev.off();

# calculates results, prints them out as files, and makes a data frame of results
resM <- getDEresults("mother", "WT", annot) #control has to go second
resAF1 <- getDEresults("AF1", "WT", annot)
resAF2<- getDEresults("AF2", "WT", annot)

