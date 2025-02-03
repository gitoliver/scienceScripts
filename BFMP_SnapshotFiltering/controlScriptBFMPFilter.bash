#!/bin/bash 

if [ $# -ne 2 ]; then
    echo "Usage: $0 glcNAcResidueList snapshotFolderList"
    echo "Exmpl: $0 allNagResidues.txt snapshotFolderList.txt"
    exit 1;
fi

nagResidueList=$1
snapshotFolderList=$2


filterListOutName=filterList.out
>collated_$filterListOutName
for folder in $(cat $snapshotFolderList)
do
    echo "Doing $folder"
    bash /home/oliver/Programs/scienceScripts/BFMP_SnapshotFiltering/filterNon1C4GlcNAcSnapshots.bash $nagResidueList $folder /home/oliver/Programs/scienceScripts/BFMP_SnapshotFiltering/bfmp_configFile.txt $filterListOutName > tmp.out
    cat $filterListOutName >> collated_$filterListOutName
    echo "Done"
done
echo "Details on which snapshots to filter for which residue are here: collated_$filterListOutName"
rm tmp.out
