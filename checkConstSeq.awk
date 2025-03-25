#!/usr/bin/awk -f

BEGIN {
    constSeq[1] = "CTTGCTATGCACTCTTGTGCTTAGCTCTGAAAC";
    constSeq[2] = "GCTATGCTGTTTCCAGCTTAGCTCTTAAAC";

    nReadsToTest = 1000000;
}

BEGINFILE{
    P[0][0] = 0;
    delete P;
    noSeq = 0;
}

{
    # extract position of constSeq
    if (FNR%4 == 2) {
        noSeq++;
        for (seq in constSeq) {
            if (index($0, constSeq[seq]) > 0) {
                # position of constant sequence
                P[seq][ index($0, constSeq[seq]) ] ++;
                noSeq --;
                break;
            };
        };
    };
    if (FNR>4*nReadsToTest)
        nextfile;
}

ENDFILE {
    OFS="\t";
    print "Read % for " nReadsToTest " reads for file " ARGIND":";
    for (seq in P) {
        # find mode
        maxc = 0;
        totCount = 0;
        for (p in P[seq]) {
            if (P[seq][p] > maxc && p!=0) {
                maxc = P[seq][p];
                modeP = p;
            };
            #totCount += P[seq][p];
        };

        print "Constant sequence " seq;
        #c1 = 0;
        for (p=modeP-2; p<=modeP+2; p++) {
            print p, (P[seq][p]+0)/nReadsToTest;
            #c1 += P[seq][p];
        };
    };
    print "noSeq", noSeq/nReadsToTest;

};