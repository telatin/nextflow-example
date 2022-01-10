#!/bin/bash
out=shotgun
mkdir  -p $out
set -euxo pipefail
for i in sources/*.fa;
do
    b=$(basename $i)
    echo "-- $i"
    seqfu rotate -i 10000 $i > "/tmp/$b"
    if [[ -e $out/${b}_1.fq.gz ]]; then
       rm $out/${b}_{1,2}.fq.gz
    fi
    echo > $out/${b}_1.fq
    echo > $out/${b}_2.fq
    for ref in $i "/tmp/$b";
    do
      echo $ref
      art_illumina -na -ss HS25 -i $ref -p -l 150 -f 20 -m 200 -s 10 -o $out/tmp_
      cat $out/tmp_1.fq >> $out/${b}_1.fq
      cat $out/tmp_2.fq >> $out/${b}_2.fq
    done
done
