#!/bin/bash

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

export TIMEFORMAT="r:%lR  u:%lU  s:%lS"
unset `env | grep VERBOSE | cut -f 1 -d =`
for sid in *.*.sids
do
    old_len=0
    new_len=`wc -l $sid | cut -f 1 -d ' '`

    touch "$sid.len"
    old_len=`cat "$sid.len"`

    if test "$old_len" = "$new_len"
    then
        echo "======= $old_len == $new_len : $sid"
        continue
    else
        echo "======= $new_len != $old_len : $sid"
        echo "$new_len" > $sid.len
    fi

    time (./plot.py $sid >>plot.log 2>&1 || echo "############# ERROR ###############")
done
