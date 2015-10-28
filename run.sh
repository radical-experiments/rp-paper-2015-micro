#!/bin/sh


# load the virtenv
. ./ve/bin/activate
python -c 'import radical.pilot as rp' || exit

# list of components we want to benchmark.  For each component, we will create
# a config which configures the blowup mechanism to load just that component.
# We will then run that config repeatedly (for stats) and collect the profles.
COMPONENTS='inp sch exe out'
# COMPONENTS='exe'

# number of repetitions
REPS=1

# target resource : cores per node
RESOURCES='stampede:16 local'
# RESOURCES='local'

# compute unit load
# CU_LOAD='sleep_%s.json'
CU_LOAD='cu_true.json'

# experiment sizes (make sure it fits into the queue limits after the agent
# nodes were added)
# SIZES='128: 256: 512: 1024:'
SIZES='256: 512: 1024: 2048:'
SIZES='1024:'
SIZES='250:normal 500:normal 1000:normal'
SIZES='250:normal 1000:normal'

# number of components per sub agent
WORKERS='1 2 4 8'
WORKERS='1'
WORKERS='1 8'

# number of sub agents to use
AGENTS='1'
AGENTS='2 4 8 1'

# agent layout to use
# simple_n describes a layout where n sub-agents all have a full set of
# $WORKER agent components -- AgentWorker and AgentSchedulingComponent remain
# singletons in agent_0 though
AGENT_CFG_TMPL='agent_simple.tmpl'

# fixed parameters
RUNTIME=30

# staging file sizes
FILES='0 1 1K 1M'
FILES='0'

mkdir -p 'data/'

tmp='./tmp.dat'

# we always run exactly one CU, but clone 'n' in the component of interest
n=10000

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
                        # for each experiment, we create a new config with the requested
                        # number of sub agents
                        cfg="agent_$c.$s.$d.$a.$w.$r.cfg"
    
                        cat "$AGENT_CFG_TMPL" \
                            | sed -e "s/###sub_agents###/$sub_agents/g" \
                            > "$cfg"
        
                        for C in $COMPONENTS
                        do
                            if test "$c" = "$C"
                            then
                                # set this component number
                                cat "$cfg" | sed -e "s/###${C}_worker###/$w/g" > "$tmp"
                                mv "$tmp" "$cfg"
        
                                # set this clone number to create clones
                                cat "$cfg" | sed -e "s/###${C}_clone###/$n/g" > "$tmp"
                                mv "$tmp" "$cfg"
        
                                # set this drop number to drop clones
                                cat "$cfg" | sed -e "s/###${C}_drop###/1/g" > "$tmp"
                                mv "$tmp" "$cfg"
                            else
                                # set all *other* component numbers to 1
                                cat "$cfg" | sed -e "s/###${C}_worker###/1/g" > "$tmp"
                                mv "$tmp" "$cfg"
        
                                # set *other* clone number to create no clones
                                cat "$cfg" | sed -e "s/###${C}_clone###/1/g" > "$tmp"
                                mv "$tmp" "$cfg"
        
                                # set *other* drop number to drop nothing
                                cat "$cfg" | sed -e "s/###${C}_drop###/0/g" > "$tmp"
                                mv "$tmp" "$cfg"
                           fi
                        done
    
                        # do the remaining wildcards (if COMPONENTS is incomplete)
                        cat "$cfg" | sed -e "s/###.*_worker###/1/g" > "$tmp"
                        mv "$tmp" "$cfg"
                        cat "$cfg" | sed -e "s/###.*_clone###/1/g" > "$tmp"
                        mv "$tmp" "$cfg"
                        cat "$cfg" | sed -e "s/###.*_drop###/0/g" > "$tmp"
                        mv "$tmp" "$cfg"
        
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
        
                            tag="$c : $s : $d : $a : $w : $r : $i :"
                            grep "$tag" experiment.sids >/dev/null
        
                            if test $? = 0
                            then
                                echo "tag exists - skipping experiment $tag"
        
                            else
                                echo "running experiment $tag ($cfg)"
        
                                rm -f  last.sid
                                rm -rf $HOME/.saga/adaptors/shell_job/
                                killall -9 -q -u merzky python
                                sleep 1
                                
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
                                radicalpilot-fetch-profiles -s "$sid" -t "data/"
                                radicalpilot-close-session  -m export -s "$sid" 
                                mv "$sid".json "data/$sid/"
                                mv "$log"      "data/$sid/"
                                cp "$cfg"      "data/$sid/"
                                ls -l          "data/$sid/"
                                rm -f "$sid.prof"
                            fi
                        done
                    done
    
                    rm -f "$cfg"
                done
            done
        done
    done
done

