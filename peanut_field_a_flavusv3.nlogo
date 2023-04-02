breed [peanuts peanut]
breed [spores spore]
patches-own [soil-infected?]
peanuts-own [plant-infected? pod-count kernel-count kernel-af]



to setup
  clear-all
  setup-soil
  setup-spores

  reset-ticks
end

to setup-soil
  ask patches [ set pcolor brown set soil-infected? FALSE]

  ;make a square field of peanut plants
  ask patches with [ abs pxcor < 13 and abs pycor < 13 ]
    [sprout-peanuts 1 [ set shape "peanut_plant"  set size .25 set pod-count  0 set kernel-af 0] ;setting up our peanut plants. Note that each plants has no pods at the beginning
  ]


end


to setup-spores ;here each patch can be infected or not. We color it orange.
  ask n-of (infected_patches * (32 ^ 2) / 100) patches [sprout-spores 1 [set shape "aspergillus" set size 0.5 set pcolor orange]]


end

to go
  ask peanuts [set size size + 0.005] ;allow our peanut plants to grow each tick, which represent 1 day
  infect-patches; spores infect the soil
  infect-from-patches ; the soil infects the peanut plants
  move-spores
  add_pods ;as peanuts grow, they produce pods in the soil
  infect_kernels ;kernels become infected when a plant is infected and and it's vulnerable due to environmental stress

  if ticks >= Season_length [ stop ] ; assume peanut harvest after 9-120 days
  tick
end


to move-spores
  ask spores [
    right random 360
    forward 0.1
  ]
end


to infect-patches
  ask patches with [ any? spores-here]
    [set pcolor orange]
end

to infect-from-patches
; note that infection of plants is a stochastic process. However, the probability depends partly on whether pesticides are used to prevent plant disease and other pests in the first place
  ask peanuts [
    ifelse (pcolor = orange) and (pesticide-use = false) and (random 100 < 50) ;we assume plant infection is more likely if pesticides are not used.
    [
      set shape "peanut_plant_infected"
      set plant-infected?  true

    ]
    [
    if (pcolor = orange) and (pesticide-use = true) and (random 100 < 5)
      [
        set shape "peanut_plant_infected"
        set plant-infected?  true
      ]

    ]]
end


to add_pods ;we add pods based on how many days we are into the growing season. The pods start to develop at day forty
  ask peanuts[
  (ifelse
    ticks < 40
    [set pod-count 0]
    ticks = 40
    [set pod-count 10]
    ticks mod 5 = 0
      [
        if heat-stress = true [set pod-count pod-count + 1]   ;water stressed plants will add pods more slowly
        if heat-stress = false [set pod-count pod-count + 2]
      ]
   )


               ]
  ask peanuts [set kernel-count pod-count * 2]
end

to infect_kernels ;infection of peanut kernels depends on both use of water stress of the the plant and pesticide use. With more water stress, plants produce fewer phytolexins
                  ;and other defenses against aflatoxigenic fungi
  ask peanuts[
  if plant-infected? = true[
    (ifelse
      (heat-stress = false) and (pesticide-use = true)
      [set kernel-af 1 ]

       (heat-stress = false) and (pesticide-use = false)
      [set kernel-af  20  ]

      (heat-stress = true) and (pesticide-use = true)
      [set kernel-af 50 ]

      (heat-stress = true) and (pesticide-use = false)
      [set kernel-af 100 ]
  )]]

end
@#$#@#$#@
GRAPHICS-WINDOW
212
59
781
629
-1
-1
17.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
4
10
74
43
NIL
setup
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
79
10
142
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
8
208
205
328
Infected Plants
Time
Totals
0.0
120.0
0.0
20.0
true
true
"" ""
PENS
"Sick Plants" 1.0 0 -5298144 true "" "plot count peanuts with [shape  = \"peanut_plant_infected\"]"

SLIDER
1
49
173
82
Infected_patches
Infected_patches
0
50
14.0
1
1
%
HORIZONTAL

SLIDER
0
87
177
120
Season_length
Season_length
90
120
115.0
1
1
Days
HORIZONTAL

SWITCH
2
123
143
156
pesticide-use
pesticide-use
0
1
-1000

SWITCH
5
157
133
190
heat-stress
heat-stress
0
1
-1000

PLOT
8
339
210
459
Mean pods/plant
NIL
NIL
0.0
120.0
-5.0
50.0
true
false
"" ""
PENS
"pod-count" 1.0 0 -8630108 true "" "plot mean [pod-count] of peanuts"

PLOT
10
478
210
628
Average Peanut Aflatoxin
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [kernel-af] of peanuts "

TEXTBOX
217
10
813
60
Agent Based Model of Peanut Aflatoxin Contamination in a Field
20
0.0
1

@#$#@#$#@
## WHAT IS IT?

All of us want food that is safe from contaminants, right? Aspergillus flavus is a toxigenic fungus that can infect grains before and after harvest in hot and humid areas, producing a potent carcinogen know as aflatoxin. Here we model the infection and growth of A. flavus in a peanut field over a growing season and the contamination of peanut kernels due to aflatoxins. The agents in this model are spores of A. flavus and peanut plants. Patches are soil. 

## HOW IT WORKS


A peanut crop planted in rows grows over a season ranging from 90 to 120 days.

Aspergillus flavus is randomly distribute in the field and its life cycle is composed of two main phases:
1) colonization of plant residues in soil
2) infection of crop tissues

