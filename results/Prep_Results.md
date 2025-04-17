# Prepare configs
## CRISPR feature reference: 5p
* extract gene and non-targeting names from Lexi's sgrna file
```
awk '{if ($1 ~ "neg") {print $4 "\n" $5} else {print $1}}' sgrna_library_content_h1escVciCompetition_crispri_h1esc_v1_20250124.tsv | sort -du > targets.txt
```
* extract existing records from the pilot CR reference .csv
```
 awk '(ARGIND==1) {if ($1 ~ "neg") {T[$4]++; T[$5]++} else {T[$1]++}} (ARGIND==2) {split($0,f,","); a=f[1]; if (a!~"non") {split(a,b,"_"); a=b[1]} if (FNR==1 || a in T) print }' sgrna_library_content_h1escVciCompetition_crispri_h1esc_v1_20250124.tsv VCI_pilot_CR_feature_reference.csv > VCI_competition_5p_CR_feature_reference.csv
 ```
 **Unexpected**: there are 10 new non-targeting sgrna:
 ```
 diff <(cut -d, -f1 VCI_competition_5p_CR_feature_reference.csv | grep non- | sort) <(grep non- targets.txt )
 ```
* generate the CR reference .csv directly from Lexi's sgrna file
```
../sgtable2crReference.awk sgrna_library_content_h1escVciCompetition_crispri_h1esc_v1_20250124.tsv > VCI_competition_5pFlex_CR_feature_reference.csv
```

# Processing: Flex
* link FASTQs
```
cd /processed_datasets/VCI/VCI_competition/FASTQ/
/home/adobin/projects/code/CTC_scRNAseq/cellranger/link_fastq_to_cr.sh  "Lane1 Lane2 Lane3"    '/processed_datasets/VCI/VCI_competition/FASTQ/Flex/*/'   /processed_datasets/VCI/VCI_competition/FASTQ/Flex_CR_P5P7   "GEX CRISPR"   "preamp"
```

# Processing: 5p
* CR .csv files for each library
```
fqdir=/processed_datasets/VCI/VCI_competition/FASTQ/5p_CR; for lane in S01 S02 S03 S04 S05 S06 S07 S08 S09 S10 S11 S12 S13 S14 S15 S16; do echo fastqs,sample,library_type, > $lane.csv; echo $fqdir/$lane,GEX,Gene Expression, >> $lane.csv; echo $fqdir/$lane,CRISPR,CRISPR Guide Capture, >> $lane.csv; done
```

* Combine CR metrics files
```
awk 'NR==1 || FNR==2 {print substr(FILENAME,1,3) "," $0} ' S??/outs/metrics_summary.csv > S01-16.summary.csv
```

* Upload CR summaries to the Goolge drive
```
for s in S??; do echo $s; cd /processed_datasets/VCI/VCI_competition/CR/RunCR/$s/outs/; ~/projects/code/CTC_scRNAseq/scripts/rclone_gdrive.sh "Computational Analyses/VCI_competition/5p_first/CRsummaries/"   "VCI_comp_5p_first_$s"   "metrics_summary.csv   web_summary.html"; done
```

# Processing: 3p
## FASTQ QC: check for guides in CRISPR FASTQs
* link fastqs in CR format
```
/home/adobin/projects/code/CTC_scRNAseq/cellranger/link_fastq_to_cr.sh  "S01 S02 S03 S04 S05 S06 S07 S08 S09 S10 S11 S12 S13 S14 S15 S16" `pwd`/3p `pwd`/3p_CR "GEX CRISPR"
```
* directly check the presence of protospacers in FASTQs
```
awk '(ARGIND==1) {G[$6]=FNR; G[$7]=FNR*2} (ARGIND==2 && FNR%4==2) {for (g in G) {x=index($0,g); if (x>0) break}; print x }' ../CR/VCI_competition/configs/sgrna_library_content_h1escVciCompetition_crispri_h1esc_v1_20250124.tsv <(zcat 3p_CR/S01/CRISPR_S1_L001_R2_001.fastq.gz) | head -n 10000 | sort -r | uniq -c
```
Peak at 32b, with a significant contribution at 31b.
```
   2161 0
      1 27
      2 28
     45 29
    432 30
   1986 31
   4860 32
    438 33
     46 34
     17 35
      6 36
      3 39
      2 41
      1 46
```
* counts per guide per position
```
awk '(ARGIND==1) {G[$6]=FNR; G[$7]=FNR*2} (ARGIND==2 && FNR%4==2) {x=index($0, "GTTTAAGAGCTAAGCTGGAA"); if (x==0) next; g=substr($0,x-20,20); print G[g] }' ../CR/VCI_competition/configs/sgrna_library_content_h1escVciCompetition_crispri_h1esc_v1_20250124.tsv <(zcat 3p_CR/S01/CRISPR_S1_L001_R2_001.fastq.gz) | head -n 10000 | sort -r | uniq -c | sort -k1,1rn
```

