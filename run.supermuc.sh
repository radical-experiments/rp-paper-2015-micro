#!/bin/sh

# list of components we want to benchmark.  For each component, we will create
# a config which configures the blowup mechanism to load just that component.
# We will then run that config repeatedly (for stats) and collect the profles.
COMPONENTS='agent staging_input scheduling execution staging_output update'

# number of repetitions
REPS=1

# target resource
# RESOURCE='local'
RESOURCE='supermuc'

# compute unit load
CU_LOAD='sleep_%s.json'

# experiment sizes
# SIZES="128:development 512:development 1024:normal"
SIZES="128: 512: 1024:"

# number of workers
WORKERS="1 4 8"

# fixed parameters
RUNTIME=30

mkdir -p "data.$RESOURCE/"
mkdir -p 'log.$RESOURCE/'

# create 10^[246] byte sized dummy files for staging
for d in 1 1K 1M
do
   if ! test -f /tmp/input_$d.dat
   then
       dd if=/dev/urandom of=/tmp/input_$d.dat count=$d iflag=count_bytes
   fi
done


for c in $COMPONENTS
do

    for tmp in $SIZES
    do

        s=`echo $tmp | cut -f 1 -d :`
        q=`echo $tmp | cut -f 2 -d :`

        for w in $WORKERS
        do

            cat agent_config.tmpl | sed -e "s/###$c###/$s/g" \
                                  | sed -e "s/###worker###/$w/g" \
                                  | sed -e "s/###.*###/1/g" \
                                  > agent_config.json
            # diff agent_config.tmpl  agent_config.json

        
            for d in 1 1K 1M
            do
        
                i=0
                while ! test $i = "$REPS"
                do
                    i=$((i+1))
                    exp="${c}_${RESOURCE}_${s}_${d}_${w}_${i}"
                    log="log.$RESOURCE/$exp.log"
                    load=`printf "$CU_LOAD" $d`

                    tag="$RESOURCE : $c : $s : $d : $w : $i :"
                    grep "$tag" experiment.$RESOURCE.sids >/dev/null

                    if test $? = 0
                    then
                        echo "tag exists - skipping experiment $tag"

                    else
                        echo "running experiment $tag"

                        rm -rf $HOME/.saga/adaptors/shell_job/
                        killall -9 -q -u merzky python
                        sleep 1
        
                        python experiment.py       \
                            -a "agent_config.json" \
                            -c "$s"                \
                            -u "1"                 \
                            -t "$RUNTIME"          \
                            -r "$RESOURCE"         \
                            -l "$load"             \
                            -q "$q"                \
                            | tee "$log" 
        
                        sid=`grep 'session id:' $log | tail -n 1 | cut -f 2 -d :`
                        sid=`echo $sid` # trim white spaces
        
                        echo "$tag $sid" | tee -a experiment.$RESOURCE.sids
        
                        radicalpilot-stats -m prof -s "$sid" -p "data.$RESOURCE/"
                        radicalpilot-close-session -m export -s "$sid" 
                        mv -v "$sid".json data.$RESOURCE/
                    fi
                done
            done
        done
    done
done

