if [ $# != 6 ]; then
    echo "Usage: $0 simReplicates.txt inputFolder outputFolder alignerInputs.txt filterFile.txt alignmentResidue"
    exit
fi
simReplicates=$1
inputFolder=$2
outputFolder=$3
alignerInputs=$4
filterFile=$5
alignmentResidue=$6
nextNagResidue=$(($alignmentResidue - 1 ))
source $alignerInputs

cd $outputFolder
>chimeraOutput.txt
for simReplicate in `cat ../$simReplicates`
do
    echo "Doing $simReplicate"
    echo "open $REFERENCE_3D_STRUCTURE" > $simReplicate-input.cmd
    fileCount=1
    RELATIVE_PATH_TO_SNAPSHOTS=`echo "$TEMPLATE_PATH_TO_SNAPSHOTS" | sed "s/SYSTEM/$inputFolder\/$simReplicate/g"`
    for filePath in `ls $RELATIVE_PATH_TO_SNAPSHOTS`
    do
        fileName=$(basename -- "$filePath")
        snapshotNumber="${fileName##*.}"
        echo "Checking for $alignmentResidue,$simReplicate,$fileName or $nextNagResidue,$simReplicate,$fileName in ../$filterFile"
        if [ $(grep -c "^$alignmentResidue,$simReplicate,$fileName$" ../$filterFile) -eq 0 ] && [ $(grep -c "^$nextNagResidue,$simReplicate,$fileName$" ../$filterFile) -eq 0 ]; then
            echo "open $filePath" >> $simReplicate-input.cmd
            echo "match #$fileCount$SYSTEM_MATCH_STRING $REFERENCE_MATCH_STRING" >> $simReplicate-input.cmd
            echo "findclash $REFERENCE_OVERLAP_SELECTION test #$fileCount$SYSTEM_PROTEIN_OVERLAP_RESIDUES saveFile $simReplicate-ss$snapshotNumber-proteinOverlaps.txt" >> $simReplicate-input.cmd
            echo "write #$fileCount $simReplicate-ss$snapshotNumber-aligned.pdb" >> $simReplicate-input.cmd
            fileCount=$(($fileCount + 1))
            if [ $fileCount -gt $STRUCTURE_LIMIT_CHIMERA ]; then
                echo "Running chimera for $simReplicate"
                chimera --nogui $simReplicate-input.cmd >> chimeraOutput.txt
                fileCount=1
                echo "open $REFERENCE_3D_STRUCTURE" > $simReplicate-input.cmd
            fi
        else
            echo "FILTERED"
        fi
    done
    chimera --nogui $simReplicate-input.cmd >> chimeraOutput.txt
done
echo "Fin"
cd ../

