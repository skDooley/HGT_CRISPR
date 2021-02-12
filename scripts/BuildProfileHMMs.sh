#!/bin/bash

# '''
# Author: Shane K. Dooley
# Date: March 19, 2020
# Script: BuildHmms.sh
# Purpose: Take all the fasta files that contains orthologs of a protein and build an hmm.
# Usage: File names must end with "<PROTEIN_NAME>_generated_##-##-####.fasta"
# '''

# Directories
CWD=/mnt/research/germs/shane/hgt
cd $CWD
PROFILE_FASTAS_DIR=data/profiles
HMM_DIR=data/hmms

# Get the fastas
fastas=($PROFILE_FASTAS_DIR/*.fasta)

#For each fasta
for fasta in "${fastas[@]}"; do
    #Get the gene name using the criteria defined in the usage statement
    #gene=${fasta:20:-27}
    #gene=${gene:(-4)}
    nSeqs=`grep ">" $fasta|wc -l`
    if [[ $nSeqs -lt 20 ]]; then
        continue
    fi
    pwd 
    echo $nSeqs $fasta
    cd-hit -i $fasta -T 0 -M 0 -d 0 -c .90 -sc 1 -o $fasta.grouped
    break

    # Align the proteins
    # alnignmentFile=${fasta/"fasta"/"aln"}
    # if [ -f $alnignmentFile ]; then
    #     echo "Done $alnignmentFile";
    # 	continue;
    # fi
    # echo "Aligning $alnignmentFile"
    # mafft --quiet --thread 20 --maxiterate 1000 --globalpair $fasta > $alnignmentFile
    
    # # Build the HMM
    # echo "Building HMM"
    # hmmFile=${fasta/"fasta"/"hmm"}
    # hmmFile=${hmmFile/"profiles"/"hmms"}
    # hmmbuild --cpu 20 --amino $hmmFile $alnignmentFile
    
done
echo "Done"
