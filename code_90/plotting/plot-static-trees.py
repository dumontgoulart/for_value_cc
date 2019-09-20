import numpy as np
import matplotlib.pyplot as plt
import pickle
# from tree import *
# from opt import *
# import folsom
import pandas as pd

# old - March 2018
# best_seeds = {'rulecurve': {0.0: 1, 0.1: 3, 0.5: 3, 1.0: 0, 2.0: 1},
#               'actual': {0.0: 9, 0.1: 6, 0.5: 5, 1.0: 9, 2.0: 9},
#               'perfect': {0.0: 8, 0.1: 5, 0.5: 0, 1.0: 5, 2.0: 6}
# }

# New results - march 2018
best_seeds = {'rulecurve': {0.0: 5, 0.1: 7, 0.5: 3, 1.0: 8, 2.0: 8},
              'actual': {0.0: 0, 0.1: 2, 0.5: 4, 1.0: 1, 2.0: 0},
              'perfect': {0.0: 1, 0.1: 2, 0.5: 3, 1.0: 1, 2.0: 7},
              'p1': {0.0: 3, 0.1: 20, 0.5: 4, 1.0: 6, 2.0: 3},
              'longlead': {0.0: 5, 0.1: 2, 0.5: 3, 1.0: 9, 2.0: 2}
}

# for ftype in ['rulecurve', 'actual', 'perfect']:
for ftype in ['p1', 'longlead']:
  for gwcap in [0.0, 0.1, 0.5, 1.0, 2.0]:
    print('%s_%f' % (ftype, gwcap))
    
    seed = best_seeds[ftype][gwcap]

    snapshots = pickle.load(open('%s/snapshots-forecast-%s-gw%0.1fTAF-seed-%d.pkl' 
                            % (ftype,ftype,gwcap,seed), 'rb'), encoding='latin1')
    P = snapshots['best_P'][-1]

    print(str(P))
    outfile = 'figs/FX-trees/tree-%s-gw%0.1fTAF-seed-%d.svg' % (ftype,gwcap,seed)
    P.graphviz_export(outfile)
