library("DESeq")

getDEresults <- function(sample, control) {
  
  res <- nbinomTest( cds, control, sample )
  #write.table(res, file=paste(control, "_vs_", sample, ".res", sep=""), sep="\t")
  
  pdf(file=paste(control, "_vs_", sample, "_MAplot.pdf", sep=""));
  plotMA(res)
  dev.off();
  
  pdf(file=paste(control, "_vs_", sample, "_pvalplot.pdf", sep=""));
  hist(res$pval, breaks=100, col="skyblue", border="slateblue", main="");
  dev.off();
  
  #write results
  resSig = res[ res$padj < 0.05, ];
  resFiltered = resSig[complete.cases(resSig) & resSig[3] != 0 & resSig[4] != 0,]; #filters out the NA fields. Still leaves some infinities
  
  colnames(resFiltered)[3] <- paste("Basemean ",control, sep="")
  colnames(resFiltered)[4] <- paste("Basemean ",sample, sep="")
  colnames(resFiltered)[5] <- paste("foldChange (",sample,"/", control, ")", sep="")
  colnames(resFiltered)[6] <- paste("log2foldChange (",sample,"/", control, ")", sep="")
  
  write.table(resFiltered, file=paste(control, "_vs_", sample, "_FDR5.res", sep=""), sep="\t", row.names=FALSE)
 
}


#replicate correlation graph
panel.cor <- function(x, y, digits=2, prefix="", cex.cor, ...){
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y))
  if (r < 0.05) {
    r <- 0.0
  }
  txt <- format(c(r, 0.123456789), digits=digits, scientific=F)[1]
  txt <- paste(prefix, txt, sep="")
#  if(missing(cex.cor)) cex.cor <- 1.8/strwidth(txt)
if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
  #if (r < 0.05) {
  #   txt <- " "
  #}
  text(0.5, 0.5, txt, cex=1.6)
  #text(0.5, 0.5, txt, cex = cex.cor * r)
}

# reading in data
counts <- read.table("RNAseq_trans_counts_table.txt", header=T, row.names=1, sep="\t")
names(counts)
counts <- counts[,c(3,5:9,2,4,1,12:16,10,11)] # reordering

# data conditions
conds <- c(rep("WT", 4), rep("mother", 4), rep("AF1", 4), rep("AF2", 4))

#converts missing data into zeros
for (i in 1:ncol(counts)) {
  counts[is.na(counts[,i]),i] <- 0
}

ribosomalDesign = data.frame (
  rownames =colnames(counts),
  condition = conds,
  libType = c(rep("single-end", 16)) )

cds <- newCountDataSet( counts, conds )
cds <- estimateSizeFactors( cds )
#to see the size factors
sizeFactors( cds )

#this should be the normalized data
set <- counts(cds, normalized=TRUE)
write.table(set, file="normalized_counts.txt", sep="\t")

cds <- estimateDispersions( cds )
str(fitInfo(cds))

pdf(file="Dispersion.pdf");
plotDispEsts(cds)
dev.off();

getDEresults("mother", "WT") #control second
getDEresults("AF1", "WT")
getDEresults("AF2", "WT")

#turns out this file is massive, so might actually be better in a different format
# if you want correlation files, put in the right col numbers here

colnames(set) <- c("WT1", "WT2", "WT3", "WT4", "M1", "M2", "M3", "M4", "AF1a", "AF1a", "AF1c", "AF1d", 
                "AF2a", "AF2b", "AF2c", "AF2d")
#png("correlation.png")
png("correlation.png")
pairs(set[,1:16], col="blue", lower.panel=panel.cor, cex=0.8, cex.axis=0.8, pch=".")
dev.off()

#pdf("correlation_WT.pdf")
png("correlation_WT.png")
pairs(set[,1:4], col="blue", lower.panel=panel.cor, cex=1.8, cex.axis=1.2, pch=".")
dev.off()

png("correlation_mother.png")
pairs(set[,5:8], col="blue", lower.panel=panel.cor, cex=1.8, cex.axis=1.2, pch=".")
dev.off()

png("correlation_AF1.png")
pairs(set[,9:12], col="blue", lower.panel=panel.cor, cex=1.8, cex.axis=1.2, pch=".")
dev.off()

png("correlation_AF2.png")
pairs(set[,13:16], col="blue", lower.panel=panel.cor, cex=1.8, cex.axis=1.2, pch=".")
dev.off()


# hierarchical clustering using Euclidean distance
# and average linkage:
distance<-dist(t(set),method="euclidian")
cluster<-hclust(distance, method = "average")
par(cex=0.7)
plot(cluster, main = "Sample distance")


