#!/usr/bin/env python

import os
import sys
import pprint
import collections         as coll
import radical.pilot       as rp
import radical.pilot.utils as rpu

#------------------------------------------------------------------------------
#
def create_event_filter():

    # create a dict which orders states
    unit_state_value = coll.OrderedDict()
  # unit_state_value[rp.SCHEDULING                   ] =   5
  # unit_state_value[rp.STAGING_INPUT                ] =   6
  # unit_state_value[rp.AGENT_STAGING_INPUT_PENDING  ] =   7
    unit_state_value[rp.AGENT_STAGING_INPUT          ] =   8
    unit_state_value[rp.ALLOCATING_PENDING           ] =   9
    unit_state_value[rp.ALLOCATING                   ] =  10
    unit_state_value[rp.EXECUTING_PENDING            ] =  11
    unit_state_value[rp.EXECUTING                    ] =  12
    unit_state_value[rp.AGENT_STAGING_OUTPUT_PENDING ] =  13
    unit_state_value[rp.AGENT_STAGING_OUTPUT         ] =  14
    unit_state_value[rp.PENDING_OUTPUT_STAGING       ] =  15
  # unit_state_value[rp.STAGING_OUTPUT               ] =  16
    unit_state_value[rp.DONE                         ] =  17
    
    # also create inverse dict
    inv_unit_state_value = coll.OrderedDict()
    for k, v in unit_state_value.items():
        inv_unit_state_value[v] = k
    
    # create a filter which catches transitions between states
    event_filter = coll.OrderedDict()
    for val in inv_unit_state_value:
        s_in  = inv_unit_state_value[val]
        s_out = inv_unit_state_value.get(val+1)
    
        # nothing transitions out of last state
        if not s_out:
            continue
    
      # not interested in pending states...
      # if 'pending' in s_in.lower():
      #     continue
    
        event_filter[s_in] = {'in' : [{'state' : s_in, 
                                       'event' : 'advance',
                                       'msg'   : ''}],
                              'out': [{'state' : s_out, 
                                       'event' : 'advance'}]}
    return event_filter


# ------------------------------------------------------------------------------
#
def read_experiments(exp_index):

    idx=0
    with open(exp_index, 'r') as f:
        for line in f.readlines():
            if line[0] == "#":
                continue
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
            print c, s, d, a, w, r, i, sid 
            if c not in experiments:
                experiments[c] = list()
            experiments[c].append([sid, "%s %s %s %s %s %s %s" % (c, s, d, a, w, r, i)])
    
    print
    pprint.pprint(experiments)
    
    exp_frames = rpu.get_experiment_frames(experiments, exp_data)
  # pprint.pprint(exp_frames)

    return exp_frames


# ------------------------------------------------------------------------------
#
def translate_label(label):

    c, s, d, a, w, r, i = label.split()

    ctype = {'exe' : 'execute',
             'inp' : 'input',
             'out' : 'output',
             'sch' : 'sched.'}.get(c, '')

    if ctype: loc = "%-8s [%-7s]" % (r, ctype)
    else    : loc = "%-8s" % r

  # ret = "%s: %3d SA, %3d CI, %4d cores" % (loc, int(a), int(w), int(s))
  # ret = "%-10s" % r

    n = int(a) * int(w)
    ret = " %2d " % int(n)

    return ret


