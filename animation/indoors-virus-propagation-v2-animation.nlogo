;;
;;
;;
turtles-own [
  sick?
  sick-time
  healty-time
  total-sick-time
  total-healty-time
]

;;
;;
;;
patches-own [
  contaminated?
  work-station?
]

;;
;;
;;
globals [
  %infected
  %contaminated
  init-contamination-ratio
  machine-allocation-prob
  obstacle-color
  machine-color
  contaminated-patch-color
  time-interval
]

;;
;; process initialization
;;
to setup
  clear-all

  ;;
  ;; some variables without the controls in the UI
  ;;
  set time-interval 900 ;; 1/4 hour
  set init-contamination-ratio 0
  set machine-allocation-prob 0.1

  ;;
  ;; visualization parameters
  ;;
  set obstacle-color black
  set machine-color blue
  set contaminated-patch-color pink

  ;;
  ;; setup procedure
  ;;
  setup-patches
  setup-turtles

  ;; reset the ticks
  reset-ticks
end

;;
;; single step
;;
to go
  ask turtles [
    move-turtles
    get-infected
    infect-patches

    if sick? [
      set sick-time sick-time + 1
      set total-sick-time total-sick-time + 1
    ]

    if not sick? [
      set total-healty-time total-healty-time + 1
    ]

    if random-float 1.0 < agent-healing-prob [
      get-healthy
      set sick-time 0
    ]
  ]

  ask patches [
    heal-patches
  ]

  update-global-variables

  tick
  export-view (word ticks ".png")
end

;;
;; generate obstacles and containated patches
;; configurations are defined as functions
;;
to setup-patches

  ;; generate obstacles for simulating interiors
  (ifelse configuration = "world-1" [
    setup-wordl-1
  ] configuration = "world-2" [
    setup-wordl-2
  ] configuration = "world-3" [
    setup-wordl-3
  ] configuration = "world-4" [
    setup-wordl-4
  ])

  ;;
  ;; distribute contaminating material on the patches withoout obstacles
  ;; machines can also be contaminated
  ;;
  ask patches [
    if pcolor = white and random-float 100 < init-contamination-ratio
    ;; this is a contaminated patch
    [
      set pcolor contaminated-patch-color
      set contaminated? true
    ]
  ]
end

;;
;; configuration 1 - two rooms
;;
to setup-wordl-1
  resize-world 0 20 0 40
  ask patches [
    set pcolor white
    set contaminated? false
  ]

  ask patches [
    if pxcor = 0 or pycor = 0 or pxcor = max-pxcor or pycor = max-pycor [
      set pcolor obstacle-color
    ]

    ;; middle wall
    if pycor = max-pycor / 2 [
      set pcolor obstacle-color
    ]

    if pycor = max-pycor / 2 and ( pxcor = max-pxcor / 2 or pxcor = max-pxcor / 2  + 1 or pxcor = max-pxcor / 2 - 1 ) [
      set pcolor red
    ]

    ;; make corridor
    if pcolor != obstacle-color and ( pxcor = max-pxcor / 2 or pxcor = max-pxcor / 2  + 1 or pxcor = max-pxcor / 2 - 1 )[
      set pcolor gray + 4
    ]

    if pcolor != obstacle-color and pcolor != gray + 4 and pycor != max-pycor / 2 [
      if random-float 1 < machine-allocation-prob [
        set pcolor machine-color
      ]
    ]

    ;; clear corridor
    if pcolor = gray + 4 [
      set pcolor white
    ]

  ]
end

