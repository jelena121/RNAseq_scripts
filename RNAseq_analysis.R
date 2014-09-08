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
	pdf(file=paste(control, "_vs_", sample, "_pvalplot.pdf", sep=""));
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
	write.table(resFiltered, file=paste(control, "_vs_", sample, "_FDR5_filtered.res",
	 sep=""), sep="\t", row.names=TRUE, col.names=NA)
	
	# returns filtered results to workspace
	return(resFiltered)
}