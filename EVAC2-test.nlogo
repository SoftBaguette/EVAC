globals [initial-average-fitness evolved-average-fitness]

breed [sheep a-sheep]
breed [dogs dog]

turtles-own [last-action next-move]
dogs-own [weights]

to setup
  clear-all
  set-default-shape sheep "sheep"
  set-default-shape dogs "wolf"

  ; Create 50 sheep
  create-sheep 50 [
    set color white
    set size 1
    setxy random-xcor random-ycor
    set last-action "stay"
    set next-move "TBD"
  ]

  ; Create 5 dogs with evolved weights
  create-dogs 5 [
    set color yellow
    set size 1
    setxy random-xcor random-ycor
    set weights [0.3 0.1 0.3 0.1 0.2] ; Example evolved weights, replace with actual evolved weights
    set next-move "TBD"
  ]

  reset-ticks
end

to go
  if not any? turtles [ stop ]

  ; Move sheep and dogs
  ask sheep [
    move-sheep
  ]

  ask dogs [
    move-dog
  ]

  tick
end

; Procedure to move sheep based on defined behaviors
to move-sheep
  ifelse any? dogs-here [
    move-to-empty-patch ; Move to empty patch if there's a dog on current patch
  ] [
    ifelse any? neighbors with [any? dogs-here] [
      move-to one-of neighbors with [not any? dogs-here] ; Move to a neighboring patch without dogs
    ] [
      ifelse any? neighbors with [not any? sheep-here and any? neighbors with [any? sheep-here]] [
        move-to one-of neighbors with [not any? sheep-here and any? neighbors with [any? sheep-here]] ; Move to a patch with no sheep but adjacent to a patch with sheep
      ] [
        ifelse any? neighbors with [count sheep-here < count sheep] [
          move-to one-of neighbors with [count sheep-here < count sheep] ; Move to a less crowded neighboring patch
        ] [
          stochastic-move ; If no other conditions apply, move randomly
        ]
      ]
    ]
  ]
end

; Procedure to move sheep randomly if no other rules apply
to stochastic-move
  let last-dir last-action
  ifelse random-float 100 < 50 [
    if last-dir = "N" [ set heading 0 fd 1 ]
    if last-dir = "S" [ set heading 180 fd 1 ]
    if last-dir = "E" [ set heading 90 fd 1 ]
    if last-dir = "W" [ set heading 270 fd 1 ]
    if last-dir = "stay" [ stay-put ]
  ] [
    let choice random 4
    if choice = 0 [ set heading 0 fd 1 set last-action "N" ]
    if choice = 1 [ set heading 180 fd 1 set last-action "S" ]
    if choice = 2 [ set heading 90 fd 1 set last-action "E" ]
    if choice = 3 [ set heading 270 fd 1 set last-action "W" ]
  ]
end

; Procedure to move dogs based on weights
to move-dog
  let choice weighted-random weights
  if choice = 0 [ set heading 0 fd 1 ] ; North
  if choice = 1 [ set heading 180 fd 1 ] ; South
  if choice = 2 [ set heading 90 fd 1 ] ; East
  if choice = 3 [ set heading 270 fd 1 ] ; West
  if choice = 4 [ stay-put ] ; Stay
end

; Function to report a weighted random choice from a list
to-report weighted-random [weight-list]
  let total-sum sum weight-list
  let r random-float total-sum
  let cum 0
  let choice 0
  while [cum <= r] [
    set cum cum + item choice weight-list
    set choice choice + 1
  ]
  report choice - 1
end

; Procedure for staying put (doing nothing)
to stay-put
  ; Do nothing
end

; Procedure to move to an empty patch
to move-to-empty-patch
  move-to one-of patches with [not any? dogs-here]
end

; Evaluate the initial, non-adaptive behavior
to evaluate-initial-behavior
  let initial-scores []
  repeat 10 [
    setup
    repeat 100 [
      if not any? turtles [ stop ]
      ask sheep [ move-sheep ]
      ask dogs [ move-dog ]
      tick
    ]
    set initial-scores lput (calculate-fitness_rep) initial-scores
  ]
  set initial-average-fitness mean initial-scores
  print (word "Initial average fitness: " initial-average-fitness)
