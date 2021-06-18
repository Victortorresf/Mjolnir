require "vector2"
require "world"
require "enemy"
require "waypoint"
require "projectiles"
require "player"

gamestate = "menu"

local level1 = {}
local badguys = {}
local CScreen = require "cscreen"

function Start()
  --------------------------------------------------------------------------------------------------------TELA
  
  love.window.setFullscreen(true, "desktop")
  CScreen.init(1920, 1080, true)
  
  --------------------------------------------------------------------------------------------------------
  
  LoadPlayer()
  LoadEnemies()
  
  --------------------------------------------------------------------------------------------------------MUSICA
  
  fundo = love.audio.newSource("Sound Fx/MusicaFundo.ogg","stream")
  
  
  --------------------------------------------------------------------------------------------------------IMAGENS
  
  MainMenu = love.graphics.newImage("Visual Assets/MainMenu.png")
  MenuHistoria = love.graphics.newImage("Visual Assets/Historia.png")
  FundoMenu = love.graphics.newImage("Visual Assets/MENU.png")
  MenuPausa = love.graphics.newImage("Visual Assets/MenuPausa.png")
  Creditos = love.graphics.newImage("Visual Assets/Creditos.png")
  Morto = love.graphics.newImage("Visual Assets/Morto.png")
  Instructions = love.graphics.newImage("Visual Assets/instrucoes.png")
  --------------------------------------------------------------------------------------------------------MUNDO
  
  level1[1] = CreateObject(1000, 1000, 16000, 80) -- chao até inicio level 9 (1 ate 2= +-2000 pixels)
  level1[2] = CreateObject(-160, 0, 80, 1900) -- Parede esquerda
  
  level1[3] = CreateObject(4400, 600, 500, 80) -- plataforma 1.1
  
  level1[4] = CreateObject(5900, 600, 500, 80) -- plataforma 2.1
  level1[5] = CreateObject(6500, 200, 500, 80) -- plataforma 2.2
  
  level1[6] = CreateObject(7550, 700, 250, 80) -- plataforma 3.1
  level1[7] = CreateObject(8050, 450, 250, 80) -- plataforma 3.2
  level1[8] = CreateObject(8500, 150, 400, 80) -- plataforma 3.3
  
  level1[9] = CreateObject(9250, 600, 250, 80) -- plataforma 4.1
  level1[10] = CreateObject(9750, 250, 250, 80) -- plataforma 4.2
  level1[11] = CreateObject(10150, 600, 250, 80) -- plataforma 4.3
  
  level1[12] = CreateObject(11200, 300, 250, 80) -- plataforma 5.1
  level1[13] = CreateObject(11800, 600, 250, 80) -- plataforma 5.2
  
  level1[14] = CreateObject(13400, 600, 500, 80) -- plataforma 6.1
  
  --------------------------------------------------------------------------------------------------------PATH 
  local path1 = {}
    path1[1] = CreateWaypoint(1900, 870)
    path1[2] = CreateWaypoint(3000, 870)
    ---------------------------------------
  local path2 = {}
    path2[1] = CreateWaypoint(4800, 200)
    path2[2] = CreateWaypoint(3800, 200)
    ---------------------------------------
  local path3 = {}
    path3[1] = CreateWaypoint(6300, 870)
    path3[2] = CreateWaypoint(5700, 870)
  local path4 = {}
    path4[1] = CreateWaypoint(6650, 50)
    path4[2] = CreateWaypoint(5500, 50)
    ---------------------------------------
  local path5 = {}
    path5[1] = CreateWaypoint(8700, 870)
    path5[2] = CreateWaypoint(7300, 870)
  local path6 = {}
    path6[1] = CreateWaypoint(8500, 20)
    path6[2] = CreateWaypoint(8830, 20)
  local path7 = {}
    path7[1] = CreateWaypoint(7300, 50)
    path7[2] = CreateWaypoint(8200, 50)
    ---------------------------------------
  local path8 = {}
    path8[1] = CreateWaypoint(9150, 50)
    path8[2] = CreateWaypoint(9950, 50)
  local path9 = {}
    path9[1] = CreateWaypoint(9150, 870)
    path9[2] = CreateWaypoint(10050, 870)
  local path10 = {}
    path10[1] = CreateWaypoint(9940, 120)
    path10[2] = CreateWaypoint(9750, 120)
    ---------------------------------------
  local path11 = {}
    path11[1] = CreateWaypoint(11000, 870)
    path11[2] = CreateWaypoint(12200, 870)
  local path12 = {}
    path12[1] = CreateWaypoint(12200, 80)
    path12[2] = CreateWaypoint(11000, 80)
    
