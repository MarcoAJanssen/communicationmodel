breed [ tokens token ]
breed [ players player ]

players-own
   [
   speed           ; actual speed of player
   t-count         ; Number of tokens collected.
   number          ; id number of player
   nrmoves         ; nrmoves done during a timestep
   p_harvest
   Trust
  prob-harvest
  trust_inequality
  timecrazy
  adjustmentrate
  adjustmentrate_harvest
  sigma
  sigma2

   ]

tokens-own [
  value ; value of the token for the four players
  ]

patches-own [
   nrn             ; number of tokens on neighboring 8 cells
]

extensions [csv]

globals [
  p                ; reproduction rate of tokens
  initialamount    ; initial amount of tokens in resource
  resource
  collected
  mean-trust
  filename
  resource1 resource2 resource3 resource4 resource5 resource6 resource7 resource8 resource9         ; set of resource level for each time step (accumulated over runs)
  collected1 collected2 collected3 collected4 collected5 collected6 collected7 collected8 collected9       ; list of number tokens collected for each round
  roundofgame
  run-nr           ; run number
  indicator1a indicator1b indicator1c indicator1d indicator1e indicator1f indicator1g indicator1h indicator1i
  indicator2a indicator2b indicator2c indicator2d indicator2e indicator2f indicator2g indicator2h indicator2i
  fitness
  trust1 trust2 trust3 trust4 trust5 trust6 trust7 trust8 trust9
  ]


;;;;;;;
;; New
;;;;;;;

to onerun

  initial-setup
  start-out-file

  ;let game-rounds [0 1 2 3 4 5 6 7 8 9]
  while [ticks < 2161][
    if ticks mod 240 = 0 [
      set roundofgame roundofgame + 1
      setup-each-round
      if roundofgame > 3 and roundofgame < 7 [
        ask players [set Trust Trust + sigma * (1 - Trust)]
      ]
;      show timer
    ]
    go-each-round

    tick
  ]
;  if roundofgame = 10 [file-close stop]
;  show timer
  file-close
  stop
end


to start-out-file

  let d-and-t (remove-item 6 (remove-item 7 (remove-item 8 (remove "-"(remove " "(remove "." (remove ":" date-and-time)))))))
  set filename (word "../results/" d-and-t "-" A-sigma "-" A-sigma2 "-" behaviorspace-run-number ".csv")

  file-open filename
 file-type "A-trust_inequality,B-trust_inequality,movement,A-sigma,B-sigma,A-timecrazy,B-timecrazy,A-prob-harvest,B-prob-harvest,A-adjustmentrate,B-adjustmentrate,A-adjustmentrate_harvest,B-adjustmentrate_harvest,A-sigma2,B-sigma2,maxspeed,resource,collected,mean-trust,ticks,seconds,roundofgame"
  file-print ""

end

to initial-setup

  clear-all
  reset-timer
  reset-ticks

  set p 0.01
  set initialamount 169
  set roundofgame 0
  set-default-shape tokens "circle 2"
  set-default-shape players "circle"

  ;; Populate the world with players along the x-axis, spaced evenly.
  create-players 1 [set xcor 3 set number 1]
  create-players 1 [set xcor 9 set number 2]
  create-players 1 [set xcor 16 set number 3]
  create-players 1 [set xcor 22 set number 4]

  ask players [
    set color blue
    set ycor 13
    set t-count 0   ;; Start with no tokens
    set heading (random 4 * 90)
    set p_harvest prob-harvest
    ;; Initialize all players' speed.
    set speed random-normal 3 0.65
    ;; Initialize player's trust
    set Trust random-normal 0.5 0.1

    ifelse random-float 1 < shareA [
       set sigma A-sigma
       set sigma2 A-sigma2
       set timecrazy A-timecrazy
       set prob-harvest A-prob-harvest
       set trust_inequality A-trust_inequality
       set adjustmentrate A-adjustmentrate
       set adjustmentrate_harvest A-adjustmentrate_harvest
    ][
       set sigma B-sigma
       set sigma B-sigma2
       set timecrazy B-timecrazy
       set prob-harvest B-prob-harvest
       set trust_inequality B-trust_inequality
       set adjustmentrate B-adjustmentrate
       set adjustmentrate_harvest B-adjustmentrate_harvest
    ]


    if Trust < 0 [set Trust 0]
    if Trust > 1 [set Trust 1]
  ]
end

to setup-each-round

  ask tokens [die]
  set resource 0
  set collected 0

  ask players with [number = 1] [set xcor 3 set ycor 13 set t-count 0 set heading random 4 * 90]
  ask players with [number = 2] [set xcor 9 set ycor 13 set t-count 0 set heading random 4 * 90]
  ask players with [number = 3] [set xcor 16 set ycor 13 set t-count 0 set heading random 4 * 90]
  ask players with [number = 4] [set xcor 22 set ycor 13 set t-count 0 set heading random 4 * 90]


  ;; Populate the world with tokens.
  ask n-of initialamount patches [
    sprout-tokens 1 [set color green set value 0]
  ]

end

to go-each-round
;  while [ticks < 240] [

  if ticks mod 240 > 2  [move-players]
  grow-tokens

  set resource count Tokens
  set collected sum [t-count] of players
  set mean-trust mean [Trust] of players

  write-out-file

    ;if count tokens = 0 [stop]
;  ]
end

to write-out-file

  let seconds (ticks mod 240) + 1

  file-type (word A-trust_inequality ",")
  file-type (word B-trust_inequality ",")
  file-type (word movement ",")
  file-type (word A-sigma ",")
  file-type (word B-sigma ",")
  file-type (word A-timecrazy ",")
  file-type (word B-timecrazy ",")
  file-type (word A-prob-harvest ",")
  file-type (word B-prob-harvest ",")
  file-type (word A-adjustmentrate ",")
  file-type (word B-adjustmentrate ",")
  file-type (word A-adjustmentrate_harvest ",")
  file-type (word B-adjustmentrate_harvest ",")
  file-type (word A-sigma2 ",")
  file-type (word B-sigma2 ",")
  file-type (word maxspeed ",")
  file-type (word resource ",")
  file-type (word collected ",")
  file-type (word mean-trust ",")
  file-type (word ticks ",")
  file-type (word seconds ",")
  file-type roundofgame

  file-print ""

end


;;;;;;;;;;;;;;;
;;;;;;;;
;;
;;;;;;;;
;;;;;;;;;;;;;;;

to setup
 ; clear-all
 ; set run-nr 1
  reset-ticks
  ask turtles [die]
  set p 0.01
  set initialamount 169
  set roundofgame 1
  setup-players
  setup-round
end

;; Populate the world with tokens.
to setup-round
  set-default-shape tokens "circle"
  let teller 0
  ask tokens [die]
  while [teller < initialamount] [
    ask one-of patches
    [
      if count turtles-here = 0 [sprout-tokens 1 [set color green set value 0] set teller teller + 1]
    ]
  ]
  ask players with [number = 1] [set xcor 3 set ycor 13]
  ask players with [number = 2] [set xcor 9 set ycor 13]
  ask players with [number = 3] [set xcor 16 set ycor 13]
  ask players with [number = 4] [set xcor 22 set ycor 13]

  ask players
      [
      set t-count 0   ;; Start with no tokens
       let head random 4
       if head = 0 [set heading 0]
       if head = 1 [set heading 90 ]
       if head = 2 [set heading 180]
       if head = 3 [set heading 270]
      ]
end

;; Populate the world with players along the x-axis, spaced evenly.
to setup-players
   set-default-shape players "circle"

   create-players 1 [set xcor 3 set number 1]
   create-players 1 [set xcor 9 set number 2]
   create-players 1 [set xcor 16 set number 3]
   create-players 1 [set xcor 22 set number 4]

   ask players [
      set color blue
      set ycor 13]

   ask players
      [
      set t-count 0   ;; Start with no tokens
       let head random 4
       if head = 0 [set heading 0]
       if head = 1 [set heading 90 ]
       if head = 2 [set heading 180]
       if head = 3 [set heading 270]
      ;  set p_harvest random-normal prob-harvest stdevprob
       ;  set p_harvest prob-harvest
       ; if p_harvest < 0.1 [set p_harvest 0.1]
       ; if p_harvest > 1 [set p_harvest 1]
      ]

   ;; Initialize all players' speed.
   ask players [
     ifelse random-float 1 < shareA [
       set sigma A-sigma
       set sigma2 A-sigma2
       set timecrazy A-timecrazy
       set prob-harvest A-prob-harvest
       set trust_inequality A-trust_inequality
       set adjustmentrate A-adjustmentrate
       set adjustmentrate_harvest A-adjustmentrate_harvest
    ][
       set sigma B-sigma
       set sigma B-sigma2
       set timecrazy B-timecrazy
       set prob-harvest B-prob-harvest
       set trust_inequality B-trust_inequality
       set adjustmentrate B-adjustmentrate
       set adjustmentrate_harvest B-adjustmentrate_harvest
    ]
    set p_harvest prob-harvest

      set speed random-normal 3 0.65
      set Trust random-normal 0.5 0.1
      if Trust < 0 [set Trust 0]
      if Trust > 1 [set Trust 1]
   ]
end


to go
   ; if (count tokens = 0) [stop]
  if ticks = 240 [if roundofgame < 9 [reset-ticks]
    if roundofgame = 1 [set collected1 lput total-tokens collected1]
    if roundofgame = 2 [set collected2 lput total-tokens collected2]
    if roundofgame = 3 [set collected3 lput total-tokens collected3]
    if roundofgame = 4 [set collected4 lput total-tokens collected4]
    if roundofgame = 5 [set collected5 lput total-tokens collected5]
    if roundofgame = 6 [set collected6 lput total-tokens collected6]
    if roundofgame = 7 [set collected7 lput total-tokens collected7]
    if roundofgame = 8 [set collected8 lput total-tokens collected8]
    if roundofgame = 9 [set collected9 lput total-tokens collected9]
    set roundofgame roundofgame + 1
    ifelse roundofgame < 10 [setup-round][stop]
  ]
  if ticks < 1 [ ask players [
    if roundofgame = 4 [set Trust Trust + sigma * (1 - Trust)]
     if roundofgame = 5 [set Trust Trust + sigma2 * (1 - Trust)]
     if roundofgame = 6 [set Trust Trust + sigma2 * (1 - Trust)
    ]
    ]
  ]
  if ticks > 2  [move-players]
  ;; Stop simulation when there are no more tokens or 4 minutes is passed.



  grow-tokens
  if roundofgame = 1 [set resource1 replace-item (ticks + 1) resource1 (item (ticks + 1) resource1 + count tokens)]
  if roundofgame = 2 [set resource2 replace-item (ticks + 1) resource2 (item (ticks + 1) resource2 + count tokens)]
  if roundofgame = 3 [set resource3 replace-item (ticks + 1) resource3 (item (ticks + 1) resource3 + count tokens)]
  if roundofgame = 4 [set resource4 replace-item (ticks + 1) resource4 (item (ticks + 1) resource4 + count tokens)]
  if roundofgame = 5 [set resource5 replace-item (ticks + 1) resource5 (item (ticks + 1) resource5 + count tokens)]
  if roundofgame = 6 [set resource6 replace-item (ticks + 1) resource6 (item (ticks + 1) resource6 + count tokens)]
  if roundofgame = 7 [set resource7 replace-item (ticks + 1) resource7 (item (ticks + 1) resource7 + count tokens)]
  if roundofgame = 8 [set resource8 replace-item (ticks + 1) resource8 (item (ticks + 1) resource8 + count tokens)]
  if roundofgame = 9 [set resource9 replace-item (ticks + 1) resource9 (item (ticks + 1) resource9 + count tokens)]

  if roundofgame = 1 [set trust1 replace-item (ticks + 1) trust1 (item (ticks + 1) trust1 + mean [Trust] of players)]
  if roundofgame = 2 [set trust2 replace-item (ticks + 1) trust2 (item (ticks + 1) trust2 + mean [Trust] of players)]
  if roundofgame = 3 [set trust3 replace-item (ticks + 1) trust3 (item (ticks + 1) trust3 + mean [Trust] of players)]
  if roundofgame = 4 [set trust4 replace-item (ticks + 1) trust4 (item (ticks + 1) trust4 + mean [Trust] of players)]
  if roundofgame = 5 [set trust5 replace-item (ticks + 1) trust5 (item (ticks + 1) trust5 + mean [Trust] of players)]
  if roundofgame = 6 [set trust6 replace-item (ticks + 1) trust6 (item (ticks + 1) trust6 + mean [Trust] of players)]
  if roundofgame = 7 [set trust7 replace-item (ticks + 1) trust7 (item (ticks + 1) trust7 + mean [Trust] of players)]
  if roundofgame = 8 [set trust8 replace-item (ticks + 1) trust8 (item (ticks + 1) trust8 + mean [Trust] of players)]
  if roundofgame = 9 [set trust9 replace-item (ticks + 1) trust9 (item (ticks + 1) trust9 + mean [Trust] of players)]

 tick
if roundofgame = 10 [stop]
end

