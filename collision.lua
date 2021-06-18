require "vector2"

local som_ReceberDano = love.audio.newSource("Sound Fx/RecebeDano.ogg", "static")

function GetBoxCollisionDirection(x1, y1, w1, h1, x2, y2, w2, h2)  -- detecção de colisão
  local xdistance = math.abs ((x1 + (w1 / 2)) - (x2 + (w2 / 2)))
  local ydistance = math.abs ((y1 +(h1 / 2)) - (y2 + (h2 / 2)))
  local combinedwidth = (w1 /2) + (w2 / 2)
  local combinedheight = (h1 / 2) + (h2 / 2)
  
  if xdistance > combinedwidth then
     return vector2.new(0,0)
  end
  if ydistance > combinedheight then
     return vector2.new(0,0)
  end

  local overlapx = math.abs(xdistance - combinedwidth)
  local overlapy = math.abs(ydistance - combinedheight)
  local direction = vector2.normalize(vector2.sub(vector2.new(x1,y1), vector2.new(x2,y2))) -- to find the direction between the objects
  local collisiondirection
  
  if overlapx > overlapy then
    collisiondirection = vector2.new(0, direction.y * overlapy)
  elseif overlapx < overlapy then
    collisiondirection = vector2.new(direction.x * overlapx,0)
  else 
    collisiondirection = vector2.new(direction.x * overlapx, direction.y * overlapy)
  end
  return collisiondirection
end

function CheckCollision(world, player, futureposition, movedirection, acceleration) -- Colisão com mundo
  for i = 1, #world, 1 do
    local collisiondirection = GetBoxCollisionDirection(futureposition.x, futureposition.y, 
                                                        player.size.x, player.size.y,
                                                        world[i].position.x, world[i].position.y,
                                                        world[i].size.x, world[i].size.y)
    local collisiondir = vector2.normalize(collisiondirection)
    if (collisiondir.x ~= 0 or collisiondir.y ~= 0) then
      if collisiondir.y ~= 0 and movedirection.y ~= collisiondir.y then
        player.velocity.y = 0
        acceleration.y = 0
        if collisiondir.y == -1 then
          player.onGround = true
        end
      end
      if collisiondir.x ~= 0 and movedirection.x ~= collisiondir.x then
        player.velocity.x = 0
        acceleration.x = 0
      end
      if math.ceil(collisiondirection.x) ~= 0 then
        player.position.x = player.position.x + collisiondirection.x
      end
      if math.ceil(collisiondirection.y) ~= 0 then
        player.position.y = player.position.y + collisiondirection.y
      end
    end
  end
  return acceleration
end

function CheckEnemyCollision(enemies, player, futureposition, movedirection, acceleration) -- dano no inimigo
  for i = 1, #enemies, 1 do
    if enemies[i].health > 0 then
      local collisiondirection = GetBoxCollisionDirection(futureposition.x, futureposition.y,
                                                          player.size.x, player.size.y,
                                                          enemies[i].position.x, enemies[i].position.y,
                                                          enemies[i].size.x, enemies[i].size.y)
      local collisiondir = vector2.normalize(collisiondirection)
      if not (collisiondir.x == 0 and collisiondir.y == 0) then
        if collisiondir.y ~= 0 and movedirection.y ~= collisiondir.y then --[[JumpAttackcoolddown <=0]]
          player.velocity.y = 0
          acceleration.y = 0
          player.velocity.x = player.velocity.x - 500 --Empurrao em X no player
          --enemies[i].health = enemies[i].health - player.Ydamage
        end
        if collisiondir.x ~= 0 and movedirection.x ~= collisiondir.x then
          player.velocity.x = player.velocity.x - 300 --Empurrao em X no player
          player.velocity.y = player.velocity.y - 250 --Empurrao em Y no player
          acceleration.x = 0
        end
        if math.ceil(collisiondirection.x) ~= 0 then
          player.position.x = player.position.x + collisiondirection.x
        end
        if math.ceil(collisiondirection.y) ~= 0 then
          player.position.y = player.position.y + collisiondirection.y
        end
        if player.invulnerableCD <= 0 then
          player.anim_type = 1
          player.anim_frame = 5
          player.health = player.health - enemies[i].damage ----- perde vida na colisao
          love.audio.play(som_ReceberDano)
          player.invulnerableCD = player.max_invulnerableCD 
        end
      end
    end
  end
  return acceleration
end