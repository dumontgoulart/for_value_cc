import numpy as np
import pickle
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style('whitegrid')

sbpc = 1

colors = {'rulecurve': '0.5', 'actual': 'steelblue', 'perfect': 'indianred'}
plt.rcParams['figure.figsize'] = (13,3)


for gwcap in [0.0, 0.1, 0.5, 1.0, 2.0]:
  for ftype in ['rulecurve', 'actual', 'perfect']:

    nfes = []
    bestfs = []

    for s in range(10):
      data = pickle.load(
        open('%s/snapshots-forecast-%s-gw%0.1fTAF-seed-%d.pkl' 
              % (ftype,ftype,gwcap,s), 'rb'), encoding='latin1') # encoding important py3
      if data:
        nfe = data['nfe']
        nfes.append(nfe)
        best_f = np.array(data['best_f'])
        bestfs.append(best_f)
        print('%s, %f, %s' % (s, best_f[-1], data['best_P'][-1])) # to see tree logic

      # results = model.f(data['best_P'][-1])
      # print results

    plt.subplot(1,5,sbpc)
    plt.semilogx(nfes[0], np.array(bestfs).T, color=colors[ftype], linewidth=1)
    plt.ylim([0,0.5])
    plt.xlim([500,10**5])

    plt.xlabel('NFE')

    if sbpc == 1:
      plt.ylabel('J (TAF/d)$^2$')
      plt.legend(['Rule Curve', 'Actual Forecast', 'Perfect Forecast'])
    # else:
    #   plt.set_yticklabels([])
  sbpc += 1

plt.tight_layout()
plt.savefig('convergence.svg')
plt.show()