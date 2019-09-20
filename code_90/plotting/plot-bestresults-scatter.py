import numpy as np
import pickle
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style('whitegrid')

# squared deficit (TAF/d)^2 - this is the objective function being optimized
ys = {'rulecurve': [0.3126, 0.2679, 0.153268, 0.136219, 0.131672283],
      'actual': [0.153244, 0.1316638, 0.068909, 0.045393402, 0.0190872],
      'perfect': [0.11927, 0.097985, 0.0414717, 0.02446, 0.0174897],
#persistence': [0.150568971,0.120994024,0.053979463,0.028257996,0.018227036],
      'longlead': [0.117524388,0.094365856,0.035264384,0.020977189,0.007612582],
      # 'p1': [0.448482562,0.357939206,0.157957095,0.102409181,0.064908551]
      'p1': [0.332181037,0.25472958,0.147153177,0.102409181,0.064908551]
}

# use best ensemble results instead
# ys['actual'] = [0.149920143, 0.128233648, 0.066591662, 0.043376866, 0.018090449]

# mean daily deficit (TAF/d) - which is not being optimized
# ys = {'rulecurve': [0.2669026268262545, 0.22799916892273786, 
#                    0.13078131410719246, 0.10884702599846334, 
#                    0.08158280954094368],
#       'actual': [0.15869274905182146, 0.16135989381557841, 
#                  0.052809983809804215, 0.04384345759015923, 
#                  0.013977924877389988],
#       'perfect': [0.15429107071294448, 0.1363983083068852, 
#                   0.06034064712214835, 0.028457500781120776, 
#                   0.013030639560553017]}



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
           linewidth=2, markersize=15)

plt.ylabel('Best objective function value, J (TAF/d)$^2$')
# plt.ylabel('Mean Daily Deficit (TAF/d)')
plt.xlabel('Groundwater Recharge Capacity, TAF/d')
plt.legend(ftypes, ncol=3)
plt.savefig('B-bestf-raw.svg')
plt.show()