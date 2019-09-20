import numpy as np
import pickle
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style('whitegrid')

# squared deficit (TAF/d)^2 - this is the objective function being optimized
ys = {'rulecurve': [0.433152982, 0.396613205, 0.27852784, 0.197571178, 0.235903355],
      'actual': [0.355857083, 0.338111266, 0.259224168, 0.212983521, 0.155342658],
      'perfect': [0.317636764, 0.295797764, 0.243909448, 0.184201263, 0.16452359],
      #'persistence': [0.34306585,0.290206341,0.200346656,0.17538364,0.153774261],
      'longlead': [0.285131052,0.285004294,0.20870448,0.157709026,0.08313068],
      'p1': [0.577186652,0.537758291,0.290941944,0.224612076,0.117210435]
}

xs = [0.0, 0.1, 0.5, 1.0, 2.0]

colors = {'rulecurve': '0.5', 
          'actual': 'steelblue', 
          'perfect': 'indianred',
          'persistence': 'green',
          'p1': 'green',
          'longlead': 'yellow'}
# plt.rcParams['figure.figsize'] = (13,3)
ftypes = ys.keys()

for ftype in ftypes:
  if ftype=='persistence':
    continue
  plt.plot(xs, ys[ftype], '--.', color=colors[ftype], 
           linewidth=2, markersize=20)

plt.ylabel('Best objective function value, J (TAF/d)$^2$')
# plt.ylabel('Mean Daily Deficit (TAF/d)')
plt.xlabel('Groundwater Recharge Capacity, TAF/d')
plt.legend(ftypes, ncol=3)
plt.show()
# plt.savefig('bestf.svg')