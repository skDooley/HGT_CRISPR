library(geiger)
library(phytools)
library(geomorph)
library(ape)

# 1. Load the trees and data
SixteenS = read.tree("TypeII-16S.faa.tree",tree.names = TRUE)
CasTree = read.tree("TypeII-Cas9s.faa.tree",tree.names = TRUE)
fractionMGE = read.csv("FractionMGEs.csv",row.names=1,header=TRUE)

# 2. Condition the data based on the 16S phylogeny
phyloMat16s = geomorph:::phylo.mat(fractionMGE,SixteenS)
conditionedData.16S = phyloMat16s$D.mat%*%as.matrix(fractionMGE)

# 3. Test Phylogentic trees imperically (Determine if the trees are different enough)
Cas9 = geomorph:::phylo.mat(fractionMGE,CasTree)
simularityRes=two.b.pls(Cas9$C,phyloMat16s$C)
summary(simularityRes)