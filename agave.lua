-- agave
-- version@author
-- <lines link>
--
-- <tag line>
--
-- <instructions go here

-- lines starting with "--" are comments, they don't get executed

--var1 = util.linlin(-20, 20, 1, 127, 13.13)
--var1 = math.ceil(var1)

lorenz = include('lib/lorenz')
pixel = include('lib/pixel')
control = include('lib/control')

BP = 10 -- BP = brightness of pixel variable for changing if needed

state_table = {
  x={}, 
  y={},
  z={},
}
--state_table[1]={}
--state_table.x={}

-- engine.name = 'PolyPerc'

-- system clock tick
-- this function is started by init() and runs forever
-- if the sequence is on, it steps forward on each clock tick
-- tempo is controlled via the global clock, which can be set in the PARAMETERS menu 
tick = function()
  while true do
   -- clock.sync(1)
   clock.sleep(1/10)
   table.insert(state_table.x, lorenz.state[1])
   table.insert(state_table.y, lorenz.state[2])
   table.insert(state_table.z, lorenz.state[3])
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
    while true do
      clock.sleep(1/15)
      redraw()
    end
  end)
  lorenz:init() 
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
function redraw()
 screen.clear()
 screen.line_width(1)
 screen.level(10)
 screen.aa(1)
 screen.move(50,24)
 scrn_loc_x = util.linlin(-20, 20, 1, 127, lorenz.state[1])
 scrn_loc_x = math.floor(scrn_loc_x)
 scrn_loc_y = util.linlin(-25, 26, 1, 64, lorenz.state[2])
 scrn_loc_y = math.floor(scrn_loc_y) 
 controller:create_pixel(scrn_loc_x, scrn_loc_y)
 controller:display_pixels()
  screen.stroke()
  screen.update()
end
--------------------------------------------------------------------------------
