
from sys import path as spath
spath.append("/mnt/research/germs/shane/transActRNA/scripts/")
from CRISPRtools import *
from os import chdir
from pickle import dump,load
chdir("/mnt/research/germs/shane/hgt/data")
refSeq = load(open("pickles/RefSeq.p","rb"))

from os import system
from Bio.SeqIO import index as fasta_index,write
fh=open("assemblies/fullAssemblies/AssemblyCompilation_0.fasta","w")
fCount = 0
chrCount = 0
allChrs = set()
for i,(asm,operon) in enumerate(refSeq.items()):
    assembly = fasta_index(operon.assembly,"fasta")
    for crisprFile in operon.crisprFiles:
            try: crisprResults = readCRISPR(crisprFile) # Read the CRISPR file
            except: print(asm,crisprFile)
            if len(crisprResults)==0:continue
            for chrName in crisprResults:
                if chrName in allChrs:continue
                allChrs.add(chrName)   
                write(assembly[chrName],fh,"fasta")
                chrCount+=1
                if chrCount%10000 == 0:
                    fCount+=1
                    print(fCount,i,chrCount)
                    fh.close()
                    fh=open("assemblies/fullAssemblies/AssemblyCompilation_%i.fasta" % (fCount),"w")
fh.close()
print(fCount)