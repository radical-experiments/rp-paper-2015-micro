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
rm    plot_all.lst
touch plot_all.lst
for sid in *.*.sids
do
    old_len=0
    new_len=`wc -l $sid | cut -f 1 -d ' '`

    touch "$sid.len"
    old_len=`cat "$sid.len"`

    if test "$old_len" = "$new_len"
    then
        printf "======= %2d == %2d : $sid\n" $new_len $old_len
        continue
    else
        printf "======= %2d != %2d : $sid\n" $new_len $old_len
        echo ./plot.py $sid >> plot_all.lst
        echo "$new_len" > $sid.len
    fi

done

cat plot_all.lst
echo "plotting `wc -l plot_all.lst` times"
time parallel ./plot.py < plot_all.lst

