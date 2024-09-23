#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May  5 19:20:54 2022

@author: jam
"""

#%%

import pandas as pd
import numpy as np

import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.colors as colors
mpl.rc('text', usetex=True)
mpl.rc('font', family='serif')
mpl.rc('font', size=10)

def mav(x, w=100):
  return np.convolve(x, np.ones(w), 'valid') / w


#%% data import
# file with data from the experiment
# Note: header=6 is for NetLogo data

exp_desc = 'exp7a-sick_increase_large_s_pop100'


# choose the configuration of the interior
confs = ['world-1', 'world-2', 'world-3', 'world-4', 'world-5']

popul = 100
conf = 4


exp_desc_extr = exp_desc + f'_{confs[conf]}' +'_hist'

data = []


data = pd.read_csv('data/' + exp_desc + '.csv', header=6)
data = data[data['configuration'] == confs[conf]]
data = data[data['population'] == popul]

#%% column names

c = [
     "[run number]",
     "agent-healing-prob",
     "patch-heal-prob",
     "configuration",
     "population",
     "latency-period",
     "mobility-prob",
     "patch-contamination-prob",
     "init-infected-number",
     "direct-infection-weight",
     "indirect-infection-weight",
     "patch-infection-weight",
     "infection-probability",
     "[step]",
     "increase-sick"
  ]

# variables
# 1st is different for each plot
# 2nd and 3rd vars provide axes for plots
# 4th variable is visualized
v = ['mobility-prob', 'init-infected-number','patch-contamination-prob', 'increase-sick']
# vl = ['pc', r'$p_\lambda$', 'mobility']
vl = [ '$\mu$','initially infected agents', 'patch contamination probability',  'increase-sick']

# selection for plotting

# selected values of the 1st variable
# var0s = [0.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08]
var0s = [0.1,0.5,1]
# var0s = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 0.8, 1]

# all vaues for 2nd dna 3rd variable
# var1s = data[v[1]].unique()
# var2s = data[v[2]].unique()
var1s =  [_ for _ in [1,5,10]]
var2s = [0.5] # only one case

# patch-contamination-prob
pcps = [0.1, 0.5]

#%% 
# calculate mean for the presented variable
df = []


df = pd.DataFrame(columns=v)

for v0 in var0s:
  for v1 in var1s:
    for v2 in var2s:
      df.loc[len(df.index)] = [
        v0,
        v1,
        v2,
        data[ (data[v[0]] == v0) & (data[v[1]] == v1) & (data[v[2]] == v2) ] ['increase-sick']
      ]

#%%

fig = mpl.figure.Figure(figsize=(6,6))
# levels = np.linspace(0,11)
# levels = range(1,14,2)
colors = ["red","navy", "green"]
line_styles = ['solid','dashed','-.']

plot_data = []

for i,v0 in enumerate(var0s):
  for j,v1 in enumerate(var1s):
    # print(i,j)
    
    axs = fig.add_subplot(3,3,i+1+3*j)
    for k,pcp in enumerate(pcps):
      plot_data.append(df[df[v[0]] == v0])
        
      plot_data[k] = data[ (data['mobility-prob'] == v0) & (data['init-infected-number'] == v1) & (data['patch-contamination-prob'] == pcp) ]['increase-sick'].to_numpy()
      axs.hist(plot_data[k], bins=8, density=False, histtype = 'step', color=colors[k], linestyle=line_styles[k])
    
    axs.set_xlim(0,30)
    axs.set_ylim(0,60)
 
   
    axs.text(18,44,f"$\mu={v0}$")
    
    if i==1:
      axs.set_title(f"{v1} initialy infected")
    
    axs.grid(True,linestyle=':', linewidth=0.25, c='k')
    
    if i not in [0]:
      axs.set_yticklabels([])
    
    if j not in [2]:
      axs.set_xticklabels([])
      
      
    if i==1 and j==2:
        axs.set_xlabel("number of new infections")
    if j==1 and i==0:
        axs.set_ylabel("number of occurences")
      
    axs.set_xticks([6*_ for _ in range(6)])
    axs.set_yticks([10*_ for _ in range(7)])
 

fig.tight_layout()

plotFileName = "plots/plot_"+ exp_desc_extr +".pdf"
print("[INFO] Saving: " + plotFileName)
fig.savefig(plotFileName, format="pdf", bbox_inches = 'tight')
display(fig)
