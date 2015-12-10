#!/bin/sh

unset RADICAL_PILOT_PROFILE 
unset RADICAL_VERBOSE

# export RADICAL_PILOT_PROFILE=TRUE
 
# RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=tmp.log ./experiment.py -a agent_exe.500.0.10.1.bw.cfg -c 512 -u 1 -t 15 -r bw -l cu_true.json -q debug

env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.01.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.01.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.02.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.03.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.04.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.01.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.01.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.02.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.03.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.04.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.01.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.01.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.02.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.03.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.04.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.01.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.01.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.02.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.03.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env RADICAL_PILOT_PROFILE=TRUE RADICAL_VERBOSE=DEBUG  RADICAL_LOG_TGT=agent_out.500.0.1.1.local.04.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json

env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.05.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.06.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.07.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.08.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.09.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.05.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.06.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.07.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.08.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.09.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.05.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.06.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.07.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.08.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.09.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.05.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.06.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.07.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.08.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json
env                            RADICAL_VERBOSE=REPORT RADICAL_LOG_TGT=agent_out.500.0.1.1.local.09.log ./experiment.py -a agent_out.500.0.1.1.local.cfg -c 256 -u 1 -t 15 -r stampede -l cu_true.json

