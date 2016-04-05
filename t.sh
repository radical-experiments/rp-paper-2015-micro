
# export RP_PLOT_LIMIT=1000
unset RP_PLOT_LIMIT

# time ./plot.py sids/exe.1000.stampede.sids
# time ./plot.py sids/out.1000.bw.sids

  time ./plot.py sids/exe.500.1.1.sids
  time ./plot.py sids/inp.500.1.1.sids
  time ./plot.py sids/inp.500.4.4.sids
  time ./plot.py sids/out.500.1.1.sids
  time ./plot.py sids/sch.500.1.1.sids


cp -v plots/exe.1000.stampede.plots/time_s_rate_units_s.pdf ~/papers/radical-pilot/sc16/figures/micro_1000_stampede_exe_unit_throughput.pdf
cp -v plots/out.1000.bw.plots/time_s_rate_units_s.pdf       ~/papers/radical-pilot/sc16/figures/micro_1000_bw_out_unit_throughput.pdf
cp -v plots/inp.500.4.4.plots/time_s_rate_units_s.pdf       ~/papers/radical-pilot/sc16/figures/micro_inp_500_4_4_unit_throughput.pdf 
cp -v plots/exe.500.1.1.plots/time_s_rate_units_s.pdf       ~/papers/radical-pilot/sc16/figures/micro_exe_500_1_1_unit_throughput.pdf
cp -v plots/inp.500.1.1.plots/time_s_rate_units_s.pdf       ~/papers/radical-pilot/sc16/figures/micro_inp_500_1_1_unit_throughput.pdf 
cp -v plots/out.500.1.1.plots/time_s_rate_units_s.pdf       ~/papers/radical-pilot/sc16/figures/micro_out_500_1_1_unit_throughput.pdf 
cp -v plots/sch.500.1.1.plots/time_s_rate_units_s.pdf       ~/papers/radical-pilot/sc16/figures/micro_sch_500_1_1_unit_throughput.pdf 

cp -v plots/exe.1000.stampede.plots/time_s_rate_units_s.png ~/papers/radical-pilot/sc16/figures/micro_1000_stampede_exe_unit_throughput.png
cp -v plots/out.1000.bw.plots/time_s_rate_units_s.png       ~/papers/radical-pilot/sc16/figures/micro_1000_bw_out_unit_throughput.png
cp -v plots/inp.500.4.4.plots/time_s_rate_units_s.png       ~/papers/radical-pilot/sc16/figures/micro_inp_500_4_4_unit_throughput.png 
cp -v plots/exe.500.1.1.plots/time_s_rate_units_s.png       ~/papers/radical-pilot/sc16/figures/micro_exe_500_1_1_unit_throughput.png
cp -v plots/inp.500.1.1.plots/time_s_rate_units_s.png       ~/papers/radical-pilot/sc16/figures/micro_inp_500_1_1_unit_throughput.png 
cp -v plots/out.500.1.1.plots/time_s_rate_units_s.png       ~/papers/radical-pilot/sc16/figures/micro_out_500_1_1_unit_throughput.png 
cp -v plots/sch.500.1.1.plots/time_s_rate_units_s.png       ~/papers/radical-pilot/sc16/figures/micro_sch_500_1_1_unit_throughput.png 
