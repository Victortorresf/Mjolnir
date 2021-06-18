require "vector2"
require 'collision'


--------------------- Players Parameters
local player = {
    position = vector2.new(1439, 800),
    velocity = vector2.new(0, 0),
    size = vector2.new(110, 120),
    maxvelocity = 950,
    mass = 1.2,
    onGround = true,
    frictioncoefficient = 550,
    health = 50,
    damage = 5,
    Ydamage = 2,
    specialdmg = 15,
    movedirection = vector2.new(0,0),
    invulnerableCD = 0,
    max_invulnerableCD = 1,
    attackcoolddown = 1.5,
    anime = {},
    anim_frame = 1,
    anim_time = 0,
    anim_type = 1
}
  
  
local dir = 1
local gravity = vector2.new(0,800)
local som_attack1
local fundo1 = love.graphics.newImage("Visual Assets/Background1920x1080.png")


function GetPlayerPositionX()
  player.position = vector2.new(1449,800)
  player.heath = 100
end

function GetPlayer()
  return player
end

function LoadPlayer()
  som_attackspecial = love.audio.newSource("Sound Fx/ataque_special.ogg", "static")
  som_basicattacks = love.audio.newSource("Sound Fx/atk_basico.ogg", "static")
  love.graphics.setDefaultFilter('nearest', 'nearest')
  thor_atlas = love.graphics.newImage("Visual Assets/thor spr.png")

  player.anime[1] =  LoadTiles(0, 0, 5, 0, 16, 16)-- idle
  player.anime[2] =  LoadTiles(0, 1, 6, 1, 16, 16)-- walk
  player.anime[3] =  LoadTiles(0, 2, 3, 2, 21, 17)-- soco
  player.anime[4] =  LoadTiles(0, 2, 3, 2, 22, 25)-- especial
end

function LoadTiles(offsetx, offsety, nx, ny, w, h)
  local count = 1
  local animation = {}
  for i = 0, nx, 1 do
    for j = offsety, ny, 1 do
      animation [count] = love.graphics.newQuad(i * w , j * h, w, h,
                                               thor_atlas:getWidth(), thor_atlas:getHeight())
      count = count + 1
    end
  end
  return animation
end

