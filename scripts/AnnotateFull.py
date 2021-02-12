import sys
sys.path.append("/mnt/research/germs/shane/transActRNA/scripts/")
from AnnotateTree import *
from BCBio import GFF
from CRISPRtools import *
from glob import glob
from os import chdir,system
from pickle import dump
from time import sleep
typeIIs = dict(fasta_index("/mnt/research/germs/shane/transActRNA/data/proteins/All_Cas9-Like-filtered.faa","fasta"))
chdir("/mnt/research/germs/shane/hgt/data")
typeIIOperons = load(open("pickles/Type_II_Operons.p","rb"))
print(len(typeIIOperons))
refSeqPath="/mnt/research/germs/shane/databases/assemblies/NCBI/refseq/bacteria"
gffFiles = set(glob("%s/*.gff" % (refSeqPath)))
allAccessions = set()
for protID,op in typeIIOperons.items():
    asmID = op.assembly[op.assembly.rfind("/")+1:].replace(".fasta","")
    allAccessions.add(asmID)

masterMetadata = read_csv("tables/HGT_Metadata.csv")
masterMetadata.set_index("Accession",inplace=True)
dumped=False

interestTypes = set(["CDS",'gene'])
c=0
bad,good = set(),set()


for accession, operon in typeIIOperons.items():
    gff = operon.assembly.replace(".fasta",".gff")
    ascession = gff[gff.rfind("/")+1:-4]
    if masterMetadata.at[ascession,"16S Present"]==True:continue
    if not gff in gffFiles:
        bad.add(gff)
        continue
    with open(gff) as fh:
        try:
            for rec in GFF.parse(fh):
                for feature in rec.features: 
                    try:masterMetadata.at[ascession,feature.type]+=1
                    except: pass

                    if masterMetadata.at[ascession,'16S Present']:continue
                    for subfeature in feature.sub_features:
                        if subfeature.type not in interestTypes:continue
                        if "product" in subfeature.qualifiers and "16S" in subfeature.qualifiers['product'][0]:
                            if "Note" in subfeature.qualifiers and "incomplete" in subfeature.qualifiers['Note'][0]:continue
                            try:
                                if not path.exists("proteins/16S/%s.faa"%(ascession)):
                                    system("esearch -db protein -query \"%s\" |efetch -format fasta &>proteins/16S/%s.faa" %(subfeature.qualifiers['Name'][0],ascession) )
                                    sleep(3)
                                    c+=1
                                good.add(ascession)
                                masterMetadata.at[ascession,'16S Present']=True
                                break
                            except: bad.add(gff)
        except: 
            print("Error with reading %s" % (gff))


masterMetadata.to_csv("tables/HGT_Metadata.csv")
dump(good,open("pickles/CheckedIDs_Good.p","wb"))
dump(bad,open("pickles/CheckedIDs_Bad.p","wb"))

print(c,len(good),len(bad),masterMetadata[masterMetadata["16S Present"]==True].shape[0])
