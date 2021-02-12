from Bio.Alphabet import IUPAC
from Bio.SeqFeature import SeqFeature, FeatureLocation
from Bio.SeqIO import index as fasta_index, write as fasta_write
from Bio import SearchIO
from glob import glob
from pandas import DataFrame
from numpy import zeros
from os import path,remove as rm, system
from sys import argv
from pickle import dump

def pullCoords(descr):
    startIndex = descr.find("from ")+5
    isComplement = False
    strand = "+"
    if descr[startIndex]=='c':
        startIndex+=11
        isComplement=True
        strand="-"
    endIndex = descr.find("..",startIndex)
    startCoord = int(descr[startIndex:endIndex])
    if isComplement:
        chrIndex = descr.find(") of ",endIndex)
        endCoord = int(descr[endIndex+2:chrIndex])
        buffer=5
    else:
        chrIndex = descr.find(" of ",endIndex)
        endCoord = int(descr[endIndex+2:chrIndex])
        buffer = 4
    endChrIndex = descr.find(" ",chrIndex+buffer)
    if strand=='-': chrName = descr[chrIndex+5:endChrIndex]
    else:chrName = descr[chrIndex+4:endChrIndex]
    return min(int(startCoord), int(endCoord)),max(int(startCoord), int(endCoord)), strand, chrName

results=glob(argv[1]+'.HMM.*')
FASTA=fasta_index(argv[2],"fasta")
records={}
for seqID in FASTA: 
	records[seqID]=FASTA[seqID]
	records[seqID].seq.alphabet = IUPAC.unambiguous_dna

results.sort()
for hmmResult in results:
	try: qresult = SearchIO.read(hmmResult, 'hmmer3-text')
	except: 
		print("Failed:",hmmResult);
		rm(hmmResult)
		continue
	if len(qresult.hits)==0:
		rm(hmmResult)
		continue
	gene,description = qresult.description.split(': ')
	for hit in qresult.hits:
		start,end,strand,chromosome = pullCoords(hit.description)
		newFeature = SeqFeature(FeatureLocation(start=start, end=end), type='CDS',qualifiers={'gene':gene,'product':description,"source":"phagefinder"})
		try:records[chromosome].features.append(newFeature)
		except:
			die
			break
	rm(hmmResult)

accsesion = argv[1]
fasta_write(list(records.values()),open(accsesion+".gbk",'w'),"genbank")
