import numpy as np
import pandas as pd
import pickle
from ptreeopt import PTreeOpt
from folsom import Folsom
import os

# set parameters
forecast_type = 'rulecurve' # other options: rulecurve, actual, etc.
pump_max = 0.0 # TAF/day
seed = 7
ini_date=2000
end_date=2020
scen=82
# define path to output file
outfile = 'output/snapshots-forecast-%s-gw%0.1fTAF-seed-%d-%d-%d-%d.pkl' % (forecast_type, pump_max, seed, ini_date, end_date, scen)

np.random.seed(seed)
actions = ['Release_Demand', 'Hedge_90', 'Hedge_80', 'Hedge_70', 'Hedge_60', 'Hedge_50']

# set groundwater storage capacity
if pump_max == 0.0:
  storage_cap = 0.
else:
  storage_cap = 500. # TAF
  actions.append('GW_Inject')

# setup depends on forecast type
if forecast_type == 'rulecurve':
  use_tocs = True
  feature_bounds = [[0,975], [0, 366]]
  feature_names = ['St-1', 'dowy']
else:
  use_tocs = False
  feature_bounds = [[0,975], [0, 366]]
  feature_names = ['St-1+Qt+P3', 'dowy']
  actions.append('Release_Excess_CP')

# create model
model = Folsom('data/folsom-daily-future-82.csv', 
                sd='2000-01-01', ed='2000-12-29',
                scen = scen,
                gw_storage_cap = storage_cap, 
                gw_pump_max = pump_max,  
                use_tocs = use_tocs,
                forecast_type = forecast_type)

# create optimization algorithm (w/ a bunch of input options)
algorithm = PTreeOpt(model.f, 
                    feature_bounds = feature_bounds,
                    feature_names = feature_names,
                    discrete_actions = True,
                    action_names = actions,
                    mu = 10,
                    cx_prob = 0.70,
                    population_size = 96,
                    max_depth = 7)
        
# run optimization algorithm, save results
# while it's running, it will print to the console every log_frequency iterations
snapshots = algorithm.run(max_nfe = 10000, log_frequency = 100, parallel=False)
pickle.dump(snapshots, open(outfile, 'wb'))

# note the "pickle" file format is used because the policies are data structures
# they can't be saved easily in a CSV format for example
# see the output folder for some example scripts of how to open and plot the output data