# ------------------------------------------------------------------------------
#
def plot_experiments(exp_frames, figdir):

    import numpy  as np
    import pandas as pd

    event_filter = create_event_filter()
    
    for exp in exp_frames.keys():
        print "plotting '%s'" % exp
    
        # these are the frames we want to plot for this experiment
        plot_frames = list()

        exp2state = { 'inp' : rp.AGENT_STAGING_INPUT, 
                      'sch' : rp.ALLOCATING,
                      'exe' : rp.EXECUTING,
                      'out' : rp.AGENT_STAGING_OUTPUT }

        for frame, label in exp_frames[exp]:

            state = exp2state[exp]

            rp.utils.add_frequency   (frame, tgt='rate'  , spec=event_filter[state]['in'])
            rp.utils.add_event_count (frame, tgt='events', spec=event_filter[state]['in'])
            rp.utils.add_concurrency (frame, tgt='conc'  , spec=event_filter[state])
            rp.utils.calibrate_frame (frame,               spec=event_filter[state]['in'])
            
            frame['t_idx'] = pd.to_datetime(frame['time'], unit='us')
            frame = frame.set_index(pd.DatetimeIndex(frame['t_idx']))

            samples = frame[['t_idx', 'time', 'rate', 'events', 'conc']].dropna()

          # print "0 %s" % label
          # print samples
          # print "1 ---------"
          # print repr(samples)
          # print "2 ---------"
          # print samples.dtypes
          # print "3 ---------"
          # print samples.ix
          # print "4 ---------"
          # print type(samples)
          # print "5 ---------"
          # print
          # print

            
            plot_frames.append([samples, translate_label(label)])

        cmap = {'Comet'       : 'green'  ,
                'Stampede'    : 'red'    ,
                'Blue Waters' : 'blue'   ,
                ' 1 '         : 'red'    ,
                ' 2 '         : 'green'  ,
                ' 4 '         : 'blue'   ,
                ' 8 '         : 'black'  ,
                ' 16 '        : 'orange' ,
                ' 32 '        : 'magenta'}
            
        # create plots for each type (rate, events, concurrency)
        rp.utils.frame_plot(plot_frames, figdir=figdir, logx=False, logy=False,
                     # title="%s_unit_throughput" % exp, 
                       legend=True, cmap=cmap,
                       axis=[['time', 'Time (s)'],
                             ['rate', "Rate (units/s)"]])
        
        rp.utils.frame_plot(plot_frames, figdir=figdir, logx=False, logy=False,
                     # title="%s_unit_concurrency" % exp, 
                       legend=True, cmap=cmap,
                       axis=[['time', 'Time (s)'],
                             ['conc', 'Concurrent Units']])

        rp.utils.frame_plot(plot_frames, figdir=figdir, logx=False, logy=False,
                     # title="%s_state_transitions" % exp, 
                       legend=True, cmap=cmap,
                       legend_pos='upper left',
                       axis=[['time',  'Time (s)'],
                             ['events', "Number of Events"]])
        
    
      # for frame, label in exp_frames[exp]:
      #
      #     # we add a data frame column for CU concurrency for the component of
      #     # interest.  Also, we calibrate t0 to when the first unit enters that
      #     # component.
      #     rpu.add_frequency   (frame, tgt='cu_freq',  spec=event_filter[exp]['in'])
      #     rpu.add_event_count (frame, tgt='cu_count', spec=event_filter[exp]['in'])
      #     rpu.add_concurrency (frame, tgt='cu_conc',  spec=event_filter[exp])
      #     rpu.calibrate_frame (frame,                 spec=event_filter[exp]['in'])
      #     plot_frames.append([frame, label])
      #   # plot_frames.append([frame, None])
      #
      # # create the plots for CU concurrency over time, and also show the plots in the notebook
      # fig, _ = rpu.frame_plot(plot_frames, logx=False, logy=False,
      #                         title="%s_freq" % exp, legend=True, figdir=figdir,
      #                         axis=[['time',    'time (s)'],
      #                               ['cu_freq', "frequency CUs in '%s'" % exp]])
      #
      # # create the plots for CU concurrency over time, and also show the plots in the notebook
      # fig, _ = rpu.frame_plot(plot_frames, logx=False, logy=False,
      #                         title="%s_count" % exp, legend=True, figdir=figdir,
      #                         axis=[['time',    'time (s)'],
      #                               ['cu_count', "count of CUs in '%s'" % exp]])
      #
      # # inverse axis, use logar. scale for time
      # fig, _ = rpu.frame_plot(plot_frames, logx=False, logy=False,
      #                         title="%s_conc" % exp, legend=True, figdir=figdir,
      #                         axis=[['time',   'time (s)'],
      #                               ['cu_conc', 'number of concurrent CUs']])
    
    
# ------------------------------------------------------------------------------
#
if __name__ == "__main__":

    base        = "/home/merzky/saga/experiments/rp-paper-2015-micro"
    base        = "/home/merzky/radical/rp-paper-2015-micro"
    exp_data    = "%s/data/"            % (base)
    exp_index   = "%s/experiment.sids"  % (base)
    experiments = dict()
    
    if len(sys.argv) > 1:
        exp_index = sys.argv[1]

    tgt = '.'.join(os.path.basename(exp_index).split('.')[:-1])
    
    figdir = "%s/plots/%s.plots" % (base, tgt)
    try:
        os.mkdir (figdir)
    except OSError:
        pass

    exp_frames = read_experiments(exp_index)
    plot_experiments(exp_frames, figdir)


