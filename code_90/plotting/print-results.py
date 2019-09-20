import numpy as np
import pickle
import pandas as pd

for ftype in ['perfect']:
# for ftype in ['persistence', 'longlead']:
# for ftype in ['p1']:
  for gwcap in [0.0, 0.1, 0.5, 1.0, 2.0]:
    print('\nForecast:', ftype, ', GW:', gwcap, 'TAF/d')
    
    for s in range(25): # 20-25 are from 200k NFE reruns
      try:
        data = pickle.load(
          open('%s/snapshots-forecast-%s-gw%0.1fTAF-seed-%d.pkl' 
                % (ftype,ftype,gwcap,s), 'rb'), encoding='latin1') # encoding important py3
        if data:
          nfe = data['nfe']
          best_f = np.array(data['best_f'])
          # print(best_f[-1])
          print(best_f[-1], data['best_P'][-1])
          # print('%s, %f, %s' % (s, best_f[-1], data['best_P'][-1])) # to see tree logic

        # results = model.f(data['best_P'][-1])
        # print results

      except:
        pass
      
