#!/bin/sh

# list of components we want to benchmark.  For each component, we will create
# a config which configures the blowup mechanism to load just that component.
# We will then run that config repeatedly (for stats) and collect the profles.
COMPONENTS='staging_input scheduling execution staging_output'

# number of repetitions
REPS=3

# target resource
RESOURCE='xsede.stampede'

# compute unit load
CU_LOAD='sleep_%s.json'

# fixed parameters
N_CORES=8
N_UNITS=4
RUNTIME=10

mkdir -p "data/"
mkdir -p 'log/'

# create 10^[246] byte sized dummy files for staging
for s in 1 1K 1M
do
   if ! test -f /tmp/input_$s.dat
   then
       dd if=/dev/urandom of=/tmp/input_$s.dat count=$s iflag=count_bytes
   fi
done


for c in $COMPONENTS
do

    for s in 1 1K 1M
    do

        i=0
        while ! test $i = "$REPS"
        do
            rm -rf $HOME/.saga/adaptors/shell_job/

            i=$((i+1))
            exp="${c}_${RESOURCE}_$s_$i"
            log="log/$exp.log"
            load=`printf "$CU_LOAD" $s`

            python experiment.py   \
                -a "agent_$c.json" \
                -c "$N_CORES"      \
                -u "$N_UNITS"      \
                -t "$RUNTIME"      \
                -r "$RESOURCE"     \
                -l "$load"         \
                -e "$exp"          \
                | tee "$log" 

            sid=`grep 'session id:' $log | tail -n 1 | cut -f 2 -d :`
            sid=`echo $sid` # trim white spaces

            printf "%-25s : $RESOURCE : $i : $sid\n" "$c" | tee -a experiment.sids

            radicalpilot-stats -m prof -s "$sid" -p "data/"

        done
    done
done

