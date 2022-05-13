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

exp_desc = 'exp1'

# choose the configuration of the interior
confs = ['world-1', 'world-2', 'world-3']

data = pd.read_csv('data/' + exp_desc + '.csv', header=6) 
data = data[data['configuration'] == confs[1]]

#%% column names

c = [
     '[run number]',
     'mobility-prob',
     'agent-healing-prob',
     'configuration',
     'direct-infection-weight',
     'patch-contamination-prob',
     'patch-heal-prob',
     'init-infected-number',
     'population',
     'patch-infection-weight',
     'infection-probability',
     '[step]',
     'increase-sick'
     ]

# variables
# 1st is different for each plot
# 2nd and 3rd vars provide axes for plots
# 4th variable is visualized
v = ['mobility-prob','patch-contamination-prob', 'patch-heal-prob', 'increase-sick']
# vl = ['pc', r'$p_\lambda$', 'mobility']
vl = ['$\mu$', 'patch contamination probability', 'patch healing probability', 'increase-sick']

# selection for plotting

# selected values of the 1st variable
# var0s = [0.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08]
var0s = [_/10 for _ in range(2,11)]
var0s = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 0.8, 1]

# all vaues for 2nd dna 3rd variable
var1s = data[v[1]].unique()
var2s = data[v[2]].unique()


#%% 
# calculate mean for the presented variable
df = pd.DataFrame(columns=v)

for v0 in var0s:
    for v1 in var1s:
        for v2 in var2s:
            df.loc[len(df.index)] = [
                v0,
                v1,
                v2,
                data[ (data[v[0]] == v0) & (data[v[1]] == v1) & (data[v[2]] == v2) ] ['increase-sick'].std()
            ]

#%%

fig = mpl.figure.Figure(figsize=(6,5.5))
levels = np.linspace(0,10,5)

for i,v0 in enumerate(var0s):
    axs = fig.add_subplot(331+i);
    plot_data = df[df[v[0]] == v0][[v[1], v[2], v[3]]].to_numpy()

    axs.contour(
        plot_data.T[0].reshape(len(var1s), len(var2s)), 
        plot_data.T[1].reshape(len(var1s), len(var2s)), 
        plot_data.T[2].reshape(len(var1s), len(var2s)),
        levels = levels,
        colors = 'k',linestyles='dotted'
    )
    
    im=axs.contourf(
        plot_data.T[0].reshape(len(var1s), len(var2s)), 
        plot_data.T[1].reshape(len(var1s), len(var2s)), 
        plot_data.T[2].reshape(len(var1s), len(var2s)),
        levels = levels,
        cmap = 'Reds',
        norm=colors.Normalize(vmin=0, vmax=max(levels)),        
    )
    
    axs.set_title(chr(97+i) +') '+vl[0]+'='+str(v0))
    axs.set_xticks(var1s[::4])
    
    axs.grid(True,linestyle=':', linewidth=0.5, c='k')
    
    if i not in [6,7,8]:
        axs.set_xticklabels([])
     
    if i not in [0,3,6]:
        axs.set_yticklabels([])
        
    if i==7:
        axs.set_xlabel(vl[1])
    if i==3:
        axs.set_ylabel(vl[2])
        

cbar_ax = fig.add_axes([0.125, 1.02, 0.8, 0.02])
cbar = fig.colorbar(im, cax=cbar_ax, orientation="horizontal")
cbar.set_ticklabels([str(l)+"\%" for l in levels])

fig.tight_layout()

fig.savefig("plots/plot_"+ exp_desc +".pdf", format="pdf", bbox_inches = 'tight')
display(fig)
