require "vector2"
require "projectiles"
require "player"

local level = {}

local PATROL, ATTACK = 1, 2


function CreateEnemy(x, y, w, h, t, hp, dmg, epath)
 -- 1 = Corredor
 -- 2 = Voador
 -- 3 = Loki
  return {
    position = vector2.new(x, y),
    velocity = vector2.new(x or 0, y or 0),
    size = vector2.new(w,h),
    direction = vector2.new(1,1),
    mass = 1,
    maxvelocity = 120,
    movedirection = vector2.new(0,0),
    movechangetime = 1 ,
    movetimer = 0,
    path = epath,
    pathindex = 1,
    state = PATROL,
    maxviewdistance = 250,
    shoottimer = 1,
    shootrate = 1.4,
    projectiles = {},
    damage = dmg,
    health = hp,
    type = t
    }
end

local attackcoolddown = 0.5

local villain = {
  anime = {}
}
local anim_frame = 1
local anim_time =0
local rotation = 0

function LoadEnemies()
  enemy_atlas = love.graphics.newImage("Visual Assets/enemy spr1.png")
  
  villain.anime[1] = LoadEnemyTiles(0, 0, 4, 0, 16, 23)--soldier
  villain.anime[2] = LoadEnemyTiles(0, 1, 3, 1, 23, 25)--fly
  villain.anime[3] = LoadEnemyTiles(0, 2, 4, 2, 22, 26)
end

function LoadEnemyTiles(offsetx, offsety, nx, ny, w, h)
  local count = 1
  local animation = {}
  for i = 0, nx, 1 do
    for j = offsety, ny, 1 do
      animation [count] = love.graphics.newQuad(i * w , j * h, w, h,
                                               enemy_atlas:getWidth(), enemy_atlas:getHeight())
      count = count + 1
    end
  end
  return animation
end

function UpdateEnemies(dt, enemies, player, world)

  anim_time = anim_time + dt -- increases the time with dt
  if anim_time > 0.2 then
    anim_frame = anim_frame + 1 -- go to the next frame
    if anim_frame >= 4 then
      anim_frame = 1
    end
    anim_time = 0 -- reset the time counter
  end
  
  if attackcoolddown > 0 then
    attackcoolddown = attackcoolddown - dt
  end
  for i = 1, #enemies do
    if enemies[i].health > 0 then
      local acceleration = vector2.new(0, 0)
      local playerdirection = vector2.sub(player.position, enemies[i].position)
      
      local projectiledirection = vector2.sub(player.position, enemies[i].position)
      projectiledirection = vector2.normalize(projectiledirection)
      rotation = math.atan2(projectiledirection.y, projectiledirection.x)
      
      if enemies[i].state == PATROL then
        local movedirection = vector2.sub(enemies[i].path[enemies[i].pathindex].position, enemies[i].position)
        local waypointdistance = vector2.magnitude(movedirection)
        movedirection = vector2.normalize(movedirection)
        if waypointdistance > 1 then -- Movimento Inimigo
          local moveForce = vector2.mult(movedirection, 100)
          acceleration = vector2.applyForce(moveForce, enemies[i].mass, acceleration)
          enemies[i].velocity = vector2.add(enemies[i].velocity, vector2.mult(acceleration, dt))
          enemies[i].velocity = vector2.limit(enemies[i].velocity, enemies[i].maxvelocity)
          enemies[i].position = vector2.add(enemies[i].position, vector2.mult(enemies[i].velocity, dt))
        else
          enemies[i].velocity = vector2.new(0, 0)
          enemies[i].pathindex = enemies[i].pathindex + 1
          if enemies[i].pathindex > #enemies[i].path then
            enemies[i].pathindex = 1
          end
        end
        
        if Cansee(player, enemies[i].position, enemies[i].direction) and enemies[i].type == 2 then  -- Start Shooting
            enemies[i].state = ATTACK
        end
        if player.position.x >= 12000 and enemies[i].type == 3 then
          enemies[i].state = ATTACK
        end
        elseif enemies[i].state == ATTACK then
        enemies[i].shoottimer = enemies[i].shoottimer + dt
          if enemies[i].shoottimer > enemies[i].shootrate then
            if enemies[i].type == 2 then 
              playerdirection = vector2.new(0,1)
            else 
              playerdirection = vector2.normalize(playerdirection)
            end
            if enemies[i].type == 2 then
              table.insert(enemies[i].projectiles,CreateProjectile(enemies[i].position.x+(enemies[i].size.x - 100), enemies[i].position.y + (enemies[i].size.y - 18), 15, playerdirection))
              enemies[i].shoottimer = 0
            end
            if enemies[i].type == 3 then
              table.insert(enemies[i].projectiles,CreateProjectile(enemies[i].position.x+(enemies[i].size.x - 100), enemies[i].position.y + 60, 8, playerdirection))
              enemies[i].shoottimer = 0
            end
          end
          if Cansee(player, enemies[i].position, enemies[i].direction) == false then
            enemies[i].state = PATROL
          end  
        end   
    end
    UpdateProjectiles(dt, enemies[i].projectiles, world, player)
  end
