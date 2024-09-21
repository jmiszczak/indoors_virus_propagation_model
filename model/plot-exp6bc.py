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

#exp1_desc = 'exp6c-sick_increase_small_s_varpop'
exp1_desc = 'exp6b-sick_increase_large_s_varpop'


# choose the configuration of the interior
confs = ['world-1', 'world-2', 'world-3', 'world-4', 'world-5']



#popul = 100
conf = 4

exp1_desc_extr = f'_{confs[conf]}'

data1 = pd.read_csv('data/' + exp1_desc + '.csv', header=6) 
data1 = data1[data1['configuration'] == confs[conf]]

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
# 1st is different for each column of plots
# 2st is different for each rows of plots
# 3nd and 4rd vars provide axes for plots
# 5th variable is visualized
v = ['mobility-prob', 'population', 'patch-contamination-prob', 'init-infected-number', 'increase-sick']
# vl = ['pc', r'$p_\lambda$', 'mobility']
vl = ['$\mu$', '$n$', 'patch contamination probability', 'initially infected agents', 'increase-sick']

# selection for plotting

# selected values of the 1st variable
# var0s = [0.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08]
#var0s = [_/10 for _ in range(2,11)]
#var0s = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 0.8, 1]
var0s = [0.1, 0.2, 0.5] # mobility
var1s = [30, 50, 70] # populations

# all vaues for 2nd dna 3rd variable
var2s = data1[v[2]].unique()
var3s = data1[v[3]].unique()


#%% 
# calculate mean for the presented variable
df = pd.DataFrame(columns=v)

for v0 in var0s:
    for v1 in var1s:
        for v2 in var2s:
            for v3 in var3s:
                df.loc[len(df.index)] = [
                    v0,
                    v1,
                    v2,
                    v3,
                    data1[ (data1[v[0]] == v0) & (data1[v[1]] == v1) & (data1[v[2]] == v2) & (data1[v[3]] == v3) ] ['increase-sick'].mean()
                    ]

#%%

fig = mpl.figure.Figure(figsize=(6,5.5))
# levels = np.linspace(0,11)
levels = range(1,5,1)

for i,v0 in enumerate(var0s):
    for j,v1 in enumerate(var1s):
        axs = fig.add_subplot(3,3,1+i+3*j)
        plot_data = df[(df[v[0]] == v0) & (df[v[1]] == v1)][[v[2], v[3], v[4]]].to_numpy()
    
        axs.contour(
            plot_data.T[0].reshape(len(var2s), len(var3s)), 
            plot_data.T[1].reshape(len(var2s), len(var3s)), 
            plot_data.T[2].reshape(len(var2s), len(var3s)),
            levels = levels,
            antialiased = True,
            linewidths = 0.5,
            colors = 'k',linestyles='dotted'
        )
        
        im=axs.contourf(
            plot_data.T[0].reshape(len(var2s), len(var3s)), 
            plot_data.T[1].reshape(len(var2s), len(var3s)), 
            plot_data.T[2].reshape(len(var2s), len(var3s)),
            levels = levels,
            cmap = 'inferno_r',
            norm=colors.Normalize(vmin=min(levels), vmax=max(levels)),        
        )
        
        axs.set_title(chr(97+i) +') '+vl[0]+'='+str(v0)+", "+ vl[1]+'='+str(v1))
        axs.set_xticks(var2s[::1])
        axs.set_yticks(var3s[::1])
        # axs.set_xlim(0,1)
        
        axs.grid(True,linestyle=':', linewidth=0.5, c='k')
        
        if i+3*j not in [6,7,8]:
            axs.set_xticklabels([])
         
        if i+3*j not in [0,3,6]:
            axs.set_yticklabels([])
            
        if i+3*j==7:
            axs.set_xlabel(vl[2])
        if i+3*j==3:
            axs.set_ylabel(vl[3])
        


cbar_ax = fig.add_axes([0.125, 1.02, 0.8, 0.02])
cbar = fig.colorbar(im, cax=cbar_ax, orientation="horizontal",label='number of new infections')
cbar.ax.xaxis.set_ticks_position('bottom')
cbar.ax.xaxis.set_label_position('top')
cbar.set_ticklabels([str(l) for l in levels])

fig.tight_layout()

plotFileName = "plots/plot_"+ exp1_desc + exp1_desc_extr +".pdf"
print("[INFO] Saving: " + plotFileName)

fig.savefig(plotFileName, format="pdf", bbox_inches = 'tight')
display(fig)
