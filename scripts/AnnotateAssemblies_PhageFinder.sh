#!/bin/sh
# set -e
# source ~/bin/anaconda3/bin/activate
echo "Processing directory hgt/data/assemblies/crisprAnnotated"
FASTAS=(/mnt/research/germs/shane/hgt/data/assemblies/crisprAnnotated/*.fasta)
ORFS_PATH=/mnt/gs18/scratch/users/dooleys1/hgt/orfs
PHAGE_FINDER=~/bin/phage_finder_v2.1 #/bin/phage_finder_v2.1.sh
ASSEMBLY_DIR=/mnt/research/germs/shane/hgt/data/assemblies/crisprAnnotated
RESULTS=/mnt/research/germs/shane/hgt/data/annotations/PhageFinder
SCRIPTS=/mnt/research/germs/shane/hgt/scripts/hpc_scripts/annotation
HEADER=/mnt/research/germs/shane/hgt/scripts/hpc_scripts/Header.sb
cd $RESULTS
counter=0
scrCounter=0
cat $HEADER > $SCRIPTS/PhageFinder_$scrCounter.sb

start=$1
start=$((10000*start))
end=$((start+10000));


if [[ $end -ge ${#FASTAS[@]} ]]; then
	end=${#FASTAS[@]}
fi

completed=0
echo "Start=$start End=$end"

# for fastaFile in "${FASTAS[@]}"; do 
# for ((j=$start; j<$end; j++)); do
while read accession; do

	fastaFile="$ASSEMBLY_DIR/$accession.fasta"
	# accession=$(basename "$fastaFile" .fasta)

	if [[ -f $RESULTS/$accession.gbk ]]; then
		((completed++));
		continue
	fi

	# ((counter++));
	# remainder=`expr $counter % 20`
	# if [ $remainder == 0 ]; then
	# 	echo "python /mnt/research/germs/shane/transActRNA/scripts/GetOrfs.py $fastaFile $ORFS_PATH/$accession.orfs 200" >> $SCRIPTS/PhageFinder_$scrCounter.sb
	# else
	# 	echo "python /mnt/research/germs/shane/transActRNA/scripts/GetOrfs.py $fastaFile $ORFS_PATH/$accession.orfs 200 &" >> $SCRIPTS/PhageFinder_$scrCounter.sb
	# fi

	# if [[ ! -f $ORFS_PATH/$accession.orfs ]]; then
	# 	echo "Getting ORFs $ORFS_PATH/$accession.orfs"
	# 	python /mnt/research/germs/shane/transActRNA/scripts/GetOrfs.py $fastaFile $ORFS_PATH/$accession.orfs 100 
	# fi
	mkdir -p $RESULTS/$accession
	echo "mkdir -p $RESULTS/$accession" >> $SCRIPTS/PhageFinder_$scrCounter.sb
	for i in `cat $PHAGE_FINDER/hmm3.lst`; do
		if [[ ! -f $accession.HMM.$i.out ]]; then
			hmmsearch $PHAGE_FINDER/PHAGE_HMM3s_dir/$i.HMM $ORFS_PATH/$accession.orfs &> $RESULTS/$accession/$accession.HMM.$i.out
			echo "hmmsearch $PHAGE_FINDER/PHAGE_HMM3s_dir/$i.HMM $ORFS_PATH/$accession.orfs &> $RESULTS/$accession/$accession.HMM.$i.out " >> $SCRIPTS/PhageFinder_$scrCounter.sb
	  	fi
	done
	
	python /mnt/research/germs/shane/hgt/scripts/ReadHMMs.py $RESULTS/$accession/$accession $fastaFile
	mv $RESULTS/$accession/$accession.gbk $RESULTS/
	rmdir $RESULTS/$accession

	echo "python /mnt/research/germs/shane/hgt/scripts/ReadHMMs.py $RESULTS/$accession/$accession $fastaFile " >> $SCRIPTS/PhageFinder_$scrCounter.sb
	echo "mv $RESULTS/$accession/$accession.gbk $RESULTS/ " >> $SCRIPTS/PhageFinder_$scrCounter.sb
	echo "rmdir $RESULTS/$accession " >> $SCRIPTS/PhageFinder_$scrCounter.sb
	((counter++));
	remainder=`expr $counter % 10`
	if [[ $remainder == 0 ]]; then
		sbatch $SCRIPTS/PhageFinder_$scrCounter.sb
		rm $SCRIPTS/PhageFinder_$scrCounter.sb
		((scrCounter++));
		cat $HEADER > $SCRIPTS/PhageFinder_$scrCounter.sb

		# jobs=$(squeue -u dooleys1|grep -v JOBID| wc -l)
		# echo -en "Jobs=$jobs with counter at $counter on $(date)\t"
	 # 	total=0
		# while [ $jobs -gt 75 ]; do
		# 	echo "Sleeping Total: $total submitting: PhageFinder_$scrCounter.sb"
		# 	total=$((total + 10))
		# 	sleep 10
		# 	jobs=$(squeue -u dooleys1|wc -l)
		# done

		
	fi
done < /mnt/research/germs/shane/hgt/data/MissingPF2.txt

echo "Finished $start to $end with $counter that had not yet been run $completed"

echo "$SCRIPTS/PhageFinder_$scrCounter.sb"