* check constant sequences following protospacer
```
zcat 3p_CR/S01/CRISPR_S1_L001_R2_001.fastq.gz | awk 'NR%4==2 {print substr($0,52,20)}' | head -n 10000 | sort | uniq -c |sort -k1,1rn | head -n5
```
```
   3702 GTTTCAGAGCTAAGCACAAG
   1563 GTTTAAGAGCTAAGCTGGAA
   1275 TTTAAGAGCTAAGCTGGAAA
    850 TTTCAGAGCTAAGCACAAGA
    267 TTAAGAGCTAAGCTGGAAAC
```

* check both A and B constant sequences and protospacers
```
awk '(ARGIND==1) {G[$6]=FNR; G[$7]=FNR*2} ENDFILE {print length(G) > "/dev/stderr"} (ARGIND==2 && FNR%4==2) {x=index($0, "GTTTCAGAGCTAAGCACAAG"); if (x==0) x=index($0, "GTTTAAGAGCTAAGCTGGAA"); if (x==0) next; g=substr($0,x-20,20); print G[g] }' ../CR/VCI_competition/configs/sgrna_library_content_h1escVciCompetition_crispri_h1esc_v1_20250124.tsv <(zcat 3p_CR/S01/CRISPR_S1_L001_R2_001.fastq.gz) | head -n 1000000 | sort -r | uniq -c | sort -k1,1rn | wc -l
```

## prepare files and run CR
* generate the CR reference .csv directly from Lexi's sgrna file
```
../sgtable2crReference_3p.awk sgrna_library_content_h1escVciCompetition_crispri_h1esc_v1_20250124.tsv > VCI_competition_3p_CR_feature_reference.csv
```

* check that reference .csv sequences are detected in FASTQs
```
/processed_datasets/VCI/VCI_competition/CR/VCI_competition/checkCRrefCsvWithFastq.awk /processed_datasets/VCI/VCI_competition/CR/VCI_competition/configs/VCI_competition_3p_CR_feature_reference.csv <(zcat CRISPR_S1_L001_R2_001.fastq.gz | head -n 1000000) | sort -k2,2n | less
```

* prepare CR configs for each lane
```
fqdir=/processed_datasets/VCI/VCI_competition/FASTQ/3p_CR; for lane in S01 S02 S03 S04 S05 S06 S07 S08 S09 S10 S11 S12 S13 S14 S15 S16; do echo fastqs,sample,library_type, > $lane.csv; echo $fqdir/$lane,GEX,Gene Expression, >> $lane.csv; echo $fqdir/$lane,CRISPR,CRISPR Guide Capture, >> $lane.csv; done
```

* submit CR jobs
```
for lane in S01 S02 S03 S04 S05 S06 S07 S08 S09 S10 S11 S12 S13 S14 S15 S16; do echo $lane; sbatch --partition cpu_batch_high_mem ../VCI_competition/runCR_3p5p.sh $lane `pwd`/$lane.csv /processed_datasets/VCI/VCI_competition/CR/VCI_competition/configs/VCI_competition_3p_CR_feature_reference.csv `pwd`/$lane /media/24TBNVME/ctc/bioinf/tmp/VCI_comp_5p/$lane; sleep 600; done
```

# Simple QC for FASTQs
## CRISPR
### Constant sequence presence:
```
 ./checkConstSeq.awk <(zcat ../../FASTQ/5p/VCI_exp002_competition_5prime_CRISPR_S01-1_R2_001.fastq.gz) <(zcat ../../FASTQ/5p/VCI_exp002_competition_5prime_CRISPR_S01-2_R2_001.fastq.gz)
 ```
 ```
 Read % for 1000000 reads for file 1:
Constant sequence 1
29	0.000424
30	0.006657
31	0.477844
32	0.000876
33	2e-06
Constant sequence 2
32	0.000435
33	0.006564
34	0.476701
35	0.001133
36	3.1e-05
noSeq	0.029054
Read % for 1000000 reads for file 2:
Constant sequence 1
29	0.00034
30	0.004212
31	0.875839
32	0.003389
33	1.9e-05
Constant sequence 2
32	2.5e-05
33	0.00033
34	0.091716
35	0.000404
36	4e-06
noSeq	0.023171
```
**Good**: small % of reads with no constant sequecing

**Unexpected**: 1st file has roughly equal numbers of const seq1 and seq2, 2nd file has mostly seq1