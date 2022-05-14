#!/bin/bash
expName=${0/.sh/}
expName=${expName/./}
expName=${expName/\//}
echo "[INFO] Running experiment: " $expName
echo -n "[INFO] Start time: "
date +"%H:%M"
netlogo-headless.sh --model indoors-virus-propagation-v2.nlogo --setup-file experiments-v2.xml --table data/$expName.csv --experiment $expName
echo -n "[INFO] End time:"
date +"%H:%M"

