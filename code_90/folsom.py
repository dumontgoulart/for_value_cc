from __future__ import division
import numpy as np 
import pandas as pd

cfs_to_taf = 2.29568411*10**-5 * 86400 / 1000
taf_to_cfs = 1000 / 86400 * 43560

def water_day(d):
  return d - 274 if d >= 274 else d + 91

def max_release(S):
  storage = [90, 100, 400, 600, 975]
  release = cfs_to_taf*np.array([0, 35000, 40000, 115000, 130000]) # make the last one 130 for future runs
  return np.interp(S, storage, release)

def tocs(d):
  tp = [0, 50, 151, 200, 243, 366]
  sp = [975, 400, 400, 750, 975, 975]
  return np.interp(d, tp, sp)


class Folsom():

  def __init__(self, datafile, sd, ed, scen, gw_storage_cap, gw_pump_max,
               fit_historical = False, use_tocs = False, 
               forecast_type = 'perfect'):

    self.df = pd.read_csv(datafile, index_col=0, parse_dates=True)[sd:ed]
    self.K = 975 # capacity, TAF
    self.dowy = np.array([water_day(d) for d in self.df.index.dayofyear])
    self.D = np.loadtxt('data/demand.txt')[self.dowy]
    self.T = len(self.df.index)
    self.fit_historical = fit_historical
    self.use_tocs = use_tocs
    self.gw_storage_cap = gw_storage_cap
    self.gw_pump_max = gw_pump_max

    self.scen = scen
    
    self.Q = self.df.inflow.values

    if forecast_type == 'perfect' or forecast_type == 'rulecurve' or forecast_type == 'p1':
      precip_file = 'data/forecast_future_scen%d.csv' %(scen)
    else:
      precip_file = 'data/forecast_future_scen%d.csv' %(scen)

    self.precip = pd.read_csv(precip_file, index_col=0, parse_dates=True)[sd:ed]
    self.P3 = np.percentile(self.precip.iloc[:,1:31].values, 90, axis=1)

    self.forecast_type = forecast_type

  def f(self, P, mode='optimization'):

    T = self.T
    S,Sgw,R,target,tocrule = [np.zeros(T) for _ in range(5)]
    cost = 0.
    mdd = 0.
    K = 975.
    D = self.D
    Q = self.Q
    P3 = self.P3
    dowy = self.dowy
    R[0] = D[0]
    policies = [None]
    gw_pump_max = self.gw_pump_max # TAF/d in either direction
    gw_storage_cap = self.gw_storage_cap
    S[0] = 500 # self.df.storage.values[0]

    for t in range(1,T):
      #median = np.median(P3[t]) #shoudl we go for median and 90th or for wrose case?
      nine = P3[t] #lian suggested also to go for robust solution, considering the best response for most of them

      policy,rules = P.evaluate([S[t-1] + Q[t] + nine, self.dowy[t]])

      if policy == 'Release_Demand':
        target[t] = D[t]
      elif policy == 'Hedge_90':
        target[t] = 0.9*D[t]
      elif policy == 'Hedge_80':
        target[t] = 0.8*D[t]
      elif policy == 'Hedge_70':
        target[t] = 0.7*D[t]
      elif policy == 'Hedge_60':
        target[t] = 0.6*D[t]
      elif policy == 'Hedge_50':
        target[t] = 0.5*D[t]
      elif policy == 'GW_Inject':
        target[t] = D[t] + gw_pump_max
      elif policy == 'Release_Excess_CP':
        if self.forecast_type == 'p1':
          target[t] = Q[t]
        else:
          target[t] = Q[t] + nine # bring to conservation pool
      
      tocrule[t] = tocs(dowy[t])

      if self.use_tocs:
        target[t] = max((Q[t] + S[t-1] - tocrule[t]), target[t]) # bring to conservation pool

      if mode == 'simulation':
        policies.append(policy)

      # apply constraints to find actual release
      R[t] = min(target[t], S[t-1] + Q[t])
      R[t] = min(R[t], max_release(S[t-1] + Q[t]))
      R[t] = min(R[t], R[t-1] + cfs_to_taf*60000) # ramping rate up, original 90000 = 178.512TAF, cfs_to_taf(90000), cfs_to_taf(60000)=119TAF observed from researvoir outflows=118
      R[t] = max(R[t], R[t-1] - cfs_to_taf*40000) # ramping rate down, original 60000 = 119.0085TAF 

      spill = max(S[t-1] + Q[t] - R[t] - K, 0)
      R[t] += spill

      S[t] = S[t-1] + Q[t] - R[t]

      # update groundwater storage
      gw_t = 0 # default

      if R[t] > D[t]: #and policy == 'GW_Inject': # inject excess
        gw_t = min(R[t]-D[t], gw_pump_max, gw_storage_cap-Sgw[t-1])
      elif R[t] < D[t]: # make up deficit from GW (always)
        gw_t = -1*min(gw_pump_max, D[t]-R[t], Sgw[t-1])

      Sgw[t] = Sgw[t-1] + gw_t

      # want to penalize deficit. excess release doesn't matter if demand is met.
      deficit = max(D[t] - R[t] + gw_t, 0)
      cost += deficit**2 / T
      mdd += deficit / T # mean daily deficit
      
      if R[t] > cfs_to_taf*130000:
        cost += 10**9 * (R[t] - cfs_to_taf*130000) # flood penalty, high enough to be a constraint


    if mode == 'simulation':
      df = self.df.copy()
      df['Ss'] = pd.Series(S, index=df.index)
      df['Sgw'] = pd.Series(Sgw, index=df.index)
      df['Rs'] = pd.Series(R, index=df.index)
      df['demand'] = pd.Series(D, index=df.index)
      df['target'] = pd.Series(target, index=df.index)
      df['policy'] = pd.Series(policies, index=df.index, dtype='category')
      df['tocrule'] = pd.Series(tocrule, index=df.index)
      return df
    else:
      if self.fit_historical:
        return np.sqrt(np.mean((S - self.df.storage.values)**2))
      else:
        return cost  # average daily squared value. (or replace w/mdd)
