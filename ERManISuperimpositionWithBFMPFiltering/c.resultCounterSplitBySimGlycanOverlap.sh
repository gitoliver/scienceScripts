#!/bin/bash

#Bad hack after the fact. SHould just keep the snapshots for each trajectory separate.

if [ $# != 2 ]; then
    echo "Usage: $0 simReplicateList.txt folderList.txt"
    exit
fi
simReplicateList=$1
folderList=$2

echo "Counting number of structures with 0-5 overlaps:"
echo "Glycosite,Sim,NoClashProtein,NoClashIncludingGlycan,NoClashIncludingGlycanCore,Total"
for folder in `cat $folderList`
do
    i=0
    for simReplicate in `cat $simReplicateList`
    do
        totalStructures=`ls $folder/$simReplicate-ss*-proteinOverlaps.txt | grep -c "."`
        totalNonClashing=`grep "^[0-9] contacts$" $folder/$simReplicate-ss*-proteinOverlaps.txt | grep -c "."`
        totalNonClashingGlycan=`grep "^[0-9] contacts$" $folder/$simReplicate-ss*-glycanOverlaps.txt | grep -c "."`
        totalNonClashingGlycanCore=`grep "^[0-9] contacts$" $folder/$simReplicate-ss*-glycanCoreOverlaps.txt | grep -c "."`
        echo "$folder,$i,$totalNonClashing,$totalNonClashingGlycan,$totalNonClashingGlycanCore,$totalStructures"
        i=$(($i + 1))
    done
done