As the pods of peanuts grow at the roots, peanut pods come into contact with  aspergillus flavus spores in the soil. Normally healthy plants counter the growth of A flavus with resistance mechanisms such as production of compounds such as phytolexins. However, when plants are water stressed, water activity lowers, and kernels produce lower levels of phytolexins. Plants can be left more vulnerable by additional state variables  such as pest infestation, disease, and commpetition of soil resources against weeds. Therefore use of pesticides is a factor affecting plant health and resistance to aflatoxigenic fungi. Ultimately peanut kernel contamination occurs when peanut pods crack as a result of disease, water stress, and pest infestation. 

Important note: as this model is a simple proof of concept, it does not employ an exhaustive use of current knowledge of fungal soil ecology or the biosynthetic pathways underpinning aflatoxin production by A. flavus and other toxigenic fungi. Furthermore, aflatoxin contamination tends to occurs in hotspots with extreme contamination and is rarely uniform within a field. 


## HOW TO USE IT

For a quickstart, press setup, then go. 

You can use sliders and settings to adjust the % of soil patches infected with A. flavus, peanut growing season length, and agronomic factors (pesticide use, water stress).

The plots indicate the number of sick plants in the field, the average number of pods per plant, and the average aflatoxin in the whole field. 

## THINGS TO NOTICE

You'll see that this is a dynamic system: fungal spores move within the field, peanut plants grow... They become infected depending on the agronomic conditions and fungal prevalence that you control.

## THINGS TO TRY

Change the percentage of infected soil patches. You'll see a big impact on peanut contamination. 

## EXTENDING THE MODEL

Some parameters in this model were not taken directly from literature and should be rigorously reviewed, such as empirical rates of A. flavus spread within a field during a growing season, average aflatoxin contamination associated with the agronomic factors in the model, etc.  This is especially true for the estimation of kernel aflatoxin, which is influenced by many more factors than we can model here (micro-stresses localized within a field, rainfall, humidity, temperature, irrigation efficacy, soil history, peanut variety, etc). Since aflatoxins are not normally distributed, it may be interesting to model a different estimator for contamination instead of the mean. 


## RELATED MODELS

I'm not aware of other open source ABMs that model aspergillus flavus spread in a field and the amount of aflatoxin crops. But if there are, please contact me to share. There are however, models of aflatoxin risk. See these for examples: https://cropmanagement.cals.ncsu.edu/risk-tools/default.html

## CREDITS AND REFERENCES

The deterministic variables and relationships of this model were inspired by the following papers. They can be further reviewed by those interested in improving the parameters of the model. 

Abbas, HK, et al. 2009. Ecology of Aspergillus flavus, regulation of aflatoxin production, and management strategies to reduce aflatoxin contamination of corn. Toxin Reviews. 28 (2-3). 

Abde-Hadi, A, et al. 2012. Journal Royal Society Interface.A systems approach to model the relationship between aflatoxin gene cluster expression, environmental factors, growth and toxin production by Aspergillus flavus. 9(69)

Dorner JW, et al. 1989. Interrelationship of kernel water activity, soil temperature, maturity, and phytoalexin production in preharvest aflatoxin contamination of drought-stressed peanuts. Mycopathologia. 105. 

Horn, BW. 2006. Relationship between soil densities of Aspergillus species and colonization of wounded peanut seeds. Can J Microbiol.

Magan, N and Olsen M. 2004. Chapter 8: Environmental Conditions Affecting Mycotoxins. In: Mycotoxins in food: Detection and control. CRC Press.

Sanchis V., Magan N. 2004. Environmental conditions affecting mycotoxins. In Mycotoxins in food: detection and control, ch. 8 (eds Magan N., Olsen M.), pp. 174–189 Cambridge, UK: Woodhead Publishing Ltd

US Department of Agriculture. Web Soil Survey- Soil Health-Organic Matter- Summary by Map Unit-- Decatur County, Georgia. https://websoilsurvey.sc.egov.usda.gov/App/WebSoilSurvey.aspx. Accessed 12/28/2022. 

Zablotowicz RM. 2007. Population ecology of Aspergillus flavus associated with Mississippi Delta soils. Food Additives and Contaminants. 24. 
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

aspergillus
false
13
Circle -2064490 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -6459832 true false 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true false 120 120 60

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

peanut_plant
false
0
Rectangle -10899396 true false 135 90 165 300
Polygon -10899396 true false 135 255 90 210 45 195 75 255 135 285
Polygon -10899396 true false 165 255 210 210 255 195 225 255 165 285
Polygon -10899396 true false 135 180 90 135 45 120 75 180 135 210
Polygon -10899396 true false 165 180 165 210 225 180 255 120 210 135
Polygon -10899396 true false 135 105 90 60 45 45 75 105 135 135
Polygon -10899396 true false 165 105 165 135 225 105 255 45 210 60
Polygon -10899396 true false 135 90 120 45 150 15 180 45 165 90
Circle -1184463 true false 120 270 30

peanut_plant_infected
false
0
Rectangle -10899396 true false 135 90 165 300
Polygon -2674135 true false 135 255 90 210 45 195 75 255 135 285
Polygon -2674135 true false 165 255 210 210 255 195 225 255 165 285
Polygon -2674135 true false 135 180 90 135 45 120 75 180 135 210
Polygon -2674135 true false 165 180 165 210 225 180 255 120 210 135
Polygon -2674135 true false 135 105 90 60 45 45 75 105 135 135
Polygon -2674135 true false 165 105 165 135 225 105 255 45 210 60
Polygon -2674135 true false 135 90 120 45 150 15 180 45 165 90
Circle -1184463 true false 120 270 30
Circle -1184463 true false 150 270 30

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
NetLogo 6.3.0
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
