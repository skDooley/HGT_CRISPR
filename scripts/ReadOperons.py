import sys
sys.path.append("/mnt/research/germs/shane/transActRNA/scripts/")
from CRISPRtools import *
from os import chdir
chdir("data")
# Gene=sys.argv[1]
# print(Gene)
# crisprs = load(open("/mnt/research/germs/shane/hgt/data/pickles/RefSeqCRISPRs.p","rb"))
# casOperons = CasOperons(Gene)
# casOperons.hasCas9("/mnt/research/germs/shane/hgt/data/proteins/searches/%s/" %(Gene.replace("C","c")),crisprs)

casOperons=load(open("pickles/AllCasOps.p",'rb'))
for prot in ["Cas1","Cas2","Cas9","Cas12"]: 
	allCasAsmFile = "assemblies/All_%s_Unique_Assemblies.fasta" % (prot)
	allCasAAsFile = "proteins/All_%s-Like.faa" % (prot)
	casOperons[prot].uniqueNukeSeqs(allCasAsmFile,allCasAAsFile)
	print("Completed: "+prot)
dump(casOperons,open("pickles/AllCasOps.p",'wb'))