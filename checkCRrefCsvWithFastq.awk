#!/usr/bin/awk -f

# CR reference CSV file format:
#id,name,read,pattern,sequence,feature_type,target_gene_id,target_gene_name
#AASS_P1P2_A,AASS_P1P2_A,R2,(BC)GTTTCAGAGCTAAGCACAAG,GCGACTCGGAAGATTCGAGG,CRISPR Guide Capture,Non-Targeting,Non-Targeting
#AASS_P1P2_B,AASS_P1P2_B,R2,(BC)GTTTAAGAGCTAAGCTGGAA,GACAAGTCGGCGCCCCAGAG,CRISPR Guide Capture,Non-Targeting,Non-Targeting

BEGIN {
    FS=",";
}

(ARGIND==1 && FNR>1) {
    seq = $4;
    gsub(".BC.", $5, seq);
    S[$1] = seq;
    N[$1] = 0;
}

(ARGIND==2 && FNR%4==2) {
    for (guide in S) {
        if (index($0, S[guide]) > 0) {
            N[guide]++;
            break;
        }
    }
}

END {
    for (guide in S) {
        print guide, N[guide];
    }
}