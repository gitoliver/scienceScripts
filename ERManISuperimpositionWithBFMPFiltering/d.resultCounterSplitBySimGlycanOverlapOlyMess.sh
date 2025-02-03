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
        #totalNonClashing=`grep "^[0-9] contacts$" $folder/$simReplicate-ss*-proteinOverlaps.txt | grep -c "."`
        # Ok for glycans, when I first did this I calculated the overlaps separately from protein and now must check every file against the equivalent other file.
        # I changed the scripts to calculate protein and glycan together, but this mess is for the results from before.
        p=0 # protein non clashing count
        pg=0 # protein plus glycan non-clashing
        pgc=0 # protein plus glycan core non-clashing (the core is the two GlcNAcs plus Manb)
        for file in $(grep -l "^[0-9] contacts$" $folder/$simReplicate-ss*-proteinOverlaps.txt)
        do
            p=$(($p + 1))
            commonName=$( echo $file | cut -d \- -f 1-3 )
            if grep -q "^[0-9] contacts$" $commonName-glycanOverlaps.txt; then
                pg=$(($pg + 1))
            fi
            if grep -q "^[0-9] contacts$" $commonName-glycanCoreOverlaps.txt; then
                pgc=$(($pgc + 1))
            fi
        done 
        #echo "$totalNonClashing == $p ?"
        echo "$folder,$i, $p, $pg, $pgc, $totalStructures"
        #totalNonClashingGlycan=`grep "^[0-9] contacts$" $folder/$simReplicate-ss*-glycanOverlaps.txt | grep -c "."`
        #totalNonClashingGlycanCore=`grep "^[0-9] contacts$" $folder/$simReplicate-ss*-glycanCoreOverlaps.txt | grep -c "."`
        #echo "$folder,$i,$totalNonClashing,$totalNonClashingGlycan,$totalNonClashingGlycanCore,$totalStructures"
        i=$(($i + 1))
    done
done


