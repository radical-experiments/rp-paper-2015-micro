#!/bin/sh

for c in inp sch exe out
do
    for s in 250 500 1000
    do
        for a in 1 2 4 8
        do
            for w in 1 2 4 8
            do
               f="$c.$s.$a.$w.sids"
               grep "$c :  $s :  0 :  $a :  $w : " experiment.sids > $f
               test -s $f || rm $f
           done
       done

       for r in bw comet stampede
       do
           f="$c.$s.$r.sids"
           grep "$c : $s : " experiment.sids | grep $r > $f
           test -s $f || rm $f
       done
   done
done

for sid in *.*.sids
do
    old_len=0
    new_len=`wc -l $sid | cut -f 1 -d ' '`

    touch "$sid.len"
    old_len=`cat "$sid.len"`

    if test "$old_len" = "$new_len"
    then
        echo "$sid: $old_len = $new_len"
        continue
    fi

    wc -l $sid  | cut -f 1 -d ' ' > $sid.len
    new_len=`cat "$sid.len"`
    echo "======= $sid: $new_len"
    (./plot.py $sid || echo "############# ERROR ###############")
done
