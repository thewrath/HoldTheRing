--oriented object in lua !
module = "spriteManager"

math.randomseed(os.time())

local spriteManager = {}

--constructor of the class sprite 
function spriteManager.newSprite(pX, pY, pPathToTexture)
  
  local sprite = {}
  sprite.miniMap = {}
  sprite.position = {}
  sprite.isPosition = {}
  sprite.x = pX
  sprite.y = pY
  sprite.size = {}
  sprite.size.x = 32
  sprite.size.y = 32
  --le joueur est en vie
  sprite.inLive = true
  
  --le sprite ne possede pas l'anneaux au debut ( il faut qui le trouve ) 
  sprite.ring = false
  --le currentLevel
  sprite.currentLevel = nil

  --timer pour le score lorsque que le joueur possede l'anneau
  sprite.holdTheRingTimer = {}
  sprite.holdeTheRingTimer = love.timer.getTime()
  --de base on ne demarre pas le timer 
  sprite.holdTheRingTimer.start = false
  
  --timer du sprite
  sprite.startTimer = love.timer.getTime()
  sprite.endTimer = nil
  
  -- gandalf = 1 aragorn = 2 gimli = 3 
  sprite.apparence = math.random(1,3)

  if sprite.apparence == 1 then
    sprite.textToSay = "Vous, ne passerez, pas !"
  elseif sprite.apparence == 2 then
    sprite.textToSay = "Que dites-vous ?!"
  elseif sprite.apparence == 3 then 
    sprite.textToSay = "Nous les nains, nous sommes des sprinters, \n redoutables sur de courtes distances !"
  end
  
  --le tileset du sprite
  sprite.tileset = {}
  sprite.tileset.image = love.graphics.newImage(pPathToTexture)
  sprite.tileset.quads = {
    love.graphics.newQuad(0,0,34,32,sprite.tileset.image:getDimensions()),
    love.graphics.newQuad(34,0,32,32,sprite.tileset.image:getDimensions()),
    love.graphics.newQuad(66,0,42,32,sprite.tileset.image:getDimensions()),
    love.graphics.newQuad(160,0,34,32,sprite.tileset.image:getDimensions()),
    love.graphics.newQuad(194,0,32,32,sprite.tileset.image:getDimensions()),
    love.graphics.newQuad(226,0,42,32,sprite.tileset.image:getDimensions()),  
    love.graphics.newQuad(108,0,20,32,sprite.tileset.image:getDimensions())
  }
  
  --another method like getter and setter 
  function sprite.move(pX, pY)
    sprite.x = sprite.x + pX
    sprite.y = sprite.y + pY
  end

  --charge la miniMap
  function sprite.loadMiniMap()
    --charge la miniMap 
    sprite.miniMap[0] = {0,0,0,0,0,0,0}
    sprite.miniMap[1] = {0,13,4,2,3,9,0}
    sprite.miniMap[2] = {0,12,2,1,7,8,0}
    sprite.miniMap[3] = {0,14,6,5,10,11,0}
    sprite.miniMap[4] = {0,0,0,0,0,0,0}

    --la position du sprite dans la miniMap
    sprite.position[0] = {0,0,0,0,0,0,0}
    sprite.position[1] = {0,0,0,0,0,0,0}
    sprite.position[2] = {0,0,0,1,0,0,0}
    sprite.position[3] = {0,0,0,0,0,0,0}
    sprite.position[4] = {0,0,0,0,0,0,0}
  end

  function sprite.draw()
    sprite.endTimer = love.timer.getTime()
    if sprite.endTimer - sprite.startTimer < 8 then
      love.graphics.setColor(255,255,255)
      love.graphics.print(sprite.textToSay, sprite.x+50,sprite.y)
    end
    --on dessine la petite map en bas à gauche 
    for y=1, #sprite.miniMap do
      for x=1, #sprite.miniMap[y] do
        --un rectangle blanc pour une salle normale et un vert pour la salle actuel 
        if sprite.miniMap[y][x] ~= 0 then
          if sprite.position[y][x] == 1 then
            --on dessine un rectangle vert
            love.graphics.setColor(0,255,0)
            love.graphics.rectangle("fill",(16*x),400+(10*y),16,10)
            love.graphics.setColor(255,255,255)
          else
            --on dessine un rectangle blanc 
            love.graphics.setColor(255,255,255)
            love.graphics.rectangle("line",(16*x),400+(10*y),16,10)
          end
        end
      end
    end
    
    --on verifie si le sprite a l'anneaux 
    sprite.checkTheRing()
    --si il a l'anneaux on allume le  timer
    if sprite.holdTheRingTimer.start == true then
      sprite.holdTheRingTimer.timer = love.timer.getTime()
      love.graphics.print("Time : " ..tostring(sprite.holdTheRingTimer.timer),450,10)
    else
      love.graphics.print("Time : ",450,10)
    end
    --on dessine le sprite
    love.graphics.draw(sprite.tileset.image,sprite.tileset.quads[sprite.apparence],sprite.x,sprite.y)
  end

  --fonction qui verifie si on peut acceder a un level 
  function sprite.checkIfLevelInTheNextBorder(pPositionToCheck)
    for y=0, #sprite.position do
      for x=1, #sprite.position[y] do
        if sprite.position[y][x] == 1 then
          --on verifie en haut 
          if pPositionToCheck == 1 then
            if sprite.miniMap[y-1][x] ~= 0 then
              return true
            else 
              return false
            end
          --on verifie a droite
          elseif pPositionToCheck == 2 then
            if sprite.miniMap[y][x+1] ~= 0 then
              return true
            else 
              return false
            end
          --on verifie en bas
          elseif pPositionToCheck == 3 then
            if sprite.miniMap[y+1][x] ~= 0 then
              return true
            else 
              return false
            end
          --on verifie a gauche
          elseif pPositionToCheck == 4 then
            if sprite.miniMap[y][x-1] ~= 0 then
              return true
            else 
              return false
            end
          end
        end
      end
    end
  end

  --fonction pour bouger le sprite dans sa liste position 
  function sprite.movePositionInList(pPositionToMove)
    sprite.whereIsLocatedMySprite()
    if pPositionToMove == 1 and sprite.y < 0 then
      if sprite.checkIfLevelInTheNextBorder(pPositionToMove) == true then
        sprite.position[sprite.isPosition.y-1][sprite.isPosition.x] = 1
        sprite.position[sprite.isPosition.y][sprite.isPosition.x] = 0
        sprite.y = 480
      else
        sprite.y = sprite.y +50
      end
    elseif pPositionToMove == 2 and sprite.x > 640 then
      if sprite.checkIfLevelInTheNextBorder(pPositionToMove) == true then
        sprite.position[sprite.isPosition.y][sprite.isPosition.x+1] = 1
        sprite.position[sprite.isPosition.y][sprite.isPosition.x] = 0
        sprite.x = 0
      else
        sprite.x = sprite.x -50
      end
    elseif pPositionToMove == 3 and sprite.y > 480 then
      if sprite.checkIfLevelInTheNextBorder(pPositionToMove) == true then
        sprite.position[sprite.isPosition.y+1][sprite.isPosition.x] = 1
        sprite.position[sprite.isPosition.y][sprite.isPosition.x] = 0
        sprite.y = 0
      else
        sprite.y = sprite.y -50
      end
    elseif pPositionToMove == 4 and sprite.x < 0 then
      if sprite.checkIfLevelInTheNextBorder(pPositionToMove) == true then
        sprite.position[sprite.isPosition.y][sprite.isPosition.x-1] = 1
        sprite.position[sprite.isPosition.y][sprite.isPosition.x] = 0
        sprite.x = 640
      else
        sprite.x = sprite.x +50
      end
    end
  end

  --fonction pour savoir ou est le sprite dans sa liste position 
  function sprite.whereIsLocatedMySprite()
    for y=0, #sprite.position do
      for x=1, #sprite.position[y] do
        if(sprite.position[y][x] == 1) then
          sprite.isPosition.y = y
          sprite.isPosition.x = x
          sprite.currentLevel = sprite.miniMap[y][x]
          break
        end
      end
    end
  end
  
  --la fonction qui verifie si le sprite a l'anneau 
  function sprite.checkTheRing()
    if sprite.inLive == true then 
      if sprite.ring == true then
        if sprite.apparence < 4 then
          --on change l'apparence du personnage +3
          sprite.apparence = sprite.apparence + 3
          --on demarre le timer pour le score du joueur 
          sprite.holdTheRingTimer.start = true 
        end
      else
        if sprite.apparence >3 then
           --on change l'apparence du personnage -3
          sprite.apparence = sprite.apparence - 3
          --on demarre le timer pour le score du joueur 
          sprite.holdTheRingTimer.start = false 
        end
      end
    end
  end

  --fonction qui appelée lorsque que un ennemie touche le hero 
  function sprite.hit()
    if sprite.ring == true then
      sprite.ring = false
    else 
      sprite.inLive = false
      print("ok")
      sprite.apparence = 7
    end
  end
  
  --on appelle certaines méthode lors de l'initialisation 
  sprite.loadMiniMap()
  sprite.whereIsLocatedMySprite()
  return sprite
end

return spriteManager
