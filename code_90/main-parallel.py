import numpy as np
# import matplotlib.pyplot as plt
import pandas as pd
import pickle
from ptreeopt import PTreeOpt
from folsom import Folsom
import os

pump_max=0.0;
storage_cap = 0.
#TRY TO DEVELOP A FOR FOR THE DIFFERENT SCENARIOS: the idea is to put the three scenarios in a for,
# then to call it dynamically in the input file for both inflow and forecast

for forecast_type in ['rulecurve', 'actual']:
  for scen in [17,52,82]:
    for dates in ['hist','future']:
      if dates == 'hist':
        init_d = 2000
        end_d = 2019
      elif dates == 'future':
        init_d = 2080
        end_d = 2099

      for seed in range(10):

        outfile = 'output/snapshots-forecast-%s-seed-%d-%d-%d-scen%d.pkl' % (forecast_type, seed, init_d, end_d,scen)
        if os.path.isfile(outfile):
          continue

        np.random.seed(seed)
        actions = ['Release_Demand', 'Hedge_90', 'Hedge_80', 'Hedge_70', 'Hedge_60', 'Hedge_50']

        if forecast_type == 'rulecurve':
          use_tocs = True
          feature_bounds = [[0,975], [0, 366]]
          feature_names = ['St-1', 'dowy']
        else:
          use_tocs = False
          feature_bounds = [[0,975], [0, 366]]
          feature_names = ['St-1+Qt+P3', 'dowy']
          actions.append('Release_Excess_CP')

        model = Folsom('data/folsom-daily-future-%d.csv' %(scen), 
                        sd='%d-01-01' %(init_d), ed='%d-12-29' %(end_d),
                        scen = scen,
                        gw_storage_cap = storage_cap, 
                        gw_pump_max = pump_max,  
                        use_tocs = use_tocs,
                        forecast_type = forecast_type) #i think this is necessary, maybe someone forgot it

        algorithm = PTreeOpt(model.f, 
                            feature_bounds = feature_bounds,
                            feature_names = feature_names,
                            discrete_actions = True,
                            action_names = actions,
                            mu = 10,
                            cx_prob = 0.70,
                            population_size = 96, # hpc hack 7/18/17
                            max_depth = 5)
                
                
        snapshots = algorithm.run(max_nfe = 100000, log_frequency = 1000, parallel=True)

        if snapshots:
          pickle.dump(snapshots, open(outfile, 'wb'))
