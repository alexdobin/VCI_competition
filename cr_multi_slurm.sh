#!/bin/bash
#SBATCH --partition cpu_batch
#SBATCH --mem 400G
#SBATCH -c 50
#SBATCH -t 120:00:00
#SBATCH -m cyclic

# input
while [[ $# -gt 0 ]]; do
  case $1 in
    --fastqDir)
      fastqDir="$2"
      shift;shift
      ;;

    --runId)
      runId="$2"
      shift;shift
      ;;

    --configCsv)
      configCsv="$2"
      shift;shift
      ;;

    --outDir)
      outDir="$2"
      shift;shift
      ;;

    --genomeDir)
      genomeDir="$2"
      shift;shift
      ;;

    --probeSet)
      probeSet="$2"
      shift;shift
      ;;

    --featRef)
      featRef="$2"
      shift;shift
      ;;

    --featRefProtein)
      featRefProtein="$2"
      shift;shift
      ;;

    --crExe)
      crExe="$2"
      shift;shift
      ;;

    --runDir)
      runDir="$2"
      shift;shift
      ;;

    --subsampleRateGEX)
      subsampleRateGEX="$2"
      shift;shift
      ;;

    --subsampleRateCRISPR)
      subsampleRateCRISPR="$2"
      shift;shift
      ;;

    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# ncores and mem: default or from slurm values
ncores=50
[[ -n $SLURM_CPUS_PER_TASK ]] && ncores=$SLURM_CPUS_PER_TASK
mem=200
[[ -n $SLURM_MEM_PER_NODE ]] && mem=$((SLURM_MEM_PER_NODE/1000))

echo $runId   $fastqDir   $lib_csv   $outDir   $genomeDir   $probeSet   $featRef   $ncores   $mem

#########################################################################################

# outdir
mkdir -p $outDir

# run dir
[[ -z "$runDir" ]] && runDir=/media/8TBNVME/ctc/Bioinformatics/Runs/CR_$runId
mkdir -p $runDir; rm -rf $runDir; mkdir -p $runDir; cd $runDir

# substitute parameters into configCsv
cp $configCsv config.csv

for repl in genomeDir probeSet fastqDir featRef featRefProtein subsampleRateGEX subsampleRateCRISPR; do
    replsed="s#__replace_${repl}__#${!repl}#g"
    echo $replsed
    sed -i $replsed config.csv
done

#__replace_genomeDir__ __replace_probeSet__ __replace_fastqDir__ __replace_feature_reference__

# run CR multi
$crExe multi --id=cr_run --csv=config.csv --localmem=$mem --localcores=$ncores --disable-ui &> $outDir/log.cr && echo $runId > DONE_CR

# move all output to outdir if needed
[[ -f "DONE_CR" ]] && [[ "$runDir" != "$outDir" ]] && mv -f * $outDir && echo $runId > $outDir/DONE_move

# test
#ls && echo $runId > DONE_CR \

###################3
# 5p command
#$cellranger count --id=$runId \
#    --transcriptome=$genome  --feature-ref=$featref  --libraries=$cr_lib_csv \
#    --localcores=$ncores     --localmem=$mem         --create-bam=false &> $outdir/log.$runId

