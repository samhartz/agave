-- CAM
-- version0.5@duturley
-- <lines link>
--
-- <tag line>
--;r
-- <instructions go here

-- lines starting with "--" are comments, they don't get executed
mu = require('musicutil')
s = require 'sequins'

--CAM = include('lib/CAM_model_fixed')
CAM = include('lib/CAM_model_chaos')
pixel = include('lib/pixel')
control = include('lib/control')

BP = 10 -- BP = brightness of pixel variable for changing if needed
--steps = 1
i = 1   -- i is used to establish the beginning value of the loops
snazzypage = 1
malictime = 0
circadiantime = 0

state_table = {
  x={}, 
  y={}
  --z={},
}

engine.name = 'CAMSounds'

-- system clock tick
-- this function is started by init() and runs forever
-- if the sequence is on, it steps forward on each clock tick
-- tempo is controlled via the global clock, which can be set in the PARAMETERS menu 
-- tick = function()
--   while true do
--    --clock.sync(1)
--    clock.sleep(1/10)
--    table.insert(state_table.x, mn)
--    table.insert(state_table.y, z)
--    --table.insert(state_table.z, lorenz.state[3])
--   end
-- end


--------------------------------------------------------------------------------
-- init runs first!
function init()
  -- configure stuff
engine.algoName('sinfmlp')
engine.gain(3)
engine.release(7)
engine.attack(0.1)
engine.pw(7)
local min_chord = mu.generate_chord(60, "minor")
min_chord_seq = s{table.unpack(min_chord)}

local maj_chord = mu.generate_chord(69, "major")
maj_chord_seq = s{table.unpack(maj_chord)}
  -- clock.run(tick)       -- start the sequencer

  clock.run(function()  -- redraw the screen and grid at 15fps
    -- need to make it so this i loop runs for the length of time that steps function calculates
    while i > 0 do    -- for iteration to be non permanent and work with chaos equation
      clock.sleep(1/15)


      tl = ta       -- assume leaf temp equal to atmospheric

      tempC = ta - 273. -- convert to K
      psat = A_SAT*math.exp((B_SAT*(tempC))/(C_SAT + tempC)) -- saturated vapor pressure in Pa
      qa = 0.622*rh/100.*psat/P_ATM --needs to be in kg/kg, specific humidity in atmosphere


      breath_of_the_plant(phi)

      table.insert(state_table.x, mn)
      table.insert(state_table.y, z)
   
      malic_content()
      if i % 15 == 0 then
        cirdian_rythm()
      end
      redraw()
      i = i + 1
    end
  end)

  norns.enc.sens(1,8)   -- set the knob sensitivity
  norns.enc.sens(2,4)

  params:add_option("temp_setting", "temp setting", {"285","289","293","297","301"}, 1)
  params:set_action ("temp_setting", function(x) 
    print(x) 
    if x==1 then
      ta = 285
    elseif x==2 then
      ta = 289
    elseif x==3 then
      ta = 293
    elseif x==4 then
      ta = 297
    elseif x==5 then
      ta = 301
    end
  end)


end

--------------------------------------------------------------------------------
-- encoder
function enc(n, delta)
  screen.clear()
  if n==1 then
    --Change the page
    snazzypage = util.clamp(snazzypage + delta,1,3)

  elseif n==2 then
    -- E2 do something
    print("encoder: ", n,delta)

  elseif n==3 then
    -- E3 do something
    local temp_setting = params:get("temp_setting")
    local new_setting = util.clamp(temp_setting+delta,1,5)
    params:set("temp_setting",new_setting)
  end
end

--------------------------------------------------------------------------------
-- key
function key(n,z)
  if n==3 and z==1 then
    -- K3, on key down do something

  elseif n==2 and z==1 then
    -- K2, on key down do something

  end
end

--------------------------------------------------------------------------------
-- Add command section
function malic_content()
  local scalez = util.linexp(0, 1, 40, 3000, z)
  engine.amp(mn)
  engine.z(scalez)
 --generate_chord (root_num, chord_type[, inversion])
  -- {name = "Minor Major 7", alt_names = {"MinMaj7"}, intervals = {0, 3, 7, 11}},
 -- {name = "Minor", alt_names = {"Min"}, intervals = {0, 3, 7}},
  --{name = "Minor 6", alt_names = {"Min6"}, intervals = {0, 3, 7, 9}},
 -- {name = "Minor 7", alt_names = {"Min7"}, intervals = {0, 3, 7, 10}},
 -- {name = "Minor 69", alt_names = {"Min69"}, intervals = {0, 3, 7, 9, 14}},
 -- {name = "Minor 9", alt_names = {"Min9"}, intervals = {0, 3, 7, 10, 14}},
 -- {name = "Minor 11", alt_names = {"Min11"}, intervals = {0, 3, 7, 10, 14, 17}},
 -- {name = "Minor 13", alt_names = {"Min13"}, intervals = {0, 3, 7, 10, 14, 17, 21}},
end
function cirdian_rythm()
  if z > 0.5 then
    engine.hz(min_chord_seq())
  --[[engine.hz(chord[1])
    engine.hz(chord[2])
    engine.hz(chord[3])]]
    print('minor')
  elseif z < 0.5 then
    engine.hz(maj_chord_seq())
    --[[engine.hz(chord[1])
    engine.hz(chord[2])
    engine.hz(chord[3])]]
    print('major')
  end
  
end

--------------------------------------------------------------------------------
function redraw()  -- here we draw the pixel created by pixel.lua and display it through a callback to the controller that tracks it.
  if mn ~= nil then 
    screen.clear()
    screen.line_width(1)
    screen.level(10)
    screen.aa(1)
    screen.move(125,10)
    screen.text_right(snazzypage..'/3')
    screen.move(125,20)
    screen.text_right("temp "..ta)
    screen.stroke()
    if snazzypage == 1 then
      malictime = malictime + 1
      screen.move(50,24)
      scrn_loc_y = util.linlin(0, 1, 1, 64, mn)
      scrn_loc_y = math.floor(scrn_loc_y)
      screen.pixel(malictime, scrn_loc_y)
      screen.stroke()
      if malictime == 127 then
        screen.clear()
        malictime = 1
      end
    elseif snazzypage == 2 then
          circadiantime  = circadiantime  + 1
      screen.move(50,24)
      scrn_loc_y = util.linlin(0, 1, 1, 64, z)
      scrn_loc_y = math.floor(scrn_loc_y) 
      screen.pixel(circadiantime, scrn_loc_y)
      screen.stroke()
      if circadiantime == 127 then
        screen.clear()
        circadiantime = 1
      end  
    elseif snazzypage == 3 then
      screen.move(50,24)
      scrn_loc_x = util.linlin(0, 1, 1, 127, z)
      scrn_loc_x = math.floor(scrn_loc_x)
      scrn_loc_y = util.linlin(0, 1, 1, 64, mn)
      scrn_loc_y = math.floor(scrn_loc_y) 
      controller:create_pixel(scrn_loc_x, scrn_loc_y)
      controller:display_pixels()
      screen.stroke()
      --screen.update()
    end
    screen.update()
  end
end
--------------------------------------------------------------------------------