;;
;; configuration 2 - three rooms
;;
to setup-wordl-2
  resize-world 0 20 0 40
  ask patches [
    set pcolor white
    set contaminated? false
  ]

  ask patches [
    if pxcor = 0 or pycor = 0 or pxcor = max-pxcor or pycor = max-pycor [
      set pcolor obstacle-color
    ]

    if pycor = max-pycor / 4 or pycor = 3 * max-pycor / 4 [
      set pcolor obstacle-color
    ]

    if pycor = max-pycor / 4 or pycor = 3 * max-pycor / 4 and ( pxcor = max-pxcor / 2 or pxcor = max-pxcor / 2  + 1 or pxcor = max-pxcor / 2 - 1 )[
      set pcolor white
    ]

    if pcolor != obstacle-color and ( pxcor = max-pxcor / 2 or pxcor = max-pxcor / 2  + 1 or pxcor = max-pxcor / 2 - 1 )[
      set pcolor gray + 4
    ]

    if pcolor != obstacle-color and pcolor != gray + 4 and pycor != max-pycor / 2 [
      if random-float 1 < machine-allocation-prob [
        set pcolor machine-color
      ]
    ]

    ;; clear corridor
    if pcolor = gray + 4 [
      set pcolor white
    ]

  ]
end

;;
;; configuration 3 - four rooms
;;
to setup-wordl-3
  resize-world 0 20 0 40
  ask patches [
    set pcolor white
    set contaminated? false
  ]

  ask patches [
    if pxcor = 0 or pycor = 0 or pxcor = max-pxcor or pycor = max-pycor [
      set pcolor obstacle-color
    ]

    if pycor = max-pycor / 4 or pycor = 3 * max-pycor / 4 or pycor = max-pycor / 2 [
      set pcolor obstacle-color
    ]

    if (pycor = max-pycor / 4 or pycor = 3 * max-pycor / 4 or pycor = max-pycor / 2) and ( pxcor = max-pxcor / 2 or pxcor = max-pxcor / 2  + 1 or pxcor = max-pxcor / 2 - 1 )[
      set pcolor white
    ]

    if pcolor != obstacle-color and ( pxcor = max-pxcor / 2 or pxcor = max-pxcor / 2  + 1 or pxcor = max-pxcor / 2 - 1 )[
      set pcolor gray + 4
    ]

    if pcolor != obstacle-color and pcolor != gray + 4 and pycor != max-pycor / 2 [
      if random-float 1 < machine-allocation-prob [
        set pcolor machine-color
      ]
    ]

    ;; clear corridor
    if pcolor = gray + 4 [
      set pcolor white
    ]
  ]
end

;;
;; configuration 4 - three rooms, horizontal
;;
to setup-wordl-4
  resize-world 0 32 0 24
  ask patches [
    set pcolor white
    set contaminated? false
  ]

  ask patches [
    if pxcor = 0 or pycor = 0 or pxcor = max-pxcor or pycor = max-pycor [
      set pcolor obstacle-color
    ]

    if pycor = max-pycor / 4 or pycor = 3 * max-pycor / 4 [
      set pcolor obstacle-color
    ]

    if pycor = max-pycor / 4 or pycor = 3 * max-pycor / 4 and ( pxcor = max-pxcor / 2 or pxcor = max-pxcor / 2  + 1 or pxcor = max-pxcor / 2 - 1 )[
      set pcolor white
    ]

    if pcolor != obstacle-color and ( pxcor = max-pxcor / 2 or pxcor = max-pxcor / 2  + 1 or pxcor = max-pxcor / 2 - 1 )[
      set pcolor gray + 4
    ]

    if pcolor != obstacle-color and pcolor != gray + 4 and pycor != max-pycor / 2 [
      if random-float 1 < machine-allocation-prob [
        set pcolor machine-color
      ]
    ]

    ;; clear corridor
    if pcolor = gray + 4 [
      set pcolor white
    ]

  ]
end

;;
;; setup agents
;;

;;
;; create agents and make some of them sick
;;
to setup-turtles
  let move-to-patches patches with [
    pcolor != obstacle-color and
    pcolor != machine-color
  ]

  create-turtles population [
    set shape "person"
    set sick? false
    set sick-time 0
    set total-healty-time 0.0001
    if any? move-to-patches [ move-to one-of move-to-patches ]
    get-healthy
  ]

  ask n-of init-infected-number turtles [
    set sick? true
    get-sick
    set sick-time 0
    set total-sick-time 0
  ]
end

;;
;; update reporting variables
;;
to update-global-variables
  if count turtles > 0 [
    set %infected (count turtles with [ sick? ] / count turtles) * 100
  ]

  set %contaminated ( count patches with [ contaminated? ] / count patches with [ not contaminated? ] ) * 100
