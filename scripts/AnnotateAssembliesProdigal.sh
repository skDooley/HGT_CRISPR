#!/bin/sh
counter=0
ASSEMBLY_DIR=/mnt/research/germs/shane/hgt/data/assemblies/crisprAnnotated/
PROD_OUT=/mnt/research/germs/shane/hgt/data/annotations/Prodigal
cd $ASSEMBLY_DIR
FASTAS=(*.fasta)
for fastaFile in "${FASTAS[@]}"; do 
	accession=$(basename "$fastaFile" .fasta)

	if [[ -f $PROD_OUT/$accession.prodigal.gbk ]]; then 
		continue
	fi
	
	((counter++));
	remainder=`expr $counter % 20`
	if [ $remainder == 0 ]; then
		echo $counter
		prodigal -i $fastaFile -o $PROD_OUT/$accession.prodigal.gbk 2>/dev/null
	else
		prodigal -i $fastaFile -o $PROD_OUT/$accession.prodigal.gbk 2>/dev/null &
	fi
	
	
done