end

function Cansee(player, enemyposition, enemydirection)
  local playerdir = vector2.normalize(vector2.sub(player.position, enemyposition))
  local angle = math.acos(vector2.dot(enemydirection, playerdir))
  if (math.deg(angle) < 10) then
    return true
  end
  return false
end



function DrawEnemy(enemies, projectiles, dir, type)
  love.graphics.setColor(1, 1, 1)
    for i = 1, #enemies do
      if enemies[i].health > 0 then
        if enemies[i].velocity.x > 0 then
          --[[love.graphics.setColor(0.2,0.2,0.9) -- Player
          love.graphics.rectangle("fill", enemies[i].position.x, enemies[i].position.y, enemies[i].size.x, enemies[i].size.y)]]
          love.graphics.draw(enemy_atlas, villain.anime[enemies[i].type][anim_frame], enemies[i].position.x-10, enemies[i].position.y, 0, 6, 6)
          love.graphics.setColor(1, 1, 1) -- caixa da barra de vida
          love.graphics.rectangle("line", -enemies[i].position.x, enemies[i].position.y - 15, enemies[i].size.x, 5)
          love.graphics.setColor(1, 0, 0) -- vida dos inimigos
          love.graphics.rectangle("fill", enemies[i].position.x, enemies[i].position.y - 15, enemies[i].health * 2, 5)
         elseif enemies[i].velocity.x < 0 then
          love.graphics.draw(enemy_atlas, villain.anime[enemies[i].type][anim_frame], enemies[i].position.x + 134, enemies[i].position.y, 0, -6, 6)
          love.graphics.setColor(1, 1, 1) -- caixa da barra de vida
          love.graphics.rectangle("line", -enemies[i].position.x, enemies[i].position.y - 15, enemies[i].size.x, 5)
          love.graphics.setColor(1, 0, 0) -- vida dos inimigos
          love.graphics.rectangle("fill", enemies[i].position.x+30, enemies[i].position.y - 15, enemies[i].health * 2, 5)
        end
      end
      DrawProjectiles(enemies[i].projectiles, rotation, enemies[i].type)
    end
end
--[[function DrawEnemy(enemies)
  for i = 1, #enemies do
    if enemies[i].health > 0 then
      love.graphics.setColor(1, 1, 1) -- caixa da barra de vida
      love.graphics.draw(enemy_atlas, villain.anime[enemies[i].type][anim_frame], enemies[i].position.x, enemies[i].position.y, 0,  6, 6)
      love.graphics.rectangle("line", enemies[i].position.x, enemies[i].position.y - 15, enemies[i].size.x, 5)

      love.graphics.setColor(1, 0, 0) -- vida dos inimigos
      love.graphics.rectangle("fill", enemies[i].position.x, enemies[i].position.y - 15, enemies[i].health * 2, 5)
     -- love.graphics.rectangle("fill", enemies[i].position.x, enemies[i].position.y, enemies[i].size.x, enemies[i].size.y)
    end
    DrawProjectiles(enemies[i].projectiles, rotation, enemies[i].type)
  end
end   ]]