end

;;
;; model dynamics
;;

;; avoid obstacles during the move
to move-turtles
  let current-mobility mobility-prob
  if count neighbors4 with [ pcolor = machine-color ] = 0
  [
    set current-mobility 100 * mobility-prob
  ]

  if random-float 1 < current-mobility / time-interval [
    let move-to-patches neighbors with [ pcolor != obstacle-color and pcolor != machine-color ]
    ;;if random-float 1.0 <  (count move-to-patches) / (count neighbors) [
      if any? move-to-patches [ move-to one-of move-to-patches ]
    ;;]
  ]
end

;; three methods for getting infected
to get-infected
  get-infected-by-contamination
  get-infected-by-contact
  get-infected-by-proximity
end

;; get infected by contact with contaminated patch
to get-infected-by-contamination
  if contaminated? and random-float 1 < patch-infection-weight * infection-probability
  [
    get-sick
  ]
end

;; get infected by a direct contact with another agent
to get-infected-by-contact
  if (count other turtles-here with [ sick? ])  > 0
  [
    if random-float 1 < direct-infection-weight * infection-probability
    [
      get-sick
    ]
  ]
end

;; get infected be getting around a sick agent
to get-infected-by-proximity
  if (count other (turtles-on neighbors4) with [ sick? ]) > 0
  [
    if random-float 1 < indirect-infection-weight * infection-probability
    [
      get-sick
    ]
  ]
end

;; leave some contaminating material on the patch
to infect-patches
  ;;set label sick?
  if sick? and ( random-float 1 < patch-contamination-prob )
  [
    set pcolor pink
    set contaminated? true
  ]
end

;; healing process for patches
to heal-patches
  if contaminated? and ( random-float 1 < patch-heal-prob )
  [
    set pcolor white
    set contaminated? false
  ]
end

;; getting sick
to get-sick
  set sick? true
  set color red
  set sick-time 1
end

;; recovering from the infection
to get-healthy
  set sick? false
  set color green
  set sick-time 0
end
;;

;;to-report indirect-infection-weight
;;  report 1 - (direct-infection-weight + patch-infection-weight)
;;end

;; only sick agents are immune
to-report immune?
  report sick-time > 0
end

;;
;; reporters for plotting and for the experiments
;;

;; number of sick agents
to-report how-many-sick
  report count turtles with [ sick? ]
end

;; ratio of sick agents
to-report ratio-sick
  report count turtles with [ sick? ] / count turtles
end

;; number of contagenous patches
to-report how-many-cont
  report count patches with [ pcolor = pink ]
end

;; ratio of contagenous patches
to-report ratio-cont
  report count patches with [ pcolor = pink ] / count patches
end

;; increase in the number of sick agents
to-report increase-sick
  report how-many-sick - init-infected-number
end
@#$#@#$#@
GRAPHICS-WINDOW
290
10
793
394
-1
-1
15.0
1
10
1
1
1
0
0
0
1
0
32
0
24
0
0
1
ticks
10.0

BUTTON
13
16
183
49
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
15
165
185
198
population
population
0
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
15
60
105
93
Go
go
NIL
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
110
60
185
93
Run
reset-timer \nrepeat 8 * 60 [go]\nprint timer
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

SLIDER
15
215
185
248
init-infected-number
init-infected-number
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
20
510
275
543
mobility-prob
mobility-prob
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
20
560
275
593
patch-contamination-prob
patch-contamination-prob
0
1
1.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
30
265
275
296
Weights of the spread channels
14
0.0
0

TEXTBOX
25
485
270
516
Parameters of agents and patches
14
0.0
1

SLIDER
20
390
270
423
direct-infection-weight
direct-infection-weight
0
0.1
0.1
0.0001
1
NIL
HORIZONTAL

SLIDER
20
340
267
373
patch-infection-weight
patch-infection-weight
0
0.1
1.0E-4
0.0001
1
NIL
HORIZONTAL

SLIDER
20
615
275
648
agent-healing-prob
agent-healing-prob
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
20
660
275
693
patch-heal-prob
patch-heal-prob
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
20
290
270
323
infection-probability
infection-probability
0
1
1.0
0.01
1
NIL
HORIZONTAL

