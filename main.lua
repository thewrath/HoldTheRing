module = "main"

--tout les commentaire commencent par liv seront relatif à ce module 
require "livsh"

io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end

local WIDTH = 640
local HEIGHT = 480

local spriteManager =require("spriteManager")
local donjonManager = require("donjonManager")
local hero = nil
local donjon = nil 

function love.load()
  --settings de la fenetre 
  love.window.setTitle("Hold the ring") 
  love.window.setMode(WIDTH,HEIGHT)
  font = love.graphics.newFont("assets/kenpixel_mini.ttf", 13)
  --on utilise la font prealablement chargée 
  love.graphics.setFont(font)
  --creation du hero 
  hero = spriteManager.newSprite(288,208,"assets/heros.png")
  --creation du donjon 
  donjon = donjonManager.newDonjon()
  donjon.loadMiniMapFromSpriteMiniMap(hero.miniMap)
  
  --liv load des du lightworld
  -- create light world
	lightWorld = love.light.newWorld()
	--lightWorld:setTranslation(0, 32)
	lightWorld:setAmbientColor(60, 60, 60)
	lightWorld:setRefractionStrength(32.0)
	lightWorld.isPixelShadows = true
  
  --creation d'une lumiere qui sui le joueur
	light = lightWorld:newLight(0, 0, 255, 255, 255, 250)
	light:setGlowStrength(0.1)
	light:setSun(false)
  --liv
end

function love.update()
  --liv
  --update de la lumiere ( au position de la souris )
  light:setPosition(hero.x, hero.y, 50)
  --liv
  
  --deplacement du hero au clavier
  if hero.inLive == true then
    if love.keyboard.isDown("up") then
      hero.move(0,-10)
      hero.movePositionInList(1)
    elseif love.keyboard.isDown("down") then
      hero.move(0,10)
      hero.movePositionInList(3)
    elseif love.keyboard.isDown("left") then
      hero.move(-10,0)
      hero.movePositionInList(4)
    elseif love.keyboard.isDown("right") then
      hero.move(10,0)
      hero.movePositionInList(2)
    end  
  end
  donjon.setCurrentLevel(hero.position)  
  hero.ring = donjon.checkCollisionPlayerAndRing(hero)
  donjon.update(hero)
end

function love.draw()
  --on dessine le level ( la map ) et le hero
  donjon.draw()
  
  --liv
  --update du lightworld
	lightWorld:update()
  --liv
  
  hero.draw()
  --les fps 
  love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  --liv
  -- dessine tout le shader ombres etc  
	lightWorld:drawShadow()
	lightWorld:drawShine()
	lightWorld:drawPixelShadow()
	lightWorld:drawGlow()
	lightWorld:drawRefraction()
	lightWorld:drawReflection()
	love.postshader.draw()
  --liv
end
