#!/bin/sh

for d in data/rp*/
do 
    test -f $d/pilot.0000/agent_0.AgentWorker.0.child.prof || mv -v $d quarantined/
done