CHOOSER
15
105
153
150
configuration
configuration
"world-1" "world-2" "world-3" "world-4"
3

PLOT
820
10
1215
300
virus spread
time
number of infected
0.0
500.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot how-many-sick"

MONITOR
820
330
937
375
Increase of sick
increase-sick
2
1
11

SLIDER
20
440
265
473
indirect-infection-weight
indirect-infection-weight
0
0.1
0.0027
0.0001
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model incorporates three mechanisms shaping the dynamics of opinion formation, which mimics the dynamics of the virus spreading in the population. There are three methods of getting infected (or convinced) - direct contact, indirect contact, and contact with ``contaminated'' elements.

## HOW IT WORKS

The model describes a process of opinion formation. Each agent is either *infected* by some opinion, or he or she is clear (not infected). The interaction is not symmetric, since only infected agents can infect other agents. An agent can infect other agents in two situations. The first situation - **direct contact** - occurs when both occupy the same patch. The second situation - **indirect contact** - occurs when they occupy neighbouring patches.

Additionally, an infected agent can contaminate visited patches. This mechanism of opinion formation is introduced in analogy of **contact with contaminated objects**, surface or material, which can be considered as an additional channel for spreading some diseases.

## HOW TO USE IT

The user interface is divided into three sections. 

In the setup section one can fix the population (slider *population*), percentage of patches which are considered as unavailable for agents (slider *init-obstacles-ratio*), as well as initial percentage of contaminated patches (slider *init-contamination-ratio*) and the initial number of infected agents (slider *init-infected-ratio*).

The second section - *Weights of the spread channels* - includes parameter of the opinion (or virus) spread. Slider *infection-probability* can be used to control the overall probability of getting infected. Additionally, sliders *direct-infection-weight* and *patch-infection-weight* can be used to change the probabilities of getting infected during the direct contact and via contact with a contaminated patch. Monitor *indirect-infection-weight* displays the current value of probability assigned to the second channel - indirect contact - and it is calculated as the complement of the other two channels.

The third section - *Parameters of agents and patches* - included parameters controling healing and mobility. In particular,

  * slider *mobility-prob* controls the probability of agents ot make a move;
  * slider *patch-contamination-prob* defines the probability of a patch to be contaminated by a visiting, sick agent;
  * slider *agent-healing-prob* controls the probability of a sick agent to get healty at each tick;
  * slilder *patch-heal-prob* controls the probability od a contaminated patch to get clean;

## THINGS TO NOTICE

The most interesting observation of the interplay between the weights assigned to particular channels. Weights assigned to all channels should sum up to one. However, in many situations, to low probability of getting infected via contact with contaminated patches (*patch-infection-weight*). In other words, setting too large value of *direct-infection-weight* is more likely to result in getting all agents healthy. On the other hand, by increasing the weight of the *patch-infection-weight* (or *indirect-infection-weight*), it is relatively easy to obtain a stable number of infected agents, independently of the other parameters, including mobility.

## THINGS TO TRY

One of the features of the model is the ability to control the mobility. This cab be dome by significantly limit the mobility with the hight perncetage of obstacles. On the other hand. one can control the probility of moving (slider *mobility*), and it can be changed during the run.

## EXTENDING THE MODEL

One of the possible extension of the model can be made by introducing two or more  competing opinions. In this case, one has to introduce variables for marking the agents with their opinions. Additionally, one can consider different susceptibility (or immunity) of agents for adoption of other opinions.

## NETLOGO FEATURES

The model does not include. Each agent can in one of two states - sick, represented by colour *red* and healthy, represented by colour *white*. Similarly, each patch can be contaminated (pink) or clean (white). Black patches represent obstacles and are fixed during the setup phase.

## RELATED MODELS

There are several models in the NetLogo Models Library related to virus spread. In particular, Virus on a Network incorporates additional topology of connections, which could provide additional method of extending the presented model.

## CREDITS AND REFERENCES

The model has been developed by Jaroslaw Miszczak and Krzysztof Domino, Institute of Theoretical and Applied Informatics, Polish Academy of Sciences.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
