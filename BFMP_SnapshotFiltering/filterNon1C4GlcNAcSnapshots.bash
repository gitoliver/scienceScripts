#!/bin/bash 

if [ $# -ne 4 ]; then
    echo "Usage: $0 glcNAcResidueList snapshotFolder bfmpConfigFile filterListoutfileName"
    echo "Exmpl: $0 allNagResidues.txt 0.5.3.IntegrinAlphaVJustAlpha-snapshots bfmp_configFile.txt filterList.out"
    echo "Warning: Don't put a / after the snapshotFolder name, i.e. this no: 0.5.3.IntegrinAlphaVJustAlpha-snapshots/"
    exit 1;
fi
glcNAcResidueList=$1
snapshotFolder=$2
bfmpConfigFile=$3
snapshotsToFilterOut=$4 
ringConformationsCollated=ringConformationsCollated$snapshotFolder.out # This makes it senstivitive to trailing / in the folderName

echo "Called like this:"
echo "$0 $1 $2 $3"

>$snapshotsToFilterOut
>$ringConformationsCollated
for glcNAc in $(cat $glcNAcResidueList)
do
    echo "Checking shapes of GlcNAc $glcNAc"
    sed "s/RESIDUE_NUMBER/$glcNAc/g" $bfmpConfigFile > tmpConfig.txt
    for snapshot in $(ls $snapshotFolder)
    do
        echo "Checking $snapshotFolder/$snapshot"
        /home/oliver/Programs/BFMP/detect_shape $snapshotFolder/$snapshot tmpConfig.txt
        if [ $(grep -c "4d1" ring_conformations.txt) -eq 0 ]; then
            echo "$snapshotFolder/$snapshot: Residue $glcNAc does not have a BFMP 4d1 shape (iupac 4C1) within cutoff (see $bfmpConfigFile for cutoff used)"
            printf "%s,%s,%s\n" $glcNAc $snapshotFolder $snapshot >> $snapshotsToFilterOut
        fi
        sed "s/^1/$snapshot $glcNAc/g" ring_conformations.txt >> $ringConformationsCollated
    done
done
echo "Finished"
rm tmpConfig.txt ring_conformations.txt
