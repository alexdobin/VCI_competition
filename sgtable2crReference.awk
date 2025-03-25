#!/usr/bin/awk -f

# input:
# gene	transcript	sgID_AB	sgID_A	sgID_B	protospacer_A	protospacer_B	grna_type	oligo_seq
# A1BG	P1	A1BG_+_58858964.23-P1|A1BG_-_58858788.23-P1	A1BG_+_58858964.23-P1	A1BG_-_58858788.23-P1	GCTCCGGGCGACGTGGAGTG	GGGGCACCCAGGAGCGGTAG	targeting	ATTTTGCCCCTGGTTCTTCCACCTTGTTGGCTCCGGGCGACGTGGAGTGGTTTCAGAGCGAGACGTGCCTGCAGGATACGTCTCAGAAACATGGGGGCACCCAGGAGCGGTAGGTTTAAGAGCTAAGCTGCCAGTTCATTTCTTAGGG
# A1BG	P2	A1BG_-_58864840.23-P2|A1BG_-_58864822.23-P2	A1BG_-_58864840.23-P2	A1BG_-_58864822.23-P2	GCCGGTGCAGTGAGTGTCTG	GATGATGGTCGCGCTCACTC	targeting	ATTTTGCCCCTGGTTCTTCCACCTTGTTGGCCGGTGCAGTGAGTGTCTGGTTTCAGAGCGAGACGTGCCTGCAGGATACGTCTCAGAAACATGGATGATGGTCGCGCTCACTCGTTTAAGAGCTAAGCTGCCAGTTCATTTCTTAGGG
# AASS	P1P2	AASS_+_121784247.23-P1P2|AASS_+_121784219.23-P1P2	AASS_+_121784247.23-P1P2	AASS_+_121784219.23-P1P2	GCGACTCGGAAGATTCGAGG	GACAAGTCGGCGCCCCAGAG	targeting	ATTTTGCCCCTGGTTCTTCCACCTTGTTGGCG
# negative_control	negative_control	non-targeting_01114|non-targeting_02257	non-targeting_01114	non-targeting_02257	GCAGTAGATGGAATCAGGCG	GGTAAGCGCCTAACAATGGA	nontargeting	ATTTTGCCCCTGGTTCTTCCACCTTGTTGGCAGTAGATGGAATCAGGCGGTTTCAGAGCGAGACGTGCCTGCAGGATACGTCTCAGAAACATGGGTAAGCGCCTAACAATGGAGTTTAAGAGCTAAGCTGCCAGTTCATTTCTTAGGG
# negative_control	negative_control	non-targeting_01117|non-targeting_00200	non-targeting_01117	non-targeting_00200	GCGGCAGCGGCCCACGAGAA	GACCGCCGCGCGGCCTAACG	nontargeting	ATTTTGCCCCTGGTTCTTCCACCTTGTTGGCGGCAGCGGCCCACGAGAAGTTTCAGAGCGAGACGTGCCTGCAGGATACGTCTCAGAAACATGGACCGCCGCGCGGCCTAACGGTTTAAGAGCTAAGCTGCCAGTTCATTTCTTAGGG

# output:
# id,name,read,pattern,sequence,feature_type,target_gene_id,target_gene_name
# FOXA1_A,FOXA1_A,R2,CTTGCTATGCACTCTTGTGCTTAGCTCTGAAAC(BC),CTTCACCGCTGCGCGCGACC,CRISPR Guide Capture,Non-Targeting,Non-Targeting
# FOXA1_B,FOXA1_B,R2,GCTATGCTGTTTCCAGCTTAGCTCTTAAAC(BC),CTTCACCGCTGCGCGCGACC,CRISPR Guide Capture,Non-Targeting,Non-Targeting

# Function to generate the reverse complement of a nucleotide sequence
function reverse_complement(seq, rev_seq, i, n, complement) {
    # Initialize an array with complementary nucleotides
    complement["A"] = "T"
    complement["T"] = "A"
    complement["C"] = "G"
    complement["G"] = "C"

    n = length(seq)
    rev_seq = ""

    # Reverse the sequence and get the complement
    for (i = n; i >= 1; i--) {
        base = substr(seq, i, 1)
        rev_seq = rev_seq complement[base]
    }

    return rev_seq
}

BEGIN {

    header = "id,name,read,pattern,sequence,feature_type,target_gene_id,target_gene_name";
    pattern["A"] = "CTTGCTATGCACTCTTGTGCTTAGCTCTGAAAC(BC)";
    pattern["B"] = "GCTATGCTGTTTCCAGCTTAGCTCTTAAAC(BC)";
    read = "R2";
    cr_type = "CRISPR Guide Capture";

    print header;
    OFS = ",";

    print "position_A,position_B" > "guide_pairs_AB.csv";

    getline; # skip header
}
{
    gene = $1;
    transcript = $2;
    gsub(",", ";", transcript); # in afew cases several transcripts are listed comma-separated

    idAB = $3;
    id["A"] = $4;
    id["B"] = $5;
    proto["A"] = reverse_complement(toupper($6));
    proto["B"] = reverse_complement(toupper($7));
    type = $8;

    if (gene ~ /control/) {
        gene = type;
    } else {
        id["A"] = gene "_" transcript "_A";
        id["B"] = gene "_" transcript "_B";
    }

    print id["A"], id["B"] > "guide_pairs_AB.csv";

    for (pos in pattern) {
        print id[pos], id[pos], read, pattern[pos], proto[pos], cr_type, "Non-Targeting,Non-Targeting"; # CR needs gene_ids, so for now will use Non-Targeting
    }

}
