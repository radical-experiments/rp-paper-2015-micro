#!/bin/sh

export RADICAL_PILOT_PROFILE=True
export RADICAL_DEBUG=TRUE
export RADICAL_VERBOSE=DEBUG
export RADICAL_UTILS_VERBOSE=DEBUG
export RADICAL_SAGA_VERBOSE=DEBUG
export RADICAL_PILOT_VERBOSE=DEBUG

# load the virtenv
. $HOME/saga/radical.pilot.micro/ve/bin/activate
python -c 'import radical.pilot as rp; print rp.version_detail'

# list of components we want to benchmark.  For each component, we will create
# a config which configures the blowup mechanism to load just that component.
# We will then run that config repeatedly (for stats) and collect the profles.
COMPONENTS='inp sch exe out'

# number of repetitions
REPS=1

# target resource
# RESOURCE='local'
RESOURCE='stampede'

# compute unit load
CU_LOAD='sleep_%s.json'

# experiment sizes
# SIZES="128: 512: 1024:"
# SIZES="128:development 512:development 1024:normal"
SIZES="512:development"

# number of components per sub agent
WORKERS="2 4 8 1"

# number of sub agents to use
AGENTS="2 4 8 1"

# agent layout to use
# simple_n describes a layout where n sub-agents all have a full set of
# $WORKER agent components -- AgentWorker and AgentSchedulingComponent remain
# singletons in agent.0 though
AGENT_CFG_TMPL="agent_simple.tmpl"

# fixed parameters
RUNTIME=30

FILES="0 1 1K 1M"
FILES="0"

mkdir -p "data/"
mkdir -p 'log/'


r="$RESOURCE"
tmp="./tmp.dat"
n=1024  # nuymber of clones to use

for a in $AGENTS
do
    a_idx=2
    sub_agents="\"agent.1\""
    while test "$a_idx" -le "$a"
    do
        sub_agents="$sub_agents, \"agent.$a_idx\""
        a_idx=$((a_idx+1))
    done

    for c in $COMPONENTS
    do
        for tmp in $SIZES
        do
            s=`echo $tmp | cut -f 1 -d :`
            q=`echo $tmp | cut -f 2 -d :`
    
            for w in $WORKERS
            do
                # for each experiment, we create a new config with the requested
                # number of sub agents
                cfg="agent.$c.$s.$d.$a.$w.$r.cfg"
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
    
                cat $cfg
    
                for d in $FILES
                do
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
                        log="log/$exp.log"
                        load=`printf "$CU_LOAD" $d`
    
                        tag="$c : $s : $d : $a : $w : $r : $i :"
                        grep "$tag" experiment.sids >/dev/null
    
                        if test $? = 0
                        then
                            echo "tag exists - skipping experiment $tag"
    
                        else
                            echo "running experiment $tag"
    
                            rm -rf $HOME/.saga/adaptors/shell_job/
                            killall -9 -q -u merzky python
                            sleep 1
            
                            python experiment.py       \
                                -a "$cfg"              \
                                -c "$s"                \
                                -u "1"                 \
                                -t "$RUNTIME"          \
                                -r "$r"                \
                                -l "$load"             \
                                -q "$q"                \
                                2>&1 | tee "$log" 
            
                            sid=`grep 'session id:' $log | tail -n 1 | cut -f 2 -d :`
                            sid=`echo $sid` # trim white spaces
            
                            echo "$tag $sid" | tee -a experiment.sids
                            mkdir -p "$data/$sid"
            
                            radicalpilot-stats -m prof -s "$sid" -p "data/"
                            radicalpilot-close-session -m export -s "$sid" 
                            mv -v "$sid".json data/
                            echo "$log"
                            exit
                        fi
                    done
                done
            done
        done
    done
done

