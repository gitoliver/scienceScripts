if [ $# != 6 ]; then
    echo "Usage: $0 simReplicates.txt inputFolder outputFolder alignerInputs.txt filterFile.txt alignmentResidue"
    exit
fi
echo "$0 called with simReplicates.txt:$1 ,inputFolder:$2 ,outputFolder:$3 ,alignerInputs.txt:$4 ,filterFile.txt:$5 ,alignmentResidue:$6"
simReplicates=$1
inputFolder=$2
outputFolder=$3
alignerInputs=$4
filterFile=$5
alignmentResidue=$6
nextNagResidue=$(($alignmentResidue - 1 ))
thisGlycanLastResidueNumber=$(( $nextNagResidue + 10 )) # Funky selectors for overlaps. Assumes Man9
thisGlycanManBResidueNumber=$(( $alignmentResidue + 1 ))
source $alignerInputs
if [ -z "${FIRST_GLYCAN_RESIDUE}" ]; then
    echo "You need to set FIRST_GLYCAN_RESIDUE and LAST_GLYCAN_RESIDUE in your alignerInputs.txt file"
    exit 1
fi
cd $outputFolder
>chimeraOutput.txt
for simReplicate in `cat ../$simReplicates`
do
    echo "Doing $simReplicate"
    echo "open $REFERENCE_3D_STRUCTURE" > $simReplicate-input.cmd
    fileCount=1
    RELATIVE_PATH_TO_SNAPSHOTS=`echo "$TEMPLATE_PATH_TO_SNAPSHOTS" | sed "s,SYSTEM,$inputFolder/$simReplicate,g"`
    echo "RELATIVE_PATH_TO_SNAPSHOTS:${RELATIVE_PATH_TO_SNAPSHOTS}"
    snapshotNumber=0
    for filePath in `ls $RELATIVE_PATH_TO_SNAPSHOTS`
    do
        fileName=$(basename -- "$filePath")
        #snapshotNumber="${fileName##*.}" # Only works for files named ss.1, ss.2 etc
	snapshotNumber=$(($snapshotNumber + 1))
        echo "Checking for $alignmentResidue,$simReplicate,$fileName or $nextNagResidue,$simReplicate,$fileName in ../$filterFile"
        if [ $(grep -c "^$alignmentResidue,$simReplicate,$fileName$" ../$filterFile) -eq 0 ] && [ $(grep -c "^$nextNagResidue,$simReplicate,$fileName$" ../$filterFile) -eq 0 ]; then
            echo "open $filePath" >> $simReplicate-input.cmd
            echo "match #$fileCount$SYSTEM_MATCH_STRING $REFERENCE_MATCH_STRING" >> $simReplicate-input.cmd
            echo "findclash $REFERENCE_OVERLAP_SELECTION test #$fileCount$SYSTEM_PROTEIN_OVERLAP_RESIDUES saveFile $simReplicate-ss$snapshotNumber-proteinOverlaps.txt" >> $simReplicate-input.cmd
            echo "findclash $REFERENCE_OVERLAP_SELECTION test \"#$fileCount$SYSTEM_PROTEIN_OVERLAP_RESIDUES | #$fileCount:$FIRST_GLYCAN_RESIDUE-$LAST_GLYCAN_RESIDUE & ~#$fileCount:$nextNagResidue-$thisGlycanLastResidueNumber\" saveFile $simReplicate-ss$snapshotNumber-glycanOverlaps.txt" >> $simReplicate-input.cmd
            echo "findclash $REFERENCE_OVERLAP_SELECTION test \"#$fileCount$SYSTEM_PROTEIN_OVERLAP_RESIDUES | #$fileCount:4YB,VMB & ~#$fileCount:$nextNagResidue-$thisGlycanManBResidueNumber\" saveFile $simReplicate-ss$snapshotNumber-glycanCoreOverlaps.txt" >> $simReplicate-input.cmd
            #echo "write #$fileCount $simReplicate-ss$snapshotNumber-aligned.pdb" >> $simReplicate-input.cmd
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

