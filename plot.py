#!/usr/bin/env python

import os
import sys
import pprint
import radical.pilot       as rp
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
      # c: component
      # s: size of pilot
      # d: data size
      # a: number of agents
      # w: number of workers
      # r: resource
      # i: index of reptition
      # "$c : $s : $d : $a : $w : $r : $i : $sid"
        c, s, d, a, w, r, i, sid = line.replace(' ', '').replace('\n', '').split(':')
        if c not in experiments:
            experiments[c] = list()
        experiments[c].append([sid, "%s %s %s %s %s %s %s" % (c, s, d, a, w, r, i)])

print
pprint.pprint(experiments)

exp_frames = rpu.get_experiment_frames(experiments, exp_data)
# pprint.pprint(exp_frames)

event_filter = {'inp' : {'in' : [{'state' : rp.AGENT_STAGING_INPUT,
                                  'event' : 'advance'                       }],
                         'out': [{'state' : rp.AGENT_SCHEDULING,
                                  'event' : 'advance'                       }],
                        },
                'sch' : {'in' : [{'state' : rp.AGENT_SCHEDULING,
                                  'event' : 'advance'                       }],
                         'out': [{'state' : rp.AGENT_EXECUTING_PENDING,
                                  'event' : 'advance'                       }],
                        },
                'exe' : {'in' : [{'state' : rp.EXECUTING,
                                  'event' : 'advance'                       }],
                         'out': [{'state' : rp.AGENT_STAGING_OUTPUT_PENDING,
                                  'event' : 'advance'                       }],
                        },
                'out' : {'in' : [{'state' : rp.AGENT_STAGING_OUTPUT,
                                  'event' : 'advance'                       }],
                         'out': [{'state' : rp.PENDING_OUTPUT_STAGING ,
                                  'event' : 'advance'                       }],
                        }
               }


for exp in sorted(exp_frames.keys()):
    print "plotting '%s'" % exp

    # these are the franes we want to plot for this experiment
    plot_frames = list()

    for frame, label in exp_frames[exp]:

        # we add a data frame column for CU concurrency for the component of
        # interest.  Also, we calibrate t0 to when the first unit enters that
        # component.
        rpu.add_frequency   (frame, tgt='cu_freq',  spec=event_filter[exp]['in'])
        rpu.add_event_count (frame, tgt='cu_count', spec=event_filter[exp]['in'])
        rpu.add_concurrency (frame, tgt='cu_conc',  spec=event_filter[exp])
        rpu.calibrate_frame (frame,                 spec=event_filter[exp]['in'])
        plot_frames.append([frame, label])
      # plot_frames.append([frame, None])

    # create the plots for CU concurrency over time, and also show the plots in the notebook
    fig, _ = rpu.frame_plot(plot_frames, logx=False, logy=False,
                            title="%s_freq" % exp, legend=True, figdir=figdir,
                            axis=[['time',    'time (s)'],
                                  ['cu_freq', "frequency CUs in '%s'" % exp]])

    # create the plots for CU concurrency over time, and also show the plots in the notebook
    fig, _ = rpu.frame_plot(plot_frames, logx=False, logy=False,
                            title="%s_count" % exp, legend=True, figdir=figdir,
                            axis=[['time',    'time (s)'],
                                  ['cu_count', "count of CUs in '%s'" % exp]])
  # fig.show()

    # inverse axis, use logar. scale for time
    fig, _ = rpu.frame_plot(plot_frames, logx=False, logy=False,
                            title="%s_conc" % exp, legend=True, figdir=figdir,
                            axis=[['time',   'time (s)'],
                                  ['cu_conc', 'number of concurrent CUs']])
  # fig.show()