to manyruns
  clear-all
  set resource1 [] set resource2 [] set resource3 [] set resource4 [] set resource5 [] set resource6 [] set resource7 [] set resource8 [] set resource9 []
  set trust1 [] set trust2 [] set trust3 [] set trust4 [] set trust5 [] set trust6 [] set trust7 [] set trust8 [] set trust9 []
  set collected1 [] set collected2 [] set collected3 [] set collected4 [] set collected5 [] set collected6 [] set collected7 [] set collected8 [] set collected9 []
  let i 0
  while [i <= 240]
  [
    set resource1 lput 0 resource1 set resource2 lput 0 resource2 set resource3 lput 0 resource3
    set resource4 lput 0 resource4 set resource5 lput 0 resource5 set resource6 lput 0 resource6
    set resource7 lput 0 resource7 set resource8 lput 0 resource8 set resource9 lput 0 resource9
    set trust1 lput 0 trust1 set trust2 lput 0 trust2 set trust3 lput 0 trust3
    set trust4 lput 0 trust4 set trust5 lput 0 trust5 set trust6 lput 0 trust6
    set trust7 lput 0 trust7 set trust8 lput 0 trust8 set trust9 lput 0 trust9
    set i i + 1
  ]
  set i 0

  set run-nr 1
  while [run-nr <= nr-repeats]
  [
    setup
    while [ticks <= 240 and roundofgame < 10]
    [
      go
    ]
    set run-nr run-nr + 1
  ]
  ; Mean tokens collected: (X - |X-S|)/X
  ; Mean tokens available over time


  set indicator1a (242.54 - abs (mean collected1 - 242.54)) / 242.54
  set indicator1b (230.80 - abs (mean collected2 - 230.80)) / 230.80
  set indicator1c (223.59 - abs (mean collected3 - 223.59)) / 223.59
  set indicator1d (341.10 - abs (mean collected4 - 341.10)) / 341.10
  set indicator1e (375.85 - abs (mean collected5 - 375.85)) / 375.85
  set indicator1f (381.61 - abs (mean collected6 - 381.61)) / 381.61
  set indicator1g (363.10 - abs (mean collected7 - 363.10)) / 363.10
  set indicator1h (359.85 - abs (mean collected8 - 359.85)) / 359.85
  set indicator1i (349.95 - abs (mean collected9 - 349.95)) / 349.95
  set indicator2a ((166.93 - abs (item 5 resource1 / nr-repeats - 166.93)) / 166.93 +
(157.41 - abs (item 10 resource1 / nr-repeats - 157.41)) / 157.41 + (146.66 - abs (item 15 resource1 / nr-repeats - 146.66)) / 146.66 +
  (137.76 - abs (item 20 resource1 / nr-repeats - 137.76)) / 137.76 + (128.05 - abs (item 25 resource1 / nr-repeats - 128.05)) / 128.05 +
  (118.80 - abs (item 30 resource1 / nr-repeats - 118.80)) / 118.80 + (108.98 - abs (item 35 resource1 / nr-repeats - 108.98)) / 108.98 +
  (99.27 - abs (item 40 resource1 / nr-repeats - 99.27)) / 99.27 + (89.51 - abs (item 45 resource1 / nr-repeats - 89.51)) / 89.51 +
  (79.32 - abs (item 50 resource1 / nr-repeats - 79.32)) / 79.32 + (70.15 - abs (item 55 resource1 / nr-repeats - 70.15)) / 70.15 +
  (61.93 - abs (item 60 resource1 / nr-repeats - 61.93)) / 61.93 + (53.61 - abs (item 65 resource1 / nr-repeats - 53.61)) / 53.61 +
  (46.05 - abs (item 70 resource1 / nr-repeats - 46.05)) / 46.05 + (39.44 - abs (item 75 resource1 / nr-repeats - 39.44)) / 39.44 +
  (34.44 - abs (item 80 resource1 / nr-repeats - 34.44)) / 34.44 + (30.22 - abs (item 85 resource1 / nr-repeats - 30.22)) / 30.22 +
  (26.95 - abs (item 90 resource1 / nr-repeats - 26.95)) / 26.95 + (24.71 - abs (item 95 resource1 / nr-repeats - 24.71)) / 24.71 +
  (22.71 - abs (item 100 resource1 / nr-repeats - 22.71)) / 22.71 + (21.27 - abs (item 105 resource1 / nr-repeats - 21.27)) / 21.27 +
  (19.78 - abs (item 110 resource1 / nr-repeats - 19.78)) / 19.78 + (18.02 - abs (item 115 resource1 / nr-repeats - 18.02)) / 18.02 +
  (16.83 - abs (item 120 resource1 / nr-repeats - 16.83)) / 16.83 + (15.78 - abs (item 125 resource1 / nr-repeats - 15.78)) / 15.78 +
  (14.59 - abs (item 130 resource1 / nr-repeats - 14.59)) / 14.59 + (13.54 - abs (item 135 resource1 / nr-repeats - 13.54)) / 13.54 +
  (12.90 - abs (item 140 resource1 / nr-repeats - 12.90)) / 12.90 + (12.32 - abs (item 145 resource1 / nr-repeats - 12.32)) / 12.32 +
  (11.32 - abs (item 150 resource1 / nr-repeats - 11.32)) / 11.32 + (10.51 - abs (item 155 resource1 / nr-repeats - 10.51)) / 10.51 +
  (9.59 - abs (item 160 resource1 / nr-repeats - 9.59)) / 9.59 + (8.95 - abs (item 165 resource1 / nr-repeats - 8.95)) / 8.95 +
  (8.32 - abs (item 170 resource1 / nr-repeats - 8.32)) / 8.32 + (7.71 - abs (item 175 resource1 / nr-repeats - 7.71)) / 7.71 +
  (7.17 - abs (item 180 resource1 / nr-repeats - 7.17)) / 7.17 + (6.95 - abs (item 185 resource1 / nr-repeats - 6.95)) / 6.95 +
  (6.85 - abs (item 190 resource1 / nr-repeats - 6.85)) / 6.85 + (6.49 - abs (item 195 resource1 / nr-repeats - 6.49)) / 6.49 +
  (6.05 - abs (item 200 resource1 / nr-repeats - 6.05)) / 6.05 + (5.22 - abs (item 205 resource1 / nr-repeats - 5.22)) / 5.22 +
  (4.29 - abs (item 210 resource1 / nr-repeats - 4.29)) / 4.29 + (3.66 - abs (item 215 resource1 / nr-repeats - 3.66)) / 3.66 +
  (3.12 - abs (item 220 resource1 / nr-repeats - 3.12)) / 3.12 + (2.66 - abs (item 225 resource1 / nr-repeats - 2.66)) / 2.66 +
  (2.29 - abs (item 230 resource1 / nr-repeats - 2.29)) / 2.29 + (2.07 - abs (item 235 resource1 / nr-repeats - 2.07)) / 2.07 +
  (1.85 - abs (item 240 resource1 / nr-repeats - 1.85)) / 1.85) / 48

  set indicator2b ((161.10 - abs (item 5 resource2 / nr-repeats - 161.10)) / 161.10 +
(148.17 - abs (item 10 resource2 / nr-repeats - 148.17)) / 148.17 + (137.32 - abs (item 15 resource2 / nr-repeats - 137.32)) / 137.32 +
  (125.44 - abs (item 20 resource2 / nr-repeats - 125.44)) / 125.44 + (113.54 - abs (item 25 resource2 / nr-repeats - 113.54)) / 113.54 +
  (103.15 - abs (item 30 resource2 / nr-repeats - 103.15)) / 103.15 + (92.02 - abs (item 35 resource2 / nr-repeats - 92.02)) / 92.02 +
  (80.07 - abs (item 40 resource2 / nr-repeats - 80.07)) / 80.07 + (68.93 - abs (item 45 resource2 / nr-repeats - 68.93)) / 68.93 +
  (58.76 - abs (item 50 resource2 / nr-repeats - 58.76)) / 58.76 + (49.59 - abs (item 55 resource2 / nr-repeats - 49.59)) / 49.59 +
  (41.95 - abs (item 60 resource2 / nr-repeats - 41.95)) / 41.95 + (35.39 - abs (item 65 resource2 / nr-repeats - 35.39)) / 35.39 +
  (31.12 - abs (item 70 resource2 / nr-repeats - 31.12)) / 31.12 + (26.54 - abs (item 75 resource2 / nr-repeats - 26.54)) / 26.54 +
  (22.20 - abs (item 80 resource2 / nr-repeats - 22.20)) / 22.20 + (18.15 - abs (item 85 resource2 / nr-repeats - 18.15)) / 18.15 +
  (15.71 - abs (item 90 resource2 / nr-repeats - 15.71)) / 15.71 + (13.85 - abs (item 95 resource2 / nr-repeats - 13.85)) / 13.85 +
  (12.98 - abs (item 100 resource2 / nr-repeats - 12.98)) / 12.98 + (11.88 - abs (item 105 resource2 / nr-repeats - 11.88)) / 11.88 +
  (10.85 - abs (item 110 resource2 / nr-repeats - 10.85)) / 10.85 + (10.02 - abs (item 115 resource2 / nr-repeats - 10.02)) / 10.02 +
  (9.34 - abs (item 120 resource2 / nr-repeats - 9.34)) / 9.34 + (8.80 - abs (item 125 resource2 / nr-repeats - 8.80)) / 8.80 +
  (8.76 - abs (item 130 resource2 / nr-repeats - 8.76)) / 8.76 + (8.63 - abs (item 135 resource2 / nr-repeats - 8.63)) / 8.63 +
  (8.41 - abs (item 140 resource2 / nr-repeats - 8.41)) / 8.41 + (7.93 - abs (item 145 resource2 / nr-repeats - 7.93)) / 7.93 +
  (7.51 - abs (item 150 resource2 / nr-repeats - 7.51)) / 7.51 + (7.27 - abs (item 155 resource2 / nr-repeats - 7.27)) / 7.27 +
  (7.20 - abs (item 160 resource2 / nr-repeats - 7.20)) / 7.20 + (6.71 - abs (item 165 resource2 / nr-repeats - 6.71)) / 6.71 +
  (6.39 - abs (item 170 resource2 / nr-repeats - 6.39)) / 6.39 + (6.10 - abs (item 175 resource2 / nr-repeats - 6.10)) / 6.10 +
  (5.83 - abs (item 180 resource2 / nr-repeats - 5.83)) / 5.83 + (5.49 - abs (item 185 resource2 / nr-repeats - 5.49)) / 5.49 +
  (5.32 - abs (item 190 resource2 / nr-repeats - 5.32)) / 5.32 + (4.88 - abs (item 195 resource2 / nr-repeats - 4.88)) / 4.88 +
  (4.44 - abs (item 200 resource2 / nr-repeats - 4.44)) / 4.44 + (4.24 - abs (item 205 resource2 / nr-repeats - 4.24)) / 4.24 +
  (3.71 - abs (item 210 resource2 / nr-repeats - 3.71)) / 3.71 + (3.29 - abs (item 215 resource2 / nr-repeats - 3.29)) / 3.29 +
  (2.71 - abs (item 220 resource2 / nr-repeats - 2.71)) / 2.71 + (1.93 - abs (item 225 resource2 / nr-repeats - 1.93)) / 1.93 +
  (1.34 - abs (item 230 resource2 / nr-repeats - 1.34)) / 1.34 + (0.73 - abs (item 235 resource2 / nr-repeats - 0.73)) / 0.73 +
  (0.22 - abs (item 240 resource2 / nr-repeats - 0.22)) / 0.22) / 48

    set indicator2c ((159.73 - abs (item 5 resource3 / nr-repeats - 159.73)) / 159.73 +
(146.59 - abs (item 10 resource3 / nr-repeats - 146.59)) / 146.59 + (132.54 - abs (item 15 resource3 / nr-repeats - 132.54)) / 132.54 +
  (119.02 - abs (item 20 resource3 / nr-repeats - 119.02)) / 119.02 + (105.32 - abs (item 25 resource3 / nr-repeats - 105.32)) / 105.32 +
  (91.63 - abs (item 30 resource3 / nr-repeats - 91.63)) / 91.63 + (78.88 - abs (item 35 resource3 / nr-repeats - 78.88)) / 78.88 +
  (64.61 - abs (item 40 resource3 / nr-repeats - 64.61)) / 64.61 + (51.83 - abs (item 45 resource3 / nr-repeats - 51.83)) / 51.83 +
  (42.17 - abs (item 50 resource3 / nr-repeats - 42.17)) / 42.17 + (34.46 - abs (item 55 resource3 / nr-repeats - 34.46)) / 34.46 +
  (28.80 - abs (item 60 resource3 / nr-repeats - 28.80)) / 28.80 + (24.95 - abs (item 65 resource3 / nr-repeats - 24.95)) / 24.95 +
  (21.78 - abs (item 70 resource3 / nr-repeats - 21.78)) / 21.78 + (19.46 - abs (item 75 resource3 / nr-repeats - 19.46)) / 19.46 +
  (17.88 - abs (item 80 resource3 / nr-repeats - 17.88)) / 17.88 + (16.59 - abs (item 85 resource3 / nr-repeats - 16.59)) / 16.59 +
  (15.59 - abs (item 90 resource3 / nr-repeats - 15.59)) / 15.59 + (14.59 - abs (item 95 resource3 / nr-repeats - 14.59)) / 14.59 +
  (13.83 - abs (item 100 resource3 / nr-repeats - 13.83)) / 13.83 + (12.98 - abs (item 105 resource3 / nr-repeats - 12.98)) / 12.98 +
  (12.07 - abs (item 110 resource3 / nr-repeats - 12.07)) / 12.07 + (11.05 - abs (item 115 resource3 / nr-repeats - 11.05)) / 11.05 +
  (10.27 - abs (item 120 resource3 / nr-repeats - 10.27)) / 10.27 + (9.80 - abs (item 125 resource3 / nr-repeats - 9.80)) / 9.80 +
  (9.37 - abs (item 130 resource3 / nr-repeats - 9.37)) / 9.37 + (9.07 - abs (item 135 resource3 / nr-repeats - 9.07)) / 9.07 +
  (8.73 - abs (item 140 resource3 / nr-repeats - 8.73)) / 8.73 + (8.32 - abs (item 145 resource3 / nr-repeats - 8.32)) / 8.32 +
  (7.83 - abs (item 150 resource3 / nr-repeats - 7.83)) / 7.83 + (7.44 - abs (item 155 resource3 / nr-repeats - 7.44)) / 7.44 +
  (6.80 - abs (item 160 resource3 / nr-repeats - 6.80)) / 6.80 + (6.07 - abs (item 165 resource3 / nr-repeats - 6.07)) / 6.07 +
  (5.73 - abs (item 170 resource3 / nr-repeats - 5.73)) / 5.73 + (5.44 - abs (item 175 resource3 / nr-repeats - 5.44)) / 5.44 +
  (5.10 - abs (item 180 resource3 / nr-repeats - 5.10)) / 5.10 + (4.66 - abs (item 185 resource3 / nr-repeats - 4.66)) / 4.66 +
  (4.37 - abs (item 190 resource3 / nr-repeats - 4.37)) / 4.37 + (4.10 - abs (item 195 resource3 / nr-repeats - 4.10)) / 4.10 +
  (3.71 - abs (item 200 resource3 / nr-repeats - 3.71)) / 3.71 + (3.22 - abs (item 205 resource3 / nr-repeats - 3.22)) / 3.22 +
  (3.02 - abs (item 210 resource3 / nr-repeats - 3.02)) / 3.02 + (2.71 - abs (item 215 resource3 / nr-repeats - 2.71)) / 2.71 +
  (2.49 - abs (item 220 resource3 / nr-repeats - 2.49)) / 2.49 + (2.20 - abs (item 225 resource3 / nr-repeats - 2.20)) / 2.20 +
  (1.68 - abs (item 230 resource3 / nr-repeats - 1.68)) / 1.68 + (1.29 - abs (item 235 resource3 / nr-repeats - 1.29)) / 1.29 +
  (0.88 - abs (item 240 resource3 / nr-repeats - 0.88)) / 0.88) / 48

    set indicator2d ((170.49 - abs (item 5 resource4 / nr-repeats - 170.49)) / 170.49 +
  (168.78 - abs (item 10 resource4 / nr-repeats - 168.78)) / 168.78 + (165.71 - abs (item 15 resource4 / nr-repeats - 165.71)) / 165.71 +
  (163.51 - abs (item 20 resource4 / nr-repeats - 163.51)) / 163.51 + (161.20 - abs (item 25 resource4 / nr-repeats - 161.20)) / 161.20 +
  (159.56 - abs (item 30 resource4 / nr-repeats - 159.56)) / 159.56 + (157.76 - abs (item 35 resource4 / nr-repeats - 157.76)) / 157.76 +
  (155.20 - abs (item 40 resource4 / nr-repeats - 155.20)) / 155.20 + (154.00 - abs (item 45 resource4 / nr-repeats - 154.00)) / 154.00 +
  (152.27 - abs (item 50 resource4 / nr-repeats - 152.27)) / 152.27 + (151.17 - abs (item 55 resource4 / nr-repeats - 151.17)) / 151.17 +
  (149.41 - abs (item 60 resource4 / nr-repeats - 149.41)) / 149.41 + (148.12 - abs (item 65 resource4 / nr-repeats - 148.12)) / 148.12 +
  (145.44 - abs (item 70 resource4 / nr-repeats - 145.44)) / 145.44 + (143.15 - abs (item 75 resource4 / nr-repeats - 143.15)) / 143.15 +
  (140.66 - abs (item 80 resource4 / nr-repeats - 140.66)) / 140.66 + (138.66 - abs (item 85 resource4 / nr-repeats - 138.66)) / 138.66 +
  (137.39 - abs (item 90 resource4 / nr-repeats - 137.39)) / 139.39 + (136.37 - abs (item 95 resource4 / nr-repeats - 136.37)) / 136.37 +
  (135.61 - abs (item 100 resource4 / nr-repeats - 135.61)) / 135.61 + (135.00 - abs (item 105 resource4 / nr-repeats - 135.00)) / 135.00 +
  (134.34 - abs (item 110 resource4 / nr-repeats - 134.34)) / 134.34 + (134.49 - abs (item 115 resource4 / nr-repeats - 134.49)) / 134.49 +
  (133.68 - abs (item 120 resource4 / nr-repeats - 133.68)) / 133.68 + (133.10 - abs (item 125 resource4 / nr-repeats - 133.10)) / 133.10 +
  (132.00 - abs (item 130 resource4 / nr-repeats - 132.00)) / 132.00 + (131.05 - abs (item 135 resource4 / nr-repeats - 131.05)) / 131.05 +
  (129.93 - abs (item 140 resource4 / nr-repeats - 129.93)) / 129.93 + (128.51 - abs (item 145 resource4 / nr-repeats - 128.51)) / 128.51 +
  (127.20 - abs (item 150 resource4 / nr-repeats - 127.20)) / 127.20 + (125.00 - abs (item 155 resource4 / nr-repeats - 125.00)) / 125.00 +
  (122.98 - abs (item 160 resource4 / nr-repeats - 122.98)) / 122.98 + (121.24 - abs (item 165 resource4 / nr-repeats - 121.24)) / 121.24 +
  (118.78 - abs (item 170 resource4 / nr-repeats - 118.78)) / 118.78 + (116.15 - abs (item 175 resource4 / nr-repeats - 116.15)) / 116.15 +
  (113.41 - abs (item 180 resource4 / nr-repeats - 113.41)) / 113.41 + (109.12 - abs (item 185 resource4 / nr-repeats - 109.12)) / 109.12 +
  (104.02 - abs (item 190 resource4 / nr-repeats - 104.02)) / 104.02 + (98.29 - abs (item 195 resource4 / nr-repeats - 98.29)) / 98.29 +
  (90.80 - abs (item 200 resource4 / nr-repeats - 90.80)) / 90.80 + (82.66 - abs (item 205 resource4 / nr-repeats - 82.66)) / 82.66 +
  (72.24 - abs (item 210 resource4 / nr-repeats - 72.24)) / 72.24 + (63.56 - abs (item 215 resource4 / nr-repeats - 63.56)) / 63.56 +
  (53.63 - abs (item 220 resource4 / nr-repeats - 53.63)) / 53.63 + (43.63 - abs (item 225 resource4 / nr-repeats - 43.63)) / 43.63 +
  (33.22 - abs (item 230 resource4 / nr-repeats - 33.22)) / 33.22 + (23.68 - abs (item 235 resource4 / nr-repeats - 23.68)) / 23.68 +
  (16.39 - abs (item 240 resource4 / nr-repeats - 16.39)) / 16.39) / 48

    set indicator2e ((170.85 - abs (item 5 resource5 / nr-repeats - 170.85)) / 170.85 +
(169.54 - abs (item 10 resource5 / nr-repeats - 169.54)) / 169.54 + (167.17 - abs (item 15 resource5 / nr-repeats - 167.17)) / 167.17 +
  (166.17 - abs (item 20 resource5 / nr-repeats - 166.17)) / 166.17 + (166.07 - abs (item 25 resource5 / nr-repeats - 166.07)) / 166.07 +
  (165.80 - abs (item 30 resource5 / nr-repeats - 165.80)) / 165.80 + (165.34 - abs (item 35 resource5 / nr-repeats - 165.34)) / 165.34 +
  (165.39 - abs (item 40 resource5 / nr-repeats - 165.39)) / 165.39 + (166.51 - abs (item 45 resource5 / nr-repeats - 166.51)) / 166.51 +
  (166.68 - abs (item 50 resource5 / nr-repeats - 166.68)) / 166.68 + (167.22 - abs (item 55 resource5 / nr-repeats - 167.22)) / 167.22 +
  (168.22 - abs (item 60 resource5 / nr-repeats - 168.22)) / 168.22 + (168.10 - abs (item 65 resource5 / nr-repeats - 168.10)) / 168.10 +
  (168.66 - abs (item 70 resource5 / nr-repeats - 168.66)) / 168.66 + (168.85 - abs (item 75 resource5 / nr-repeats - 168.85)) / 168.85 +
  (169.07 - abs (item 80 resource5 / nr-repeats - 169.07)) / 169.07 + (169.95 - abs (item 85 resource5 / nr-repeats - 169.95)) / 169.95 +
  (170.68 - abs (item 90 resource5 / nr-repeats - 170.68)) / 170.68 + (171.54 - abs (item 95 resource5 / nr-repeats - 171.54)) / 171.54 +
  (171.56 - abs (item 100 resource5 / nr-repeats - 171.56)) / 171.56 + (171.51 - abs (item 105 resource5 / nr-repeats - 171.51)) / 171.51 +
  (170.76 - abs (item 110 resource5 / nr-repeats - 170.76)) / 170.76 + (170.07 - abs (item 115 resource5 / nr-repeats - 170.07)) / 170.07 +
  (168.63 - abs (item 120 resource5 / nr-repeats - 168.63)) / 168.63 + (167.15 - abs (item 125 resource5 / nr-repeats - 167.15)) / 167.15 +
  (165.41 - abs (item 130 resource5 / nr-repeats - 165.41)) / 165.41 + (164.78 - abs (item 135 resource5 / nr-repeats - 164.78)) / 164.78 +
  (163.07 - abs (item 140 resource5 / nr-repeats - 163.07)) / 163.07 + (161.68 - abs (item 145 resource5 / nr-repeats - 161.07)) / 161.07 +
  (158.73 - abs (item 150 resource5 / nr-repeats - 158.73)) / 158.73 + (157.12 - abs (item 155 resource5 / nr-repeats - 157.12)) / 157.12 +
  (154.49 - abs (item 160 resource5 / nr-repeats - 154.49)) / 154.49 + (152.07 - abs (item 165 resource5 / nr-repeats - 152.07)) / 152.07 +
  (147.76 - abs (item 170 resource5 / nr-repeats - 147.76)) / 147.76 + (143.02 - abs (item 175 resource5 / nr-repeats - 143.02)) / 143.02 +
  (136.66 - abs (item 180 resource5 / nr-repeats - 136.66)) / 136.66 + (129.05 - abs (item 185 resource5 / nr-repeats - 129.05)) / 129.05 +
  (121.63 - abs (item 190 resource5 / nr-repeats - 121.63)) / 121.63 + (112.15 - abs (item 195 resource5 / nr-repeats - 112.15)) / 112.15 +
  (101.20 - abs (item 200 resource5 / nr-repeats - 101.20)) / 101.20 + (89.10 - abs (item 205 resource5 / nr-repeats - 89.10)) / 89.10 +
  (77.05 - abs (item 210 resource5 / nr-repeats - 77.05)) / 77.05 + (64.95 - abs (item 215 resource5 / nr-repeats - 64.95)) / 64.95 +
  (52.44 - abs (item 220 resource5 / nr-repeats - 52.44)) / 52.44 + (39.80 - abs (item 225 resource5 / nr-repeats - 39.80)) / 39.80 +
  (28.17 - abs (item 230 resource5 / nr-repeats - 28.17)) / 28.17 + (19.10 - abs (item 235 resource5 / nr-repeats - 19.10)) / 19.10 +
  (12.12 - abs (item 240 resource5 / nr-repeats - 12.12)) / 12.12) / 48

    set indicator2f ((169.46 - abs (item 5 resource6 / nr-repeats - 169.46)) / 169.46 +
(169.15 - abs (item 10 resource6 / nr-repeats - 169.15)) / 169.15 + (168.49 - abs (item 15 resource6 / nr-repeats - 168.49)) / 168.49 +
  (167.66 - abs (item 20 resource6 / nr-repeats - 167.66)) / 167.66 + (167.56 - abs (item 25 resource6 / nr-repeats - 167.56)) / 167.56 +
  (169.05 - abs (item 30 resource6 / nr-repeats - 169.05)) / 169.05 + (170.29 - abs (item 35 resource6 / nr-repeats - 170.29)) / 170.29 +
  (170.51 - abs (item 40 resource6 / nr-repeats - 170.51)) / 170.51 + (170.93 - abs (item 45 resource6 / nr-repeats - 170.93)) / 170.93 +
  (170.61 - abs (item 50 resource6 / nr-repeats - 170.61)) / 170.61 + (171.66 - abs (item 55 resource6 / nr-repeats - 171.66)) / 171.66 +
  (172.39 - abs (item 60 resource6 / nr-repeats - 172.39)) / 172.39 + (172.46 - abs (item 65 resource6 / nr-repeats - 172.46)) / 172.46 +
  (172.24 - abs (item 70 resource6 / nr-repeats - 172.24)) / 172.24 + (171.95 - abs (item 75 resource6 / nr-repeats - 171.95)) / 171.95 +
  (171.83 - abs (item 80 resource6 / nr-repeats - 171.83)) / 171.83 + (173.73 - abs (item 85 resource6 / nr-repeats - 173.73)) / 173.73 +
  (175.20 - abs (item 90 resource6 / nr-repeats - 175.20)) / 175.20 + (175.85 - abs (item 95 resource6 / nr-repeats - 175.85)) / 175.85 +
  (177.32 - abs (item 100 resource6 / nr-repeats - 177.32)) / 177.32 + (178.44 - abs (item 105 resource6 / nr-repeats - 178.44)) / 178.44 +
  (178.46 - abs (item 110 resource6 / nr-repeats - 178.46)) / 178.46 + (178.59 - abs (item 115 resource6 / nr-repeats - 178.59)) / 178.59 +
  (178.05 - abs (item 120 resource6 / nr-repeats - 178.05)) / 178.05 + (177.71 - abs (item 125 resource6 / nr-repeats - 177.71)) / 177.71 +
  (177.71 - abs (item 130 resource6 / nr-repeats - 177.71)) / 177.71 + (176.20 - abs (item 135 resource6 / nr-repeats - 176.20)) / 176.20 +
  (174.44 - abs (item 140 resource6 / nr-repeats - 174.44)) / 174.44 + (173.56 - abs (item 145 resource6 / nr-repeats - 173.56)) / 173.56 +
  (171.56 - abs (item 150 resource6 / nr-repeats - 171.56)) / 171.56 + (168.93 - abs (item 155 resource6 / nr-repeats - 168.93)) / 168.93 +
  (165.54 - abs (item 160 resource6 / nr-repeats - 165.54)) / 165.54 + (161.88 - abs (item 165 resource6 / nr-repeats - 161.88)) / 161.88 +
  (157.78 - abs (item 170 resource6 / nr-repeats - 157.78)) / 157.78 + (153.05 - abs (item 175 resource6 / nr-repeats - 153.05)) / 153.05 +
  (146.93 - abs (item 180 resource6 / nr-repeats - 146.93)) / 146.93 + (138.59 - abs (item 185 resource6 / nr-repeats - 138.59)) / 138.59 +
  (129.12 - abs (item 190 resource6 / nr-repeats - 129.12)) / 129.12 + (118.76 - abs (item 195 resource6 / nr-repeats - 118.76)) / 118.76 +
  (106.73 - abs (item 200 resource6 / nr-repeats - 106.73)) / 106.73 + (92.51 - abs (item 205 resource6 / nr-repeats - 92.51)) / 92.51 +
  (78.17 - abs (item 210 resource6 / nr-repeats - 78.17)) / 78.17 + (63.34 - abs (item 215 resource6 / nr-repeats - 63.34)) / 63.34 +
  (48.29 - abs (item 220 resource6 / nr-repeats - 48.29)) / 48.29 + (35.20 - abs (item 225 resource6 / nr-repeats - 35.20)) / 35.20 +
  (23.02 - abs (item 230 resource6 / nr-repeats - 23.02)) / 23.02 + (12.54 - abs (item 235 resource6 / nr-repeats - 12.54)) / 12.54 +
  (5.41 - abs (item 240 resource6 / nr-repeats - 5.41)) / 5.41) / 48

    set indicator2g ((169.49 - abs (item 5 resource7 / nr-repeats - 169.49)) / 169.49 +
(168.61 - abs (item 10 resource7 / nr-repeats - 168.61)) / 168.61 + (167.07 - abs (item 15 resource7 / nr-repeats - 167.07)) / 167.07 +
  (166.05 - abs (item 20 resource7 / nr-repeats - 166.05)) / 166.05 + (165.41 - abs (item 25 resource7 / nr-repeats - 165.41)) / 165.41 +
  (164.02 - abs (item 30 resource7 / nr-repeats - 164.02)) / 164.02 + (163.95 - abs (item 35 resource7 / nr-repeats - 163.95)) / 163.95 +
  (162.83 - abs (item 40 resource7 / nr-repeats - 162.83)) / 162.83 + (161.80 - abs (item 45 resource7 / nr-repeats - 161.80)) / 161.80 +
  (161.17 - abs (item 50 resource7 / nr-repeats - 161.17)) / 161.17 + (160.15 - abs (item 55 resource7 / nr-repeats - 160.15)) / 160.15 +
  (160.24 - abs (item 60 resource7 / nr-repeats - 160.24)) / 160.24 + (160.51 - abs (item 65 resource7 / nr-repeats - 160.51)) / 160.51 +
  (161.17 - abs (item 70 resource7 / nr-repeats - 161.17)) / 161.17 + (160.93 - abs (item 75 resource7 / nr-repeats - 160.93)) / 160.93 +
  (161.10 - abs (item 80 resource7 / nr-repeats - 161.10)) / 161.10 + (162.46 - abs (item 85 resource7 / nr-repeats - 162.46)) / 162.46 +
  (163.95 - abs (item 90 resource7 / nr-repeats - 163.95)) / 163.95 + (163.71 - abs (item 95 resource7 / nr-repeats - 163.71)) / 163.71 +
  (163.88 - abs (item 100 resource7 / nr-repeats - 163.88)) / 163.88 + (163.56 - abs (item 105 resource7 / nr-repeats - 163.56)) / 163.56 +
  (163.05 - abs (item 110 resource7 / nr-repeats - 163.05)) / 163.05 + (161.73 - abs (item 115 resource7 / nr-repeats - 161.73)) / 161.73 +
  (160.66 - abs (item 120 resource7 / nr-repeats - 160.66)) / 160.66 + (159.17 - abs (item 125 resource7 / nr-repeats - 159.17)) / 159.17 +
  (158.54 - abs (item 130 resource7 / nr-repeats - 158.54)) / 158.54 + (157.73 - abs (item 135 resource7 / nr-repeats - 157.73)) / 157.73 +
  (157.02 - abs (item 140 resource7 / nr-repeats - 157.02)) / 157.02 + (155.37 - abs (item 145 resource7 / nr-repeats - 155.37)) / 155.37 +
  (153.12 - abs (item 150 resource7 / nr-repeats - 153.12)) / 153.12 + (150.71 - abs (item 155 resource7 / nr-repeats - 150.11)) / 150.11 +
  (148.68 - abs (item 160 resource7 / nr-repeats - 148.68)) / 148.68 + (143.76 - abs (item 165 resource7 / nr-repeats - 143.76)) / 143.76 +
  (138.41 - abs (item 170 resource7 / nr-repeats - 138.41)) / 138.41 + (131.80 - abs (item 175 resource7 / nr-repeats - 131.80)) / 131.80 +
  (124.17 - abs (item 180 resource7 / nr-repeats - 124.17)) / 124.17 + (114.78 - abs (item 185 resource7 / nr-repeats - 114.78)) / 114.78 +
  (105.34 - abs (item 190 resource7 / nr-repeats - 105.34)) / 105.34 + (94.56 - abs (item 195 resource7 / nr-repeats - 94.56)) / 94.56 +
  (83.37 - abs (item 200 resource7 / nr-repeats - 83.37)) / 83.37 + (71.34 - abs (item 205 resource7 / nr-repeats - 71.34)) / 71.34 +
  (58.46 - abs (item 210 resource7 / nr-repeats - 58.46)) / 58.46 + (44.85 - abs (item 215 resource7 / nr-repeats - 44.85)) / 44.85 +
  (33.61 - abs (item 220 resource7 / nr-repeats - 33.61)) / 33.61 + (24.07 - abs (item 225 resource7 / nr-repeats - 24.07)) / 24.07 +
  (14.66 - abs (item 230 resource7 / nr-repeats - 14.66)) / 14.66 + (6.95 - abs (item 235 resource7 / nr-repeats - 6.95)) / 6.95 +
  (3.05 - abs (item 240 resource7 / nr-repeats - 3.05)) / 3.05) / 48

    set indicator2h ((168.63 - abs (item 5 resource8 / nr-repeats - 168.63)) / 168.63 +
  (166.29 - abs (item 10 resource8 / nr-repeats - 166.29)) / 166.29 + (164.46 - abs (item 15 resource8 / nr-repeats - 164.46)) / 164.46 +
  (162.63 - abs (item 20 resource8 / nr-repeats - 162.63)) / 163.63 + (161.00 - abs (item 25 resource8 / nr-repeats - 161.00)) / 161.00 +
  (160.66 - abs (item 30 resource8 / nr-repeats - 160.66)) / 160.66 + (160.24 - abs (item 35 resource8 / nr-repeats - 160.24)) / 160.24 +
  (158.68 - abs (item 40 resource8 / nr-repeats - 158.68)) / 158.68 + (156.76 - abs (item 45 resource8 / nr-repeats - 156.76)) / 156.76 +
  (155.34 - abs (item 50 resource8 / nr-repeats - 155.34)) / 155.34 + (154.58 - abs (item 55 resource8 / nr-repeats - 154.58)) / 154.58 +
  (155.71 - abs (item 60 resource8 / nr-repeats - 155.71)) / 155.71 + (156.37 - abs (item 65 resource8 / nr-repeats - 156.37)) / 156.37 +
  (156.98 - abs (item 70 resource8 / nr-repeats - 156.98)) / 156.98 + (156.56 - abs (item 75 resource8 / nr-repeats - 156.56)) / 156.56 +
  (156.44 - abs (item 80 resource8 / nr-repeats - 156.44)) / 156.44 + (156.44 - abs (item 85 resource8 / nr-repeats - 156.44)) / 156.44 +
  (155.68 - abs (item 90 resource8 / nr-repeats - 155.68)) / 155.68 + (154.93 - abs (item 95 resource8 / nr-repeats - 154.93)) / 154.93 +
  (156.07 - abs (item 100 resource8 / nr-repeats - 156.07)) / 156.07 + (157.51 - abs (item 105 resource8 / nr-repeats - 157.51)) / 157.51 +
  (158.61 - abs (item 110 resource8 / nr-repeats - 158.61)) / 158.61 + (159.66 - abs (item 115 resource8 / nr-repeats - 159.66)) / 159.66 +
  (159.76 - abs (item 120 resource8 / nr-repeats - 159.76)) / 159.76 + (159.73 - abs (item 125 resource8 / nr-repeats - 159.73)) / 159.73 +
  (159.37 - abs (item 130 resource8 / nr-repeats - 159.37)) / 159.37 + (159.32 - abs (item 135 resource8 / nr-repeats - 159.32)) / 159.32 +
  (158.12 - abs (item 140 resource8 / nr-repeats - 158.12)) / 158.12 + (156.56 - abs (item 145 resource8 / nr-repeats - 156.56)) / 156.56 +
  (155.00 - abs (item 150 resource8 / nr-repeats - 155.00)) / 155.00 + (152.59 - abs (item 155 resource8 / nr-repeats - 152.59)) / 152.59 +
  (149.95 - abs (item 160 resource8 / nr-repeats - 149.95)) / 149.95 + (145.66 - abs (item 165 resource8 / nr-repeats - 145.66)) / 145.66 +
  (141.05 - abs (item 170 resource8 / nr-repeats - 141.05)) / 141.05 + (135.73 - abs (item 175 resource8 / nr-repeats - 135.73)) / 135.73 +
  (129.22 - abs (item 180 resource8 / nr-repeats - 129.22)) / 129.22 + (120.85 - abs (item 185 resource8 / nr-repeats - 120.85)) / 120.85 +
  (111.68 - abs (item 190 resource8 / nr-repeats - 111.68)) / 111.68 + (101.76 - abs (item 195 resource8 / nr-repeats - 101.76)) / 101.76 +
  (91.56 - abs (item 200 resource8 / nr-repeats - 91.56)) / 91.56 + (79.12 - abs (item 205 resource8 / nr-repeats - 79.12)) / 79.12 +
  (65.29 - abs (item 210 resource8 / nr-repeats - 65.29)) / 65.29 + (50.46 - abs (item 215 resource8 / nr-repeats - 50.46)) / 50.46 +
  (36.98 - abs (item 220 resource8 / nr-repeats - 36.98)) / 36.98 + (26.37 - abs (item 225 resource8 / nr-repeats - 26.37)) / 26.37 +
  (17.85 - abs (item 230 resource8 / nr-repeats - 17.85)) / 17.85 + (9.78 - abs (item 235 resource8 / nr-repeats - 9.78)) / 9.78 +
  (3.22 - abs (item 240 resource8 / nr-repeats - 3.22)) / 3.22) / 48

    set indicator2i ((167.88 - abs (item 5 resource9 / nr-repeats - 167.88)) / 167.88 +
  (164.51 - abs (item 10 resource9 / nr-repeats - 164.51)) / 164.51 + (161.63 - abs (item 15 resource9 / nr-repeats - 161.63)) / 161.63 +
  (160.61 - abs (item 20 resource9 / nr-repeats - 160.61)) / 160.61 + (159.07 - abs (item 25 resource9 / nr-repeats - 159.07)) / 159.07 +
  (157.88 - abs (item 30 resource9 / nr-repeats - 157.88)) / 157.88 + (156.10 - abs (item 35 resource9 / nr-repeats - 156.10)) / 156.10 +
  (154.71 - abs (item 40 resource9 / nr-repeats - 154.71)) / 154.71 + (153.00 - abs (item 45 resource9 / nr-repeats - 153.00)) / 153.00 +
  (151.68 - abs (item 50 resource9 / nr-repeats - 151.68)) / 151.68 + (151.37 - abs (item 55 resource9 / nr-repeats - 151.37)) / 151.37 +
  (150.46 - abs (item 60 resource9 / nr-repeats - 150.46)) / 150.46 + (149.61 - abs (item 65 resource9 / nr-repeats - 149.61)) / 149.61 +
  (149.02 - abs (item 70 resource9 / nr-repeats - 149.02)) / 149.02 + (149.41 - abs (item 75 resource9 / nr-repeats - 149.41)) / 149.41 +
  (149.63 - abs (item 80 resource9 / nr-repeats - 149.63)) / 149.63 + (149.59 - abs (item 85 resource9 / nr-repeats - 149.59)) / 149.59 +
  (149.32 - abs (item 90 resource9 / nr-repeats - 149.32)) / 149.32 + (149.51 - abs (item 95 resource9 / nr-repeats - 149.51)) / 149.51 +
  (150.32 - abs (item 100 resource9 / nr-repeats - 150.32)) / 150.32 + (151.29 - abs (item 105 resource9 / nr-repeats - 151.29)) / 151.29 +
  (151.76 - abs (item 110 resource9 / nr-repeats - 151.76)) / 151.76 + (151.98 - abs (item 115 resource9 / nr-repeats - 151.98)) / 151.98 +
  (152.41 - abs (item 120 resource9 / nr-repeats - 152.41)) / 152.41 + (152.05 - abs (item 125 resource9 / nr-repeats - 152.05)) / 152.05 +
  (152.44 - abs (item 130 resource9 / nr-repeats - 152.44)) / 152.22 + (151.85 - abs (item 135 resource9 / nr-repeats - 151.85)) / 151.85 +
  (150.05 - abs (item 140 resource9 / nr-repeats - 150.05)) / 150.05 + (148.83 - abs (item 145 resource9 / nr-repeats - 148.83)) / 148.83 +
  (146.66 - abs (item 150 resource9 / nr-repeats - 146.66)) / 146.66 + (144.34 - abs (item 155 resource9 / nr-repeats - 144.34)) / 144.34 +
  (140.83 - abs (item 160 resource9 / nr-repeats - 140.83)) / 140.83 + (137.49 - abs (item 165 resource9 / nr-repeats - 137.49)) / 137.49 +
  (133.95 - abs (item 170 resource9 / nr-repeats - 133.95)) / 133.95 + (129.71 - abs (item 175 resource9 / nr-repeats - 129.71)) / 129.71 +
  (123.00 - abs (item 180 resource9 / nr-repeats - 123.00)) / 123.00 + (114.46 - abs (item 185 resource9 / nr-repeats - 114.46)) / 114.46 +
  (106.90 - abs (item 190 resource9 / nr-repeats - 106.90)) / 106.90 + (98.32 - abs (item 195 resource9 / nr-repeats - 98.32)) / 98.32 +
  (89.27 - abs (item 200 resource9 / nr-repeats - 89.27)) / 89.27 + (77.59 - abs (item 205 resource9 / nr-repeats - 77.59)) / 77.59 +
  (65.56 - abs (item 210 resource9 / nr-repeats - 65.56)) / 65.56 + (52.83 - abs (item 215 resource9 / nr-repeats - 52.83)) / 52.83 +
  (40.51 - abs (item 220 resource9 / nr-repeats - 40.51)) / 40.51 + (29.00 - abs (item 225 resource9 / nr-repeats - 29.00)) / 29.00 +
  (19.10 - abs (item 230 resource9 / nr-repeats - 19.10)) / 19.10 + (9.61 - abs (item 235 resource9 / nr-repeats - 9.61)) / 9.61 +
  (4.10 - abs (item 240 resource9 / nr-repeats - 4.10)) / 4.10) / 48

  set fitness (indicator1a + indicator1b + indicator1c + indicator1d + indicator1e + indicator1f + indicator1g + indicator1h + indicator1i
             + indicator2a + indicator2b + indicator2c + indicator2d + indicator2e + indicator2f + indicator2g + indicator2h + indicator2i) / 18
