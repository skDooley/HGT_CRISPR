#!/bin/sh

# source ~/bin/anaconda3/bin/activate
SCRIPTS=/mnt/research/germs/shane/hgt/scripts/hpc_scripts
ASSEMBLY_DIR=/mnt/research/germs/shane/hgt/data/assemblies/crisprAnnotated
FASTAS=($ASSEMBLY_DIR/*.fasta)
RESULTS=/mnt/research/germs/shane/hgt/data/annotations/ISEScan
HEADER=$SCRIPTS/Header.sb
cd $RESULTS

while read accession; do
# for fastaFile in "${FASTAS[@]}"; do 
# 	accession=$(basename "$fastaFile" .fasta)
	fastaFile="$ASSEMBLY_DIR/$accession.fasta"
	if [[ -f $RESULTS/prediction/crisprAnnotated/$accession.fasta.sum ]]; then
		continue
	fi
	
	cat $HEADER > $SCRIPTS/annotation/$accession.sb
	echo "cd $RESULTS" >> $SCRIPTS/annotation/$accession.sb
	# cd $RESULTS
	# python ~/bin/anaconda3/bin/isescan.py --nthread 20 $fastaFile proteome $RESULTS/$accession
	# break
	echo "python ~/bin/anaconda3/bin/isescan.py --nthread 5 $fastaFile proteome $RESULTS/$accession" >> $SCRIPTS/annotation/$accession.sb
	sbatch $SCRIPTS/annotation/$accession.sb

	jobs=$(squeue -u dooleys1|grep -v JOBID| wc -l)
 	total=0
	while [ $jobs -gt 999 ]; do
		echo "Sleeping Total: $total"
		total=$((total + 10))
		sleep 10
		jobs=$(squeue -u dooleys1|wc -l)
	done

done < /mnt/research/germs/shane/hgt/data/RepGCFs.txt #Cas12_IDs.txt


# --removeShortIS ????
# remove incomplete (partial) IS elements which include IS
# element with length < 400 or single copy IS element
# without perfect TIR.