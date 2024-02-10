--[[pixel
version 1.0 @duturley, 
<lines link> - will attach later

<tag line> chaos, lorenz,
 ]]
local Pixel = {}

function Pixel:new(x, y, name) --creates a function using colon allows it to reference itself as self later, rather than a period 
   local p = {                 --which creates a non-self referential variable
    x = x,
    y = y,
    name = name,
    level = BP
  }
   setmetatable(p,self)  --creates new table of itself and references to itself as Pixel
  self.__index = self
  
  function p:display()
    screen.level(self.level)
    screen.move(self.x, self.y)
    screen.pixel(self.x, self.y)
    screen.stroke()
    screen.update()
  end

function p:fade()
  self.level = self.level - 1 
  return self.level 
end

  return p

end

------------------------------------------------------------------------------
return Pixel