end


;; Calculates the total number of tokens collected by all players.  Used for BehaviorSpace.
to-report total-tokens
  let t-tokens 0
  ask players
  [
    set t-tokens (t-tokens + t-count)
  ]
  report t-tokens
end

;; Grow new tokens based on p*n/8.
to grow-tokens
  ask patches [
   set nrn count neighbors with [count tokens-on self > 0]
  ]
  ask patches with [count turtles-here = 0]  ;; Grow tokens only on unoccupied cells (no tokens or players)
  [
    if ((random-float 1) < (p * nrn / 8))  ;; Regeneration probability p*n/8
    [
      sprout-tokens 1 [set color green]
    ]
  ]
end

;; players are limited to moving N, S, E, and W. players move a certain number of cells per call to this function, depending on their speed.
to move-players

  ask players [set nrmoves 0]
  repeat 10 [
    ask players [
      let playerself self
      ;direction
      if movement = "random" [
        let head random 4
        if head = 0 [set heading 0]
        if head = 1 [set heading 90]
        if head = 2 [set heading 180]
        if head = 3 [set heading 270]
      ]

      if movement = "greedy" [
        let greedytarget min-one-of tokens [distance myself]
        if greedytarget != nobody [
          face greedytarget
          if heading < 45 or heading >= 315 [set heading 0]
          if heading < 135 and heading >= 45 [set heading 90]
          if heading < 225 and heading >= 135 [set heading 180]
          if heading < 315 and heading >= 225 [set heading 270]
        ]
      ]
      let desiredspeed speed
      ifelse ((roundofgame > 3) and (ticks > timecrazy)) [][
        set desiredspeed speed - Trust * adjustmentrate * speed]

      ifelse random-float 1 < (desiredspeed / 10) [
         if movement = "cost-benefit" [
         ; calculate value for each token
          ask tokens [
            let tokendistance distance playerself
            let otheragentcloser 0
            let I 0
            if ([xcor] of playerself = xcor) or ([ycor] of playerself = ycor) [set I 1]
            set value (1 / (1 + tokendistance))
          ]
          if count tokens > 0 [
            let target max-one-of tokens [value]
            face target
            if heading < 45 or heading >= 315 [set heading 0]
            if heading < 135 and heading >= 45 [set heading 90]
            if heading < 225 and heading >= 135 [set heading 180]
            if heading < 315 and heading >= 225 [set heading 270]
          ]
        ]
        fd 1]
      [


        if (count tokens-here > 0) [
          ifelse (roundofgame > 3 and (ticks > timecrazy))
          [
          ;  if random-float 1 < p_harvest [
              if random-float 1 < 1 [
              set t-count t-count + 1
              ask one-of tokens-here [die]
            ]
          ] [
            if random-float 1 < (p_harvest * (1 - adjustmentrate_harvest * Trust) )  [
             set t-count t-count + 1
              ask one-of tokens-here [die]]]]]
      set nrmoves nrmoves + 1
    ]
  ]
  ask players [
    let difference 0
    let i number
    let j 1
    while [j < 5]
    [
      set difference difference + abs (([t-count] of one-of players with [number = i]) - ([t-count] of one-of players with [number = j])) / (1 + mean [t-count] of players)
      set j j + 1
    ]

    set Trust Trust - 0.333 * trust_inequality * difference
    if Trust < 0 [set Trust 0]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
233
11
605
384
-1
-1
14.0
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
25
0
25
1
1
1
ticks
30.0

PLOT
645
10
981
332
Tokens Remaining data
Seconds
Number of Tokens
0.0
240.0
0.0
200.0
false
true
"clear-plot\nplot 169" ""
PENS
"1" 1.0 2 -16777216 true "plot 169" "if ticks = 5 [plot 167]\nif ticks = 10 [plot 157]\nif ticks = 15  [plot 147]\nif ticks = 20  [plot 138]\nif ticks = 25  [plot 128]\nif ticks = 30  [plot 119]\nif ticks = 35  [plot 109]\nif ticks = 40  [plot 99]\nif ticks = 45  [plot 90]\nif ticks = 50  [plot 79]\nif ticks = 55  [plot 70]\nif ticks = 60  [plot 62]\nif ticks = 65  [plot 54]\nif ticks = 70  [plot 46]\nif ticks = 75  [plot 39]\nif ticks = 80  [plot 34]\nif ticks = 85  [plot 30]\nif ticks = 90  [plot 27]\nif ticks = 95  [plot 25]\nif ticks = 100 [plot 23]\nif ticks = 105 [plot 21]\nif ticks = 110  [plot 20]\nif ticks = 115  [plot 18]\nif ticks = 120  [plot 17]\nif ticks = 125  [plot 16]\nif ticks = 130  [plot 15]\nif ticks = 135  [plot 14]\nif ticks = 140  [plot 13]\nif ticks = 145  [plot 12]\nif ticks = 150  [plot 11]\nif ticks = 155  [plot 11]\nif ticks = 160  [plot 10]\nif ticks = 165 [plot 9]\nif ticks = 170 [plot 8]\nif ticks = 175 [plot 8]\nif ticks = 180 [plot 7]\nif ticks = 185 [plot 7]\nif ticks = 190 [plot 7]\nif ticks = 195 [plot 6]\nif ticks = 200 [plot 6]\nif ticks = 205 [plot 5]\nif ticks = 210 [plot 4]\nif ticks = 215 [plot 4]\nif ticks = 220 [plot 3]\nif ticks = 225 [plot 3]\nif ticks = 230 [plot 2]\nif ticks = 235 [plot 2]\nif ticks = 240 [plot 2]\nif (ticks mod 5 != 0) [plot (-1)]"
"2" 1.0 2 -7500403 true "" "if ticks = 5 [plot 161]\nif ticks = 10 [plot 148]\nif ticks = 15  [plot 137]\nif ticks = 20  [plot 125]\nif ticks = 25  [plot 114]\nif ticks = 30  [plot 103]\nif ticks = 35  [plot 92]\nif ticks = 40  [plot 80]\nif ticks = 45  [plot 69]\nif ticks = 50  [plot 59]\nif ticks = 55  [plot 50]\nif ticks = 60  [plot 42]\nif ticks = 65  [plot 35]\nif ticks = 70  [plot 31]\nif ticks = 75  [plot 27]\nif ticks = 80  [plot 22]\nif ticks = 85  [plot 18]\nif ticks = 90  [plot 16]\nif ticks = 95  [plot 14]\nif ticks = 100 [plot 13]\nif ticks = 105 [plot 12]\nif ticks = 110  [plot 11]\nif ticks = 115  [plot 10]\nif ticks = 120  [plot 9]\nif ticks = 125  [plot 9]\nif ticks = 130  [plot 9]\nif ticks = 135  [plot 9]\nif ticks = 140  [plot 8]\nif ticks = 145  [plot 8]\nif ticks = 150  [plot 8]\nif ticks = 155  [plot 7]\nif ticks = 160  [plot 7]\nif ticks = 165  [plot 7]\nif ticks = 170 [plot 6]\nif ticks = 175 [plot 6]\nif ticks = 180 [plot 6]\nif ticks = 185 [plot 5]\nif ticks = 190 [plot 5]\nif ticks = 195 [plot 5]\nif ticks = 200 [plot 4]\nif ticks = 205 [plot 4]\nif ticks = 210 [plot 4]\nif ticks = 215 [plot 3]\nif ticks = 220 [plot 3]\nif ticks = 225 [plot 2]\nif ticks = 230 [plot 1]\nif ticks = 235 [plot 1]\nif ticks = 240 [plot 0]\nif (ticks mod 5 != 0) [plot (-1)]"
"3" 1.0 2 -2674135 true "" "if ticks = 5 [plot 160]\nif ticks = 10 [plot 147]\nif ticks = 15  [plot 133]\nif ticks = 20  [plot 119]\nif ticks = 25  [plot 105]\nif ticks = 30  [plot 92]\nif ticks = 35  [plot 79]\nif ticks = 40  [plot 65]\nif ticks = 45  [plot 52]\nif ticks = 50  [plot 42]\nif ticks = 55  [plot 34]\nif ticks = 60  [plot 29]\nif ticks = 65  [plot 25]\nif ticks = 70  [plot 22]\nif ticks = 75  [plot 19]\nif ticks = 80  [plot 18]\nif ticks = 85  [plot 17]\nif ticks = 90  [plot 16]\nif ticks = 95  [plot 15]\nif ticks = 100 [plot 14]\nif ticks = 105 [plot 13]\nif ticks = 110  [plot 12]\nif ticks = 115  [plot 11]\nif ticks = 120  [plot 10]\nif ticks = 125  [plot 10]\nif ticks = 130  [plot 9]\nif ticks = 135  [plot 9]\nif ticks = 140  [plot 9]\nif ticks = 145  [plot 8]\nif ticks = 150  [plot 8]\nif ticks = 155  [plot 7]\nif ticks = 160  [plot 7]\nif ticks = 165 [plot 6]\nif ticks = 170 [plot 6]\nif ticks = 175 [plot 5]\nif ticks = 180 [plot 5]\nif ticks = 185 [plot 5]\nif ticks = 190 [plot 4]\nif ticks = 195 [plot 4]\nif ticks = 200 [plot 4]\nif ticks = 205 [plot 3]\nif ticks = 210 [plot 3]\nif ticks = 215 [plot 3]\nif ticks = 220 [plot 2]\nif ticks = 225 [plot 2]\nif ticks = 230 [plot 2]\nif ticks = 235 [plot 1]\nif ticks = 240 [plot 1]\nif (ticks mod 5 != 0) [plot (-1)]"
"4" 1.0 2 -955883 true "" "if ticks = 5 [plot 170]\nif ticks = 10 [plot 169]\nif ticks = 15  [plot 166]\nif ticks = 20  [plot 164]\nif ticks = 25  [plot 161]\nif ticks = 30  [plot 159]\nif ticks = 35  [plot 158]\nif ticks = 40  [plot 155]\nif ticks = 45  [plot 154]\nif ticks = 50  [plot 152]\nif ticks = 55  [plot 151]\nif ticks = 60  [plot 149]\nif ticks = 65  [plot 148]\nif ticks = 70  [plot 145]\nif ticks = 75  [plot 143]\nif ticks = 80  [plot 141]\nif ticks = 85  [plot 139]\nif ticks = 90  [plot 137]\nif ticks = 95  [plot 136]\nif ticks = 100 [plot 136]\nif ticks = 105 [plot 135]\nif ticks = 110  [plot 134]\nif ticks = 115  [plot 134]\nif ticks = 120  [plot 134]\nif ticks = 125  [plot 133]\nif ticks = 130  [plot 132]\nif ticks = 135  [plot 131]\nif ticks = 140  [plot 130]\nif ticks = 145  [plot 129]\nif ticks = 150  [plot 127]\nif ticks = 155  [plot 125]\nif ticks = 160  [plot 123]\nif ticks = 165 [plot 121]\nif ticks = 170 [plot 119]\nif ticks = 175 [plot 116]\nif ticks = 180 [plot 113]\nif ticks = 185 [plot 109]\nif ticks = 190 [plot 104]\nif ticks = 195 [plot 98]\nif ticks = 200 [plot 91]\nif ticks = 205 [plot 83]\nif ticks = 210 [plot 73]\nif ticks = 215 [plot 64]\nif ticks = 220 [plot 54]\nif ticks = 225 [plot 44]\nif ticks = 230 [plot 33]\nif ticks = 235 [plot 24]\nif ticks = 240 [plot 16]\nif (ticks mod 5 != 0) [plot (-1)]"
"5" 1.0 2 -6459832 true "" "if ticks = 5 [plot 171]\nif ticks = 10 [plot 170]\nif ticks = 15  [plot 167]\nif ticks = 20  [plot 166]\nif ticks = 25  [plot 166]\nif ticks = 30  [plot 166]\nif ticks = 35  [plot 165]\nif ticks = 40  [plot 165]\nif ticks = 45  [plot 167]\nif ticks = 50  [plot 167]\nif ticks = 55  [plot 167]\nif ticks = 60  [plot 168]\nif ticks = 65  [plot 168]\nif ticks = 70  [plot 169]\nif ticks = 75  [plot 169]\nif ticks = 80  [plot 169]\nif ticks = 85  [plot 170]\nif ticks = 90  [plot 171]\nif ticks = 95  [plot 172]\nif ticks = 100 [plot 172]\nif ticks = 105 [plot 172]\nif ticks = 110  [plot 171]\nif ticks = 115  [plot 170]\nif ticks = 120  [plot 169]\nif ticks = 125  [plot 167]\nif ticks = 130  [plot 165]\nif ticks = 135  [plot 165]\nif ticks = 140  [plot 163]\nif ticks = 145  [plot 162]\nif ticks = 150  [plot 159]\nif ticks = 155  [plot 157]\nif ticks = 160  [plot 154]\nif ticks = 165 [plot 152]\nif ticks = 170 [plot 148]\nif ticks = 175 [plot 143]\nif ticks = 180 [plot 137]\nif ticks = 185 [plot 129]\nif ticks = 190 [plot 122]\nif ticks = 195 [plot 112]\nif ticks = 200 [plot 101]\nif ticks = 205 [plot 89]\nif ticks = 210 [plot 77]\nif ticks = 215 [plot 65]\nif ticks = 220 [plot 52]\nif ticks = 225 [plot 40]\nif ticks = 230 [plot 28]\nif ticks = 235 [plot 19]\nif ticks = 240 [plot 12]\nif (ticks mod 5 != 0) [plot (-1)]"
"6" 1.0 2 -1184463 true "" "if ticks = 5 [plot 169]\nif ticks = 10 [plot 169]\nif ticks = 15  [plot 168]\nif ticks = 20  [plot 168]\nif ticks = 25  [plot 168]\nif ticks = 30  [plot 169]\nif ticks = 35  [plot 170]\nif ticks = 40  [plot 171]\nif ticks = 45  [plot 171]\nif ticks = 50  [plot 171]\nif ticks = 55  [plot 172]\nif ticks = 60  [plot 172]\nif ticks = 65  [plot 172]\nif ticks = 70  [plot 172]\nif ticks = 75  [plot 172]\nif ticks = 80  [plot 172]\nif ticks = 85  [plot 174]\nif ticks = 90  [plot 175]\nif ticks = 95  [plot 176]\nif ticks = 100 [plot 177]\nif ticks = 105 [plot 178]\nif ticks = 110  [plot 178]\nif ticks = 115  [plot 179]\nif ticks = 120  [plot 178]\nif ticks = 125  [plot 178]\nif ticks = 130  [plot 178]\nif ticks = 135  [plot 176]\nif ticks = 140  [plot 174]\nif ticks = 145  [plot 174]\nif ticks = 150  [plot 172]\nif ticks = 155  [plot 169]\nif ticks = 160  [plot 166]\nif ticks = 165 [plot 162]\nif ticks = 170 [plot 158]\nif ticks = 175 [plot 153]\nif ticks = 180 [plot 147]\nif ticks = 185 [plot 139]\nif ticks = 190 [plot 129]\nif ticks = 195 [plot 119]\nif ticks = 200 [plot 107]\nif ticks = 205 [plot 93]\nif ticks = 210 [plot 78]\nif ticks = 215 [plot 63]\nif ticks = 220 [plot 48]\nif ticks = 225 [plot 35]\nif ticks = 230 [plot 23]\nif ticks = 235 [plot 13]\nif ticks = 240 [plot 5]\nif (ticks mod 5 != 0) [plot (-1)]"
"7" 1.0 2 -10899396 true "" "if ticks = 5 [plot 169]\nif ticks = 10 [plot 169]\nif ticks = 15  [plot 167]\nif ticks = 20  [plot 166]\nif ticks = 25  [plot 165]\nif ticks = 30  [plot 164]\nif ticks = 35  [plot 164]\nif ticks = 40  [plot 163]\nif ticks = 45  [plot 162]\nif ticks = 50  [plot 161]\nif ticks = 55  [plot 160]\nif ticks = 60  [plot 160]\nif ticks = 65  [plot 161]\nif ticks = 70  [plot 161]\nif ticks = 75  [plot 161]\nif ticks = 80  [plot 161]\nif ticks = 85  [plot 162]\nif ticks = 90  [plot 164]\nif ticks = 95  [plot 164]\nif ticks = 100 [plot 164]\nif ticks = 105 [plot 164]\nif ticks = 110  [plot 163]\nif ticks = 115  [plot 162]\nif ticks = 120  [plot 161]\nif ticks = 125  [plot 159]\nif ticks = 130  [plot 159]\nif ticks = 135  [plot 158]\nif ticks = 140  [plot 157]\nif ticks = 145  [plot 155]\nif ticks = 150  [plot 153]\nif ticks = 155  [plot 151]\nif ticks = 160  [plot 147]\nif ticks = 165 [plot 144]\nif ticks = 170 [plot 138]\nif ticks = 175 [plot 132]\nif ticks = 180 [plot 124]\nif ticks = 185 [plot 115]\nif ticks = 190 [plot 105]\nif ticks = 195 [plot 95]\nif ticks = 200 [plot 83]\nif ticks = 205 [plot 71]\nif ticks = 210 [plot 58]\nif ticks = 215 [plot 45]\nif ticks = 220 [plot 34]\nif ticks = 225 [plot 24]\nif ticks = 230 [plot 15]\nif ticks = 235 [plot 7]\nif ticks = 240 [plot 3]\nif (ticks mod 5 != 0) [plot (-1)]"
"8" 1.0 2 -13840069 true "" "if ticks = 5 [plot 169]\nif ticks = 10 [plot 166]\nif ticks = 15  [plot 164]\nif ticks = 20  [plot 163]\nif ticks = 25  [plot 161]\nif ticks = 30  [plot 161]\nif ticks = 35  [plot 160]\nif ticks = 40  [plot 159]\nif ticks = 45  [plot 157]\nif ticks = 50  [plot 155]\nif ticks = 55  [plot 155]\nif ticks = 60  [plot 156]\nif ticks = 65  [plot 157]\nif ticks = 70  [plot 157]\nif ticks = 75  [plot 156]\nif ticks = 80  [plot 156]\nif ticks = 85  [plot 156]\nif ticks = 90  [plot 156]\nif ticks = 95  [plot 155]\nif ticks = 100 [plot 156]\nif ticks = 105 [plot 158]\nif ticks = 110  [plot 159]\nif ticks = 115  [plot 160]\nif ticks = 120  [plot 160]\nif ticks = 125  [plot 160]\nif ticks = 130  [plot 159]\nif ticks = 135  [plot 159]\nif ticks = 140  [plot 158]\nif ticks = 145  [plot 157]\nif ticks = 150  [plot 155]\nif ticks = 155  [plot 153]\nif ticks = 160  [plot 150]\nif ticks = 165 [plot 146]\nif ticks = 170 [plot 141]\nif ticks = 175 [plot 136]\nif ticks = 180 [plot 129]\nif ticks = 185 [plot 121]\nif ticks = 190 [plot 112]\nif ticks = 195 [plot 102]\nif ticks = 200 [plot 92]\nif ticks = 205 [plot 79]\nif ticks = 210 [plot 65]\nif ticks = 215 [plot 50]\nif ticks = 220 [plot 37]\nif ticks = 225 [plot 26]\nif ticks = 230 [plot 18]\nif ticks = 235 [plot 10]\nif ticks = 240 [plot 3]\nif (ticks mod 5 != 0) [plot (-1)]"
"9" 1.0 2 -14835848 true "" "if ticks = 5 [plot 168]\nif ticks = 10 [plot 165]\nif ticks = 15  [plot 162]\nif ticks = 20  [plot 161]\nif ticks = 25  [plot 159]\nif ticks = 30  [plot 158]\nif ticks = 35  [plot 156]\nif ticks = 40  [plot 155]\nif ticks = 45  [plot 153]\nif ticks = 50  [plot 152]\nif ticks = 55  [plot 151]\nif ticks = 60  [plot 150]\nif ticks = 65  [plot 150]\nif ticks = 70  [plot 149]\nif ticks = 75  [plot 149]\nif ticks = 80  [plot 150]\nif ticks = 85  [plot 150]\nif ticks = 90  [plot 149]\nif ticks = 95  [plot 150]\nif ticks = 100 [plot 150]\nif ticks = 105 [plot 151]\nif ticks = 110  [plot 152]\nif ticks = 115  [plot 152]\nif ticks = 120  [plot 152]\nif ticks = 125  [plot 152]\nif ticks = 130  [plot 152]\nif ticks = 135  [plot 152]\nif ticks = 140  [plot 150]\nif ticks = 145  [plot 149]\nif ticks = 150  [plot 147]\nif ticks = 155  [plot 144]\nif ticks = 160  [plot 141]\nif ticks = 165 [plot 137]\nif ticks = 170 [plot 134]\nif ticks = 175 [plot 130]\nif ticks = 180 [plot 123]\nif ticks = 185 [plot 114]\nif ticks = 190 [plot 107]\nif ticks = 195 [plot 98]\nif ticks = 200 [plot 89]\nif ticks = 205 [plot 76]\nif ticks = 210 [plot 66]\nif ticks = 215 [plot 53]\nif ticks = 220 [plot 41]\nif ticks = 225 [plot 29]\nif ticks = 230 [plot 19]\nif ticks = 235 [plot 10]\nif ticks = 240 [plot 4]\nif (ticks mod 5 != 0) [plot (-1)]"

SLIDER
10
55
165
88
maxspeed
maxspeed
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
639
342
859
375
B-prob-harvest
B-prob-harvest
0.4
1
0.89
0.01
1
NIL
HORIZONTAL

SLIDER
8
96
166
129
nr-repeats
nr-repeats
0
100
41.0
1
1
NIL
HORIZONTAL

BUTTON
13
189
99
222
NIL
manyruns
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
16
321
73
366
NIL
run-nr
17
1
11

BUTTON
113
197
176
230
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
119
260
196
293
NIL
onerun
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
8
132
146
177
movement
movement
"random" "greedy" "cost-benefit"
2

MONITOR
19
397
262
442
NIL
fitness
17
1
11

SLIDER
638
378
857
411
B-trust_inequality
B-trust_inequality
0
0.001
6.2E-4
0.00001
1
NIL
HORIZONTAL

PLOT
1413
23
1783
335
Trust
NIL
NIL
0.0
240.0
0.0
1.0
true
true
"clear-plot" ""
PENS
"1" 1.0 0 -16777216 true "" "if ticks > 0 [plot (item ticks trust1 / run-nr)]"
"2" 1.0 0 -7500403 true "" "if ticks > 0 [plot (item ticks trust2 / run-nr)]"
"3" 1.0 0 -2674135 true "" "if ticks > 0 [plot (item ticks trust3 / run-nr)]"
"4" 1.0 0 -955883 true "" "if ticks > 0 [plot (item ticks trust4 / run-nr)]"
"5" 1.0 0 -6459832 true "" "if ticks > 0 [plot (item ticks trust5 / run-nr)]"
"6" 1.0 0 -1184463 true "" "if ticks > 0 [plot (item ticks trust6 / run-nr)]"
"7" 1.0 0 -10899396 true "" "if ticks > 0 [plot (item ticks trust7 / run-nr)]"
"8" 1.0 0 -13840069 true "" "if ticks > 0 [plot (item ticks trust8 / run-nr)]"
"9" 1.0 0 -14835848 true "" "if ticks > 0 [plot (item ticks trust9 / run-nr)]"

SLIDER
637
414
859
447
B-sigma
B-sigma
0.5
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
637
450
858
483
B-timecrazy
B-timecrazy
120
240
195.0
1
1
NIL
HORIZONTAL

SLIDER
637
486
856
519
B-adjustmentrate
B-adjustmentrate
0
1
0.92
0.01
1
NIL
HORIZONTAL

SLIDER
636
521
856
554
B-adjustmentrate_harvest
B-adjustmentrate_harvest
0.5
1
0.71
0.01
1
NIL
HORIZONTAL

SLIDER
634
556
856
589
B-sigma2
B-sigma2
0.5
1
0.68
0.01
1
NIL
HORIZONTAL

PLOT
996
12
1378
332
Resource simulated
NIL
NIL
0.0
240.0
0.0
200.0
true
true
"clear-plot\nplot 169" ""
PENS
"1" 1.0 0 -16777216 true "" "if ticks > 0 [plot (item ticks resource1 / run-nr)]"
"2" 1.0 0 -7500403 true "" "if ticks > 0 [plot (item ticks resource2 / run-nr)]"
"3" 1.0 0 -2674135 true "" "if ticks > 0 [plot (item ticks resource3 / run-nr)]"
"4" 1.0 0 -955883 true "" "if ticks > 0 [plot (item ticks resource4 / run-nr)]"
"5" 1.0 0 -6459832 true "" "if ticks > 0 [plot (item ticks resource5 / run-nr)]"
"6" 1.0 0 -1184463 true "" "if ticks > 0 [plot (item ticks resource6 / run-nr)]"
"7" 1.0 0 -10899396 true "" "if ticks > 0 [plot (item ticks resource7 / run-nr)]"
"8" 1.0 0 -13840069 true "" "if ticks > 0 [plot (item ticks resource8 / run-nr)]"
"9" 1.0 0 -14835848 true "" "if ticks > 0 [plot (item ticks resource9 / run-nr)]"

SLIDER
899
342
1098
375
A-prob-harvest
A-prob-harvest
0
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
897
378
1100
411
A-trust_inequality
A-trust_inequality
0
0.001
0.0
0.00001
1
NIL
HORIZONTAL

SLIDER
895
415
1098
448
A-sigma
A-sigma
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
893
453
1097
486
A-timecrazy
A-timecrazy
120
240
150.0
1
1
NIL
HORIZONTAL

SLIDER
890
490
1100
523
A-adjustmentrate
A-adjustmentrate
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
886
525
1102
558
A-adjustmentrate_harvest
A-adjustmentrate_harvest
0.5
1
0.51
0.01
1
NIL
HORIZONTAL

SLIDER
894
561
1102
594
A-sigma2
A-sigma2
0.5
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
191
462
363
495
shareA
shareA
0
1
0.5
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="false">
    <setup>manyruns</setup>
    <timeLimit steps="1"/>
    <metric>fitness</metric>
    <metric>mean collected1</metric>
    <metric>mean collected2</metric>
    <metric>mean collected3</metric>
    <metric>mean collected4</metric>
    <metric>mean collected5</metric>
    <metric>mean collected6</metric>
    <metric>mean collected7</metric>
    <metric>mean collected8</metric>
    <metric>mean collected9</metric>
    <enumeratedValueSet variable="p1-input">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p2-input">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p3-input">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement">
      <value value="&quot;cost-benefit&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-harvest">
      <value value="0.89"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-repeats">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxspeed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdevprob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdevnoise">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust_inequality">
      <value value="1.95E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.89"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma2">
      <value value="0.63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="timecrazy">
      <value value="195"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adjustmentrate">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adjustmentrate_harvest">
      <value value="0.71"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="100" runMetricsEveryStep="true">
    <setup>manyruns</setup>
    <timeLimit steps="1"/>
    <metric>fitness</metric>
    <metric>mean collected1</metric>
    <metric>mean collected2</metric>
    <metric>mean collected3</metric>
    <metric>mean collected4</metric>
    <metric>mean collected5</metric>
    <metric>mean collected6</metric>
    <metric>mean collected7</metric>
    <metric>mean collected8</metric>
    <metric>mean collected9</metric>
    <metric>item 5 resource1</metric>
    <metric>item 10 resource1</metric>
    <metric>item 15 resource1</metric>
    <metric>item 20 resource1</metric>
    <metric>item 25 resource1</metric>
    <metric>item 30 resource1</metric>
    <metric>item 35 resource1</metric>
    <metric>item 40 resource1</metric>
    <metric>item 45 resource1</metric>
    <metric>item 50 resource1</metric>
    <metric>item 55 resource1</metric>
    <metric>item 60 resource1</metric>
    <metric>item 65 resource1</metric>
    <metric>item 70 resource1</metric>
    <metric>item 75 resource1</metric>
    <metric>item 80 resource1</metric>
    <metric>item 85 resource1</metric>
    <metric>item 90 resource1</metric>
    <metric>item 95 resource1</metric>
    <metric>item 100 resource1</metric>
    <metric>item 105 resource1</metric>
    <metric>item 110 resource1</metric>
    <metric>item 115 resource1</metric>
    <metric>item 120 resource1</metric>
    <metric>item 125 resource1</metric>
    <metric>item 130 resource1</metric>
    <metric>item 135 resource1</metric>
    <metric>item 140 resource1</metric>
    <metric>item 145 resource1</metric>
    <metric>item 150 resource1</metric>
    <metric>item 155 resource1</metric>
    <metric>item 160 resource1</metric>
    <metric>item 165 resource1</metric>
    <metric>item 170 resource1</metric>
    <metric>item 175 resource1</metric>
    <metric>item 180 resource1</metric>
    <metric>item 185 resource1</metric>
    <metric>item 190 resource1</metric>
    <metric>item 195 resource1</metric>
    <metric>item 200 resource1</metric>
    <metric>item 205 resource1</metric>
    <metric>item 210 resource1</metric>
    <metric>item 215 resource1</metric>
    <metric>item 220 resource1</metric>
    <metric>item 225 resource1</metric>
    <metric>item 230 resource1</metric>
    <metric>item 235 resource1</metric>
    <metric>item 240 resource1</metric>
    <metric>item 5 resource2</metric>
    <metric>item 10 resource2</metric>
    <metric>item 15 resource2</metric>
    <metric>item 20 resource2</metric>
    <metric>item 25 resource2</metric>
    <metric>item 30 resource2</metric>
    <metric>item 35 resource2</metric>
    <metric>item 40 resource2</metric>
    <metric>item 45 resource2</metric>
    <metric>item 50 resource2</metric>
    <metric>item 55 resource2</metric>
    <metric>item 60 resource2</metric>
    <metric>item 65 resource2</metric>
    <metric>item 70 resource2</metric>
    <metric>item 75 resource2</metric>
    <metric>item 80 resource2</metric>
    <metric>item 85 resource2</metric>
    <metric>item 90 resource2</metric>
    <metric>item 95 resource2</metric>
    <metric>item 100 resource2</metric>
    <metric>item 105 resource2</metric>
    <metric>item 110 resource2</metric>
    <metric>item 115 resource2</metric>
    <metric>item 120 resource2</metric>
    <metric>item 125 resource2</metric>
    <metric>item 130 resource2</metric>
    <metric>item 135 resource2</metric>
    <metric>item 140 resource2</metric>
    <metric>item 145 resource2</metric>
    <metric>item 150 resource2</metric>
    <metric>item 155 resource2</metric>
    <metric>item 160 resource2</metric>
    <metric>item 165 resource2</metric>
    <metric>item 170 resource2</metric>
    <metric>item 175 resource2</metric>
    <metric>item 180 resource2</metric>
    <metric>item 185 resource2</metric>
    <metric>item 190 resource2</metric>
    <metric>item 195 resource2</metric>
    <metric>item 200 resource2</metric>
    <metric>item 205 resource2</metric>
    <metric>item 210 resource2</metric>
    <metric>item 215 resource2</metric>
    <metric>item 220 resource2</metric>
    <metric>item 225 resource2</metric>
    <metric>item 230 resource2</metric>
    <metric>item 235 resource2</metric>
    <metric>item 240 resource2</metric>
    <metric>item 5 resource3</metric>
    <metric>item 10 resource3</metric>
    <metric>item 15 resource3</metric>
    <metric>item 20 resource3</metric>
    <metric>item 25 resource3</metric>
    <metric>item 30 resource3</metric>
    <metric>item 35 resource3</metric>
    <metric>item 40 resource3</metric>
    <metric>item 45 resource3</metric>
    <metric>item 50 resource3</metric>
    <metric>item 55 resource3</metric>
    <metric>item 60 resource3</metric>
    <metric>item 65 resource3</metric>
    <metric>item 70 resource3</metric>
    <metric>item 75 resource3</metric>
    <metric>item 80 resource3</metric>
    <metric>item 85 resource3</metric>
    <metric>item 90 resource3</metric>
    <metric>item 95 resource3</metric>
    <metric>item 100 resource3</metric>
    <metric>item 105 resource3</metric>
    <metric>item 110 resource3</metric>
    <metric>item 115 resource3</metric>
    <metric>item 120 resource3</metric>
    <metric>item 125 resource3</metric>
    <metric>item 130 resource3</metric>
    <metric>item 135 resource3</metric>
    <metric>item 140 resource3</metric>
    <metric>item 145 resource3</metric>
    <metric>item 150 resource3</metric>
    <metric>item 155 resource3</metric>
    <metric>item 160 resource3</metric>
    <metric>item 165 resource3</metric>
    <metric>item 170 resource3</metric>
    <metric>item 175 resource3</metric>
    <metric>item 180 resource3</metric>
    <metric>item 185 resource3</metric>
    <metric>item 190 resource3</metric>
    <metric>item 195 resource3</metric>
    <metric>item 200 resource3</metric>
    <metric>item 205 resource3</metric>
    <metric>item 210 resource3</metric>
    <metric>item 215 resource3</metric>
    <metric>item 220 resource3</metric>
    <metric>item 225 resource3</metric>
    <metric>item 230 resource3</metric>
    <metric>item 235 resource3</metric>
    <metric>item 240 resource3</metric>
    <metric>item 5 resource4</metric>
    <metric>item 10 resource4</metric>
    <metric>item 15 resource4</metric>
    <metric>item 20 resource4</metric>
    <metric>item 25 resource4</metric>
    <metric>item 30 resource4</metric>
    <metric>item 35 resource4</metric>
    <metric>item 40 resource4</metric>
    <metric>item 45 resource4</metric>
    <metric>item 50 resource4</metric>
    <metric>item 55 resource4</metric>
    <metric>item 60 resource4</metric>
    <metric>item 65 resource4</metric>
    <metric>item 70 resource4</metric>
    <metric>item 75 resource4</metric>
    <metric>item 80 resource4</metric>
    <metric>item 85 resource4</metric>
    <metric>item 90 resource4</metric>
    <metric>item 95 resource4</metric>
    <metric>item 100 resource4</metric>
    <metric>item 105 resource4</metric>
    <metric>item 110 resource4</metric>
    <metric>item 115 resource4</metric>
    <metric>item 120 resource4</metric>
    <metric>item 125 resource4</metric>
    <metric>item 130 resource4</metric>
    <metric>item 135 resource4</metric>
    <metric>item 140 resource4</metric>
    <metric>item 145 resource4</metric>
    <metric>item 150 resource4</metric>
    <metric>item 155 resource4</metric>
    <metric>item 160 resource4</metric>
    <metric>item 165 resource4</metric>
    <metric>item 170 resource4</metric>
    <metric>item 175 resource4</metric>
    <metric>item 180 resource4</metric>
    <metric>item 185 resource4</metric>
    <metric>item 190 resource4</metric>
    <metric>item 195 resource4</metric>
    <metric>item 200 resource4</metric>
    <metric>item 205 resource4</metric>
    <metric>item 210 resource4</metric>
    <metric>item 215 resource4</metric>
    <metric>item 220 resource4</metric>
    <metric>item 225 resource4</metric>
    <metric>item 230 resource4</metric>
    <metric>item 235 resource4</metric>
    <metric>item 240 resource4</metric>
    <metric>item 5 resource5</metric>
    <metric>item 10 resource5</metric>
    <metric>item 15 resource5</metric>
    <metric>item 20 resource5</metric>
    <metric>item 25 resource5</metric>
    <metric>item 30 resource5</metric>
    <metric>item 35 resource5</metric>
    <metric>item 40 resource5</metric>
    <metric>item 45 resource5</metric>
    <metric>item 50 resource5</metric>
    <metric>item 55 resource5</metric>
    <metric>item 60 resource5</metric>
    <metric>item 65 resource5</metric>
    <metric>item 70 resource5</metric>
    <metric>item 75 resource5</metric>
    <metric>item 80 resource5</metric>
    <metric>item 85 resource5</metric>
    <metric>item 90 resource5</metric>
    <metric>item 95 resource5</metric>
    <metric>item 100 resource5</metric>
    <metric>item 105 resource5</metric>
    <metric>item 110 resource5</metric>
    <metric>item 115 resource5</metric>
    <metric>item 120 resource5</metric>
    <metric>item 125 resource5</metric>
    <metric>item 130 resource5</metric>
    <metric>item 135 resource5</metric>
    <metric>item 140 resource5</metric>
    <metric>item 145 resource5</metric>
    <metric>item 150 resource5</metric>
    <metric>item 155 resource5</metric>
    <metric>item 160 resource5</metric>
    <metric>item 165 resource5</metric>
    <metric>item 170 resource5</metric>
    <metric>item 175 resource5</metric>
    <metric>item 180 resource5</metric>
    <metric>item 185 resource5</metric>
    <metric>item 190 resource5</metric>
    <metric>item 195 resource5</metric>
    <metric>item 200 resource5</metric>
    <metric>item 205 resource5</metric>
    <metric>item 210 resource5</metric>
    <metric>item 215 resource5</metric>
    <metric>item 220 resource5</metric>
    <metric>item 225 resource5</metric>
    <metric>item 230 resource5</metric>
    <metric>item 235 resource5</metric>
    <metric>item 240 resource5</metric>
    <metric>item 5 resource6</metric>
    <metric>item 10 resource6</metric>
    <metric>item 15 resource6</metric>
    <metric>item 20 resource6</metric>
    <metric>item 25 resource6</metric>
    <metric>item 30 resource6</metric>
    <metric>item 35 resource6</metric>
    <metric>item 40 resource6</metric>
    <metric>item 45 resource6</metric>
    <metric>item 50 resource6</metric>
    <metric>item 55 resource6</metric>
    <metric>item 60 resource6</metric>
    <metric>item 65 resource6</metric>
    <metric>item 70 resource6</metric>
    <metric>item 75 resource6</metric>
    <metric>item 80 resource6</metric>
    <metric>item 85 resource6</metric>
    <metric>item 90 resource6</metric>
    <metric>item 95 resource6</metric>
    <metric>item 100 resource6</metric>
    <metric>item 105 resource6</metric>
    <metric>item 110 resource6</metric>
    <metric>item 115 resource6</metric>
    <metric>item 120 resource6</metric>
    <metric>item 125 resource6</metric>
    <metric>item 130 resource6</metric>
    <metric>item 135 resource6</metric>
    <metric>item 140 resource6</metric>
    <metric>item 145 resource6</metric>
    <metric>item 150 resource6</metric>
    <metric>item 155 resource6</metric>
    <metric>item 160 resource6</metric>
    <metric>item 165 resource6</metric>
    <metric>item 170 resource6</metric>
    <metric>item 175 resource6</metric>
    <metric>item 180 resource6</metric>
    <metric>item 185 resource6</metric>
    <metric>item 190 resource6</metric>
    <metric>item 195 resource6</metric>
    <metric>item 200 resource6</metric>
    <metric>item 205 resource6</metric>
    <metric>item 210 resource6</metric>
    <metric>item 215 resource6</metric>
    <metric>item 220 resource6</metric>
    <metric>item 225 resource6</metric>
    <metric>item 230 resource6</metric>
    <metric>item 235 resource6</metric>
    <metric>item 240 resource6</metric>
    <metric>item 5 resource7</metric>
    <metric>item 10 resource7</metric>
    <metric>item 15 resource7</metric>
    <metric>item 20 resource7</metric>
    <metric>item 25 resource7</metric>
    <metric>item 30 resource7</metric>
    <metric>item 35 resource7</metric>
    <metric>item 40 resource7</metric>
    <metric>item 45 resource7</metric>
    <metric>item 50 resource7</metric>
    <metric>item 55 resource7</metric>
    <metric>item 60 resource7</metric>
    <metric>item 65 resource7</metric>
    <metric>item 70 resource7</metric>
    <metric>item 75 resource7</metric>
    <metric>item 80 resource7</metric>
    <metric>item 85 resource7</metric>
    <metric>item 90 resource7</metric>
    <metric>item 95 resource7</metric>
    <metric>item 100 resource7</metric>
    <metric>item 105 resource7</metric>
    <metric>item 110 resource7</metric>
    <metric>item 115 resource7</metric>
    <metric>item 120 resource7</metric>
    <metric>item 125 resource7</metric>
    <metric>item 130 resource7</metric>
    <metric>item 135 resource7</metric>
    <metric>item 140 resource7</metric>
    <metric>item 145 resource7</metric>
    <metric>item 150 resource7</metric>
    <metric>item 155 resource7</metric>
    <metric>item 160 resource7</metric>
    <metric>item 165 resource7</metric>
    <metric>item 170 resource7</metric>
    <metric>item 175 resource7</metric>
    <metric>item 180 resource7</metric>
    <metric>item 185 resource7</metric>
    <metric>item 190 resource7</metric>
    <metric>item 195 resource7</metric>
    <metric>item 200 resource7</metric>
    <metric>item 205 resource7</metric>
    <metric>item 210 resource7</metric>
    <metric>item 215 resource7</metric>
    <metric>item 220 resource7</metric>
    <metric>item 225 resource7</metric>
    <metric>item 230 resource7</metric>
    <metric>item 235 resource7</metric>
    <metric>item 240 resource7</metric>
    <metric>item 5 resource8</metric>
    <metric>item 10 resource8</metric>
    <metric>item 15 resource8</metric>
    <metric>item 20 resource8</metric>
    <metric>item 25 resource8</metric>
    <metric>item 30 resource8</metric>
    <metric>item 35 resource8</metric>
    <metric>item 40 resource8</metric>
    <metric>item 45 resource8</metric>
    <metric>item 50 resource8</metric>
    <metric>item 55 resource8</metric>
    <metric>item 60 resource8</metric>
    <metric>item 65 resource8</metric>
    <metric>item 70 resource8</metric>
    <metric>item 75 resource8</metric>
    <metric>item 80 resource8</metric>
    <metric>item 85 resource8</metric>
    <metric>item 90 resource8</metric>
    <metric>item 95 resource8</metric>
    <metric>item 100 resource8</metric>
    <metric>item 105 resource8</metric>
    <metric>item 110 resource8</metric>
    <metric>item 115 resource8</metric>
    <metric>item 120 resource8</metric>
    <metric>item 125 resource8</metric>
    <metric>item 130 resource8</metric>
    <metric>item 135 resource8</metric>
    <metric>item 140 resource8</metric>
    <metric>item 145 resource8</metric>
    <metric>item 150 resource8</metric>
    <metric>item 155 resource8</metric>
    <metric>item 160 resource8</metric>
    <metric>item 165 resource8</metric>
    <metric>item 170 resource8</metric>
    <metric>item 175 resource8</metric>
    <metric>item 180 resource8</metric>
    <metric>item 185 resource8</metric>
    <metric>item 190 resource8</metric>
    <metric>item 195 resource8</metric>
    <metric>item 200 resource8</metric>
    <metric>item 205 resource8</metric>
    <metric>item 210 resource8</metric>
    <metric>item 215 resource8</metric>
    <metric>item 220 resource8</metric>
    <metric>item 225 resource8</metric>
    <metric>item 230 resource8</metric>
    <metric>item 235 resource8</metric>
    <metric>item 240 resource8</metric>
    <metric>item 5 resource9</metric>
    <metric>item 10 resource9</metric>
    <metric>item 15 resource9</metric>
    <metric>item 20 resource9</metric>
    <metric>item 25 resource9</metric>
    <metric>item 30 resource9</metric>
    <metric>item 35 resource9</metric>
    <metric>item 40 resource9</metric>
    <metric>item 45 resource9</metric>
    <metric>item 50 resource9</metric>
    <metric>item 55 resource9</metric>
    <metric>item 60 resource9</metric>
    <metric>item 65 resource9</metric>
    <metric>item 70 resource9</metric>
    <metric>item 75 resource9</metric>
    <metric>item 80 resource9</metric>
    <metric>item 85 resource9</metric>
    <metric>item 90 resource9</metric>
    <metric>item 95 resource9</metric>
    <metric>item 100 resource9</metric>
    <metric>item 105 resource9</metric>
    <metric>item 110 resource9</metric>
    <metric>item 115 resource9</metric>
    <metric>item 120 resource9</metric>
    <metric>item 125 resource9</metric>
    <metric>item 130 resource9</metric>
    <metric>item 135 resource9</metric>
    <metric>item 140 resource9</metric>
    <metric>item 145 resource9</metric>
    <metric>item 150 resource9</metric>
    <metric>item 155 resource9</metric>
    <metric>item 160 resource9</metric>
    <metric>item 165 resource9</metric>
    <metric>item 170 resource9</metric>
    <metric>item 175 resource9</metric>
    <metric>item 180 resource9</metric>
    <metric>item 185 resource9</metric>
    <metric>item 190 resource9</metric>
    <metric>item 195 resource9</metric>
    <metric>item 200 resource9</metric>
    <metric>item 205 resource9</metric>
    <metric>item 210 resource9</metric>
    <metric>item 215 resource9</metric>
    <metric>item 220 resource9</metric>
    <metric>item 225 resource9</metric>
    <metric>item 230 resource9</metric>
    <metric>item 235 resource9</metric>
    <metric>item 240 resource9</metric>
    <enumeratedValueSet variable="p1-input">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p2-input">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p3-input">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement">
      <value value="&quot;cost-benefit&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-harvest">
      <value value="0.89"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-repeats">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxspeed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdevprob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdevnoise">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust_inequality">
      <value value="1.9E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.89"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma2">
      <value value="0.63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="timecrazy">
      <value value="195"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adjustmentrate">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adjustmentrate_harvest">
      <value value="0.71"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment3" repetitions="30" runMetricsEveryStep="false">
    <setup>manyruns</setup>
    <timeLimit steps="1"/>
    <metric>fitness</metric>
    <metric>mean collected1</metric>
    <metric>mean collected2</metric>
    <metric>mean collected3</metric>
    <metric>mean collected4</metric>
    <metric>mean collected5</metric>
    <metric>mean collected6</metric>
    <metric>mean collected7</metric>
    <metric>mean collected8</metric>
    <metric>mean collected9</metric>
    <steppedValueSet variable="p1-input" first="0" step="0.05" last="1"/>
    <enumeratedValueSet variable="p2-input">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p3-input">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement">
      <value value="&quot;cost-benefit&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-harvest">
      <value value="0.86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-repeats">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxspeed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdevprob">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stdevnoise">
      <value value="0.018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust_inequality">
      <value value="1.5E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.88"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma2">
      <value value="0.62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="timecrazy">
      <value value="193"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adjustmentrate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adjustmentrate_harvest">
      <value value="0.9"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="test1" repetitions="2" runMetricsEveryStep="true">
    <setup>onerun</setup>
    <timeLimit steps="2161"/>
    <enumeratedValueSet variable="trust_inequality">
      <value value="1.9E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement">
      <value value="&quot;cost-benefit&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.89"/>
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="timecrazy">
      <value value="195"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-harvest">
      <value value="0.89"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adjustmentrate">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-repeats">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adjustmentrate_harvest">
      <value value="0.71"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma2">
      <value value="0.63"/>
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxspeed">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
