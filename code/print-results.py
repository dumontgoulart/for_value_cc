import numpy as np
import pickle
#import pandas as pd

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
            data = pickle.load(
            open('snapshots-forecast-%s-seed-%d-%d-%d-scen%d.pkl' % 
            (forecast_type, seed, init_d, end_d,scen), 'rb'), encoding='latin1') # encoding important py3
            # print(data)
            nfe = data['nfe']
            best_f = np.array(data['best_f'])
            # # print(best_f[-1])
            # print(best_f[-1], data['best_P'][-1])
            # print('%s, %f, %s' % (s, best_f[-1], data['best_P'][-1])) # to see tree logic      

        policy = data['best_P'][-1]
        print(policy)
        policy.graphviz_export('snapshots-forecast-%s-seed-%d-%d-%d-scen%d.pkl' % (forecast_type, seed, init_d, end_d,scen))