function UpdatePlayer(dt, world, enemies)
  if player.invulnerableCD > 0 then
    player.invulnerableCD = player.invulnerableCD - dt
  end
  if player.attackcoolddown > 0 then
    player.attackcoolddown = player.attackcoolddown - dt
  end
  
  local acceleration = vector2.new(0, 0) -- Player Movement
  acceleration = vector2.applyForce(gravity, player.mass, acceleration)
  
  if vector2.magnitude(player.velocity) > 4 then -- 0 PARKINSON
    local friction = vector2.mult(player.velocity, -1)
    friction = vector2.normalize(friction)
    friction = vector2.mult(friction, player.frictioncoefficient)
    acceleration = vector2.applyForce(friction, player.mass, acceleration)
  else
    player.velocity = vector2.new(0,0)  
  end
  ------------------------------------- Movimento do jogador e animacao
  player.anim_time = player.anim_time + dt -- aumenta o tempo em dt
  if player.anim_time > 0.2 then
    player.anim_frame = player.anim_frame + 1 -- vai pro proximo frame
    if player.anim_frame >= 4 then
      player.anim_frame = 1
    end
    player.anim_time = 0 -- recomeca o timer
  end
  
  if love.keyboard.isDown("d") then -- Direita
    dir = 1
    player.anim_type = 2
    player.anim_time = player.anim_time + dt
    if player.anim_time > 0.2 then
      player.anim_frame = player.anim_frame + 1
      if player.anim_frame >= 6 then
        player.anim_frame = 1
      end
      player.anim_time = 0
    end
    local move = vector2.new(900,0)
    acceleration = vector2.applyForce(move, player.mass, acceleration)

  end 
  if love.keyboard.isDown("a") then -- Esquerda
    dir = -1
    player.anim_type = 2
    player.anim_time = player.anim_time + dt -- increases the time with dt
    if player.anim_time > 0.2 then
      player.anim_frame = player.anim_frame + 1 -- go to the next frame
      if player.anim_frame >= 6 then
        player.anim_frame = 1
      end
      player.anim_time = 0 -- reset the time counter
    end
    local move = vector2.new(-900,0)
    acceleration = vector2.applyForce(move, player.mass, acceleration)
  end

  if love.keyboard.isDown("space") and player.onGround then -- Pulo
    player.velocity.y = -950
    player.onGround = false
  end

  ----------------------------------------------------------
  player.movedirection = vector2.normalize(player.velocity)

  if love.keyboard.isDown("s") and player.onGround == false then --Cair mais rapido
    player.anim_type = 4
    player.anim_frame = 1
    gravity = vector2.new(0,5000000)
  else
    gravity = vector2.new(0,800)
  end

  
  for i = 1, #enemies, 1 do
    local collisiondirection = GetBoxCollisionDirection(player.position.x - 200, player.position.y, player.size.x + 320, player.size.y,
                                                           enemies[i].position.x, enemies[i].position.y, enemies[i].size.x, enemies[i].size.y)
    local collisiondir = vector2.normalize(collisiondirection)
    if not (collisiondir.x == 0 and collisiondir.y == 0) then
      if enemies[i].health <= 0 then
        table.remove(enemies, i)
        break
      end
      if love.keyboard.isDown("o") and player.attackcoolddown <= 0 or (love.keyboard.isDown("o") and love.keyboard.isDown("d")) and player.attackcoolddown <= 0 then
        player.anim_type = 3
        player.anim_frame = 2
      --[[  player.anim_time = player.anim_time + dt -- increases the time with dt
        if player.anim_time > 0.2 then
          player.anim_frame = player.anim_frame + 1 -- go to the next frame
          if player.anim_frame >= 3 then]]
          --end
         -- player.anim_time = 0 -- reset the time counter
        --end
        enemies[i].health = enemies[i].health - player.damage
        player.attackcoolddown = 0.5
        love.audio.play(som_basicattacks)
      end
      if love.keyboard.isDown("s") and player.attackcoolddown <= 0 and player.onGround == false then
        player.attackcoolddown = 0.5
        love.audio.play(som_attackspecial)
        enemies[i].health = enemies[i].health - player.specialdmg
      end
    end
  end
  

  if love.keyboard.isDown("1") then -- Volta para a fase inicial
    player.position = vector2.new(100,500)
  end

  if love.keyboard.isDown("2") then -- Level de testes
    player.position = vector2.new(1800,500)
  end

  if love.keyboard.isDown("3") then -- Level de testes
    player.position = vector2.new(3600,500)
  end

  if love.keyboard.isDown("5") then -- Level de testes
    player.position = vector2.new(12000,500)
  end
  
  if love.keyboard.isDown("4") then -- Level de testes
    player.position = vector2.new(10000,500)
  end
  
  if love.keyboard.isDown("h") then -- 100 health
    player.health = 50
  end

  if (not love.keyboard.isDown("d")) and (not love.keyboard.isDown("a")) and (not love.keyboard.isDown("s")) and (not love.keyboard.isDown("o"))then
    player.anim_type = 1
  end
  
  local futurevelocity = vector2.add(player.velocity, vector2.mult(acceleration, dt))
  futurevelocity = vector2.limit(futurevelocity, player.maxvelocity)
  local futureposition = vector2.add(player.position, vector2.mult(futurevelocity, dt))
  
  acceleration = CheckCollision(world, GetPlayer(), futureposition,  player.movedirection, acceleration)
  acceleration = CheckEnemyCollision(enemies, GetPlayer(), futureposition, player.movedirection, acceleration)

  player.velocity = vector2.add(player.velocity, vector2.mult(acceleration, dt))
  player.velocity = vector2.limit(player.velocity, player.maxvelocity)
  player.position = vector2.add(player.position, vector2.mult(player.velocity, dt))
end



function DrawPlayer() -- Desenhar tudo do Player.lua 
  love.graphics.draw(fundo1)
  if player.health > 0 then
    love.graphics.draw(thor_atlas, player.anime[player.anim_type][player.anim_frame], 485, player.position.y-7, 0, 8 * dir, 8, 8)
  end
end

function DrawHealthBar()
  love.graphics.setColor(1,0,0) -- Barra de vida
  love.graphics.rectangle("fill", 10, 50, player.health * 4, 30)
  love.graphics.setColor(1,1,1) -- Caixa da barra de vida
  love.graphics.rectangle("line", 10, 50, 200, 30)
end

