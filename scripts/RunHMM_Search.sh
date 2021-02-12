#!/bin/bash --login
#SBATCH --time=5:00:00             # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --ntasks=1                  # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=10           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem=10G                   # memory required per node - amount of memory (in bytes)
#SBATCH --account shadeash-colej 
#SBATCH --job-name HMMSearch4_6


source ~/bin/anaconda3/bin/activate
# set -e

REFSEQ=/mnt/research/germs/shane/databases/assemblies/NCBI/refseq/bacteria
HMM_PATH=/mnt/research/germs/shane/hgt/data/hmms
RESULTS=/mnt/research/germs/shane/hgt/data/proteins/searches
fastas=($REFSEQ/*.fasta)
remainder=0
counter=0

echo "There are ${#fastas[@]} files"

start=$1
start=$((10000*start))
end=$((start+10000));

if [[ $end -ge ${#fastas[@]} ]]; then
	end=${#fastas[@]}
fi

echo "Starting at $start and ending at $end"
found=0

for gene in "cas4" "cas6"; do
	hmmList=($HMM_PATH/$gene/*.hmm)
	numHMMs=${#hmmList[@]}
	numHMMs=$((numHMMs-1))
	Gene=${gene/c/C}

	echo "$gene"
	for ((j=$start; j<$end; j++)); do
		fasta=${fastas[$j]}

	# for fasta in "${fastas[@]}"; do 
		# ((counter++))
		# remainder=`expr $counter % 20`
		accession=$(basename "$fasta" .fasta)

		# lines=$(wc -l $RESULTS/$gene/$accession.$gene.hmmout | awk '{print $1}')
		# if [[ $lines -gt 40 ]]; then
		# 	((found++))
		# else
		# 	if [ ! -f $SCRATCH/hgt/orfs/$accession.orfs ]; then
		# 		echo "ORFS $accession"
		# 		python /mnt/research/germs/shane/transActRNA/scripts/GetOrfs.py $fasta $SCRATCH/hgt/orfs/$accession.orfs 200 >/dev/null
		# 	fi

		# 	hmmsearch --cpu 10 $HMM_PATH/$gene/Cas12_A-B-C-F.hmm $SCRATCH/hgt/orfs/$accession.orfs > "$RESULTS/$gene/$accession.$gene.hmmout"
		# 	lines=$(wc -l $RESULTS/$gene/$accession.$gene.hmmout | awk '{print $1}')

		# 	if [[ $lines -gt 40 ]]; then
		# 		echo "Found $RESULTS/$gene/$accession.$gene.hmmout"
		# 		break
		# 	else
		# 		echo "" > $RESULTS/$gene/$accession.$gene.hmmout
		# 	fi
		# fi


		if [[ -f "$RESULTS/$gene/$accession.$gene.hmmout" ]] ; then
			((found++))
			continue
		fi
		# else
		# 	hmmsearch --cpu 10 $HMM_PATH/$gene/Cas12_A-B-C-F.hmm $SCRATCH/hgt/orfs/$accession.orfs > "$RESULTS/$gene/$accession.$gene.hmmout"
		# 	lines=$(wc -l $RESULTS/$gene/$accession.$gene.hmmout | awk '{print $1}')

		# 	if [[ $lines -gt 40 ]]; then
		# 		((found++))
		# 	else
		# 		echo "" > $RESULTS/$gene/$accession.$gene.hmmout
		# 	fi
		# fi

		foundHMM=false
		for i in $(seq 0 $numHMMs); do 

			hmm=$HMM_PATH/$gene/$Gene.Cluster_$i.hmm
			hmmsearch --cpu 10 $hmm $SCRATCH/hgt/orfs/$accession.orfs > "$RESULTS/$gene/$accession.$gene.hmmout"
			lines=$(wc -l $RESULTS/$gene/$accession.$gene.hmmout | awk '{print $1}')

			if [[ $lines -gt 40 ]]; then
				((found++))
				foundHMM=true
				break
			fi

		done

		if [ "$foundHMM" = false ] ; then
			echo "" > $RESULTS/$gene/$accession.$gene.hmmout
		fi

	done

done

echo "The counter is $found"

		# remainder=`expr $counter % 1000`

		# if [[ $remainder == 0 ]]; then
		# 	echo "Completed $counter"
		# fi



# set -e
# counter=0
# j=0

# for ((j=$start; j<$end; j++)); do
# 	fasta=${fastas[$j]}
# 	# for fasta in "${fastas[@]}"; do 
# 	accession=$(basename "$fasta" .fasta)
# 	if [ ! -f $SCRATCH/hgt/orfs/$accession.orfs ]; then

# 		((counter++))
# 		remainder=`expr $counter % 20`

# 		if [ $remainder == 0 ]; then
# 			echo "FREEZE $j $counter"
# 			python /mnt/research/germs/shane/transActRNA/scripts/GetOrfs.py $fasta $SCRATCH/hgt/orfs/$accession.orfs 90 >/dev/null
# 		else
# 			echo "$j $counter"
# 			python /mnt/research/germs/shane/transActRNA/scripts/GetOrfs.py $fasta $SCRATCH/hgt/orfs/$accession.orfs 90 >/dev/null &
# 		fi

# 	fi
# done

echo "Completed $start $end"
