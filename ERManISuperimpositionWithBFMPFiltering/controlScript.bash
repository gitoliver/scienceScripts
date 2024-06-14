if [ $# != 5 ]; then
    echo "Usage: $0 simReplicates.txt alignerInputs.txt inputFolder alignmentResidues.txt filterFile.txt"
    exit
fi
simulationReplicates=$1
alignerInputs=$2
inputFolder=$3
alignmentResidues=$4
filterFile=$5
for alignmentResidue in `cat $alignmentResidues`
do
    echo "Doing residue $alignmentResidue"
    sed "s/VMB_RESIDUE/$alignmentResidue/g" $alignerInputs > $alignmentResidue.alignerInputs.txt
    rm -rf $alignmentResidue.outputs
    mkdir $alignmentResidue.outputs
    bash /home/o/Programs/scienceScripts/ERManISuperimpositionWithBFMPFiltering/a.aligner_WithLimit_AndFilter.sh $simulationReplicates $inputFolder $alignmentResidue.outputs $alignmentResidue.alignerInputs.txt $filterFile $alignmentResidue
done
