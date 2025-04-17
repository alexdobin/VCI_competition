#!/bin/bash
#SBATCH --partition cpu_batch_high_mem
#SBATCH --mem 200G
#SBATCH -c 50
#SBATCH -t 48:00:00
#SBATCH -m cyclic

# input
run_id=$1
cr_lib_csv=$2
featref=$3

outdir=$4
rundir=$5

ncores=$SLURM_CPUS_PER_TASK
mem=$((SLURM_MEM_PER_NODE/1000))

echo "run_id: $run_id" 
echo "cr_lib_csv: $cr_lib_csv"
echo "featref: $featref"
echo "outdir: $outdir"
echo "rundir: $rundir"
echo "ncores: $ncores"
echo "mem: $mem"

# locations
cellranger=/large_storage/ctc/software/cellranger-9.0.1/cellranger 
genome=/large_storage/ctc/public/genomes/refdata-gex-GRCh38-2020-A_dCas9_GFP_BFP/
#featref=/processed_datasets/VCI/VCI_competition/CR/VCI_competition/configs/VCI_competition_5pFlex_CR_feature_reference.csv

# outdir
mkdir -p $outdir

# run dir
mkdir -p $rundir; rm -rf $rundir; mkdir -p $rundir; cd $rundir

# run CR
$cellranger count --id=$run_id \
    --transcriptome=$genome  --feature-ref=$featref  --libraries=$cr_lib_csv \
    --localcores=$ncores     --localmem=$mem         --create-bam=false &> $outdir/log.$run_id

# copy all output to outdir
mv $run_id/* $outdir
