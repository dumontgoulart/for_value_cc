import numpy as np 
import matplotlib.pyplot as plt
import pandas as pd

df = pd.read_csv('folsom-daily-w2016.csv', index_col=0, parse_dates=True)
Qobs = df.inflow
df_out = Qobs.to_frame(name='obs')

# rolling forecast, not inclusive
# need to reverse the series first
def get_lead(S, w):
  return ((S[::-1]).rolling(w).mean()[::-1]).shift(-1)

for w in [3,5,10,15,30,60]:
  df_out['Q%d' % w] = get_lead(Qobs, w)

df_out.to_csv('forecasts-perfect-longlead-TAF.csv')