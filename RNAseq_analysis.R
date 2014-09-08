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


##
#
#
#
## Creating additional data diagnostic plots

# pretty scatterplot function
# stolen from Brennecke et al (2013) supp materials
# http://www.nature.com/nmeth/journal/v10/n11/extref/nmeth.2645-S2.pdf

geneScatterplot <- function( x, y, xlab, ylab, col ) {
  plot( NULL, xlim=c( -.1, 6.2 ), ylim=c( -1, 6.2 ), 
        xaxt="n", yaxt="n", xaxs="i", yaxs="i", asp=1,
        xlab=xlab, ylab=ylab )
  abline( a=-1, b=1, col = "lightgray", lwd=2 )
  abline( a=0, b=1, col = "lightgray", lwd=2 )
  abline( a=1, b=1, col = "lightgray", lwd=2 )
  abline( h=c(0,2,4,6), v=c(0,2,4,6), col = "lightgray", lwd=2 )
  points( 
    ifelse( x > 0, log10(x), -.7 ),
    ifelse( y > 0, log10(y), -.7 ),
    pch=19, cex=.2, col = col )
  axis( 1, c( -.7, 0:6 ), 
        c( "0", "1", "10", "100", expression(10^3), expression(10^4),
           expression(10^5), expression(10^6) ) )
  axis( 2, c( -.7, 0:6 ), 
        c( "0", "1", "10", "100", expression(10^3), expression(10^4),
           expression(10^5), expression(10^6) ), las=2 )
  axis( 1, -.35, "//", tick=FALSE, line=-.7 )
  axis( 2, -.35, "\\\\", tick=FALSE, line=-.7 )
}

# set colours for each sample
colWT <- rgb(78,185,75, maxColorValue=255)
colM <- rgb(190,91,165, maxColorValue=255)
colAF1 <- rgb(148,125,186, maxColorValue=255)
colAF2 <- rgb(71,93,172, maxColorValue=255)

# correlation within each experimental condition
png("correlation_log_withincond.png", width = 1000, height = 1000)
par(mfrow=c(2,2))
geneScatterplot( nCounts[,1], nCounts[,3], 
                 "normalized read count, WT1", "normalized read count, WT3",
                 colWT )
geneScatterplot( nCounts[,5], nCounts[,7], 
                 "normalized read count, M1", "normalized read count, M3",
                 colM )
geneScatterplot( nCounts[,9], nCounts[,11], 
                 "normalized read count, AF1_a", "normalized read count, AF1_c",
                 colAF1 )
geneScatterplot( nCounts[,13], nCounts[,15], 
                 "normalized read count, AF2_a", "normalized read count, AF2_c",
                 colAF2 )
dev.off()

# correlation between experimental conditions
par(mfrow=c(3,3))
png("correlation_log_withincond.png", width = 2000, height = 2000)
geneScatterplot( nCounts[,1], nCounts[,5], "normalized read count, WT1", 
				"normalized read count, M1", colWT )
geneScatterplot( nCounts[,1], nCounts[,5], 
                 "normalized read count, WT1", "normalized read count, M1",
                 colWT )
geneScatterplot( nCounts[,1], nCounts[,9], 
                 "normalized read count, WT1", "normalized read count, AF1_a",
                 colWT )
geneScatterplot( nCounts[,1], nCounts[,13], 
                 "normalized read count, WT1", "normalized read count, AF2_a",
                 colWT )
plot()
geneScatterplot( nCounts[,5], nCounts[,9], 
                 "normalized read count, M1", "normalized read count, AF1_a",
                 colM )
geneScatterplot( nCounts[,5], nCounts[,13], 
                 "normalized read count, M1", "normalized read count, AF2_a",
                 colM )
plot()
plot()
geneScatterplot( nCounts[,9], nCounts[,13], 
                 "normalized read count, AF1_a", "normalized read count, AF2_a",
                 colAF1 )

dev.off()

