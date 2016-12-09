setwd("Zobrist/Collaborative-Filtering")
library(reshape)
library(recommenderlab)

# Prior matrix manipulation
DB <- read.csv('Matrix_CF.csv')
M <- data.matrix(DB[,-c(1:2)])
M <- M[rowSums(M[,-1]) > 5,]
colnames(M) <-paste("i", 1:ncol(M), sep='')
rownames(M) <-paste("u", 1:nrow(M), sep='')

## coerce it into a binaryRatingMatrix
B <- as(M, "binaryRatingMatrix")

## Naming Evaluation Scheme
es <- evaluationScheme(B, method="cross-validation", k=2, given=5)

## evaluate several algorithms with a list
algorithms <- list(
  "random items" = list(name="RANDOM", param=NULL),
  "popular items" = list(name="POPULAR", param=NULL),
  "user-based CF" = list(name="UBCF", param=list(nn=50)))

# Evaluate the different algorithms with different number of recommendations
ev <- evaluate(es, algorithms, n=seq(0,500,50))

## look at the results (by the length of the topNList)
plot(ev, annotate=3, legend="bottomright")
plot(ev, y="ROC", annotate=3, legend="topleft")

# Calculating the AUC's
AUC <- as.numeric(by(do.call("rbind", avg(ev)), rep(1:length(ev), 
        each = length(seq(0,500,50))), function(x) {
        tpr <- c(0, x[, "TPR"], 1)
        fpr <- c(0, x[, "FPR"], 1)
        i <- 2:length(tpr)
        return((fpr[i] - fpr[i - 1]) %*% (tpr[i] + tpr[i - 1])/2)
        }))

# Saving the ROC curve graph
png('ROCs.png')
plot(ev, annotate=3, legend="bottomright")
dev.off()