end

; Evaluate the evolved behavior
to evaluate-evolved-behavior
  let evolved-scores []
  repeat 10 [
    setup
    repeat 100 [
      if not any? turtles [ stop ]
      ask sheep [ move-sheep ]
      ask dogs [ move-dog ]
      tick
    ]
    set evolved-scores lput (calculate-fitness_rep) evolved-scores
  ]
  set evolved-average-fitness mean evolved-scores
  print (word "Evolved average fitness: " evolved-average-fitness)
end

; Calculate fitness score based on sheep positions
to-report calculate-fitness_rep
  let x-var variance [pxcor] of sheep
  let y-var variance [pycor] of sheep
  report (x-var + y-var) / count sheep
end

; Main evaluation procedure
to evaluate
  setup
  evaluate-initial-behavior
  evaluate-evolved-behavior
  ; Compare the results
  ifelse evolved-average-fitness < initial-average-fitness [
    print "Evolved behavior is better."
  ] [
    print "Initial behavior is better or no significant difference."
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
855
656
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-24
24
-24
24
0
0
1
ticks
30.0

BUTTON
9
10
87
43
SETUP
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
91
10
201
43
GO (1 Tick)
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
92
201
125
RUN
run-simulation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
9
59
201
92
run-ticks
run-ticks
5
250
150.0
5
1
Ticks
HORIZONTAL

SLIDER
860
479
1195
512
population-size
population-size
5
100
75.0
5
1
NIL
HORIZONTAL

SLIDER
859
441
1195
474
generations
generations
5
100
5.0
5
1
NIL
HORIZONTAL

TEXTBOX
940
398
1118
423
Tuning Parameters:
18
0.0
1

BUTTON
854
340
1192
373
~ EVOLVE ~
evolve
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
852
10
1193
340
MEAN FITNESS SCORE vs TICKS
TICKS
MFS
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"mean fitness" 1.0 0 -13791810 true "" "plot mean fitness-scores"

BUTTON
11
137
200
170
NIL
EVALUATE
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
186
200
221
SAVE WEIGHTS
save-evolved-weights
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
# EXAM NUMBER: Y3898642

## Evaluation Procedure

### Initial Behavior Evaluation

1. Run the simulation with the initial weights set to 0.2.
2. Collect fitness scores over multiple runs to obtain a distribution of the initial fitness.

### Evolved Behavior Evaluation

1. Supposed to load the trained weights and evaluate against the initial behavior. After many many trials and errors, I ran out of time and resources to incorporate this.

## Conclusion
The project aimed to optimize the behavior of dogs in a herding simulation using a Genetic Algorithm. Weights corresponding to movement probabilities were chosen as the representation for the dogs' behaviour for its simplicity and adaptability. The fitness of the dogs was evaluated based on the variance in the positions of the sheep, with lower variance indicating better herding performance.

The Genetic Algorithm was designed with some components including: initialization, selection, crossover, mutation, elitism, and adaptive mutation rates. These elements were implemented to evolve the dogs' behavior over generations, with the goal of improving their herding efficiency.

However, several challenges were encountered during the implementation. The issue of weights being randomized instead of retained correctly was a significant obstacle, and the GA's performance was inconsistent, with fitness scores not showing the expected improvement. Despite lots of efforts to fine-tune the algorithm, the results did not indicate a significant enhancement in the dogs' herding behavior. It would get stuck at a mean fitness value of around 8.

In conclusion, while the project provided valuable insights into the application of Genetic Algorithms for behavior optimization in simulations, the implementation faced difficulties that hindered the achievement of optimal results. Future work could focus on refining the GA components, improving the mutation and crossover mechanisms, and exploring additional techniques such as fitness sharing to enhance the overall algorithm. Overall, the project highlighted both the potential and the complexities of using evolutionary algorithms in agent-based simulations.
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
0
@#$#@#$#@
