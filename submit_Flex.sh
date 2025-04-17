# samples
fastqDirAll=/processed_datasets/VCI/VCI_competition/FASTQ/Flex_CR_dipr/
outDir=/processed_datasets/VCI/VCI_competition/CR/RunCR_Flex/

# general
crExe=/large_storage/ctc/software/cellranger-8.0.1_modAD/cellranger

genomeDir=/large_storage/ctc/public/genomes/refdata-gex-GRCh38-2020-A/

configDir=/processed_datasets/VCI/VCI_competition/CR/VCI_competition/configs/
featRef=$configDir/VCI_competition_5pFlex_CR_feature_reference.csv
configCsv=$configDir/config.GEX_CRISPR_16probeBC.csv
probeSet=$configDir/Chromium_Human_Transcriptome_Probe_Set_v1.0.1_GRCh38-2020-A.targetGenesTRUE.dCas9_Gfp_Bfp.csv

for sample in  Lane2 Lane3; do

    sbatch --partition cpu_batch_high_mem -J $sample \
                                /processed_datasets/VCI/VCI_competition/CR/VCI_competition/cr_multi_slurm.sh \
                                --runId $sample --fastqDir $fastqDirAll/$sample --outDir $outDir/$sample/ --configCsv $configCsv \
                                --genomeDir $genomeDir --probeSet $probeSet --featRef $featRef --crExe $crExe \
                                --runDir /media/24TBNVME/ctc/bioinf/tmp/VCI_comp_Flex/$sample
done

