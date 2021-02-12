library(geiger)
library(phytools)
library(geomorph)
library(ape)
SixteenS = read.tree("/mnt/research/germs/shane/hgt/TypeII-16S.faa.tree",tree.names = TRUE)
CasTree = read.tree("/mnt/research/germs/shane/hgt/TypeII-Cas9s.faa.tree",tree.names = TRUE)
fractionMGE = as.matrix(fastBM(CasTree,mu=.25,bounds=c(0,1)))
phyloMat16s = geomorph:::phylo.mat(fractionMGE,SixteenS)
# phyloMat16s = geomorph:::phylo.mat(fractionMGE,CasTree)

conditionedData.16S = phyloMat16s$D.mat%*%fractionMGE
Cas9 = geomorph:::phylo.mat(fractionMGE,CasTree)
res = phylo.integration(Cas9$C,fractionMGE,phy=SixteenS)

res
