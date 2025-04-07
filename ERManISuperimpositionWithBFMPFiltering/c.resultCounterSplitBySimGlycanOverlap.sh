#!/bin/bash

#Bad hack after the fact. SHould just keep the snapshots for each trajectory separate.

if [ $# != 3 ]; then
    echo "Usage: $0 simReplicateList.txt folderList.txt toleranceRegex > output.txt"
    echo "Exmpl: $0 snapshotFolderList.txt folderList.txt [0-5] > output.txt"
    exit
fi
simReplicateList=$1
folderList=$2
toleranceRegex=$3

echo "Counting number of structures with $toleranceRegex overlaps:"
echo "Glycosite,Sim,NoClashProtein,NoClashIncludingGlycan,NoClashIncludingGlycanCore,Total"
for folder in `cat $folderList`
do
    i=0
    for simReplicate in `cat $simReplicateList`
    do
        totalStructures=`ls $folder/$simReplicate-ss*-proteinOverlaps.txt | grep -c "."`
        totalNonClashing=`grep "^$toleranceRegex contacts$" $folder/$simReplicate-ss*-proteinOverlaps.txt | grep -c "."`
        totalNonClashingGlycan=`grep "^$toleranceRegex contacts$" $folder/$simReplicate-ss*-glycanOverlaps.txt | grep -c "."`
        totalNonClashingGlycanCore=`grep "^$toleranceRegex contacts$" $folder/$simReplicate-ss*-glycanCoreOverlaps.txt | grep -c "."`
        echo "$folder,$i,$totalNonClashing,$totalNonClashingGlycan,$totalNonClashingGlycanCore,$totalStructures"
        i=$(($i + 1))
    done
done


