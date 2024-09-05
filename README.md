
![A sample animation of the simulated behaviour.](world-4-population-50.gif)


This repo contains:
- agent-based simulation for the validation of indoors virus propagation model
- description of sample experiments

# Introduction

This model incorporates three mechanisms shaping the dynamics of the virus spreading in the population. There are three methods of getting infected - direct contact, indirect contact, and contact with ``contaminated'' elements.

# Model description

Each agent is either *infected* by some opinion, or he or she is clear (not infected). The interaction is not symmetric, since only infected agents can infect other agents. An agent can infect other agents in two situations. The first situation - **direct contact** - occurs when both occupy the same patch. The second situation - **indirect contact** - occurs when they occupy neighbouring patches.

Additionally, an infected agent can contaminate visited patches. This mechanism aims to grasp **contact with contaminated objects**, surface or material, which can be considered as an additional channel for spreading some diseases.