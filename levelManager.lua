module = "levelManager"

--on importe les modules necessaire 
ennemiesManager = require("ennemiesManager")
--generer la graine aleatoire 
math.randomseed(os.time())

local levelManager = {}

--genere un level
function levelManager.newLevel(pId)
  --le level
  local level = {}
  level.map = {}
  level.id = pId
  --variable pour verifier si le level a l'anneaux ou pas 
  level.ring = {}
  level.ring.bool = false
  level.ring.x = nil
  level.ring.y = nil 
  
  --les ennemies du level
  level.ennemies = {}
  
  --le level est compose d une map generique ( tout les levels sont fait avec le même patterne )
  level.map = levelManager.loadMap()
  --d autres choses 
  level.tileset = {}
  level.tileset.image = love.graphics.newImage("assets/tileset.png")
  level.tileset.quads = {
    love.graphics.newQuad(306,239,32,32,level.tileset.image:getDimensions()),
    love.graphics.newQuad(0,0,32,32,level.tileset.image:getDimensions()),
    love.graphics.newQuad(0,65,32,32,level.tileset.image:getDimensions()),
    love.graphics.newQuad(0,96,32,32,level.tileset.image:getDimensions()),
    love.graphics.newQuad(748,375,32,32,level.tileset.image:getDimensions()),
    love.graphics.newQuad(474,509,32,32,level.tileset.image:getDimensions()),
    love.graphics.newQuad(512,443,32,32,level.tileset.image:getDimensions())
  }
  
  --fonction update du level  
  function level.update(pPlayer,currentLevel)
    for i=1, #level.ennemies do
      --l'ennemie va vers le joueur 
      if level.id == currentLevel then
        level.ennemies[i].update(pPlayer)
      else
        level.ennemies[i].resetPosition()
      end
    end
  end
  --fonction qui dessine la map
  function level.drawMap()
    for y=0, #level.map do
      for x=0, #level.map[y] do
          if level.map[y][x] == nil then
            love.graphics.draw(level.tileset.image, level.tileset.quads[1], 32*x, 32*y)
        else
          love.graphics.draw(level.tileset.image, level.tileset.quads[1], 32*x, 32*y)
          love.graphics.draw(level.tileset.image, level.tileset.quads[level.map[y][x]], 32*x, 32*y) 
        end
      end
    end
    --print(level.id, level.ring.bool)
    --on dessine l'anneau
    if level.ring.bool == true then
      love.graphics.draw(level.tileset.image, level.tileset.quads[5], level.ring.x,level.ring.y)
    end
    for i=1, #level.ennemies do
      level.ennemies[i].draw()
    end
  end
  
  --fonction pour generer les monstres du level
  function level.loadEnnemies()
    if level.id ~= 1 then
      local numberOfEnnemie = math.random(1,5)
      for i=1, numberOfEnnemie do
        level.ennemies[i] =  ennemiesManager.newEnnemie(math.random(40,600),math.random(40,400),"assets/heroTileSet.png",1)
      end
    end
  end
  
  --fonction pour créer un level avec l'anneaux
  function level.setTheRingLevel(rang)
    if rang ~= 1 then
      if math.random(0,1) == 1 then
        print("anneau positionné")
        print(level.id)
        level.ring.bool = true
        level.ring.x = math.random(50,600)
        level.ring.y = math.random(40,400)
      end
    end
  end
  
  --fonction qui modifie le decors en fonction du nombre d'ennemie dans le level( si 5 un coffre )
  function level.setEnvironnement()
    --on ajoute un coffre sur la map 
    if #level.ennemies == 5 then
      --ajout d'un break pour couper la boucle !
      while 1 do
        local y = math.random(1,#level.map)
        local x = math.random(1,#level.map[y])
        --on test voir si on est sur de la terre 
        if level.map[y][x] == 1 then
          --on ajoute un coffre 
          level.map[y][x] = 6
          --on casse la boucle 
          break
        end
      end
    -- si on a un seul ennemie on ajoute un consommable
    elseif #level.ennemies == 1 then
      while 1 do 
        --on prend des valeur random dans la liste mais on les centres 
        local y = math.random(5,#level.map-4)
        local x = math.random(5,#level.map[y]-4)
        --on test voir si on est sur de la terre 
        if level.map[y][x] == 1 then
          --on ajoute un consommable
          level.map[y][x] = 7
          --on casse la boucle 
          break
        end
      end 
    end  
  end

  --on charge les ennemies 
  level.loadEnnemies()
  return level
end

--fonction pour generer un niveau 
function levelManager.loadMap()
  local map = {}
  --le level est compose d une map generique ( tout les levels sont fait avec le même patairne )
  map[0]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[1]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[2]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[3]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[4]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[5]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[6]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[7]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[8]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[9]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[10] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[11] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[12] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[13] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  map[14] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

  --le random 
  for i=0, math.random(1,10) do
    local typeOfTile = math.random(0,10)
    local y = math.random(0,#map)
    if typeOfTile == 0 then
      map[y][math.random(1,20)] = 2
    elseif typeOfTile == 1 then
      map[y][math.random(1,20)] = 3
    elseif typeOfTile == 2 then
      map[y][math.random(1,20)] = 4
    else
      map[y][math.random(1,20)] = 1
    end
  end
  return map
end

return levelManager


