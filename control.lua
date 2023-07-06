--[[control
version 1.0 @duturley, 
<lines link> - will attach later

<tag line> chaos, lorenz,
 ]]
controller = {    -- creates global variable controller for the use in all 
    x = x,
    y = y,
    name = name,
    pixel_id = 0,
    pixels = {}
}


function controller:create_pixel(x, y)      -- a function that creates pixels inside the controller which fades them out over 10 seconds
  
  local pxl = pixel:new(x, y)
  self.pixel_id = self.pixel_id + 1         -- creates the pixel with a unique identifier that increases
  self.pixels['pxl'..self.pixel_id] = pxl   -- by 1 second each new pixel generated. 
  clock.run(controller.fade_pxl, 'pxl'..self.pixel_id)
end
  
function controller:display_pixels()        -- displays pixels with function (display_pixels()) using generic variables k, v in pairs.
  
  for k, v in pairs (self.pixels) do        -- k and v could be any variables but need to be called by whatever used in following code. 
    if v then v:display() end 
  end
end                                         

function controller.fade_pxl(pxl_name)
  
  clock.sleep(1)
  local fade_level = controller.pixels[pxl_name]:fade()
  if fade_level > 1 then 
    clock.run(controller.fade_pxl, pxl_name)
  else
    controller.remove_pxl(pxl_name) 
  end
end

function controller.remove_pxl(pxl_name)   -- callback to the function that brings back the pixel
  
  controller.pixels[pxl_name] = nil        --remove that was placed in the the first
end
  
return controller
