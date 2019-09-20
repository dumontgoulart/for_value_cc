import numpy as np
import pickle
import pandas as pd

forecast_type = 'rulecurve' # other options: rulecurve, actual, etc.
pump_max = 0.0 # TAF/day
seed = 7
ini_date=2000
end_date=2020
scen=82

data = pickle.load(
  open('output/snapshots-forecast-%s-gw%0.1fTAF-seed-%d-%d-%d-%d.pkl' 
  	% (forecast_type, pump_max, seed, ini_date, end_date, scen), 'rb'), encoding='latin1') # encoding important py3

# print(data)
nfe = data['nfe']
best_f = np.array(data['best_f'])
# # print(best_f[-1])
# print(best_f[-1], data['best_P'][-1])
# print('%s, %f, %s' % (s, best_f[-1], data['best_P'][-1])) # to see tree logic      

policy = data['best_P'][-1]
print(policy)
policy.graphviz_export('plotting/forecast-%s-gw%0.1fTAF-seed-%d-%d-%d-%d.svg' % (forecast_type, pump_max, seed, ini_date, end_date, scen))