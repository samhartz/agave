CAM

Data Sonification tool for monome norns using CAM photosynthetic model.

Demonstration: Not avaiable yet

Lines thread: coming soon

Overview

The model synthesizes sound based on the parameters malic acid content and circadian order from photosynthetic models of CAM (Crassulacean Acid Metabolism) plants. built on an adapted Farquhar et al. model parameterized for _Agave Tequila_. The original model was adapted from Python to Lua for process implementation on the Monome Norns platform. The Norns uses a combination of Lua scripts and Supercollider scripts to achieve sound creation from model outputs. Features live controlable temperature parameter.

The Sonification requires all the lua and supercollider scipts to function and the bifurcation requires the lua and attached text files. To run as is, download all parts and install on Norns for use. 

The changes in temperature will only affect the first three pages at current implementation. This maybe changed later but currently the bifurcation script is somewhat isolated from the sonification elements. 

Controls
    
  Encoder 1: Changes Display screen

  Encoder 2: No function 

  Encoder 3: Changes Temperature Settings along 5 pre-set temperatures

Screens
There are four screens available to view on the Norns device while sonification experiment plays.
  
  1. Malic Acid over time display
  
  2. Circadian Order over time display
  
  3. Malic Acid vs Circadian Order
  
  4. Bifurcation Diagram Temperature vs Circadian Order

Authors
Original model by Samantha Hartzell, Mark Bartlett, and Amilcare Porporato
Data Sonification scripts by Jonathan Snyder and Duncan Turley

References
Model is referenced in paper:
Hartzell, Samantha, et al. “Nonlinear Dynamics of the CAM Circadian Rhythm in Response to Environmental Forcing.” Theoretical Biology, vol. 368, 7 Mar. 2015, pp. 83–94, https://doi.org/10.1016/j.jtbi.2014.12.010. Accessed 17 May 2023.