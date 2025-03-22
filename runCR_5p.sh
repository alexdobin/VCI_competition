#!/bin/bash
#SBATCH --partition cpu_batch_high_mem
#SBATCH --mem 200G
#SBATCH -c 50
#SBATCH -t 48:00:00
#SBATCH -m cyclic

# input
run_id=$1
cr_lib_csv=$2
outdir=$3

ncores=$SLURM_CPUS_PER_TASK
mem=$((SLURM_MEM_PER_NODE/1000))

# locations
cellranger=/large_storage/ctc/software/cellranger-9.0.1/cellranger 
genome=/large_storage/ctc/public/genomes/refdata-gex-GRCh38-2020-A_dCas9_GFP_BFP/
featref=/scratch/ctc/bioinf/arc/VCI_CRISPRa_benchmark/CRguideReference.csv

# outdir
mkdir -p $outdir

# run dir
rundir=$outdir
mkdir -p $rundir; rm -rf $rundir; mkdir -p $rundir; cd $rundir

# echo pars
echo $run_id $cr_lib_csv $outdir `pwd` $ncores $mem

# run CR
$cellranger count --id=$run_id \
    --transcriptome=$genome  --feature-ref=$featref  --libraries=$cr_lib_csv \
    --localcores=$ncores     --localmem=$mem         --create-bam=false &> $outdir/log.$run_id

# copy all output to outdir
#cp -rf * $outdir
