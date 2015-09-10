#!/usr/bin/env python

import os
import sys
import radical.pilot.utils as rpu

if len(sys.argv) > 1:
    tgt = ".%s" % sys.argv[1]
else:
    tgt = ""

base        = "/home/merzky/saga/experiments/rp-paper-2015-micro"
exp_data    = "%s/data%s/"            % (base, tgt)
exp_index   = "%s/experiment.sids%s"  % (base, tgt)
experiments = dict()

figdir = "%s/plots%s" % (base, tgt)
try:
    os.mkdir (figdir)
except OSError:
    pass

idx=0
with open(exp_index, 'r') as f:
    for line in f.readlines():
        idx+=1
      # if idx > 10: 
      #     break
        r, c, s, d, w, i, sid = line.replace(' ', '').replace('\n', '').split(':')
        print r, c, s, d, w, i, sid
        if c not in experiments:
            experiments[c] = list()
        experiments[c].append([sid, "%s %s %s %s %s %s" % (r, c, s, d, w, i)])

import pprint
pprint.pprint(experiments)

exp_frames = rpu.get_experiment_frames(experiments, exp_data)

event_filter = {'agent'           : {'in' : [{'event'   : 'get',
                                              'message' : 'MongoDB to Agent (PendingExecution)'}, 
                                             {'event'   : 'add clone',
                                              'message' : 'Agent'}],
                                     'out': [{'event'   : 'put',
                                              'message' : 'Agent to schedule_queue (Allocating)'},
                                             {'event'   : 'drop clone',
                                              'message' : 'schedule_queue'}]
                                    },
                 'staging_input'  : {'in' : [{'event'   : 'get',
                                              'message' : 'stagein_queue to StageinWorker (StagingInput)'}],
                                     'out': [{'event'   : 'put',
                                              'message' : 'StageinWorker to update_queue'}]
                                    },
                 'scheduling'     : {'in' : [{'event'   : 'get',
                                              'message' : 'schedule_queue to Scheduler (Allocating)'}], 
                                     'out': [{'event'   : 'schedule',
                                              'message' : 'allocated'}]
                                    },
                 'execution'      : {'in' : [{'event'   : 'get',
                                              'message' : 'executing_queue to ExecutionWorker (Executing)'}, 
                                             {'event'   : 'get',
                                              'message' : 'ExecWatcher picked up unit'}],
                                     'out': [{'event'   : 'put',
                                              'message' : 'ExecWorker to watcher (Executing)'},
                                             {'event'   : 'put',
                                              'message' : 'ExecWatcher to update_queue (StagingOutput)'}]
                                    },
                 'staging_output' : {'in' : [{'event'   : 'get',
                                              'message' : 'stageout_queue to StageoutWorker (StagingOutput)'}],
                                     'out': [{'event'   : 'put',
                                              'message' : 'StageoutWorker to update_queue'}]
                                    },
                 'update'         : {'in' : [{'event'   : 'get',
                                              'message' : 'update_queue to UpdateWorker (StagingInput)'}, 
                                             {'event'   : 'get',
                                              'message' : 'update_queue to UpdateWorker (Allocating)'}, 
                                             {'event'   : 'get',
                                              'message' : 'update_queue to UpdateWorker (Executing)'},
                                             {'event'   : 'get',
                                              'message' : 'update_queue to UpdateWorker (StagingOutput)'},
                                             {'event'   : 'get',
                                              'message' : 'update_queue to UpdateWorker'}],
                                     'out': [{'event'   : 'unit update pushed (None)'},
                                             {'event'   : 'unit update pushed (StagingInput)'},
                                             {'event'   : 'unit update pushed (Allocating)'},
                                             {'event'   : 'unit update pushed (Executing)'},
                                             {'event'   : 'unit update pushed (StagingOutput)'},
                                             {'event'   : 'unit update pushed'}]
                                     }
               }

calib_filter = {'agent'           : event_filter['agent'         ]['in'],
                'staging_input'   : event_filter['staging_input' ]['in'],
                'scheduling'      : event_filter['scheduling'    ]['in'],
                'execution'       : event_filter['execution'     ]['in'],
                'staging_output'  : event_filter['staging_output']['in'],
                'update'          : event_filter['update'        ]['in']
               }



for exp in sorted(exp_frames.keys()):
    print "plotting '%s'" % exp

    # these are the franes we want to plot for this experiment
    plot_frames = list()
    
    for frame, label in exp_frames[exp]:
        # we add a data frame column for CU concurrency for the component of
        # interest.  Also, we calibrate t0 to when the first unit enters that
        # component.
        rpu.add_concurrency (frame, tgt='cu_num', spec=event_filter[exp])
        rpu.calibrate_frame (frame, spec=calib_filter[exp])
      # plot_frames.append([frame, label])
        plot_frames.append([frame, None])
        
    # create the plots for CU concurrency over time, and also show the plots in the notebook
    fig, _ = rpu.frame_plot(plot_frames, logx=False, logy=False, 
                            title=exp, legend=False, figdir=figdir,
                            axis=[['time',   'time (s)'], 
                                  ['cu_num', "number of concurrent CUs in '%s'" % exp]])
  # fig.show()
  # 
  # # inverse axis, use logar. scale for time
  # fig, _ = rpu.frame_plot(plot_frames, logx=False, logy=True, title=exp,
  #                         title=exp, legend=False, figdir=figdir,
  #                         axis=[['cu_num', 'number of concurrent CUs'],
  #                               ['time',   'time (s)']])
  # fig.show()


