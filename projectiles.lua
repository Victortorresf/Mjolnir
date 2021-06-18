require "collision"
require("vector2")

function CreateProjectile(x, y, r, dir)
  return {
          position = vector2.new(x, y),
          velocity = vector2.mult(dir, 600),
          radius = r,
          mass = 100,
          maxspeed = 480,
          damage = 5
        }
end

local som_ReceberDano = love.audio.newSource("Sound Fx/RecebeDano.ogg", "static")
local faca = love.graphics.newImage("Visual Assets/Faca.png")
local faca2 = love.graphics.newImage("Visual Assets/FacaReta.png")

function UpdateProjectiles(dt, projectiles, world, player)
  for i = #projectiles,1, -1 do
    for ii = 1, #world, 1 do
      if projectiles[i] then
        local collisiondirection = GetBoxCollisionDirection(projectiles[i].position.x, projectiles[i].position.y,
                                                            projectiles[i].radius * 2, projectiles[i].radius * 2,
                                                            world[ii].position.x, world[ii].position.y,
                                                            world[ii].size.x, world[ii].size.y)
        if collisiondirection.x ~= 0 or collisiondirection.y ~= 0 then
          table.remove(projectiles, i)
          break
        end
      end
    end
    if projectiles[i] then
      local collisiondir = GetBoxCollisionDirection(projectiles[i].position.x, projectiles[i].position.y,
                                                    projectiles[i].radius * 2, projectiles[i].radius * 2,
                                                    player.position.x, player.position.y,
                                                    player.size.x, player.size.y)
      if collisiondir.x ~= 0 or collisiondir.y ~= 0 then
        player.health = player.health - projectiles[i].damage
        player.anim_type = 1
        player.anim_frame = 5
        love.audio.play(som_ReceberDano)
        table.remove(projectiles, i)
        break
      end
    end
    if projectiles[i] then
      projectiles[i].position = vector2.add(projectiles[i].position, vector2.mult(projectiles[i].velocity, dt))
    end
  end
end

function DrawProjectiles(projectiles, dir, type) -- Voador
  love.graphics.setColor(1, 1, 1)
  for i = 1, #projectiles, 1 do
    if type == 3 then  
      love.graphics.draw(faca, projectiles[i].position.x, projectiles[i].position.y, dir, 4, 4, 19, 9)
    end
    if type == 2 then  
      love.graphics.draw(faca2, projectiles[i].position.x, projectiles[i].position.y, 0, 3,3)
    end
  end
end