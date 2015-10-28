#!/usr/bin/env python

__copyright__ = "Copyright 2013-2014, http://radical.rutgers.edu"
__license__   = "MIT"

import sys
import time
import radical.pilot as rp
import radical.utils as ru

RESOURCES = {'local' : {
                 'resource' : 'local.localhost',
                 'project'  : None,
                 'queue'    : None,
                 'schema'   : None,
                 },
             
             'test' : {
                 'resource' : 'home.test',
                 'project'  : None,
                 'queue'    : None,
                 'schema'   : 'ssh',
                 },
             
             'archer' : {
                 'resource' : 'epsrc.archer_orte',
                 'project'  : 'e290',
                 'queue'    : 'short',
                 'schema'   : None,
                 },
             
             'supermuc' : {
                 'resource' : 'lrz.supermuc',
                 'project'  : 'e290',
                 'queue'    : 'short',
                 'schema'   : None,
                 },
             
             'stampede' : {
                 'resource' : 'xsede.stampede',
                 'project'  : 'TG-MCB090174' ,
                 'queue'    : 'normal',
                 'schema'   : None,
                 },
             
             'gordon' : {
                 'resource' : 'xsede.gordon',
                 'project'  : None,
                 'queue'    : 'debug',
                 'schema'   : None,
                 },
             
             'blacklight' : {
                 'resource' : 'xsede.blacklight',
                 'project'  : None,
                 'queue'    : 'debug',
                 'schema'   : 'gsissh',
                 },
             
             'trestles' : {
                 'resource' : 'xsede.trestles',
                 'project'  : 'TG-MCB090174' ,
                 'queue'    : 'shared',
                 'schema'   : None,
                 },

             'india' : {
                 'resource' : 'futuregrid.india',
                 'project'  : None,
                 'queue'    : None,
                 'schema'   : None,
                 },

             'hopper' : {
                 'resource' : 'nersc.hopper',
                 'project'  : None,
                 'queue'    : 'debug',
                 'schema'   : 'ssh',
                 }
             }


#------------------------------------------------------------------------------
#
def run_experiment(n_cores, n_units, resources, runtime, cu_load, agent_cfg, 
        scheduler, queue=None):

    # Create a new session. No need to try/except this: if session creation
    # fails, there is not much we can do anyways...
    session = rp.Session()
    sid     = session.uid

    # all other pilot code is now tried/excepted.  If an exception is caught, we
    # can rely on the session object to exist and be valid, and we can thus tear
    # the whole RP stack down via a 'session.close()' call in the 'finally'
    # clause...
    try:

        pmgr   = rp.PilotManager(session=session)
        pilots = list()

        for resource in resources:

            if not queue: 
                queue = RESOURCES[resource]['queue']

            pdesc = rp.ComputePilotDescription()
            pdesc.resource      = RESOURCES[resource]['resource']
            pdesc.cores         = n_cores
            pdesc.project       = RESOURCES[resource]['project']
            pdesc.runtime       = runtime
            pdesc.cleanup       = False
            pdesc.access_schema = RESOURCES[resource]['schema']
            pdesc.exit_on_error = True
            pdesc._config       = agent_cfg

            if queue and resource != 'local':
                print 'queue: %s'%queue
                pdesc.queue     = queue

            pilot = pmgr.submit_pilots(pdesc)

            input_sd_pilot = {
                    'source': 'file:///etc/passwd',
                    'target': 'staging:///f1',
                    'action': rp.TRANSFER
                    }
            pilot.stage_in (input_sd_pilot)
            pilots.append (pilot)


        umgr = rp.UnitManager(session=session, scheduler=scheduler)
        umgr.add_pilots(pilots)

        input_sd_umgr   = {'source':'/etc/group',    'target': 'f2',                'action': rp.TRANSFER}
        input_sd_agent  = {'source':'staging:///f1', 'target': 'f1',                'action': rp.LINK}
        output_sd_agent = {'source':'f1',            'target': 'staging:///f1.bak', 'action': rp.COPY}
        output_sd_umgr  = {'source':'f2',            'target': 'f2.bak',            'action': rp.TRANSFER}

        cuds = list()
        for unit_count in range(0, n_units):
            cud = rp.ComputeUnitDescription()
            cud.executable     = cu_load['executable']
            cud.arguments      = cu_load['arguments']
            cud.cores          = cu_load['cores']
            cud.input_staging  = [ input_sd_umgr,  input_sd_agent]
            cud.output_staging = [output_sd_umgr, output_sd_agent]
            cuds.append(cud)

        units = umgr.submit_units(cuds)

        umgr.wait_units()

      # os.system ("radicalpilot-stats -m stat,plot -s %s > %s.stat" % (session.uid, session_name))


    except Exception as e:
        # Something unexpected happened in the pilot code above
        import logging
        logging.exception("caught Exception")
        raise

    except (KeyboardInterrupt, SystemExit) as e:
        # the callback called sys.exit(), and we can here catch the
        # corresponding KeyboardInterrupt exception for shutdown.  We also catch
        # SystemExit (which gets raised if the main threads exits for some other
        # reason).
        pass

    finally:
        # always clean up the session, no matter if we caught an exception or
        # not.
        time.sleep (10) # give time to finish clones...
        session.close (cleanup=False) # keep the DB entries...


    return sid

#-------------------------------------------------------------------------------


if __name__ == "__main__":

    import optparse
    parser = optparse.OptionParser (add_help_option=False)
    
    parser.add_option('-c', '--cores',     dest='cores')
    parser.add_option('-u', '--units',     dest='units')
    parser.add_option('-t', '--time',      dest='runtime')
    parser.add_option('-l', '--load',      dest='load')
    parser.add_option('-a', '--agent_cfg', dest='agent_cfg')
    parser.add_option('-r', '--resources', dest='resources')
    parser.add_option('-s', '--scheduler', dest='scheduler')
    parser.add_option('-q', '--queue',     dest='queue')
    
    options, args = parser.parse_args ()
    
    n_cores   = options.cores
    n_units   = options.units
    resources = options.resources
    runtime   = options.runtime
    load      = options.load
    agent_cfg = options.agent_cfg
    scheduler = options.scheduler
    queue     = options.queue

    if   scheduler == 'direct'     : scheduler = rp.SCHED_DIRECT
    elif scheduler == 'backfilling': scheduler = rp.SCHED_BACKFILLING
    elif scheduler == 'round_robin': scheduler = rp.SCHED_ROUND_ROBIN
    else                           : scheduler = rp.SCHED_ROUND_ROBIN
    
    if not n_cores  : raise ValueError ("need number of cores")
    if not n_units  : raise ValueError ("need number of units")
    if not runtime  : raise ValueError ("need pilot runtime")
    if not resources: raise ValueError ("need target resource")
    if not load     : raise ValueError ("need load config")
    if not agent_cfg: raise ValueError ("need agent config")

    if not queue    : queue = None
    
    resources = resources.split(',')

    for resource in resources:
        if not resource in RESOURCES:
            raise ValueError ("unknown resource %s" % resource)

    cu_load = ru.read_json (load)

    n_cores = int(n_cores)
    n_units = int(n_units)
    runtime = int(runtime)

    sid = run_experiment (n_cores, n_units, resources, runtime, cu_load,
            agent_cfg, scheduler, queue)

    with open('last.sid', 'w') as f:
        f.write("%s\n" % sid)

