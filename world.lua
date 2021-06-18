require "vector2"


function CreateObject(x, y, w, h)
  return {position = vector2.new(x,y), size = vector2.new(w,h)}
end

local ground = love.graphics.newImage("Visual Assets/TaleChao.png")


function DrawWorld(world)
  for i = 1, #world, 1 do
    for x = 1, world[i].size.x/ground:getWidth(), 1 do
      love.graphics.draw(ground, world[i].position.x + (x * ground:getWidth()), world[i].position.y)
    end
  end
end