--LOKI
  local path13 = {}
    path13[1] = CreateWaypoint(13000, 80)
    path13[2] = CreateWaypoint(13490, 470)
    path13[3] = CreateWaypoint(13600, 470)
    path13[4] = CreateWaypoint(14500, 80)
    path13[5] = CreateWaypoint(14500, 870)
    path13[6] = CreateWaypoint(13000, 870)
    path13[7] = CreateWaypoint(13000, 870)


  --Inimigos (3 tipos); (1=corredor, 2=voador, 3=LOKI)
  badguys[1] = CreateEnemy(1900, 870, 80, 130, 1, 45, 5, path1)
  badguys[2] = CreateEnemy(3800, 200, 135, 137, 2, 69, 5, path2)
  badguys[3] = CreateEnemy(6300, 870, 80, 130, 1, 45, 5, path3)
  badguys[4] = CreateEnemy(5500, 50, 135, 137, 2, 69, 5, path4)
  
  badguys[5] = CreateEnemy(8700, 870, 80, 130, 1, 45, 5, path5)
  badguys[6] = CreateEnemy(8500, 20, 80, 130, 1, 45, 5, path6) 
  badguys[7] = CreateEnemy(7300, 50, 135, 137, 2, 69, 5, path7)
  
  
  badguys[8] = CreateEnemy(10050, 50, 135, 137, 2, 69, 5, path8)
  badguys[9] = CreateEnemy(9150, 870, 80, 130, 1, 45, 5, path9)
  badguys[10] = CreateEnemy(9940, 120, 80, 130, 1, 45, 5, path10)
  
  badguys[11] = CreateEnemy(11000, 870, 80, 130, 1, 45, 5, path11)
  badguys[12] = CreateEnemy(12200, 80, 135, 137, 2, 69, 5, path12)
  
  badguys[13] = CreateEnemy(13000, 80, 120, 137, 3, 70, 10, path13)
end

function love.load()
  Start()
  local player = GetPlayer()
end

function love.update(dt)
  ----------------------------------------------------------- Menu, Historia, creditos, instruções e Quitar
  
  if gamestate == "menu" then
      if love.keyboard.isDown("return", "h") then
        gamestate = "history"
      elseif love.keyboard.isDown("return", "c") then
        gamestate = "creditos"
      elseif love.keyboard.isDown("escape") then
        love.event.quit()
      end
      if love.keyboard.isDown("return", "i") then
        gamestate = "arcade"
      end
  end
  ----------------------------------------------------------- instruções para jogo
  if gamestate == "arcade" then
   if love.keyboard.isDown("return", "kpenter") then
        gamestate = "play"
        Start()
        GetPlayerPositionX()
      end
  end
  ----------------------------------------------------------- Historia para Menu
  if gamestate == "history" then
    if love.keyboard.isDown("return", "backspace") then
      gamestate = "menu"
    end
  end
  ----------------------------------------------------------- Creditos para Menu
  if gamestate == "creditos" then
    if love.keyboard.isDown("return", "backspace") then
      gamestate = "menu"
    end
  end
  ----------------------------------------------------------- Jogo Rodando
  if gamestate == "play" then
    UpdatePlayer(dt, level1, badguys)
    UpdateEnemies(dt, badguys, GetPlayer(), level1)
  end
  ----------------------------------------------------------- Jogo para Pause
  if gamestate == "play" and love.keyboard.isDown("p") then
    gamestate = "pausemenu"
  end
  ----------------------------------------------------------- Pause para Jogo, historia e menu
  if gamestate == "pausemenu" then
    if love.keyboard.isDown("return", "kpenter") then
      gamestate = "play"
    end
    if love.keyboard.isDown("backspace") then
      love.event.quit("restart")
    end
  end
  ----------------------------------------------------------- Morto para Menu
  if gamestate == "Morto" then
    if love.keyboard.isDown("return", "backspace") then
      love.event.quit("restart")
    end
  end  
end


function love.draw()
  CScreen.apply()

  if gamestate =="menu" then
    love.graphics.draw(MainMenu) 
  elseif gamestate == "history" then
    love.graphics.draw(MenuHistoria)
  elseif gamestate == "pausemenu" then
    love.graphics.draw(MenuPausa)
  elseif gamestate == "Morto" then
    love.graphics.draw(Morto)
  elseif gamestate == "creditos" then
    love.graphics.draw(Creditos)
  elseif gamestate == "arcade" then
    love.graphics.draw(Instructions)
  elseif gamestate == "play" then
    love.audio.play(fundo)
    DrawPlayer()
    local player = GetPlayer()
    love.graphics.translate(-(player.position.x - 380), 0) -- Seguindo player
    DrawWorld(level1)
    
    if player.health <= 0 then
      gamestate = "Morto"
    end    
    
    DrawEnemy(badguys)
    love.graphics.translate((player.position.x - 380), 0)
    if player.position.x > 14900 then
      player.position.x = 14900
      player.velocity.x = 0
    end
    if player.position.x < 1430 then
      player.position.x = 1430
      player.velocity.x = 0
    end
  DrawHealthBar()
  end
  CScreen.cease()
end

function love.resize(width, height)
	CScreen.update(width, height)
end