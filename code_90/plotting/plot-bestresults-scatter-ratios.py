import numpy as np
import pickle
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style('whitegrid')

# squared deficit (TAF/d)^2 - this is the objective function being optimized
ys = {'rulecurve': [0.3126, 0.2679, 0.153268, 0.136219, 0.131672283],
      'actual': [0.153244, 0.1316638, 0.068909, 0.045393402, 0.0190872],
      'perfect': [0.11927, 0.097985, 0.0414717, 0.02446, 0.0174897]}

r1 = np.array(ys['rulecurve']) / np.array(ys['actual'])
r2 = np.array(ys['rulecurve']) / np.array(ys['perfect'])

xs = [0.0, 0.1, 0.5, 1.0, 2.0]

# colors = {'rulecurve': '0.5', 'actual': 'steelblue', 'perfect': 'indianred'}
# plt.rcParams['figure.figsize'] = (13,3)

plt.plot(xs, r1, '--.', color='steelblue', linewidth=2, markersize=20)
plt.plot(xs, r2, '--.', color='indianred', linewidth=2, markersize=20)


plt.title('Improvement over rule curve for same GW capacity')
plt.ylabel('Ratio (unitless)')
plt.xlabel('Groundwater Recharge Capacity, TAF/d')
plt.legend(['actual', 'perfect'], ncol=3)
plt.show()
# plt.savefig('bestf.svg')