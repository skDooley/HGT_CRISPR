#!/bin/sh
# set -e
# source ~/bin/anaconda3/bin/activate
echo "Processing directory hgt/data/assemblies/crisprAnnotated"
# FASTAS=(/mnt/research/germs/shane/hgt/data/assemblies/crisprAnnotated/*.fasta)
RESULTS=/mnt/research/germs/shane/hgt/data/annotations/IntegronFinder
SCRIPTS=/mnt/research/germs/shane/hgt/scripts/hpc_scripts/annotation
ASSEMBLY_DIR=/mnt/research/germs/shane/hgt/data/assemblies/crisprAnnotated
HEADER=/mnt/research/germs/shane/hgt/scripts/hpc_scripts/Header2.sb
counter=0
scrCounter=0
completed=0
cd $RESULTS
cat $HEADER > $SCRIPTS/IntegronFinder_$scrCounter.sb
# start=$1
# start=$((10000*start))
# end=$((start+10000));

# if [[ $end -ge ${#FASTAS[@]} ]]; then
# 	end=${#FASTAS[@]}
# fi

echo "Start=$start End=$end"


while read accession; do
# for fastaFile in "${FASTAS[@]}"; do 
# for ((j=$start; j<$end; j++)); do
	fastaFile="$ASSEMBLY_DIR/$accession.fasta"
	# fastaFile=${FASTAS[$j]}
	# accession=$(basename "$fastaFile" .fasta)

	if [[ -d "$RESULTS/Results_Integron_Finder_$accession" ]]; then
		((completed++));
		continue
	fi

	echo "integron_finder $fastaFile --cpu 20 --quiet 1>&2 2>/dev/null" >> $SCRIPTS/IntegronFinder_$scrCounter.sb
	
	((counter++));
	remainder=`expr $counter % 10`
	if [[ $remainder == 0 ]]; then
		sbatch $SCRIPTS/IntegronFinder_$scrCounter.sb
		rm $SCRIPTS/IntegronFinder_$scrCounter.sb
		((scrCounter++));
		cat $HEADER > $SCRIPTS/IntegronFinder_$scrCounter.sb
		jobs=$(squeue -u dooleys1|grep -v JOBID| wc -l)
		echo -en "Jobs=$jobs with counter at $counter on $(date)\t"
	 	total=0
		while [ $jobs -gt 999 ]; do
			echo "Sleeping Total: $total submitting: IntegronFinder_$scrCounter.sb"
			total=$((total + 10))
			sleep 10
			jobs=$(squeue -u dooleys1|wc -l)
		done
	fi
done < /mnt/research/germs/shane/hgt/data/RepGCFs.txt

echo "Finished $start to $end with $counter that had not yet been run $completed"
echo "$SCRIPTS/IntegronFinder_$scrCounter.sb"
