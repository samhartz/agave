-- agave
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
CAM = include('lib/CAM_model_Chaos')
pixel = include('lib/pixel')
control = include('lib/control')
bifurcation = include('lib/bifurcation')

snazzypage = 1


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
-- create params
temps = {"285","289","293","297","301"}
params:add_option("temp_setting", "temp setting", temps, 5)
params:set_action("temp_setting", function(x) 
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
  print("new temp setting...re init", ta) 
  init()
end)

params:add_option("phi_type", "phi type", {"phi constant","phi day/night"})
params:set_action("phi_type",function(z)
  --print(z)
  if z==1 then
    phi = phi_max
  elseif z==2 then
    phi = phi_new(i, dt, phi_maxb)
  end
end)

--phi levels param for constant levels of light
params:add_option("phi_max_levels", "phi max levels", {"10","50","100","150","300","500"}, 1)
params:set_action("phi_max_levels",function(t)
  print(t)
  if t==1 then
    phi_max = 10
  elseif t==2 then
    phi_max = 50
  elseif t==3 then
    phi_max = 100
  elseif t==4 then
    phi_max = 150
  elseif t==5 then
    phi_max = 300
  elseif t==6 then
    phi_max = 500
  end
  phi = phi_max
end) 

-- init runs first!
function init()
  if refresh_clock then clock.cancel(refresh_clock) end
  BP = 10 -- BP = brightness of pixel variable for changing if needed
  --steps = 1
  i = 1   -- i is used to establish the beginning value of the loops
  malictime = 0
  circadiantime = 0

  max_extrema = 300
  snazzy4_loaded=false
  snzp4_ix = 1
  scr_loc_xy_values = {} --this is just for testing, should be removed later

  -- configure stuff
  local temp = temps[params:get("temp_setting")]
  print("init temp", temp)
  cam_init(temp)

  engine.algoName('square_mod1')
  engine.gain(5)
  engine.release(6)
  engine.attack(.01)
  engine.pw(7)
  local min_chord = mu.generate_chord(40, "minor")
  min_chord_seq = s{table.unpack(min_chord)}

  local maj_chord = mu.generate_chord(120, "major")
  maj_chord_seq = s{table.unpack(maj_chord)}

  refresh_clock = clock.run(function()  -- redraw the screen and grid at 15fps
    -- need to make it so this i loop runs for the length of time that steps function calculates
    while i > 0 do    -- for iteration to be non permanent and work with chaos equation
      -- clock.sleep(1/15)
      clock.sleep(1/15)


      tl = ta       -- assume leaf temp equal to atmospheric

      tempC = ta - 273. -- convert to K
      psat = A_SAT*math.exp((B_SAT*(tempC))/(C_SAT + tempC)) -- saturated vapor pressure in Pa
      qa = 0.622*rh/100.*psat/P_ATM --needs to be in kg/kg, specific humidity in atmosphere


      --get the value of phi type
      --conditional statement if phi_type is constant then phi_maxb = static value, else get phi_maxb value 
      --this is where I need to call phi new(i, dt, phi_maxb)
      --tl_new(t_av, A_t, i, dt)
      --phi_new(i, dt, phi_maxb)
      if snazzypage < 4 then
      end
      breath_of_the_plant()

   
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
  

  --params:add_option("A_t", "temp amplitude", {'0','2','4','6','8','10'}, 1)
  --params:set_action("A_t", function(y)
    --print(y)
    --if y==1 then
      --A_t = 0
    --elseif y==2
      --A_t = 2
    --elseif y==3
      --A_t = 4
    --elseif y==4
      --A_t = 6
    --elseif y==5  
      --A_t = 8
    --elseif y==6
      --A_t = 10
    --end
  --end
  
end



--------------------------------------------------------------------------------
-- encoder
function enc(n, delta)
  screen.clear()
  if n==1 then
    --Change the page
    snazzypage = util.clamp(snazzypage + delta,1,4)
    print("snazzypage",snazzypage)
  elseif n==2 then
    -- E2 do something
    local temp_setting = params:get("temp_setting")
    local new_setting = util.clamp(temp_setting+delta,1,5)
    params:set("temp_setting",new_setting)

  elseif n==3 then
    -- E3 do something
    local phi_max_levels = params:get("phi_max_levels")
    local new_setting = util.clamp(phi_max_levels+delta,1,6)
    params:set("phi_max_levels",new_setting)
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
    --print('minor')
  elseif z < 0.5 then
    engine.hz(maj_chord_seq())
    --[[engine.hz(chord[1])
    engine.hz(chord[2])
    engine.hz(chord[3])]]
    --print('major')
  end
  
end

function find_min_max(vals)
  local min = math.huge
  for i = 1, #vals do
    min = min < vals[i] and min or vals[i]

  end
  local max = -math.huge
  for i = 1, #vals do
    max = max > vals[i] and max or vals[i]
  end
  -- print("min",min)
  -- print("max",max) 
    
  return min, max
end
--------------------------------------------------------------------------------
function redraw()  -- here we draw the pixel created by pixel.lua and display it through a callback to the controller that tracks it.
  if mn ~= nil then 
    screen.clear()
    if snazzy4_loaded == false then
    end
    if snazzypage < 4 then
      snazzy4_loaded = false
    end

    screen.line_width(1)
    screen.level(10)
    screen.aa(1)
    screen.move(125,10)
    screen.text_right(snazzypage..'/4')
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
    elseif snazzypage == 4 then
      if snazzy4_loaded == false then
        init()
        snazzy4_loaded = true
      end
      if #z_a > max_extrema then
        r_values4, z_values4 = bifurcation_diagram()
        min4, max4 = find_min_max(z_values4)
        -- print("load snazzypage 4",#r_values4, #z_values4, min4, max4)
        draw_snazzypage4(r_values4,z_values4,min4,max4)
      else
        print("z_a < max_extrema",#z_a)
        -- screen.clear()
        screen.move(64,32)
        screen.text_center("z_a < max extrema...hold tight")
        screen.stroke()
      end
    end
    screen.update()
  end
end

function draw_snazzypage4(r_values, z_values, min, max)
  -- print(snzp4_ix,#r_values,#z_values,r_values[snzp4_ix],z_values[snzp4_ix])
  scrn_loc_x = util.linlin(280, 301, 1, 127, r_values[snzp4_ix])
  
  scrn_loc_y = util.linlin(min, max, 1, 64, z_values[snzp4_ix])
  
  scrn_loc_x = math.floor(scrn_loc_x)
  scrn_loc_y = math.floor(scrn_loc_y)
  screen.move(scrn_loc_x, scrn_loc_y)
  screen.pixel(scrn_loc_x, scrn_loc_y)
  --controller:create_pixel(scrn_loc_x, scrn_loc_y)
  --controller:display_pixels()
  screen.fill()
  screen.update()
  if snzp4_ix < #z_values then
    snzp4_ix = snzp4_ix + 1
  else 
    snzp4_ix = 1
    print("restart snzp4_ix")
  end
end
--------------------------------------------------------------------------------




--[[[
old snazypage==4 code
elseif snazzypage == 4 then
      if snazzy4_loaded == true then
        return
      end
      screen.move(50,24)
      -- find_local_extrema(array)
      local r_values, z_values = bifurcation_diagram()
      --print(z_values)
      -- for i = 1, #z_values do  
      local min, max = find_min_max(z_values)
      -- end
      -- print(z)
      for i=1, #z_values do
        scrn_loc_x = util.linlin(280, 301, 1, 127, r_values[i])
        
        
        --scrn_loc_y = util.linlin(min, max, 1, 64, z)
        scrn_loc_y = util.linlin(min, max, 1, 64, z_values[i])
        
        -- print("scrn_loc_x, scrn_loc_y", scrn_loc_x, scrn_loc_y)
        --scrn_loc_y = util.linlin(0, 0.2, 1, 64, z_coords[i])
        table.insert(scr_loc_xy_values,{scrn_loc_x,scrn_loc_y})
        scrn_loc_x = math.floor(scrn_loc_x)
        scrn_loc_y = math.floor(scrn_loc_y)
        --screen.move(scrn_loc_x, scrn_loc_y)
        screen.pixel(scrn_loc_x, scrn_loc_y)
        --controller:create_pixel(scrn_loc_x, scrn_loc_y)
        --controller:display_pixels()
        screen.stroke()
        -- screen.update()
      end  
      if snazzy4_loaded == false then
        snazzy4_loaded = true
        print("save scr_loc_xy_values",#scr_loc_xy_values)
        tab.save(scr_loc_xy_values,norns.state.data.."scr_loc_xy_values.tab")
      end  
    end

]]