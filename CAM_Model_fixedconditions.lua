-- agave
-- version@author
-- <lines link>
--
-- <tag line>
--
-- <instructions go here

-- lines starting with "--" are comments, they don't get executed


--CAM = include('lib/CAM_model_fixed')
CAM = include('lib/CAM_model_chaos')
pixel = include('lib/pixel')
control = include('lib/control')

BP = 10 -- BP = brightness of pixel variable for changing if needed
i = 1
state_table = {
  x={}, 
  y={}
  --z={},
}

-- engine.name = 'PolyPerc'

-- system clock tick
-- this function is started by init() and runs forever
-- if the sequence is on, it steps forward on each clock tick
-- tempo is controlled via the global clock, which can be set in the PARAMETERS menu 
tick = function()
  while true do
   -- clock.sync(1)
   clock.sleep(1/10)
   table.insert(state_table.x, m)
   table.insert(state_table.y, z)
   --table.insert(state_table.z, lorenz.state[3])
   --tab.print(lorenz.state)
   --do something with each tick of the clock
  end
end

--------------------------------------------------------------------------------
-- init runs first!
function init()
  -- configure stuff

  clock.run(tick)       -- start the sequencer

  clock.run(function()  -- redraw the screen and grid at 15fps
    --while true do
    while i > 0 do    -- for iteration to be non permanent and work with chaos equation
      clock.sleep(1/15)
      breath_of_the_plant()
      redraw()
      --M_SCALE =  m/MMAX
      --mn = m/MMAX
      --print('m'..i, m)
      --phi = 250*math.sin(0.00043633*i*dt)+250
      i = i + 1
    end
  end)

  norns.enc.sens(1,8)   -- set the knob sensitivity
  norns.enc.sens(2,4)
end

--------------------------------------------------------------------------------
-- encoder
function enc(n, delta)
  if n==1 then
    -- E1 do something

  elseif n==2 then
    -- E2 do something
    print("encoder: ", n,delta)

  elseif n==3 then
    -- E3 do something

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
function redraw()  -- here we draw the pixel created by pixel.lua and display it through a callback to the controller that tracks it.
  screen.clear()
  screen.line_width(1)
  screen.level(10)
  screen.aa(1)
  screen.move(50,24)
  scrn_loc_x = util.linlin(0, 1, 1, 127, mn)
  scrn_loc_x = math.floor(scrn_loc_x)
  scrn_loc_y = util.linlin(0, 1, 1, 64, z)
  scrn_loc_y = math.floor(scrn_loc_y) 
  controller:create_pixel(scrn_loc_x, scrn_loc_y)
  controller:display_pixels()
  screen.stroke()
  screen.update()
  --end
end
--------------------------------------------------------------------------------
