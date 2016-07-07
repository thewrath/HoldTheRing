module = "donjonManager"

--generer la graine aleatoire 
math.randomseed(os.time())

--le level manager
levelManager = require("levelManager")

local donjonManager = {}

--methode pour créer un donjon
function donjonManager.newDonjon()
  --creation du donjon
  local donjon = {}
  donjon.currentLevel = nil
  donjon.drawTitle = true
  --variable pour voir si le donjon a deja un level avec un anneau 
  donjon.ring = {}
  donjon.ring.bool = false
  donjon.ring.x = nil
  donjon.ring.y = nil 
  donjon.ring.tablePos = {}
  
  donjon.ring.level = nil
  donjon.levels = {}
  donjon.miniMap = {}
  
  --variable qui contient l'ennemie a tuer 
  donjon.ennemieToKill = nil
  --variable pour contenir le logo du jeu qui sera affiche dans le premier niveau 
  donjon.gameLogo = love.graphics.newImage("assets/logo.png")

  --on remplis le donjon avec des level ( des salles )
  for i=1, 14 do
    --création de level
    donjon.levels[i] = levelManager.newLevel(i)
  end
  
  --on parcour nos level a l'envers pour placer l'anneau
  for i=1, #donjon.levels-1 do
    if donjon.ring.bool == false then
      donjon.levels[#donjon.levels-i].setTheRingLevel(i)
      donjon.ring.bool = donjon.levels[#donjon.levels-i].ring.bool
      donjon.ring.x = donjon.levels[#donjon.levels-i].ring.x
      donjon.ring.y = donjon.levels[#donjon.levels-i].ring.y
      donjon.ring.level = #donjon.levels-i
    end
    donjon.levels[#donjon.levels-i].setEnvironnement()
  end
  
  function donjon.loadMiniMapFromSpriteMiniMap(pSpriteMiniMap)
    donjon.miniMap = pSpriteMiniMap
    donjon.setCurrentLevel(pSpriteMiniMap)
  end

  --change le currentLevel lorsque le 1 se deplace dans la miniMap du sprite
  function donjon.setCurrentLevel(pSpriteMiniMap)
    for y=0, #pSpriteMiniMap do
      for x=1, #pSpriteMiniMap[y] do
        if pSpriteMiniMap[y][x] == 1 then
          donjon.currentLevel = donjon.miniMap[y][x]
          if donjon.currentLevel ~= 1 then
            donjon.drawTitle = false
          end
        end
      end
    end
  end
  
  --fonction update du donjon
  function donjon.update(pPlayer)
    for i=1, #donjon.levels do
      donjon.levels[i].update(pPlayer,donjon.currentLevel)
    end
    if donjon.checkCollisionEnnemiePlayer(pPlayer) == true then
      print("hero touché",pPlayer.x,pPlayer.y)
      --on detrui l'ennemie et on fait perdre au joueur son anneau 
      if pPlayer.ring == true then
        pPlayer.hit()
        donjon.ring.level = pPlayer.currentLevel
        donjon.levels[donjon.ring.level].ring.bool = true
        donjon.levels[donjon.ring.level].ring.x = pPlayer.x-10
        donjon.levels[donjon.ring.level].ring.y = pPlayer.y-10
        
      end
    end
  end
  
  --fonction draw du donjon
  function donjon.draw()
    donjon.levels[donjon.currentLevel].drawMap()
    --si on est au niveau 1 ( niveau de depart on dessine le titre du jeu sur le fond )
    if donjon.currentLevel == 1 and donjon.drawTitle == true then
      love.graphics.draw(donjon.gameLogo,50,50)
    end
  end
  
  --fonction qui verifie les collision entre le joueur et l'anneau
  function donjon.checkCollisionPlayerAndRing(pPlayer)
    --verifier les collision entre le joueur et l'anneau
    if donjon.currentLevel == donjon.ring.level then
      if pPlayer.ring == false or pPlayer.ring == nil then
        if pPlayer.x + pPlayer.size.x + pPlayer.size.x >= donjon.ring.x and pPlayer.x  <= donjon.ring.x + 32 and pPlayer.y + pPlayer.size.y >= donjon.ring.y and pPlayer.y <= donjon.ring.y + 32 then
          donjon.levels[donjon.ring.level].ring.bool = false
          return true
        end
      else
        --ici on retourne true car le hero a deja l'anneau 
        return true
      end
    elseif pPlayer.ring == true then
      return true
    end
  end
  
  --fonction qui verifie la collision entre le joueur et les ennemies 
  function donjon.checkCollisionEnnemiePlayer(pPlayer)
    for i=1, #donjon.levels[donjon.currentLevel].ennemies do 
      if pPlayer.x + pPlayer.size.x + pPlayer.size.x >= donjon.levels[donjon.currentLevel].ennemies[i].x and pPlayer.x  <= donjon.levels[donjon.currentLevel].ennemies[i].x + 32 and pPlayer.y + pPlayer.size.y >= donjon.levels[donjon.currentLevel].ennemies[i].y and pPlayer.y <= donjon.levels[donjon.currentLevel].ennemies[i].y + 32 then
          donjon.ennemieToKill = i
          return true
      else 
        return false
      end
    end
  end

  return donjon
end

return donjonManager