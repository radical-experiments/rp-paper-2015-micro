#!/bin/sh


# load the virtenv
. ./ve/bin/activate
python -c 'import radical.pilot as rp' || exit

if ! test -f "$1"
then
    echo "no such config to source: $1"
    exit 1
fi

. "./$1"


mkdir -p 'data/'

tmp='./tmp.dat'

# we always run exactly one CU, but clone 'n' in the component of interest.
# make sure the number is large enough to keep the components busy for some
# seconds -- otherwise we don't get decent 'frequency' (which is defined per
# full second)
n=100

for res in $RESOURCES
do
    r=`echo   -n $res | cut -f 1 -d :`
    cpn=`echo -n $res | cut -f 2 -d :`

    for a in $AGENTS
    do
        a_idx=2
        sub_agents='"agent_1"'
        while test "$a_idx" -le "$a"
        do
            sub_agents="$sub_agents, \"agent_$a_idx\""
            a_idx=$((a_idx+1))
        done

        for c in $COMPONENTS
        do
            for tmp in $SIZES
            do
                s=`echo -n $tmp | cut -f 1 -d :`
                q=`echo -n $tmp | cut -f 2 -d :`
        
                # # for each agent, we add one more node to the request.
                # s=$((a*cpn+s))
    
                for d in $FILES
                do
                    for w in $WORKERS
                    do
                        # we change a, w on the fly - remember actual values
                        old_w=$w
                        old_a=$a

                        # for the scheduler, we can only use one instance
                        if test "$c" = "sch"
                        then
                            w=1
                            a=1
                        fi

                        # for each experiment, we create a new config with the requested
                        # number of sub agents
                        cfg="agent_$c.$s.$d.$a.$w.$r.cfg"
    
                        cat "$AGENT_CFG_TMPL" \
                            | sed -e "s/###sub_agents###/$sub_agents/g" \
                            > "$cfg"

                        # configure the compent numbers in the sub agents
                        for C in $COMPONENTS
                        do

                            if test "$c" = "$C"
                            then
                                # set this component number
                                sed -e "s/###${C}_worker###/$w/g" -i "$cfg"
        
                                # set this clone number to create clones
                                sed -e "s/###${C}_clone###/$n/g" -i "$cfg"
        
                                # set this drop number to drop clones
                                sed -e "s/###${C}_drop###/1/g" -i "$cfg"
                            else
                                # set all *other* component numbers to 1
                                sed -e "s/###${C}_worker###/1/g" -i "$cfg"
        
                                # set *other* clone number to create no clones
                                sed -e "s/###${C}_clone###/1/g" -i "$cfg"
        
                                # set *other* drop number to drop nothing
                                sed -e "s/###${C}_drop###/0/g" -i "$cfg"
                           fi
                        done
    
                        # do the remaining wildcards (if COMPONENTS is incomplete)
                        sed -e "s/###.*_worker###/1/g" -i "$cfg"
                        sed -e "s/###.*_clone###/1/g"  -i "$cfg"
                        sed -e "s/###.*_drop###/0/g"   -i "$cfg"
        
                      # echo $cfg
                      # cat  $cfg
        
                        # create 10^[246] byte sized dummy files for staging
                        if ! test -f /tmp/input_$d.dat
                        then
                            dd if=/dev/urandom of=/tmp/input_$d.dat count=$d iflag=count_bytes
                        fi
        
                        i=0
                        while ! test $i = "$REPS"
                        do
                            i=$((i+1))
                            exp="${c}_${s}_${d}_${a}_${w}_${r}_${i}"
                            log="$exp.log"
                            load=`printf "$CU_LOAD" $d`
        
                            tag=`printf '%s : %4d : %2d : %2d : %2d : %-10s : %2d :' \
                                         $c    $s    $d    $a    $w      $r    $i`

                            grep "$tag" experiment.sids >/dev/null

                            if test $? = 0
                            then
                                echo "skipping experiment $tag (tag exists)"
        
                            else
                                echo "running  experiment $tag ($cfg)"
        
                                rm -f  last.sid
                                rm -rf $HOME/.saga/adaptors/shell_job/
                              # killall -9 -q -u merzky python
                              # sleep 1
                                
                                export RADICAL_PILOT_PROFILE=True
                                export RADICAL_VERBOSE="DEBUG"
                                export RADICAL_LOG_TGT="`pwd`/$log"

                                python experiment.py       \
                                    -a "`pwd`/$cfg"        \
                                    -c "$s"                \
                                    -u "1"                 \
                                    -t "$RUNTIME"          \
                                    -r "$r"                \
                                    -l "$load"             \
                                    -q "$q"
                
                                sid=`cat last.sid`
                                sid=`echo $sid` # trim white spaces
                
                                echo "$tag $sid" >> experiment.sids
                                mkdir -p "data/$sid/"

                                if test -z "$sid"
                                then
                                    echo "could not get sid"
                                    exit 1
                                fi
                
                              # radicalpilot-stats -m prof -s "$sid" -p "data/"
                           echo radicalpilot-fetch-profiles -s "$sid" -t "data/"
                                radicalpilot-fetch-profiles -s "$sid" -t "data/"
                                radicalpilot-close-session  -m export -s "$sid" 
                                mv "$sid".json "data/$sid/"
                                mv "$log"      "data/$sid/"
                                cp "$cfg"      "data/$sid/"
                                ls -l          "data/$sid/"
                                rm -f "$sid.prof"
                            fi
                        done

                        # reset to actual values for a, w
                        a=$old_a
                        w=$old_w

                    done
    
                    rm -f "$cfg"
                done
            done
        done
    done
done

